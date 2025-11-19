import type { Express, Request, Response, NextFunction } from "express";
import { createServer, type Server } from "http";
import passport from "passport";
import { Strategy as LocalStrategy } from "passport-local";
import bcrypt from "bcryptjs";
import multer from "multer";
import path from "path";
import fs from "fs";
import mime from "mime-types";
import crypto from "crypto";
import ExcelJS from "exceljs";
import { storage } from "./storage";
import { db } from "./db";
import { eq, and, or, isNull, inArray, sql as sqlExpr } from "drizzle-orm";
import * as schema from "@shared/schema";
import { 
  insertUserSchema, 
  insertClusterSchema,
  insertUnitSchema,
  insertCriteriaSchema,
  insertEvaluationPeriodSchema,
  insertEvaluationSchema,
  insertScoreSchema,
  type User 
} from "@shared/schema";
import { z } from "zod";
import { CriteriaScoreService } from "./criteriaScoreService";

/**
 * Thin helper that delegates to transactional storage method.
 * All recalculation logic is in storage layer for proper transaction handling.
 */
async function recalculateEvaluationScores(evaluationId: string): Promise<{ scoresUpdated: number }> {
  return await storage.recalculateEvaluationScoresTx(evaluationId);
}

declare global {
  namespace Express {
    interface User {
      id: string;
      username: string;
      fullName: string;
      role: string;
      clusterId: string | null;
      unitId: string | null;
    }
  }
}

passport.use(
  new LocalStrategy(async (username, password, done) => {
    try {
      const user = await storage.getUserByUsername(username);
      if (!user) {
        return done(null, false, { message: "Tên đăng nhập không tồn tại" });
      }

      const isValid = await bcrypt.compare(password, user.password);
      if (!isValid) {
        return done(null, false, { message: "Mật khẩu không đúng" });
      }

      return done(null, {
        id: user.id,
        username: user.username,
        fullName: user.fullName,
        role: user.role,
        clusterId: user.clusterId,
        unitId: user.unitId,
      });
    } catch (err) {
      return done(err);
    }
  })
);

passport.serializeUser((user, done) => {
  done(null, user.id);
});

passport.deserializeUser(async (id: string, done) => {
  try {
    const user = await storage.getUser(id);
    if (!user) {
      return done(null, false);
    }
    done(null, {
      id: user.id,
      username: user.username,
      fullName: user.fullName,
      role: user.role,
      clusterId: user.clusterId,
      unitId: user.unitId,
    });
  } catch (err) {
    done(err);
  }
});

function requireAuth(req: Request, res: Response, next: NextFunction) {
  if (!req.isAuthenticated()) {
    return res.status(401).json({ message: "Vui lòng đăng nhập" });
  }
  next();
}

function requireRole(...roles: string[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.isAuthenticated()) {
      return res.status(401).json({ message: "Vui lòng đăng nhập" });
    }
    if (!roles.includes(req.user!.role)) {
      return res.status(403).json({ message: "Bạn không có quyền truy cập" });
    }
    next();
  };
}

// Configure multer for file uploads
const uploadDir = path.join(process.cwd(), "uploads", "scores");
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const multerStorage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    const baseName = path.basename(file.originalname, ext);
    cb(null, `${baseName}-${uniqueSuffix}${ext}`);
  }
});

const upload = multer({
  storage: multerStorage,
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB
  },
  fileFilter: (req, file, cb) => {
    const allowedExtensions = /\.(pdf|doc|docx|xls|xlsx|jpg|jpeg|png|txt)$/i;
    const allowedMimeTypes = [
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'image/jpeg',
      'image/png',
      'text/plain'
    ];
    
    const hasValidExtension = allowedExtensions.test(file.originalname.toLowerCase());
    const hasValidMimeType = allowedMimeTypes.includes(file.mimetype);
    
    if (hasValidExtension && hasValidMimeType) {
      cb(null, true);
    } else {
      cb(new Error('Chỉ chấp nhận file PDF, DOC, DOCX, XLS, XLSX, JPG, PNG, TXT'));
    }
  }
});

export async function registerRoutes(app: Express): Promise<Server> {
  // Serve uploaded files with path traversal protection
  app.use('/uploads', requireAuth, (req, res, next) => {
    const uploadsDir = path.join(process.cwd(), 'uploads');
    
    // Decode URL-encoded path (handles spaces and special characters)
    const decodedPath = decodeURIComponent(req.path);
    
    // Remove leading slash from decoded path to prevent absolute path issues
    const relativePath = decodedPath.startsWith('/') ? decodedPath.slice(1) : decodedPath;
    const requestedPath = path.join(uploadsDir, relativePath);
    const normalizedPath = path.normalize(requestedPath);
    
    // Security: Ensure requested path is within uploads directory (with path separator check)
    if (!normalizedPath.startsWith(uploadsDir + path.sep) && normalizedPath !== uploadsDir) {
      return res.status(403).json({ message: "Truy cập bị từ chối" });
    }
    
    if (!fs.existsSync(normalizedPath)) {
      return res.status(404).json({ message: "File không tồn tại" });
    }
    
    // Set correct Content-Type for PDFs and other files
    const mimeType = mime.lookup(normalizedPath);
    if (mimeType) {
      res.type(mimeType);
    }
    res.setHeader('Content-Disposition', 'inline');
    res.sendFile(normalizedPath);
  });

  // Upload file endpoint
  app.post("/api/upload", requireAuth, upload.single('file'), async (req, res, next) => {
    try {
      console.log('[UPLOAD DEBUG]', {
        method: req.method,
        url: req.originalUrl,
        contentType: req.headers['content-type'],
        hasFile: !!req.file,
        fileName: req.file?.originalname,
        fileSize: req.file?.size,
        fileMime: req.file?.mimetype
      });
      
      if (!req.file) {
        console.log('[UPLOAD ERROR] No file in request');
        return res.status(400).json({ message: "Không có file được tải lên" });
      }
      
      // Check first bytes of uploaded file
      const filePath = path.join(uploadDir, req.file.filename);
      const firstBytes = fs.readFileSync(filePath, { encoding: 'utf8', flag: 'r' }).substring(0, 100);
      console.log('[FILE CONTENT CHECK]', { 
        filename: req.file.filename,
        firstBytes,
        isPDF: firstBytes.startsWith('%PDF')
      });
      
      console.log(`[FILE UPLOAD] File received: ${req.file.originalname}, Size: ${req.file.size} bytes, MIME: ${req.file.mimetype}`);
      
      const fileUrl = `/uploads/scores/${req.file.filename}`;
      res.json({ 
        message: "Upload thành công",
        filename: req.file.filename,
        fileUrl: fileUrl,
        originalName: req.file.originalname,
        size: req.file.size
      });
    } catch (error) {
      next(error);
    }
  });

  // Authentication routes
  // Admins can create any user; cluster_leaders can only create users in their cluster
  app.post("/api/auth/register", requireRole("admin", "cluster_leader"), async (req, res, next) => {
    try {
      const userData = insertUserSchema.parse(req.body);
      
      const existingUser = await storage.getUserByUsername(userData.username);
      if (existingUser) {
        return res.status(400).json({ message: "Tên đăng nhập đã tồn tại" });
      }

      // Cluster leader constraints
      if (req.user!.role === "cluster_leader") {
        // Cluster leaders can only create users with role "user"
        if (userData.role !== "user") {
          return res.status(403).json({ message: "Cụm trưởng chỉ có thể tạo người dùng đơn vị" });
        }
        
        // Force cluster to leader's cluster
        if (!req.user!.clusterId) {
          return res.status(400).json({ message: "Cụm trưởng chưa được gán vào cụm" });
        }
        
        // Verify unitId belongs to cluster leader's cluster
        if (!userData.unitId) {
          return res.status(400).json({ message: "Phải chọn đơn vị cho người dùng" });
        }
        
        const unit = await storage.getUnit(userData.unitId);
        if (!unit || unit.clusterId !== req.user!.clusterId) {
          return res.status(403).json({ message: "Đơn vị không thuộc cụm của bạn" });
        }
        
        // Force clusterId to leader's cluster (in case frontend sends wrong value)
        userData.clusterId = req.user!.clusterId;
      }

      // Admin validation (unchanged)
      if (req.user!.role === "admin") {
        if (userData.role === "admin") {
          if (userData.clusterId || userData.unitId) {
            return res.status(400).json({ message: "Quản trị viên không được gán vào cụm hoặc đơn vị" });
          }
        }
        
        if (userData.role === "cluster_leader") {
          if (!userData.clusterId) {
            return res.status(400).json({ message: "Cụm trưởng phải được gán vào một cụm" });
          }
        }
        
        if (userData.role === "user") {
          if (!userData.unitId) {
            return res.status(400).json({ message: "Người dùng đơn vị phải được gán vào một đơn vị" });
          }
        }
      }

      const hashedPassword = await bcrypt.hash(userData.password, 10);
      const user = await storage.createUser({
        ...userData,
        password: hashedPassword,
      });

      res.json({
        id: user.id,
        username: user.username,
        fullName: user.fullName,
        role: user.role,
        clusterId: user.clusterId,
        unitId: user.unitId,
      });
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Dữ liệu không hợp lệ", errors: error.errors });
      }
      next(error);
    }
  });

  app.post("/api/auth/login", (req, res, next) => {
    passport.authenticate("local", (err: any, user: Express.User | false, info: any) => {
      if (err) return next(err);
      if (!user) {
        return res.status(401).json({ message: info?.message || "Đăng nhập thất bại" });
      }
      req.login(user, (err) => {
        if (err) return next(err);
        res.json(user);
      });
    })(req, res, next);
  });

  app.post("/api/auth/logout", (req, res, next) => {
    req.logout((err) => {
      if (err) return next(err);
      res.json({ message: "Đăng xuất thành công" });
    });
  });

  app.get("/api/auth/me", requireAuth, (req, res) => {
    res.json(req.user);
  });

  // User management routes
  function sanitizeUser(user: any) {
    const { password, ...sanitized } = user;
    return sanitized;
  }

  app.get("/api/users", requireRole("admin", "cluster_leader"), async (req, res, next) => {
    try {
      let users = await storage.getUsers();
      const units = await storage.getUnits();
      
      // Filter users by cluster for cluster_leader
      if (req.user!.role === "cluster_leader" && req.user!.clusterId) {
        // Cluster leaders can only see users in their cluster
        users = users.filter(u => 
          u.clusterId === req.user!.clusterId || 
          (u.unitId && units.some(unit => unit.id === u.unitId && unit.clusterId === req.user!.clusterId))
        );
      }
      
      // Support explicit clusterId filter from query params
      const clusterIdFilter = req.query.clusterId as string | undefined;
      if (clusterIdFilter) {
        users = users.filter(u => 
          u.clusterId === clusterIdFilter ||
          (u.unitId && units.some(unit => unit.id === u.unitId && unit.clusterId === clusterIdFilter))
        );
      }
      
      const sanitized = users.map(sanitizeUser);
      res.json(sanitized);
    } catch (error) {
      next(error);
    }
  });

  app.put("/api/users/:id", requireRole("admin"), async (req, res, next) => {
    try {
      const updateUserSchema = insertUserSchema.partial().extend({
        password: z.string().min(8, "Mật khẩu phải có ít nhất 8 ký tự").optional(),
      });
      
      const userData = updateUserSchema.parse(req.body);
      
      // Check if user exists
      const existingUser = await storage.getUser(req.params.id);
      if (!existingUser) {
        return res.status(404).json({ message: "Không tìm thấy người dùng" });
      }

      // Prevent self-demotion from admin
      if (req.user!.id === req.params.id && userData.role && userData.role !== "admin") {
        return res.status(400).json({ message: "Không thể tự thay đổi quyền admin của mình" });
      }

      // Check username uniqueness if changing username
      if (userData.username && userData.username !== existingUser.username) {
        const existingUsername = await storage.getUserByUsername(userData.username);
        if (existingUsername) {
          return res.status(400).json({ message: "Tên đăng nhập đã tồn tại" });
        }
      }

      // Validate role-specific requirements
      const finalRole = userData.role || existingUser.role;
      const finalClusterId = userData.clusterId !== undefined ? userData.clusterId : existingUser.clusterId;
      const finalUnitId = userData.unitId !== undefined ? userData.unitId : existingUser.unitId;
      
      if (finalRole === "admin") {
        if (finalClusterId || finalUnitId) {
          return res.status(400).json({ message: "Quản trị viên không được gán vào cụm hoặc đơn vị" });
        }
      }
      
      if (finalRole === "cluster_leader") {
        if (!finalClusterId) {
          return res.status(400).json({ message: "Cụm trưởng phải được gán vào một cụm" });
        }
      }
      
      if (finalRole === "user") {
        if (!finalUnitId) {
          return res.status(400).json({ message: "Người dùng đơn vị phải được gán vào một đơn vị" });
        }
      }

      // Hash password if provided
      const updateData: any = { ...userData };
      if (userData.password) {
        updateData.password = await bcrypt.hash(userData.password, 10);
      }

      // Ensure at least one admin remains if demoting current admin
      if (existingUser.role === "admin" && userData.role && userData.role !== "admin") {
        const allUsers = await storage.getUsers();
        const adminCount = allUsers.filter(u => u.role === "admin").length;
        if (adminCount <= 1) {
          return res.status(400).json({ message: "Phải có ít nhất một quản trị viên trong hệ thống" });
        }
      }

      const updatedUser = await storage.updateUser(req.params.id, updateData);
      if (!updatedUser) {
        return res.status(404).json({ message: "Không tìm thấy người dùng" });
      }

      res.json(sanitizeUser(updatedUser));
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Dữ liệu không hợp lệ", errors: error.errors });
      }
      next(error);
    }
  });

  app.delete("/api/users/:id", requireRole("admin"), async (req, res, next) => {
    try {
      // Prevent self-deletion
      if (req.user!.id === req.params.id) {
        return res.status(400).json({ message: "Không thể xóa tài khoản của chính mình" });
      }

      const targetUser = await storage.getUser(req.params.id);
      if (!targetUser) {
        return res.status(404).json({ message: "Không tìm thấy người dùng" });
      }

      // Ensure at least one admin remains
      if (targetUser.role === "admin") {
        const allUsers = await storage.getUsers();
        const adminCount = allUsers.filter(u => u.role === "admin").length;
        if (adminCount <= 1) {
          return res.status(400).json({ message: "Không thể xóa quản trị viên cuối cùng" });
        }
      }

      await storage.deleteUser(req.params.id);
      res.status(204).send();
    } catch (error) {
      next(error);
    }
  });

  // Cluster routes (Admin only)
  app.get("/api/clusters", requireAuth, async (req, res, next) => {
    try {
      const clusters = await storage.getClusters();
      
      // Admin can see all clusters
      if (req.user!.role === "admin") {
        return res.json(clusters);
      }
      
      // Cluster leaders and unit users can only see their own cluster
      if (!req.user!.clusterId) {
        return res.json([]); // No cluster assigned
      }
      
      const userClusters = clusters.filter(c => c.id === req.user!.clusterId);
      res.json(userClusters);
    } catch (error) {
      next(error);
    }
  });

  // Get single cluster by ID with role-based authorization
  app.get("/api/clusters/:id", requireAuth, async (req, res, next) => {
    try {
      const cluster = await storage.getCluster(req.params.id);
      
      if (!cluster) {
        return res.status(404).json({ message: "Không tìm thấy cụm thi đua" });
      }
      
      // Admin can see any cluster
      if (req.user!.role === "admin") {
        return res.json(cluster);
      }
      
      // Non-admin can only see their own cluster
      if (req.user!.clusterId !== cluster.id) {
        return res.status(403).json({ message: "Bạn không có quyền truy cập cụm này" });
      }
      
      res.json(cluster);
    } catch (error) {
      next(error);
    }
  });

  app.post("/api/clusters", requireRole("admin"), async (req, res, next) => {
    try {
      const clusterData = insertClusterSchema.parse(req.body);
      
      // Validate cluster_type
      const validClusterTypes = ['phong', 'xa_phuong', 'khac'];
      if (!validClusterTypes.includes(clusterData.clusterType)) {
        return res.status(400).json({ 
          message: "Loại cụm không hợp lệ. Chỉ chấp nhận: phong, xa_phuong, khac" 
        });
      }
      
      const cluster = await storage.createCluster(clusterData);
      res.json(cluster);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Dữ liệu không hợp lệ", errors: error.errors });
      }
      if (error instanceof Error) {
        return res.status(400).json({ message: error.message });
      }
      next(error);
    }
  });

  app.put("/api/clusters/:id", requireRole("admin"), async (req, res, next) => {
    try {
      const clusterData = insertClusterSchema.partial().parse(req.body);
      
      // Validate cluster_type if provided
      if (clusterData.clusterType) {
        const validClusterTypes = ['phong', 'xa_phuong', 'khac'];
        if (!validClusterTypes.includes(clusterData.clusterType)) {
          return res.status(400).json({ 
            message: "Loại cụm không hợp lệ. Chỉ chấp nhận: phong, xa_phuong, khac" 
          });
        }
      }
      
      const cluster = await storage.updateCluster(req.params.id, clusterData);
      if (!cluster) {
        return res.status(404).json({ message: "Không tìm thấy cụm thi đua" });
      }
      res.json(cluster);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Dữ liệu không hợp lệ", errors: error.errors });
      }
      if (error instanceof Error) {
        return res.status(400).json({ message: error.message });
      }
      next(error);
    }
  });

  app.delete("/api/clusters/:id", requireRole("admin"), async (req, res, next) => {
    try {
      const existingCluster = await storage.getCluster(req.params.id);
      if (!existingCluster) {
        return res.status(404).json({ message: "Không tìm thấy cụm thi đua" });
      }
      
      await storage.deleteCluster(req.params.id);
      res.json({ message: "Xóa thành công" });
    } catch (error) {
      if (error instanceof Error) {
        return res.status(400).json({ message: error.message });
      }
      next(error);
    }
  });

  // Unit routes
  app.get("/api/units", requireAuth, async (req, res, next) => {
    try {
      const clusterId = req.query.clusterId as string | undefined;
      
      // Admin can see all units or filter by clusterId
      if (req.user!.role === "admin") {
        const units = await storage.getUnits(clusterId);
        return res.json(units);
      }
      
      // Cluster leaders and unit users can only see units in their cluster
      if (!req.user!.clusterId) {
        return res.json([]); // No cluster assigned
      }
      
      // If clusterId is provided, validate it matches user's cluster
      if (clusterId && clusterId !== req.user!.clusterId) {
        return res.status(403).json({ message: "Bạn chỉ có thể xem đơn vị trong cụm của mình" });
      }
      
      // Return units in user's cluster
      const units = await storage.getUnits(req.user!.clusterId);
      res.json(units);
    } catch (error) {
      next(error);
    }
  });

  app.post("/api/units", requireRole("admin", "cluster_leader"), async (req, res, next) => {
    try {
      const unitData = insertUnitSchema.parse(req.body);
      
      // Cluster leaders can only create units in their own cluster
      if (req.user!.role === "cluster_leader" && unitData.clusterId !== req.user!.clusterId) {
        return res.status(403).json({ message: "Bạn chỉ có thể tạo đơn vị trong cụm của mình" });
      }
      
      const unit = await storage.createUnit(unitData);
      res.json(unit);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Dữ liệu không hợp lệ", errors: error.errors });
      }
      if (error instanceof Error) {
        return res.status(400).json({ message: error.message });
      }
      next(error);
    }
  });

  app.put("/api/units/:id", requireRole("admin", "cluster_leader"), async (req, res, next) => {
    try {
      const unitData = insertUnitSchema.partial().parse(req.body);
      
      // Check if unit exists and belongs to user's cluster
      const existingUnit = await storage.getUnit(req.params.id);
      if (!existingUnit) {
        return res.status(404).json({ message: "Không tìm thấy đơn vị" });
      }
      
      if (req.user!.role === "cluster_leader") {
        if (existingUnit.clusterId !== req.user!.clusterId) {
          return res.status(403).json({ message: "Bạn chỉ có thể sửa đơn vị trong cụm của mình" });
        }
        
        // Cluster leaders cannot reassign units to different clusters
        if (unitData.clusterId && unitData.clusterId !== existingUnit.clusterId) {
          return res.status(403).json({ message: "Bạn không có quyền chuyển đơn vị sang cụm khác" });
        }
      }
      
      const unit = await storage.updateUnit(req.params.id, unitData);
      res.json(unit);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Dữ liệu không hợp lệ", errors: error.errors });
      }
      if (error instanceof Error) {
        return res.status(400).json({ message: error.message });
      }
      next(error);
    }
  });

  app.delete("/api/units/:id", requireRole("admin", "cluster_leader"), async (req, res, next) => {
    try {
      const existingUnit = await storage.getUnit(req.params.id);
      if (!existingUnit) {
        return res.status(404).json({ message: "Không tìm thấy đơn vị" });
      }
      
      if (req.user!.role === "cluster_leader" && existingUnit.clusterId !== req.user!.clusterId) {
        return res.status(403).json({ message: "Bạn chỉ có thể xóa đơn vị trong cụm của mình" });
      }
      
      await storage.deleteUnit(req.params.id);
      res.json({ message: "Xóa thành công" });
    } catch (error) {
      if (error instanceof Error) {
        return res.status(400).json({ message: error.message });
      }
      next(error);
    }
  });

  // OLD CRITERIA GROUPS & CRITERIA ROUTES - DISABLED - Now using /api/criteria/tree endpoints
  // These routes use the old flat criteria_groups table structure which has been replaced
  // with a tree-based criteria system. See server/criteriaTreeRoutes.ts for new endpoints.
  
  /*
  app.get("/api/criteria-groups", requireAuth, async (req, res, next) => {
    try {
      const { clusterId, year } = req.query;
      if (!clusterId || !year) {
        return res.status(400).json({ message: "Thiếu clusterId hoặc year" });
      }
      const yearNum = parseInt(year as string);
      if (isNaN(yearNum)) {
        return res.status(400).json({ message: "year phải là số hợp lệ" });
      }
      
      // Cluster leaders and unit users can only view groups in their own cluster
      if (req.user!.role !== "admin" && req.user!.clusterId !== clusterId) {
        return res.status(403).json({ message: "Bạn chỉ có thể xem nhóm tiêu chí của cụm mình" });
      }
      
      const groups = await storage.getCriteriaGroups(clusterId as string, yearNum);
      res.json(groups);
    } catch (error) {
      next(error);
    }
  });

  // OLD CRITERIA GROUPS & CRITERIA ROUTES - CONTINUED
  // These routes use the old flat criteria_groups table structure which has been replaced
  // with a tree-based criteria system. See server/criteriaTreeRoutes.ts for new endpoints.
  
  /*
  app.post("/api/criteria-groups", requireRole("admin", "cluster_leader"), async (req, res, next) => {
    try {
      const groupData = insertCriteriaGroupSchema.parse(req.body);
      
      // Cluster leaders can only create groups for their own cluster
      if (req.user!.role === "cluster_leader" && groupData.clusterId !== req.user!.clusterId) {
        return res.status(403).json({ message: "Bạn chỉ có thể tạo nhóm tiêu chí cho cụm của mình" });
      }
      
      const group = await storage.createCriteriaGroup(groupData);
      res.json(group);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Dữ liệu không hợp lệ", errors: error.errors });
      }
      next(error);
    }
  });

  app.put("/api/criteria-groups/:id", requireRole("admin", "cluster_leader"), async (req, res, next) => {
    try {
      const groupData = insertCriteriaGroupSchema.partial().parse(req.body);
      
      const existingGroup = await storage.getCriteriaGroup(req.params.id);
      if (!existingGroup) {
        return res.status(404).json({ message: "Không tìm thấy nhóm tiêu chí" });
      }
      
      if (req.user!.role === "cluster_leader") {
        if (existingGroup.clusterId !== req.user!.clusterId) {
          return res.status(403).json({ message: "Bạn chỉ có thể sửa nhóm tiêu chí của cụm mình" });
        }
        
        // Cluster leaders cannot reassign groups to different clusters
        if (groupData.clusterId && groupData.clusterId !== existingGroup.clusterId) {
          return res.status(403).json({ message: "Bạn không có quyền chuyển nhóm tiêu chí sang cụm khác" });
        }
      }
      
      const group = await storage.updateCriteriaGroup(req.params.id, groupData);
      res.json(group);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Dữ liệu không hợp lệ", errors: error.errors });
      }
      next(error);
    }
  });

  app.delete("/api/criteria-groups/:id", requireRole("admin", "cluster_leader"), async (req, res, next) => {
    try {
      const existingGroup = await storage.getCriteriaGroup(req.params.id);
      if (!existingGroup) {
        return res.status(404).json({ message: "Không tìm thấy nhóm tiêu chí" });
      }
      
      if (req.user!.role === "cluster_leader" && existingGroup.clusterId !== req.user!.clusterId) {
        return res.status(403).json({ message: "Bạn chỉ có thể xóa nhóm tiêu chí của cụm mình" });
      }
      
      await storage.deleteCriteriaGroup(req.params.id);
      res.json({ message: "Xóa thành công" });
    } catch (error) {
      next(error);
    }
  });

  // Criteria routes
  app.get("/api/criteria", requireAuth, async (req, res, next) => {
    try {
      const { groupId } = req.query;
      if (!groupId) {
        return res.status(400).json({ message: "Thiếu groupId" });
      }
      
      // Verify the group exists and check cluster ownership
      const group = await storage.getCriteriaGroup(groupId as string);
      if (!group) {
        return res.status(404).json({ message: "Không tìm thấy nhóm tiêu chí" });
      }
      
      // Cluster leaders and unit users can only view criteria in their own cluster
      if (req.user!.role !== "admin" && req.user!.clusterId !== group.clusterId) {
        return res.status(403).json({ message: "Bạn chỉ có thể xem tiêu chí của cụm mình" });
      }
      
      const criteria = await storage.getCriteria(groupId as string);
      res.json(criteria);
    } catch (error) {
      next(error);
    }
  });

  app.get("/api/criteria/:id", requireAuth, async (req, res, next) => {
    try {
      const criteria = await storage.getCriteriaById(req.params.id);
      if (!criteria) {
        return res.status(404).json({ message: "Không tìm thấy tiêu chí" });
      }
      
      // Verify cluster ownership via parent group
      const group = await storage.getCriteriaGroup(criteria.groupId);
      if (req.user!.role !== "admin" && group && req.user!.clusterId !== group.clusterId) {
        return res.status(403).json({ message: "Bạn chỉ có thể xem tiêu chí của cụm mình" });
      }
      
      res.json(criteria);
    } catch (error) {
      next(error);
    }
  });

  app.post("/api/criteria", requireRole("admin", "cluster_leader"), async (req, res, next) => {
    try {
      const criteriaData = insertCriteriaSchema.parse(req.body);
      
      // Verify the group belongs to the user's cluster
      const group = await storage.getCriteriaGroup(criteriaData.groupId);
      if (!group) {
        return res.status(404).json({ message: "Không tìm thấy nhóm tiêu chí" });
      }
      
      if (req.user!.role === "cluster_leader" && group.clusterId !== req.user!.clusterId) {
        return res.status(403).json({ message: "Bạn chỉ có thể tạo tiêu chí cho cụm của mình" });
      }
      
      const criteria = await storage.createCriteria(criteriaData);
      res.json(criteria);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Dữ liệu không hợp lệ", errors: error.errors });
      }
      next(error);
    }
  });

  app.put("/api/criteria/:id", requireRole("admin", "cluster_leader"), async (req, res, next) => {
    try {
      const criteriaData = insertCriteriaSchema.partial().parse(req.body);
      
      const existingCriteria = await storage.getCriteriaById(req.params.id);
      if (!existingCriteria) {
        return res.status(404).json({ message: "Không tìm thấy tiêu chí" });
      }
      
      const group = await storage.getCriteriaGroup(existingCriteria.groupId);
      if (req.user!.role === "cluster_leader") {
        if (group && group.clusterId !== req.user!.clusterId) {
          return res.status(403).json({ message: "Bạn chỉ có thể sửa tiêu chí của cụm mình" });
        }
        
        // If reassigning to a different group, verify the new group is in their cluster
        if (criteriaData.groupId && criteriaData.groupId !== existingCriteria.groupId) {
          const newGroup = await storage.getCriteriaGroup(criteriaData.groupId);
          if (!newGroup || newGroup.clusterId !== req.user!.clusterId) {
            return res.status(403).json({ message: "Bạn chỉ có thể chuyển tiêu chí đến nhóm trong cụm của mình" });
          }
        }
      }
      
      const criteria = await storage.updateCriteria(req.params.id, criteriaData);
      res.json(criteria);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Dữ liệu không hợp lệ", errors: error.errors });
      }
      next(error);
    }
  });

  app.delete("/api/criteria/:id", requireRole("admin", "cluster_leader"), async (req, res, next) => {
    try {
      const existingCriteria = await storage.getCriteriaById(req.params.id);
      if (!existingCriteria) {
        return res.status(404).json({ message: "Không tìm thấy tiêu chí" });
      }
      
      const group = await storage.getCriteriaGroup(existingCriteria.groupId);
      if (req.user!.role === "cluster_leader" && group && group.clusterId !== req.user!.clusterId) {
        return res.status(403).json({ message: "Bạn chỉ có thể xóa tiêu chí của cụm mình" });
      }
      
      await storage.deleteCriteria(req.params.id);
      res.json({ message: "Xóa thành công" });
    } catch (error) {
      next(error);
    }
  });
  */

  // Evaluation Period routes
  app.get("/api/evaluation-periods", requireAuth, async (req, res, next) => {
    try {
      // Admin sees all periods, others only see their cluster's periods
      let clusterId = req.query.clusterId as string | undefined;
      
      if (req.user!.role !== "admin") {
        // Force non-admin users to only see their cluster's periods
        clusterId = req.user!.clusterId || undefined;
        if (!clusterId) {
          return res.status(403).json({ message: "Bạn chưa được gán vào cụm thi đua nào" });
        }
      }
      
      const periods = await storage.getEvaluationPeriods(clusterId);
      res.json(periods);
    } catch (error) {
      next(error);
    }
  });

  app.get("/api/evaluation-periods/:id", requireAuth, async (req, res, next) => {
    try {
      const period = await storage.getEvaluationPeriod(req.params.id);
      if (!period) {
        return res.status(404).json({ message: "Không tìm thấy kỳ thi đua" });
      }
      
      // TODO: Check if period is assigned to user's cluster via evaluation_period_clusters
      
      res.json(period);
    } catch (error) {
      next(error);
    }
  });

  app.post("/api/evaluation-periods", requireRole("admin", "cluster_leader"), async (req, res, next) => {
    try {
      console.log("POST /api/evaluation-periods - Request body:", req.body);
      const periodData = insertEvaluationPeriodSchema.parse(req.body);
      console.log("Parsed period data:", periodData);
      
      // TODO: Cluster leaders should assign their own cluster via evaluation_period_clusters
      
      const period = await storage.createEvaluationPeriod(periodData);
      console.log("Created period:", period);
      res.json(period);
    } catch (error) {
      if (error instanceof z.ZodError) {
        console.error("Validation error:", error.errors);
        return res.status(400).json({ message: "Dữ liệu không hợp lệ", errors: error.errors });
      }
      console.error("Server error:", error);
      next(error);
    }
  });

  app.put("/api/evaluation-periods/:id", requireRole("admin", "cluster_leader"), async (req, res, next) => {
    try {
      const periodData = insertEvaluationPeriodSchema.partial().parse(req.body);
      
      const existingPeriod = await storage.getEvaluationPeriod(req.params.id);
      if (!existingPeriod) {
        return res.status(404).json({ message: "Không tìm thấy kỳ thi đua" });
      }
      
      // TODO: Check cluster permissions via evaluation_period_clusters
      
      const period = await storage.updateEvaluationPeriod(req.params.id, periodData);
      res.json(period);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Dữ liệu không hợp lệ", errors: error.errors });
      }
      next(error);
    }
  });

  app.delete("/api/evaluation-periods/:id", requireRole("admin", "cluster_leader"), async (req, res, next) => {
    try {
      const existingPeriod = await storage.getEvaluationPeriod(req.params.id);
      if (!existingPeriod) {
        return res.status(404).json({ message: "Không tìm thấy kỳ thi đua" });
      }
      
      // TODO: Check cluster permissions via evaluation_period_clusters
      
      await storage.deleteEvaluationPeriod(req.params.id);
      res.json({ message: "Xóa thành công" });
    } catch (error) {
      next(error);
    }
  });

  // ========== COMPETITION MANAGEMENT ENDPOINTS ==========
  
  // Get clusters assigned to a period
  app.get("/api/evaluation-periods/:id/clusters", requireAuth, async (req, res, next) => {
    try {
      const clusters = await storage.getPeriodsClustersList(req.params.id);
      res.json(clusters);
    } catch (error) {
      next(error);
    }
  });

  // Assign clusters to a period (replaces existing assignments)
  app.post("/api/evaluation-periods/:id/clusters", requireRole("admin"), async (req, res, next) => {
    try {
      const { clusterIds } = req.body;
      
      if (!Array.isArray(clusterIds)) {
        return res.status(400).json({ message: "clusterIds phải là mảng" });
      }
      
      await storage.assignClustersToPeriod(req.params.id, clusterIds);
      res.json({ message: "Đã gán cụm cho kỳ thi đua", count: clusterIds.length });
    } catch (error) {
      next(error);
    }
  });

  // Remove a cluster from a period
  app.delete("/api/evaluation-periods/:id/clusters/:clusterId", requireRole("admin"), async (req, res, next) => {
    try {
      await storage.removeClusterFromPeriod(req.params.id, req.params.clusterId);
      res.json({ message: "Đã xóa cụm khỏi kỳ thi đua" });
    } catch (error) {
      next(error);
    }
  });

  // Initialize evaluations for all units in period's clusters
  app.post("/api/evaluation-periods/:id/initialize-units", requireRole("admin", "cluster_leader"), async (req, res, next) => {
    try {
      const period = await storage.getEvaluationPeriod(req.params.id);
      if (!period) {
        return res.status(404).json({ message: "Không tìm thấy kỳ thi đua" });
      }

      // Cluster leaders can only init for their own cluster
      let clusterIds: string[] | undefined;
      if (req.user!.role === "cluster_leader" && req.user!.clusterId) {
        clusterIds = [req.user!.clusterId];
      }

      const result = await storage.initializeUnitsForPeriod(req.params.id, clusterIds);
      res.json({
        message: "Đã khởi tạo đánh giá cho các đơn vị",
        created: result.created,
        existing: result.existing,
        total: result.created + result.existing
      });
    } catch (error) {
      next(error);
    }
  });

  // Update period status (draft → active → review1 → review2 → completed)
  app.patch("/api/evaluation-periods/:id/status", requireRole("admin"), async (req, res, next) => {
    try {
      const { status } = req.body;
      
      const validStatuses = ["draft", "active", "review1", "review2", "completed"];
      if (!validStatuses.includes(status)) {
        return res.status(400).json({ message: "Trạng thái không hợp lệ" });
      }

      const period = await storage.updateEvaluationPeriod(req.params.id, { status });
      if (!period) {
        return res.status(404).json({ message: "Không tìm thấy kỳ thi đua" });
      }

      res.json({ message: "Đã cập nhật trạng thái", period });
    } catch (error) {
      next(error);
    }
  });

  // Get period details with statistics
  app.get("/api/evaluation-periods/:id/details", requireAuth, async (req, res, next) => {
    try {
      const period = await storage.getEvaluationPeriod(req.params.id);
      if (!period) {
        return res.status(404).json({ message: "Không tìm thấy kỳ thi đua" });
      }

      // Get clusters
      const clusters = await storage.getPeriodsClustersList(req.params.id);

      // Get evaluations for this period
      const evaluations = await storage.getEvaluations(req.params.id);

      // Count units by cluster
      const clusterStats = await Promise.all(
        clusters.map(async (cluster) => {
          const units = await storage.getUnits(cluster.id);
          const clusterEvaluations = evaluations.filter(e => e.clusterId === cluster.id);
          
          return {
            cluster,
            totalUnits: units.length,
            evaluationsCreated: clusterEvaluations.length,
            statusCounts: {
              draft: clusterEvaluations.filter(e => e.status === "draft").length,
              submitted: clusterEvaluations.filter(e => e.status === "submitted").length,
              review1_completed: clusterEvaluations.filter(e => e.status === "review1_completed").length,
              review2_completed: clusterEvaluations.filter(e => e.status === "review2_completed").length,
              finalized: clusterEvaluations.filter(e => e.status === "finalized").length,
            }
          };
        })
      );

      res.json({
        period,
        clusters,
        clusterStats,
        totalEvaluations: evaluations.length,
      });
    } catch (error) {
      next(error);
    }
  });

  // Copy criteria to a specific period (for period-specific criteria)
  app.post("/api/evaluation-periods/:periodId/criteria/copy", requireAuth, requireRole("admin"), async (req, res, next) => {
    try {
      const { periodId } = req.params;
      const { sourcePeriodId, clusterId } = req.body;

      // Validate period exists
      const period = await storage.getEvaluationPeriod(periodId);
      if (!period) {
        return res.status(404).json({ message: "Không tìm thấy kỳ thi đua" });
      }

      // Get source criteria from another period
      const criteriaTreeStorage = (await import('./criteriaTreeStorage')).criteriaTreeStorage;
      
      if (!sourcePeriodId) {
        return res.status(400).json({ message: "Phải chỉ định kỳ thi đua nguồn" });
      }
      
      const sourceCriteria = await criteriaTreeStorage.getCriteria(sourcePeriodId, clusterId);

      if (sourceCriteria.length === 0) {
        return res.status(404).json({ message: "Không tìm thấy tiêu chí nguồn" });
      }

      // Clone all criteria and assign to new period
      const oldToNewIdMap = new Map<string, string>();
      
      for (const criteria of sourceCriteria) {
        const { id, createdAt, updatedAt, ...criteriaWithoutId } = criteria;
        const newCriteria = await criteriaTreeStorage.createCriteria({
          ...criteriaWithoutId,
          periodId: periodId, // Assign to new period
          parentId: criteria.parentId ? oldToNewIdMap.get(criteria.parentId) || null : null,
        });
        oldToNewIdMap.set(criteria.id, newCriteria.id);
      }

      res.json({ 
        message: "Đã sao chép tiêu chí thành công",
        copiedCount: sourceCriteria.length 
      });
    } catch (error) {
      console.error('Error copying criteria:', error);
      next(error);
    }
  });

  // ========== END COMPETITION MANAGEMENT ENDPOINTS ==========

  // NEW EVALUATION SUMMARY ENDPOINT - Tree-based criteria
  app.get("/api/evaluation-periods/:periodId/units/:unitId/summary", requireAuth, async (req, res, next) => {
    try {
      const { periodId, unitId } = req.params;
      
      // Verify unit exists and check access permissions
      const unit = await storage.getUnit(unitId);
      if (!unit) {
        return res.status(404).json({ message: "Không tìm thấy đơn vị" });
      }
      
      // Role-based access control
      if (req.user!.role !== "admin") {
        if (req.user!.role === "cluster_leader" && unit.clusterId !== req.user!.clusterId) {
          return res.status(403).json({ message: "Bạn chỉ có thể xem dữ liệu của cụm mình" });
        }
        
        if (req.user!.role === "user" && unitId !== req.user!.unitId) {
          return res.status(403).json({ message: "Bạn chỉ có thể xem dữ liệu của đơn vị mình" });
        }
      }
      
      const summary = await storage.getEvaluationSummaryTree(periodId, unitId);
      if (!summary) {
        return res.status(404).json({ message: "Không tìm thấy kỳ thi đua" });
      }
      
      res.json(summary);
    } catch (error) {
      next(error);
    }
  });

  // OLD EVALUATION SUMMARY ENDPOINT - DISABLED
  // This endpoint uses the old flat criteria_groups table structure
  /*
  app.get("/api/evaluation-periods/:periodId/units/:unitId/summary", requireAuth, async (req, res, next) => {
    try {
      const { periodId, unitId } = req.params;
      
      // Verify unit exists and check access permissions
      const unit = await storage.getUnit(unitId);
      if (!unit) {
        return res.status(404).json({ message: "Không tìm thấy đơn vị" });
      }
      
      // Role-based access control
      if (req.user!.role !== "admin") {
        if (req.user!.role === "cluster_leader" && unit.clusterId !== req.user!.clusterId) {
          return res.status(403).json({ message: "Bạn chỉ có thể xem dữ liệu của cụm mình" });
        }
        
        if (req.user!.role === "user" && unitId !== req.user!.unitId) {
          return res.status(403).json({ message: "Bạn chỉ có thể xem dữ liệu của đơn vị mình" });
        }
      }
      
      const summary = await storage.getEvaluationSummary(periodId, unitId);
      if (!summary) {
        return res.status(404).json({ message: "Không tìm thấy kỳ thi đua" });
      }
      
      res.json(summary);
    } catch (error) {
      next(error);
    }
  });
  */

  // Evaluation routes
  app.get("/api/evaluations", requireAuth, async (req, res, next) => {
    try {
      const { periodId, unitId } = req.query;
      let evaluations = await storage.getEvaluations(periodId as string | undefined, unitId as string | undefined);
      
      // Filter evaluations based on user role and cluster ownership
      if (req.user!.role !== "admin") {
        // Fetch all units for evaluations to filter by cluster
        const evaluationsWithUnits = await Promise.all(
          evaluations.map(async (evaluation) => {
            const unit = await storage.getUnit(evaluation.unitId);
            return { evaluation, unit };
          })
        );
        
        evaluations = evaluationsWithUnits
          .filter(({ evaluation, unit }) => {
            if (!unit) return false;
            
            // Cluster leaders can see all evaluations in their cluster
            if (req.user!.role === "cluster_leader") {
              return unit.clusterId === req.user!.clusterId;
            }
            
            // Regular users can only see their own unit's evaluations
            return evaluation.unitId === req.user!.unitId;
          })
          .map(({ evaluation }) => evaluation);
      }
      
      res.json(evaluations);
    } catch (error) {
      next(error);
    }
  });

  app.get("/api/evaluations/:id", requireAuth, async (req, res, next) => {
    try {
      const evaluation = await storage.getEvaluation(req.params.id);
      if (!evaluation) {
        return res.status(404).json({ message: "Không tìm thấy đánh giá" });
      }
      
      // Verify access based on role and ownership
      const unit = await storage.getUnit(evaluation.unitId);
      if (!unit) {
        return res.status(404).json({ message: "Không tìm thấy đơn vị" });
      }
      
      if (req.user!.role !== "admin") {
        if (req.user!.role === "cluster_leader" && unit.clusterId !== req.user!.clusterId) {
          return res.status(403).json({ message: "Bạn chỉ có thể xem đánh giá của cụm mình" });
        }
        
        if (req.user!.role === "user" && evaluation.unitId !== req.user!.unitId) {
          return res.status(403).json({ message: "Bạn chỉ có thể xem đánh giá của đơn vị mình" });
        }
      }
      
      res.json(evaluation);
    } catch (error) {
      next(error);
    }
  });

  app.post("/api/evaluations", requireRole("admin", "cluster_leader"), async (req, res, next) => {
    try {
      const evaluationData = insertEvaluationSchema.parse(req.body);
      
      // Verify the unit exists and check cluster ownership
      const unit = await storage.getUnit(evaluationData.unitId);
      if (!unit) {
        return res.status(404).json({ message: "Không tìm thấy đơn vị" });
      }
      
      // Cluster leaders can only create evaluations for units in their cluster
      if (req.user!.role === "cluster_leader" && unit.clusterId !== req.user!.clusterId) {
        return res.status(403).json({ message: "Bạn chỉ có thể tạo đánh giá cho đơn vị trong cụm của mình" });
      }
      
      const evaluation = await storage.createEvaluation(evaluationData);
      res.json(evaluation);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Dữ liệu không hợp lệ", errors: error.errors });
      }
      next(error);
    }
  });

  // Ensure evaluation exists (create if not) - for scoring workflow
  app.post("/api/evaluations/ensure", requireAuth, async (req, res, next) => {
    try {
      const { periodId, unitId } = z.object({
        periodId: z.string(),
        unitId: z.string(),
      }).parse(req.body);

      // Verify period exists
      const period = await storage.getEvaluationPeriod(periodId);
      if (!period) {
        return res.status(404).json({ message: "Không tìm thấy kỳ thi đua" });
      }

      // Verify unit exists
      const unit = await storage.getUnit(unitId);
      if (!unit) {
        return res.status(404).json({ message: "Không tìm thấy đơn vị" });
      }

      // Check permissions
      if (req.user!.role === "user" && unitId !== req.user!.unitId) {
        return res.status(403).json({ message: "Bạn chỉ có thể tạo đánh giá cho đơn vị của mình" });
      }

      if (req.user!.role === "cluster_leader" && unit.clusterId !== req.user!.clusterId) {
        return res.status(403).json({ message: "Bạn chỉ có thể tạo đánh giá cho đơn vị trong cụm của mình" });
      }

      // Check if evaluation already exists
      let evaluation = await storage.getEvaluationByPeriodUnit(periodId, unitId);
      
      // Create if doesn't exist
      if (!evaluation) {
        evaluation = await storage.createEvaluation({
          periodId,
          clusterId: unit.clusterId,
          unitId,
          status: "draft",
        });
      }

      res.json(evaluation);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Dữ liệu không hợp lệ", errors: error.errors });
      }
      next(error);
    }
  });

  app.put("/api/evaluations/:id", requireAuth, async (req, res, next) => {
    try {
      const evaluationData = insertEvaluationSchema.partial().parse(req.body);
      
      const existingEvaluation = await storage.getEvaluation(req.params.id);
      if (!existingEvaluation) {
        return res.status(404).json({ message: "Không tìm thấy đánh giá" });
      }
      
      // Users can only update evaluations for their own unit
      if (req.user!.role === "user" && existingEvaluation.unitId !== req.user!.unitId) {
        return res.status(403).json({ message: "Bạn chỉ có thể sửa đánh giá của đơn vị mình" });
      }
      
      // Cluster leaders can only update evaluations for units in their cluster
      if (req.user!.role === "cluster_leader") {
        const unit = await storage.getUnit(existingEvaluation.unitId);
        if (unit && unit.clusterId !== req.user!.clusterId) {
          return res.status(403).json({ message: "Bạn chỉ có thể sửa đánh giá của cụm mình" });
        }
        
        // If reassigning to a different unit, verify the new unit is also in their cluster
        if (evaluationData.unitId && evaluationData.unitId !== existingEvaluation.unitId) {
          const newUnit = await storage.getUnit(evaluationData.unitId);
          if (!newUnit || newUnit.clusterId !== req.user!.clusterId) {
            return res.status(403).json({ message: "Bạn chỉ có thể chuyển đánh giá đến đơn vị trong cụm của mình" });
          }
        }
      }
      
      // Regular users cannot reassign evaluations to different units
      if (req.user!.role === "user" && evaluationData.unitId && evaluationData.unitId !== existingEvaluation.unitId) {
        return res.status(403).json({ message: "Bạn không có quyền chuyển đánh giá sang đơn vị khác" });
      }
      
      const evaluation = await storage.updateEvaluation(req.params.id, evaluationData);
      res.json(evaluation);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Dữ liệu không hợp lệ", errors: error.errors });
      }
      next(error);
    }
  });

  // Batch create evaluations for all units in a period
  app.post("/api/evaluation-periods/:id/create-evaluations", requireRole("admin", "cluster_leader"), async (req, res, next) => {
    try {
      const period = await storage.getEvaluationPeriod(req.params.id);
      if (!period) {
        return res.status(404).json({ message: "Không tìm thấy kỳ thi đua" });
      }
      
      // Get clusters assigned to this period
      const periodClusters = await db.select()
        .from(schema.evaluationPeriodClusters)
        .where(eq(schema.evaluationPeriodClusters.periodId, req.params.id));
      
      if (periodClusters.length === 0) {
        return res.status(400).json({ message: "Kỳ thi đua chưa được gán cho cụm nào" });
      }
      
      // Cluster leaders can only create for their own cluster
      let targetClusterIds = periodClusters.map(pc => pc.clusterId);
      if (req.user!.role === "cluster_leader") {
        if (!targetClusterIds.includes(req.user!.clusterId!)) {
          return res.status(403).json({ message: "Kỳ thi đua không áp dụng cho cụm của bạn" });
        }
        targetClusterIds = [req.user!.clusterId!];
      }
      
      // Get all units in target clusters
      const evaluations = [];
      for (const clusterId of targetClusterIds) {
        const units = await storage.getUnits(clusterId);
        
        for (const unit of units) {
          const existing = await storage.getEvaluations(req.params.id, unit.id);
          if (existing.length === 0) {
            const evaluation = await storage.createEvaluation({
              periodId: req.params.id,
              clusterId: clusterId,
              unitId: unit.id,
              status: "draft",
            });
            evaluations.push(evaluation);
          }
        }
      }
      
      res.json({ message: `Đã tạo ${evaluations.length} đánh giá`, evaluations });
    } catch (error) {
      next(error);
    }
  });

  // Submit self-assessment (Unit user)
  app.post("/api/evaluations/:id/submit", requireAuth, async (req, res, next) => {
    try {
      const evaluation = await storage.getEvaluation(req.params.id);
      if (!evaluation) {
        return res.status(404).json({ message: "Không tìm thấy đánh giá" });
      }
      
      // Only unit users can submit their own evaluation
      if (req.user!.role !== "user" || evaluation.unitId !== req.user!.unitId) {
        return res.status(403).json({ message: "Bạn chỉ có thể nộp đánh giá của đơn vị mình" });
      }
      
      // Can only submit from draft status
      if (evaluation.status !== "draft") {
        return res.status(400).json({ message: "Chỉ có thể nộp đánh giá ở trạng thái nháp" });
      }
      
      const updated = await storage.updateEvaluation(req.params.id, { status: "submitted" });
      res.json(updated);
    } catch (error) {
      next(error);
    }
  });

  // Complete review 1 (Cluster leader)
  app.post("/api/evaluations/:id/review1", requireRole("admin", "cluster_leader"), async (req, res, next) => {
    try {
      const evaluation = await storage.getEvaluation(req.params.id);
      if (!evaluation) {
        return res.status(404).json({ message: "Không tìm thấy đánh giá" });
      }
      
      const unit = await storage.getUnit(evaluation.unitId);
      if (!unit) {
        return res.status(404).json({ message: "Không tìm thấy đơn vị" });
      }
      
      // Cluster leaders can only review their cluster's evaluations
      if (req.user!.role === "cluster_leader" && unit.clusterId !== req.user!.clusterId) {
        return res.status(403).json({ message: "Bạn chỉ có thể thẩm định đánh giá của cụm mình" });
      }
      
      // Can only review from submitted status
      if (evaluation.status !== "submitted") {
        return res.status(400).json({ message: "Chỉ có thể thẩm định đánh giá đã nộp" });
      }
      
      const updated = await storage.updateEvaluation(req.params.id, { status: "review1_completed" });
      res.json(updated);
    } catch (error) {
      next(error);
    }
  });

  // Submit explanation (Unit user)
  app.post("/api/evaluations/:id/explain", requireAuth, async (req, res, next) => {
    try {
      const evaluation = await storage.getEvaluation(req.params.id);
      if (!evaluation) {
        return res.status(404).json({ message: "Không tìm thấy đánh giá" });
      }
      
      // Only unit users can submit explanation for their own evaluation
      if (req.user!.role !== "user" || evaluation.unitId !== req.user!.unitId) {
        return res.status(403).json({ message: "Bạn chỉ có thể giải trình cho đánh giá của đơn vị mình" });
      }
      
      // Can only explain from review1_completed status
      if (evaluation.status !== "review1_completed") {
        return res.status(400).json({ message: "Chỉ có thể giải trình sau khi hoàn thành thẩm định lần 1" });
      }
      
      const updated = await storage.updateEvaluation(req.params.id, { status: "explanation_submitted" });
      res.json(updated);
    } catch (error) {
      next(error);
    }
  });

  // Recalculate finalScores (Admin only - for migration/maintenance)
  app.post("/api/evaluations/:id/recalculate", requireRole("admin"), async (req, res, next) => {
    try {
      const evaluation = await storage.getEvaluation(req.params.id);
      if (!evaluation) {
        return res.status(404).json({ message: "Không tìm thấy đánh giá" });
      }
      
      // Audit log for manual recalculation
      console.log(`[ADMIN RECALCULATE] User ${req.user!.id} (${req.user!.username}) triggered recalculation for evaluation ${req.params.id}`);
      
      const result = await recalculateEvaluationScores(req.params.id);
      
      console.log(`[ADMIN RECALCULATE] Completed: ${result.scoresUpdated} scores updated for evaluation ${req.params.id}`);
      
      res.json({ 
        message: "Đã tính lại điểm cuối cùng thành công",
        scoresUpdated: result.scoresUpdated
      });
    } catch (error) {
      next(error);
    }
  });

  // Complete review 2 (Cluster leader)
  app.post("/api/evaluations/:id/review2", requireRole("admin", "cluster_leader"), async (req, res, next) => {
    try {
      const evaluation = await storage.getEvaluation(req.params.id);
      if (!evaluation) {
        return res.status(404).json({ message: "Không tìm thấy đánh giá" });
      }
      
      const unit = await storage.getUnit(evaluation.unitId);
      if (!unit) {
        return res.status(404).json({ message: "Không tìm thấy đơn vị" });
      }
      
      // Cluster leaders can only review their cluster's evaluations
      if (req.user!.role === "cluster_leader" && unit.clusterId !== req.user!.clusterId) {
        return res.status(403).json({ message: "Bạn chỉ có thể thẩm định đánh giá của cụm mình" });
      }
      
      // Can only review2 from explanation_submitted status
      if (evaluation.status !== "explanation_submitted") {
        return res.status(400).json({ message: "Chỉ có thể thẩm định lần 2 sau khi đơn vị giải trình" });
      }
      
      const updated = await storage.updateEvaluation(req.params.id, { status: "review2_completed" });
      res.json(updated);
    } catch (error) {
      next(error);
    }
  });

  // Finalize evaluation (Admin/Cluster leader)
  app.post("/api/evaluations/:id/finalize", requireRole("admin", "cluster_leader"), async (req, res, next) => {
    try {
      const evaluation = await storage.getEvaluation(req.params.id);
      if (!evaluation) {
        return res.status(404).json({ message: "Không tìm thấy đánh giá" });
      }
      
      const unit = await storage.getUnit(evaluation.unitId);
      if (!unit) {
        return res.status(404).json({ message: "Không tìm thấy đơn vị" });
      }
      
      // Cluster leaders can only finalize their cluster's evaluations
      if (req.user!.role === "cluster_leader" && unit.clusterId !== req.user!.clusterId) {
        return res.status(403).json({ message: "Bạn chỉ có thể hoàn tất đánh giá của cụm mình" });
      }
      
      // Can only finalize from review2_completed status
      if (evaluation.status !== "review2_completed") {
        return res.status(400).json({ message: "Chỉ có thể hoàn tất sau khi hoàn thành thẩm định lần 2" });
      }
      
      const updated = await storage.updateEvaluation(req.params.id, { status: "finalized" });
      res.json(updated);
    } catch (error) {
      next(error);
    }
  });

  // Score routes
  app.get("/api/scores", requireAuth, async (req, res, next) => {
    try {
      const { evaluationId } = req.query;
      if (!evaluationId) {
        return res.status(400).json({ message: "Thiếu evaluationId" });
      }
      
      // Verify evaluation exists and check access
      const evaluation = await storage.getEvaluation(evaluationId as string);
      if (!evaluation) {
        return res.status(404).json({ message: "Không tìm thấy đánh giá" });
      }
      
      // Check cluster ownership
      const unit = await storage.getUnit(evaluation.unitId);
      if (!unit) {
        return res.status(404).json({ message: "Không tìm thấy đơn vị" });
      }
      
      if (req.user!.role !== "admin") {
        if (req.user!.role === "cluster_leader" && unit.clusterId !== req.user!.clusterId) {
          return res.status(403).json({ message: "Bạn chỉ có thể xem điểm của cụm mình" });
        }
        
        if (req.user!.role === "user" && evaluation.unitId !== req.user!.unitId) {
          return res.status(403).json({ message: "Bạn chỉ có thể xem điểm của đơn vị mình" });
        }
      }
      
      const scores = await storage.getScores(evaluationId as string);
      res.json(scores);
    } catch (error) {
      next(error);
    }
  });

  app.get("/api/scores/:id", requireAuth, async (req, res, next) => {
    try {
      const score = await storage.getScore(req.params.id);
      if (!score) {
        return res.status(404).json({ message: "Không tìm thấy điểm" });
      }
      
      // Get the evaluation to check permissions
      const evaluation = await storage.getEvaluation(score.evaluationId);
      if (!evaluation) {
        return res.status(404).json({ message: "Không tìm thấy đánh giá" });
      }
      
      // Check cluster ownership
      const unit = await storage.getUnit(evaluation.unitId);
      if (!unit) {
        return res.status(404).json({ message: "Không tìm thấy đơn vị" });
      }
      
      if (req.user!.role !== "admin") {
        if (req.user!.role === "cluster_leader" && unit.clusterId !== req.user!.clusterId) {
          return res.status(403).json({ message: "Bạn chỉ có thể xem điểm của cụm mình" });
        }
        
        if (req.user!.role === "user" && evaluation.unitId !== req.user!.unitId) {
          return res.status(403).json({ message: "Bạn chỉ có thể xem điểm của đơn vị mình" });
        }
      }
      
      res.json(score);
    } catch (error) {
      next(error);
    }
  });

  app.post("/api/scores", requireAuth, async (req, res, next) => {
    try {
      const scoreData = insertScoreSchema.parse(req.body);
      
      // Verify the evaluation exists and check permissions
      const evaluation = await storage.getEvaluation(scoreData.evaluationId);
      if (!evaluation) {
        return res.status(404).json({ message: "Không tìm thấy đánh giá" });
      }
      
      // Users can only create scores for their own unit's evaluation
      if (req.user!.role === "user" && evaluation.unitId !== req.user!.unitId) {
        return res.status(403).json({ message: "Bạn chỉ có thể tạo điểm cho đơn vị mình" });
      }
      
      // Cluster leaders can only create scores for evaluations in their cluster
      if (req.user!.role === "cluster_leader") {
        const unit = await storage.getUnit(evaluation.unitId);
        if (!unit || unit.clusterId !== req.user!.clusterId) {
          return res.status(403).json({ message: "Bạn chỉ có thể tạo điểm cho cụm của mình" });
        }
      }
      
      const score = await storage.createScore(scoreData);
      res.json(score);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Dữ liệu không hợp lệ", errors: error.errors });
      }
      next(error);
    }
  });

  app.put("/api/scores/:id", requireAuth, async (req, res, next) => {
    try {
      const scoreData = insertScoreSchema.partial().parse(req.body);
      
      const existingScore = await storage.getScore(req.params.id);
      if (!existingScore) {
        return res.status(404).json({ message: "Không tìm thấy điểm" });
      }
      
      // Get the evaluation to check permissions
      const evaluation = await storage.getEvaluation(existingScore.evaluationId);
      if (!evaluation) {
        return res.status(404).json({ message: "Không tìm thấy đánh giá" });
      }
      
      // Users can only update scores for their own unit's evaluation
      if (req.user!.role === "user" && evaluation.unitId !== req.user!.unitId) {
        return res.status(403).json({ message: "Bạn chỉ có thể sửa điểm của đơn vị mình" });
      }
      
      // Cluster leaders can only update scores for evaluations in their cluster
      if (req.user!.role === "cluster_leader") {
        const unit = await storage.getUnit(evaluation.unitId);
        if (unit && unit.clusterId !== req.user!.clusterId) {
          return res.status(403).json({ message: "Bạn chỉ có thể sửa điểm của cụm mình" });
        }
        
        // If reassigning to a different evaluation, verify the new evaluation is also in their cluster
        if (scoreData.evaluationId && scoreData.evaluationId !== existingScore.evaluationId) {
          const newEvaluation = await storage.getEvaluation(scoreData.evaluationId);
          if (!newEvaluation) {
            return res.status(404).json({ message: "Không tìm thấy đánh giá mới" });
          }
          const newUnit = await storage.getUnit(newEvaluation.unitId);
          if (!newUnit || newUnit.clusterId !== req.user!.clusterId) {
            return res.status(403).json({ message: "Bạn chỉ có thể chuyển điểm đến đánh giá trong cụm của mình" });
          }
        }
      }
      
      // Regular users cannot reassign scores to different evaluations
      if (req.user!.role === "user" && scoreData.evaluationId && scoreData.evaluationId !== existingScore.evaluationId) {
        return res.status(403).json({ message: "Bạn không có quyền chuyển điểm sang đánh giá khác" });
      }
      
      const score = await storage.updateScore(req.params.id, scoreData);
      res.json(score);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Dữ liệu không hợp lệ", errors: error.errors });
      }
      next(error);
    }
  });

  // Bulk update scores for an evaluation (multi-stage scoring)
  app.put("/api/evaluations/:id/scores", requireAuth, async (req, res, next) => {
    try {
      const evaluation = await storage.getEvaluation(req.params.id);
      if (!evaluation) {
        return res.status(404).json({ message: "Không tìm thấy đánh giá" });
      }
      
      // Check cluster ownership
      const unit = await storage.getUnit(evaluation.unitId);
      if (!unit) {
        return res.status(404).json({ message: "Không tìm thấy đơn vị" });
      }
      
      if (req.user!.role !== "admin") {
        if (req.user!.role === "cluster_leader" && unit.clusterId !== req.user!.clusterId) {
          return res.status(403).json({ message: "Bạn chỉ có thể cập nhật điểm của cụm mình" });
        }
        
        if (req.user!.role === "user" && evaluation.unitId !== req.user!.unitId) {
          return res.status(403).json({ message: "Bạn chỉ có thể cập nhật điểm của đơn vị mình" });
        }
      }
      
      // Parse and validate scores array - EXTENDED for all criteria types
      const scoresData = z.array(z.object({
        criteriaId: z.string(),
        // Input fields for different criteria types
        actualValue: z.number().optional(),      // Type 1 (Quantitative) & Type 3 (Fixed count)
        isAchieved: z.boolean().optional(),      // Type 2 (Qualitative)
        bonusCount: z.number().optional(),       // Type 4 (+/-)
        penaltyCount: z.number().optional(),     // Type 4 (+/-)
        calculatedScore: z.number().optional(),  // Auto-calculated score
        // Review fields
        selfScore: z.number().optional(),
        selfScoreFile: z.string().optional(),
        review1Score: z.number().optional(),
        review1Comment: z.string().optional(),
        review1File: z.string().optional(),
        explanation: z.string().optional(),
        review2Score: z.number().optional(),
        review2Comment: z.string().optional(),
        review2File: z.string().optional(),
      })).parse(req.body.scores);
      
      // Stage-specific validation based on evaluation status and user role
      for (const scoreData of scoresData) {
        // Unit users can only update self-scoring before finalization
        if (req.user!.role === "user") {
          if (evaluation.status !== "draft" && evaluation.status !== "submitted") {
            if (scoreData.selfScore !== undefined || scoreData.selfScoreFile !== undefined) {
              return res.status(400).json({ message: "Chỉ có thể tự chấm điểm ở trạng thái nháp hoặc đã nộp" });
            }
          }
          
          // Unit users can only add explanation in review1_completed or explanation_submitted status
          if (evaluation.status !== "review1_completed" && evaluation.status !== "explanation_submitted") {
            if (scoreData.explanation !== undefined) {
              return res.status(400).json({ message: "Chỉ có thể giải trình sau khi hoàn thành thẩm định lần 1" });
            }
          }
          
          // Unit users cannot update review scores
          if (scoreData.review1Score !== undefined || scoreData.review1Comment !== undefined || scoreData.review1File !== undefined) {
            return res.status(403).json({ message: "Bạn không có quyền thẩm định" });
          }
          if (scoreData.review2Score !== undefined || scoreData.review2Comment !== undefined || scoreData.review2File !== undefined) {
            return res.status(403).json({ message: "Bạn không có quyền thẩm định" });
          }
        }
        
        // Cluster leaders validation (allow editing in appropriate states)
        if (req.user!.role === "cluster_leader" || req.user!.role === "admin") {
          // Can update review1 in submitted or later states (before finalized)
          if (scoreData.review1Score !== undefined || scoreData.review1Comment !== undefined || scoreData.review1File !== undefined) {
            if (evaluation.status === "draft") {
              return res.status(400).json({ message: "Không thể thẩm định khi đơn vị chưa nộp" });
            }
            if (evaluation.status === "finalized") {
              return res.status(400).json({ message: "Không thể sửa điểm đã hoàn tất" });
            }
          }
          
          // Can update review2 in explanation_submitted, review2_completed, or finalized states
          if (scoreData.review2Score !== undefined || scoreData.review2Comment !== undefined || scoreData.review2File !== undefined) {
            if (evaluation.status !== "explanation_submitted" && evaluation.status !== "review2_completed" && evaluation.status !== "finalized") {
              return res.status(400).json({ message: "Chỉ có thể thẩm định lần 2 sau khi đơn vị giải trình" });
            }
          }
        }
      }
      
      // Fetch ALL existing scores once for this evaluation
      const allExistingScores = await storage.getScores(req.params.id);
      const updatedScores = [];
      
      for (const scoreData of scoresData) {
        // Find existing score
        let existingScore = allExistingScores.find(s => s.criteriaId === scoreData.criteriaId);
        
        let score;
        if (existingScore) {
          // Prepare update data with timestamps
          const updateData: any = {};
          
          // Update input fields for different criteria types
          if (scoreData.actualValue !== undefined) {
            updateData.actualValue = scoreData.actualValue.toString();
          }
          if (scoreData.isAchieved !== undefined) {
            updateData.isAchieved = scoreData.isAchieved ? 1 : 0;
          }
          if (scoreData.bonusCount !== undefined) {
            updateData.bonusCount = scoreData.bonusCount;
          }
          if (scoreData.penaltyCount !== undefined) {
            updateData.penaltyCount = scoreData.penaltyCount;
          }
          if (scoreData.calculatedScore !== undefined) {
            updateData.calculatedScore = scoreData.calculatedScore.toString();
          }
          
          if (scoreData.selfScore !== undefined) {
            updateData.selfScore = scoreData.selfScore.toString();
            updateData.selfScoreDate = new Date();
          }
          // Only update file URL if explicitly provided (not undefined/null)
          if (scoreData.selfScoreFile !== undefined && scoreData.selfScoreFile !== null) {
            updateData.selfScoreFile = scoreData.selfScoreFile;
          }
          
          if (scoreData.review1Score !== undefined) {
            updateData.review1Score = scoreData.review1Score.toString();
            updateData.review1Date = new Date();
          }
          if (scoreData.review1Comment !== undefined) {
            updateData.review1Comment = scoreData.review1Comment;
          }
          // Only update file URL if explicitly provided (not undefined/null)
          if (scoreData.review1File !== undefined && scoreData.review1File !== null) {
            updateData.review1File = scoreData.review1File;
          }
          
          if (scoreData.explanation !== undefined) {
            updateData.explanation = scoreData.explanation;
            updateData.explanationDate = new Date();
          }
          
          if (scoreData.review2Score !== undefined) {
            updateData.review2Score = scoreData.review2Score.toString();
            updateData.review2Date = new Date();
          }
          if (scoreData.review2Comment !== undefined) {
            updateData.review2Comment = scoreData.review2Comment;
          }
          // Only update file URL if explicitly provided (not undefined/null)
          if (scoreData.review2File !== undefined && scoreData.review2File !== null) {
            updateData.review2File = scoreData.review2File;
          }
          
          // Note: finalScore will be recalculated by helper function after all updates
          score = await storage.updateScore(existingScore.id, updateData);
        } else {
          // Create new score
          const newScore: any = {
            evaluationId: req.params.id,
            criteriaId: scoreData.criteriaId,
          };
          
          // Set input fields for different criteria types
          if (scoreData.actualValue !== undefined) {
            newScore.actualValue = scoreData.actualValue.toString();
          }
          if (scoreData.isAchieved !== undefined) {
            newScore.isAchieved = scoreData.isAchieved ? 1 : 0;
          }
          if (scoreData.bonusCount !== undefined) {
            newScore.bonusCount = scoreData.bonusCount;
          }
          if (scoreData.penaltyCount !== undefined) {
            newScore.penaltyCount = scoreData.penaltyCount;
          }
          if (scoreData.calculatedScore !== undefined) {
            newScore.calculatedScore = scoreData.calculatedScore.toString();
          }
          
          if (scoreData.selfScore !== undefined) {
            newScore.selfScore = scoreData.selfScore.toString();
            newScore.selfScoreDate = new Date();
          }
          if (scoreData.selfScoreFile !== undefined) {
            newScore.selfScoreFile = scoreData.selfScoreFile;
          }
          
          // Note: finalScore will be set by helper function after creation
          score = await storage.createScore(newScore);
        }
        
        updatedScores.push(score);
      }
      
      // Recalculate finalScores and totals using helper function
      await recalculateEvaluationScores(req.params.id);
      
      res.json({ message: "Cập nhật điểm thành công", scores: updatedScores });
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Dữ liệu không hợp lệ", errors: error.errors });
      }
      next(error);
    }
  });

  // NEW: Upsert criteria result (Type 1-4 scoring)
  app.post("/api/criteria-results", requireAuth, async (req, res, next) => {
    try {
      const inputData = z.object({
        criteriaId: z.string(),
        unitId: z.string(),
        periodId: z.string(),
        targetValue: z.number().optional(), // For Type 1: Chỉ tiêu được giao
        actualValue: z.number().optional(),
        selfScore: z.number().optional(),
        bonusCount: z.number().optional(),
        penaltyCount: z.number().optional(),
        evidenceFile: z.string().nullable().optional(), // Đường dẫn server (không hiển thị)
        evidenceFileName: z.string().nullable().optional(), // Tên file gốc (hiển thị cho user)
        note: z.string().optional(),
      }).parse(req.body);

      // Permission check: Unit ownership
      if (req.user!.role === "user" && inputData.unitId !== req.user!.unitId) {
        return res.status(403).json({ message: "Bạn chỉ có thể chấm điểm cho đơn vị của mình" });
      }

      const unit = await storage.getUnit(inputData.unitId);
      if (!unit) {
        return res.status(404).json({ message: "Không tìm thấy đơn vị" });
      }

      if (req.user!.role === "cluster_leader" && unit.clusterId !== req.user!.clusterId) {
        return res.status(403).json({ message: "Bạn chỉ có thể chấm điểm cho đơn vị trong cụm của mình" });
      }

      // SECURITY: Validate period belongs to unit's cluster
      const periodClusters = await storage.getPeriodsClustersList(inputData.periodId);
      const periodHasCluster = periodClusters.some(c => c.id === unit.clusterId);
      if (!periodHasCluster) {
        return res.status(403).json({ message: "Kỳ thi đua này không áp dụng cho cụm của đơn vị" });
      }

      // SECURITY: Verify unit actually participates in this period (has evaluation)
      const evaluation = await storage.getEvaluationByPeriodUnit(inputData.periodId, inputData.unitId);
      if (!evaluation) {
        return res.status(403).json({ message: "Đơn vị chưa được khởi tạo cho kỳ thi đua này" });
      }

      // SECURITY: Validate criteria belongs to this period (and optionally cluster)
      const criteriaRows = await db.select()
        .from(schema.criteria)
        .where(
          and(
            eq(schema.criteria.id, inputData.criteriaId),
            eq(schema.criteria.periodId, inputData.periodId),
            // Criteria must be for this cluster OR global (null clusterId) - use safe Drizzle primitives
            or(
              eq(schema.criteria.clusterId, unit.clusterId),
              isNull(schema.criteria.clusterId)
            )
          )
        )
        .limit(1);
      
      if (criteriaRows.length === 0) {
        return res.status(403).json({ message: "Tiêu chí này không thuộc kỳ thi đua hoặc cụm của đơn vị" });
      }

      const criteria = criteriaRows[0];

      // FOR TYPE 1: Save targetValue to criteria_targets if provided
      if (criteria.criteriaType === 1 && inputData.targetValue !== undefined) {
        // Upsert target value for this unit+criteria+period
        const existingTarget = await db.select()
          .from(schema.criteriaTargets)
          .where(
            and(
              eq(schema.criteriaTargets.criteriaId, inputData.criteriaId),
              eq(schema.criteriaTargets.unitId, inputData.unitId),
              eq(schema.criteriaTargets.periodId, inputData.periodId)
            )
          )
          .limit(1);

        if (existingTarget.length > 0) {
          // Update existing target
          await db.update(schema.criteriaTargets)
            .set({
              targetValue: inputData.targetValue.toString(),
              updatedAt: new Date(),
            })
            .where(eq(schema.criteriaTargets.id, existingTarget[0].id));
        } else {
          // Insert new target
          await db.insert(schema.criteriaTargets).values({
            id: crypto.randomUUID(),
            criteriaId: inputData.criteriaId,
            unitId: inputData.unitId,
            periodId: inputData.periodId,
            targetValue: inputData.targetValue.toString(),
            createdAt: new Date(),
            updatedAt: new Date(),
          });
        }
      }

      // AUTO-CALCULATION: Calculate score based on criteria type
      let calculatedScore: number | null = null;
      
      if (criteria.criteriaType === 1) {
        // Type 1: Định lượng (Quantitative) - actualValue/targetValue × maxScore
        // Allow overachievement (scores > maxScore are possible)
        if (inputData.actualValue !== undefined) {
          // Use the targetValue from input if provided, otherwise look up from database
          let targetVal: number | null = null;
          
          if (inputData.targetValue !== undefined) {
            targetVal = Number(inputData.targetValue);
          } else {
            // Look up the assigned target for this unit+criteria+period
            const targetRows = await db.select()
              .from(schema.criteriaTargets)
              .where(
                and(
                  eq(schema.criteriaTargets.criteriaId, inputData.criteriaId),
                  eq(schema.criteriaTargets.unitId, inputData.unitId),
                  eq(schema.criteriaTargets.periodId, inputData.periodId)
                )
              )
              .limit(1);
            
            if (targetRows.length > 0) {
              targetVal = Number(targetRows[0].targetValue);
            }
          }
          
          if (targetVal !== null && targetVal > 0) {
            const actualVal = Number(inputData.actualValue);
            const maxScore = Number(criteria.maxScore);
            
            // Guard against division by zero and invalid numbers
            if (!isNaN(actualVal) && !isNaN(maxScore)) {
              const percentage = actualVal / targetVal;
              calculatedScore = percentage * maxScore;
              // Round to 2 decimal places, allow scores > maxScore for overachievement
              calculatedScore = Math.round(calculatedScore * 100) / 100;
            }
          }
        }
      } else if (criteria.criteriaType === 2) {
        // Type 2: Định tính (Qualitative) - achieved=maxScore, not achieved=0
        // Frontend sends: selfScore = maxScore (achieved) or 0 (not achieved)
        // We simply use the selfScore value as the calculatedScore
        if (inputData.selfScore !== undefined) {
          const selfScoreVal = Number(inputData.selfScore);
          // If selfScore > 0, consider it achieved (= maxScore)
          // If selfScore = 0, consider it not achieved (= 0)
          calculatedScore = selfScoreVal > 0 ? Number(criteria.maxScore) : 0;
        }
      }
      // Type 3 & 4: No auto-calculation needed, user enters score directly

      // Convert numbers to strings for Drizzle decimal fields
      const resultData: any = {
        criteriaId: inputData.criteriaId,
        unitId: inputData.unitId,
        periodId: inputData.periodId,
        note: inputData.note,
        // Don't set status here - let storage.upsertCriteriaResult handle it
      };
      
      // Set calculatedScore if we computed one
      if (calculatedScore !== null) {
        resultData.calculatedScore = calculatedScore.toString();
      }
      
      // Allow explicit null to clear evidenceFile
      if (inputData.evidenceFile !== undefined) {
        resultData.evidenceFile = inputData.evidenceFile;
      }
      
      // Save original filename (for display to user)
      if (inputData.evidenceFileName !== undefined) {
        resultData.evidenceFileName = inputData.evidenceFileName;
      }
      
      if (inputData.actualValue !== undefined) {
        resultData.actualValue = inputData.actualValue.toString();
      }
      if (inputData.selfScore !== undefined) {
        resultData.selfScore = inputData.selfScore.toString();
      }
      if (inputData.bonusCount !== undefined) {
        resultData.bonusCount = inputData.bonusCount;
      }
      if (inputData.penaltyCount !== undefined) {
        resultData.penaltyCount = inputData.penaltyCount;
      }

      const result = await storage.upsertCriteriaResult(resultData);
      res.json(result);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Dữ liệu không hợp lệ", errors: error.errors });
      }
      next(error);
    }
  });

  // Batch recalculate scores for Type 1 (Quantitative) criteria
  app.post("/api/criteria-results/recalculate", requireRole("admin", "cluster_leader"), async (req, res, next) => {
    try {
      const inputData = z.object({
        periodId: z.string(),
        clusterId: z.string().optional(),
      }).parse(req.body);

      // Permission check: Cluster leader can only recalculate for their own cluster
      if (req.user!.role === "cluster_leader") {
        if (!req.user!.clusterId) {
          return res.status(403).json({ message: "Bạn không thuộc cụm nào" });
        }
        if (inputData.clusterId && inputData.clusterId !== req.user!.clusterId) {
          return res.status(403).json({ message: "Bạn chỉ có thể tính lại điểm cho cụm của mình" });
        }
        // Force clusterId to user's cluster for cluster leaders
        inputData.clusterId = req.user!.clusterId;
      }

      // Get all units in the cluster (if clusterId specified)
      let targetUnitIds: string[] = [];
      if (inputData.clusterId) {
        const units = await db.select()
          .from(schema.units)
          .where(eq(schema.units.clusterId, inputData.clusterId));
        targetUnitIds = units.map(u => u.id);
        
        if (targetUnitIds.length === 0) {
          return res.json({ message: "Không có đơn vị nào trong cụm này", recalculated: 0 });
        }
      }

      // Get ALL Type 1 (quantitative) criteria for this period
      let criteriaQuery = db.select()
        .from(schema.criteria)
        .where(
          and(
            eq(schema.criteria.periodId, inputData.periodId),
            eq(schema.criteria.criteriaType, 1) // ONLY Type 1 (Quantitative)
          )
        );

      // If clusterId specified, filter criteria to that cluster or global (null clusterId)
      if (inputData.clusterId) {
        criteriaQuery = db.select()
          .from(schema.criteria)
          .where(
            and(
              eq(schema.criteria.periodId, inputData.periodId),
              eq(schema.criteria.criteriaType, 1),
              or(
                eq(schema.criteria.clusterId, inputData.clusterId),
                isNull(schema.criteria.clusterId)
              )
            )
          );
      }

      const type1Criteria = await criteriaQuery;
      
      if (type1Criteria.length === 0) {
        return res.json({ message: "Không có tiêu chí định lượng nào cần tính lại", recalculated: 0 });
      }

      const criteriaIds = type1Criteria.map(c => c.id);
      const criteriaMap = new Map(type1Criteria.map(c => [c.id, c]));

      // Get ALL criteria results for these Type 1 criteria
      let resultsQuery = db.select()
        .from(schema.criteriaResults)
        .where(
          and(
            eq(schema.criteriaResults.periodId, inputData.periodId),
            inArray(schema.criteriaResults.criteriaId, criteriaIds)
          )
        );

      // Filter by units in cluster if specified
      if (targetUnitIds.length > 0) {
        resultsQuery = db.select()
          .from(schema.criteriaResults)
          .where(
            and(
              eq(schema.criteriaResults.periodId, inputData.periodId),
              inArray(schema.criteriaResults.criteriaId, criteriaIds),
              inArray(schema.criteriaResults.unitId, targetUnitIds)
            )
          );
      }

      const results = await resultsQuery;
      
      if (results.length === 0) {
        return res.json({ message: "Không có dữ liệu điểm nào cần tính lại", recalculated: 0 });
      }

      // Get all targets for these results
      const allTargets = await db.select()
        .from(schema.criteriaTargets)
        .where(
          and(
            eq(schema.criteriaTargets.periodId, inputData.periodId),
            inArray(schema.criteriaTargets.criteriaId, criteriaIds)
          )
        );
      
      // Build map: criteriaId -> (unitId -> targetValue)
      const targetsMap = new Map<string, Map<string, number>>();
      for (const target of allTargets) {
        if (!targetsMap.has(target.criteriaId)) {
          targetsMap.set(target.criteriaId, new Map());
        }
        targetsMap.get(target.criteriaId)!.set(target.unitId, Number(target.targetValue));
      }
      
      // Group results by criteriaId
      const resultsByCriteria = new Map<string, typeof results>();
      for (const result of results) {
        if (!resultsByCriteria.has(result.criteriaId)) {
          resultsByCriteria.set(result.criteriaId, []);
        }
        resultsByCriteria.get(result.criteriaId)!.push(result);
      }
      
      // Recalculate scores for each criteria (batch by criteria to determine leader)
      let totalRecalculated = 0;
      for (const criteriaId of Array.from(resultsByCriteria.keys())) {
        const criteriaResults = resultsByCriteria.get(criteriaId)!;
        const criteria = criteriaMap.get(criteriaId);
        if (!criteria) continue;
        
        const targets = targetsMap.get(criteriaId);
        if (!targets) continue;
        
        // Use the new batch calculation algorithm
        const scores = CriteriaScoreService.batchCalculateQuantitativeScores(
          criteriaResults,
          targets,
          Number(criteria.maxScore)
        );
        
        // Update all scores in database
        for (const result of criteriaResults) {
          const calculatedScore = scores.get(result.unitId);
          if (calculatedScore === undefined) continue;
          
          await db.update(schema.criteriaResults)
            .set({ 
              calculatedScore: calculatedScore.toString(),
              updatedAt: new Date(),
            })
            .where(eq(schema.criteriaResults.id, result.id));
          
          totalRecalculated++;
        }
      }

      res.json({ 
        message: `Đã tính lại ${totalRecalculated} tiêu chí định lượng thành công`,
        recalculated: totalRecalculated 
      });
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Dữ liệu không hợp lệ", errors: error.errors });
      }
      next(error);
    }
  });

  // ==================== REPORTS ENDPOINTS ====================

  /**
   * GET /api/reports/cluster-summary
   * Get scoring summary for all units in a cluster
   * Query params: periodId, clusterId
   * Permissions: Admin (all clusters), Cluster Leader/User (own cluster only)
   */
  app.get("/api/reports/cluster-summary", requireAuth, async (req, res, next) => {
    try {
      const { periodId, clusterId } = z.object({
        periodId: z.string(),
        clusterId: z.string(),
      }).parse(req.query);

      // Permission check: Admin can view all, others only their cluster
      if (req.user!.role !== "admin") {
        const userClusterId = req.user!.role === "cluster_leader" 
          ? req.user!.clusterId 
          : (await storage.getUnit(req.user!.unitId!))?.clusterId;

        if (userClusterId !== clusterId) {
          return res.status(403).json({ message: "Bạn chỉ có thể xem báo cáo cụm của mình" });
        }
      }

      // Get all units in this cluster
      const units = await db.select()
        .from(schema.units)
        .where(eq(schema.units.clusterId, clusterId));

      // Get all evaluations for this period + cluster
      const evaluations = await db.select()
        .from(schema.evaluations)
        .where(
          and(
            eq(schema.evaluations.periodId, periodId),
            eq(schema.evaluations.clusterId, clusterId)
          )
        );

      // Get all criteria results for this period
      const unitIds = units.map(u => u.id);
      const criteriaResults = unitIds.length > 0
        ? await db.select()
            .from(schema.criteriaResults)
            .where(
              and(
                eq(schema.criteriaResults.periodId, periodId),
                inArray(schema.criteriaResults.unitId, unitIds)
              )
            )
        : [];

      // Build summary data by summing up criteriaResults
      const summaryData = units.map(unit => {
        const evaluation = evaluations.find(e => e.unitId === unit.id);
        const unitResults = criteriaResults.filter(r => r.unitId === unit.id);
        
        // Sum all scores from criteriaResults
        // selfScore (điểm tự chấm) = calculatedScore (điểm đơn vị tự tính/nhập)
        // clusterScore = điểm cụm chấm
        // approvedScore = finalScore or clusterScore or calculatedScore (priority order)
        const selfScore = unitResults.reduce((sum, r) => 
          sum + (r.calculatedScore ? parseFloat(r.calculatedScore) : 0), 0);
        const clusterScore = unitResults.reduce((sum, r) => 
          sum + (r.clusterScore ? parseFloat(r.clusterScore) : 0), 0);
        const approvedScore = unitResults.reduce((sum, r) => {
          // Priority: finalScore > clusterScore > calculatedScore
          const score = r.finalScore ? parseFloat(r.finalScore) 
                      : r.clusterScore ? parseFloat(r.clusterScore)
                      : r.calculatedScore ? parseFloat(r.calculatedScore)
                      : 0;
          return sum + score;
        }, 0);
        
        return {
          unitId: unit.id,
          unitName: unit.name,
          selfScore,
          clusterScore,
          approvedScore,
          status: evaluation?.status || "draft",
        };
      });

      // Calculate ranking based on approvedScore (descending)
      const sortedData = [...summaryData].sort((a, b) => b.approvedScore - a.approvedScore);
      const rankedData = summaryData.map(item => {
        const rank = sortedData.findIndex(s => s.unitId === item.unitId) + 1;
        return { ...item, ranking: rank };
      });

      res.json(rankedData);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Dữ liệu không hợp lệ", errors: error.errors });
      }
      next(error);
    }
  });

  /**
   * GET /api/reports/criteria-matrix
   * Get detailed unit-by-criteria scores matrix
   * Query params: periodId, clusterId
   * Permissions: Admin (all clusters), Cluster Leader/User (own cluster only)
   */
  app.get("/api/reports/criteria-matrix", requireAuth, async (req, res, next) => {
    try {
      const { periodId, clusterId } = z.object({
        periodId: z.string(),
        clusterId: z.string(),
      }).parse(req.query);

      // Permission check: Admin can view all, others only their cluster
      if (req.user!.role !== "admin") {
        const userClusterId = req.user!.role === "cluster_leader" 
          ? req.user!.clusterId 
          : (await storage.getUnit(req.user!.unitId!))?.clusterId;

        if (userClusterId !== clusterId) {
          return res.status(403).json({ message: "Bạn chỉ có thể xem báo cáo cụm của mình" });
        }
      }

      // Get criteria matrix data
      const matrixData = await storage.getCriteriaMatrix(periodId, clusterId);

      res.json(matrixData);
    } catch (error) {
      console.error("Error in /api/reports/criteria-matrix:", error);
      next(error);
    }
  });

  /**
   * GET /api/reports/criteria-matrix/export
   * Export criteria matrix to Excel
   * Query params: periodId, clusterId
   * Permissions: Admin (all clusters), Cluster Leader/User (own cluster only)
   */
  app.get("/api/reports/criteria-matrix/export", requireAuth, async (req, res, next) => {
    try {
      const { periodId, clusterId } = z.object({
        periodId: z.string(),
        clusterId: z.string(),
      }).parse(req.query);

      // Permission check: Admin can view all, others only their cluster
      if (req.user!.role !== "admin") {
        const userClusterId = req.user!.role === "cluster_leader" 
          ? req.user!.clusterId 
          : (await storage.getUnit(req.user!.unitId!))?.clusterId;

        if (userClusterId !== clusterId) {
          return res.status(403).json({ message: "Bạn chỉ có thể xuất báo cáo cụm của mình" });
        }
      }

      // Get period and cluster info for filename
      const period = await storage.getEvaluationPeriod(periodId);
      const cluster = await storage.getCluster(clusterId);
      
      if (!period || !cluster) {
        return res.status(404).json({ message: "Không tìm thấy kỳ thi đua hoặc cụm" });
      }

      // Get criteria matrix data
      const matrixData = await storage.getCriteriaMatrix(periodId, clusterId);

      // Create Excel workbook
      const workbook = new ExcelJS.Workbook();
      const worksheet = workbook.addWorksheet("Bảng điểm theo tiêu chí");

      // Group criteria by parent for header row 1
      const groupedByParent = new Map<string, typeof matrixData.criteriaHierarchy>();
      matrixData.criteriaHierarchy.forEach(criteria => {
        const parentId = criteria.parentChain.length > 0 
          ? criteria.parentChain[0].id 
          : 'root';
        if (!groupedByParent.has(parentId)) {
          groupedByParent.set(parentId, []);
        }
        groupedByParent.get(parentId)!.push(criteria);
      });

      // Build header structure
      // Row 1: "Đơn vị" + Parent group headers
      const row1 = ['Đơn vị'];
      Array.from(groupedByParent.entries()).forEach(([_, children]) => {
        const parentName = children[0].parentChain.length > 0 
          ? children[0].parentChain[0].name 
          : 'Tiêu chí';
        // Each parent group spans (children.length * 2) columns (for ĐTC and TĐ)
        row1.push(parentName);
        for (let i = 1; i < children.length * 2; i++) {
          row1.push(''); // Merge cells
        }
      });

      // Row 2: Leaf criteria codes (TC1, TC2, ...)
      const row2 = [''];
      matrixData.criteriaHierarchy.forEach(criteria => {
        row2.push(criteria.displayCode);
        row2.push(''); // For the second sub-column
      });

      // Row 3: ĐTC / TĐ labels
      const row3 = [''];
      matrixData.criteriaHierarchy.forEach(() => {
        row3.push('ĐTC');
        row3.push('TĐ');
      });

      // Add header rows
      worksheet.addRow(row1);
      worksheet.addRow(row2);
      worksheet.addRow(row3);

      // Merge cells for Row 1
      worksheet.mergeCells(1, 1, 3, 1); // "Đơn vị" spans 3 rows
      let colIndex = 2;
      Array.from(groupedByParent.entries()).forEach(([_, children]) => {
        const colSpan = children.length * 2;
        worksheet.mergeCells(1, colIndex, 1, colIndex + colSpan - 1);
        colIndex += colSpan;
      });

      // Merge cells for Row 2 (each criteria code spans 2 columns)
      colIndex = 2;
      matrixData.criteriaHierarchy.forEach(() => {
        worksheet.mergeCells(2, colIndex, 2, colIndex + 1);
        colIndex += 2;
      });

      // Style header rows
      [1, 2, 3].forEach(rowNum => {
        const row = worksheet.getRow(rowNum);
        row.font = { bold: true };
        row.fill = {
          type: "pattern",
          pattern: "solid",
          fgColor: { argb: "FFE0E0E0" },
        };
        row.alignment = { vertical: "middle", horizontal: "center" };
        row.height = 25;
      });

      // Add data rows
      matrixData.units.forEach(unit => {
        const rowData = [unit.unitShortName];
        
        matrixData.criteriaHierarchy.forEach(criteria => {
          const scores = unit.scoresByCriteria[criteria.id];
          rowData.push(
            scores?.selfScore !== null && scores?.selfScore !== undefined 
              ? scores.selfScore.toFixed(1) 
              : "-"
          );
          rowData.push(
            scores?.clusterScore !== null && scores?.clusterScore !== undefined 
              ? scores.clusterScore.toFixed(1) 
              : "-"
          );
        });

        worksheet.addRow(rowData);
      });

      // Set column widths
      worksheet.getColumn(1).width = 20; // Unit name column
      for (let i = 2; i <= row1.length; i++) {
        worksheet.getColumn(i).width = 8; // Score columns
      }

      // Add borders to all cells
      worksheet.eachRow((row) => {
        row.eachCell((cell) => {
          cell.border = {
            top: { style: "thin" },
            left: { style: "thin" },
            bottom: { style: "thin" },
            right: { style: "thin" },
          };
          cell.alignment = { 
            vertical: "middle",
            horizontal: "center",
          };
        });
      });

      // Left-align unit names
      worksheet.eachRow((row, rowNumber) => {
        if (rowNumber > 3) { // Data rows
          const cell = row.getCell(1);
          cell.alignment = { 
            vertical: "middle",
            horizontal: "left",
          };
        }
      });

      // Generate filename
      const filename = `BangDiemChiTiet_${cluster.shortName}_${period.name.replace(/\s+/g, "_")}_${new Date().toISOString().split("T")[0]}.xlsx`;

      // Set response headers
      res.setHeader("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
      res.setHeader("Content-Disposition", `attachment; filename="${encodeURIComponent(filename)}"`);

      // Write to response
      await workbook.xlsx.write(res);
      res.end();
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Dữ liệu không hợp lệ", errors: error.errors });
      }
      console.error("Error in /api/reports/criteria-matrix/export:", error);
      next(error);
    }
  });

  /**
   * GET /api/reports/cluster-summary/export
   * Export cluster summary to Excel
   * Query params: periodId, clusterId
   * Permissions: Same as cluster-summary
   */
  app.get("/api/reports/cluster-summary/export", requireAuth, async (req, res, next) => {
    try {
      const { periodId, clusterId } = z.object({
        periodId: z.string(),
        clusterId: z.string(),
      }).parse(req.query);

      // Permission check: Admin can view all, others only their cluster
      if (req.user!.role !== "admin") {
        const userClusterId = req.user!.role === "cluster_leader" 
          ? req.user!.clusterId 
          : (await storage.getUnit(req.user!.unitId!))?.clusterId;

        if (userClusterId !== clusterId) {
          return res.status(403).json({ message: "Bạn chỉ có thể xuất báo cáo cụm của mình" });
        }
      }

      // Get period and cluster info for filename
      const period = await storage.getEvaluationPeriod(periodId);
      const cluster = await storage.getCluster(clusterId);
      
      if (!period || !cluster) {
        return res.status(404).json({ message: "Không tìm thấy kỳ thi đua hoặc cụm" });
      }

      // Get all units in this cluster
      const units = await db.select()
        .from(schema.units)
        .where(eq(schema.units.clusterId, clusterId));

      // Get all evaluations for this period + cluster
      const evaluations = await db.select()
        .from(schema.evaluations)
        .where(
          and(
            eq(schema.evaluations.periodId, periodId),
            eq(schema.evaluations.clusterId, clusterId)
          )
        );

      // Build summary data
      const summaryData = units.map(unit => {
        const evaluation = evaluations.find(e => e.unitId === unit.id);
        
        return {
          unitId: unit.id,
          unitName: unit.name,
          selfScore: evaluation?.totalSelfScore ? parseFloat(evaluation.totalSelfScore) : 0,
          clusterScore: evaluation?.totalReview1Score ? parseFloat(evaluation.totalReview1Score) : 0,
          approvedScore: evaluation?.totalFinalScore ? parseFloat(evaluation.totalFinalScore) : 0,
          status: evaluation?.status || "draft",
        };
      });

      // Calculate ranking
      const sortedData = [...summaryData].sort((a, b) => b.approvedScore - a.approvedScore);
      const rankedData = summaryData.map(item => {
        const rank = sortedData.findIndex(s => s.unitId === item.unitId) + 1;
        return { ...item, ranking: rank };
      });

      // Create Excel workbook
      const workbook = new ExcelJS.Workbook();
      const worksheet = workbook.addWorksheet("Báo cáo điểm");

      // Define columns
      worksheet.columns = [
        { header: "Hạng", key: "ranking", width: 10 },
        { header: "Đơn vị", key: "unitName", width: 40 },
        { header: "Điểm tự chấm", key: "selfScore", width: 15 },
        { header: "Điểm cụm chấm", key: "clusterScore", width: 15 },
        { header: "Điểm được duyệt", key: "approvedScore", width: 15 },
        { header: "Trạng thái", key: "status", width: 20 },
      ];

      // Style header row
      const headerRow = worksheet.getRow(1);
      headerRow.font = { bold: true };
      headerRow.fill = {
        type: "pattern",
        pattern: "solid",
        fgColor: { argb: "FFE0E0E0" },
      };
      headerRow.alignment = { vertical: "middle", horizontal: "center" };
      headerRow.height = 25;

      // Add data rows
      rankedData.forEach(item => {
        const statusMap: Record<string, string> = {
          finalized: "Đã duyệt",
          review2_completed: "Chờ duyệt cuối",
          explanation_submitted: "Đã giải trình",
          review1_completed: "Đã chấm cụm",
          submitted: "Đã nộp",
          draft: "Chưa nộp",
        };

        worksheet.addRow({
          ranking: item.ranking,
          unitName: item.unitName,
          selfScore: item.selfScore > 0 ? item.selfScore.toFixed(2) : "-",
          clusterScore: item.clusterScore > 0 ? item.clusterScore.toFixed(2) : "-",
          approvedScore: item.approvedScore > 0 ? item.approvedScore.toFixed(2) : "-",
          status: statusMap[item.status] || "Chưa nộp",
        });
      });

      // Add borders to all cells
      worksheet.eachRow((row, rowNumber) => {
        row.eachCell((cell) => {
          cell.border = {
            top: { style: "thin" },
            left: { style: "thin" },
            bottom: { style: "thin" },
            right: { style: "thin" },
          };
          if (rowNumber > 1) {
            cell.alignment = { vertical: "middle" };
          }
        });
      });

      // Generate filename
      const filename = `BaoCao_${cluster.shortName}_${period.name.replace(/\s+/g, "_")}_${new Date().toISOString().split("T")[0]}.xlsx`;

      // Set response headers
      res.setHeader("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
      res.setHeader("Content-Disposition", `attachment; filename="${encodeURIComponent(filename)}"`);

      // Write to response
      await workbook.xlsx.write(res);
      res.end();
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Dữ liệu không hợp lệ", errors: error.errors });
      }
      next(error);
    }
  });

  /**
   * GET /api/evaluation-periods/:periodId/criteria/export
   * Export criteria tree to Excel
   * Query params: clusterId (optional - for cluster-specific criteria)
   * Permissions: Admin (all), Cluster Leader/User (own cluster only)
   */
  app.get("/api/evaluation-periods/:periodId/criteria/export", requireAuth, async (req, res, next) => {
    try {
      const { periodId } = req.params;
      const { clusterId: requestedClusterId } = z.object({
        clusterId: z.string().optional(),
      }).parse(req.query);

      // Determine effective clusterId based on role and request
      let effectiveClusterId: string | undefined;

      if (req.user!.role === "admin") {
        // Admin can export any cluster (or global if no clusterId provided)
        effectiveClusterId = requestedClusterId;
      } else {
        // Non-admins can only export their own cluster
        const userClusterId = req.user!.role === "cluster_leader" 
          ? req.user!.clusterId 
          : (await storage.getUnit(req.user!.unitId!))?.clusterId;

        if (!userClusterId) {
          return res.status(403).json({ message: "Không tìm thấy cụm của bạn" });
        }

        // If requestedClusterId is provided, verify it matches user's cluster
        if (requestedClusterId && requestedClusterId !== userClusterId) {
          return res.status(403).json({ message: "Bạn chỉ có thể xuất tiêu chí cụm của mình" });
        }

        // Always use user's cluster for non-admins
        effectiveClusterId = userClusterId;
      }

      // Get period info for filename
      const period = await storage.getEvaluationPeriod(periodId);
      if (!period) {
        return res.status(404).json({ message: "Không tìm thấy kỳ thi đua" });
      }

      // Fetch criteria (global or cluster-specific based on effectiveClusterId)
      const allCriteria = await db.select()
        .from(schema.criteria)
        .where(
          and(
            eq(schema.criteria.periodId, periodId),
            effectiveClusterId 
              ? or(
                  eq(schema.criteria.clusterId, effectiveClusterId),
                  isNull(schema.criteria.clusterId)
                )
              : isNull(schema.criteria.clusterId)
          )
        )
        .orderBy(schema.criteria.code);

      // Build hierarchical tree structure with indentation
      const buildTree = (items: typeof allCriteria, parentId: string | null = null, level: number = 0): any[] => {
        const children = items.filter(item => item.parentId === parentId);
        return children.flatMap(item => [
          { ...item, level },
          ...buildTree(items, item.id, level + 1)
        ]);
      };

      const hierarchicalCriteria = buildTree(allCriteria);

      // Create Excel workbook
      const workbook = new ExcelJS.Workbook();
      const worksheet = workbook.addWorksheet("Tiêu chí thi đua");

      // Define columns
      worksheet.columns = [
        { header: "Mã tiêu chí", key: "code", width: 15 },
        { header: "Tên tiêu chí", key: "name", width: 50 },
        { header: "Loại", key: "type", width: 15 },
        { header: "Điểm tối đa", key: "maxScore", width: 15 },
      ];

      // Style header row
      const headerRow = worksheet.getRow(1);
      headerRow.font = { bold: true };
      headerRow.fill = {
        type: "pattern",
        pattern: "solid",
        fgColor: { argb: "FFE0E0E0" },
      };
      headerRow.alignment = { vertical: "middle", horizontal: "center" };
      headerRow.height = 25;

      // Add data rows with indentation
      const criteriaTypeMap: Record<number, string> = {
        1: "Định lượng",
        2: "Định tính",
        3: "Chấm thẳng",
        4: "+/-",
      };

      hierarchicalCriteria.forEach(item => {
        const indent = "  ".repeat(item.level); // 2 spaces per level
        worksheet.addRow({
          code: item.code || "-",
          name: indent + item.name,
          type: criteriaTypeMap[item.criteriaType] || "-",
          maxScore: item.maxScore ? parseFloat(item.maxScore).toFixed(2) : "-",
        });
      });

      // Add borders to all cells
      worksheet.eachRow((row, rowNumber) => {
        row.eachCell((cell) => {
          cell.border = {
            top: { style: "thin" },
            left: { style: "thin" },
            bottom: { style: "thin" },
            right: { style: "thin" },
          };
          if (rowNumber > 1) {
            cell.alignment = { vertical: "middle" };
          }
        });
      });

      // Generate filename
      const clusterPart = effectiveClusterId ? `_Cum_${effectiveClusterId.substring(0, 8)}` : "";
      const filename = `TieuChi_${period.name.replace(/\s+/g, "_")}${clusterPart}_${new Date().toISOString().split("T")[0]}.xlsx`;

      // Set response headers
      res.setHeader("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
      res.setHeader("Content-Disposition", `attachment; filename="${encodeURIComponent(filename)}"`);

      // Write to response
      await workbook.xlsx.write(res);
      res.end();
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Dữ liệu không hợp lệ", errors: error.errors });
      }
      next(error);
    }
  });

  /**
   * GET /api/evaluations/:evaluationId/export
   * Export detailed scoring results for a specific evaluation to Excel
   * Permissions: Admin (all), Cluster Leader (own cluster), Unit User (own unit)
   */
  app.get("/api/evaluations/:evaluationId/export", requireAuth, async (req, res, next) => {
    try {
      const { evaluationId } = req.params;

      // Fetch evaluation with unit and period info
      const evaluation = await db.select()
        .from(schema.evaluations)
        .leftJoin(schema.units, eq(schema.evaluations.unitId, schema.units.id))
        .leftJoin(schema.evaluationPeriods, eq(schema.evaluations.periodId, schema.evaluationPeriods.id))
        .where(eq(schema.evaluations.id, evaluationId))
        .limit(1);

      if (!evaluation.length) {
        return res.status(404).json({ message: "Không tìm thấy đánh giá" });
      }

      const evalData = evaluation[0].evaluations;
      const unit = evaluation[0].units;
      const period = evaluation[0].evaluation_periods;

      if (!unit || !period) {
        return res.status(404).json({ message: "Dữ liệu không đầy đủ" });
      }

      // Check permissions
      if (req.user!.role === "user") {
        if (evalData.unitId !== req.user!.unitId) {
          return res.status(403).json({ message: "Bạn chỉ có thể xuất kết quả đơn vị của mình" });
        }
      } else if (req.user!.role === "cluster_leader") {
        if (unit.clusterId !== req.user!.clusterId) {
          return res.status(403).json({ message: "Bạn chỉ có thể xuất kết quả đơn vị trong cụm của mình" });
        }
      }
      // Admin can export any evaluation

      // Fetch all criteria results for this evaluation
      const criteriaResults = await db.select({
        criteriaId: schema.criteriaResults.criteriaId,
        actualValue: schema.criteriaResults.actualValue,
        selfScore: schema.criteriaResults.selfScore,
        clusterScore: schema.criteriaResults.clusterScore,
        finalScore: schema.criteriaResults.finalScore,
        calculatedScore: schema.criteriaResults.calculatedScore,
        evidenceFile: schema.criteriaResults.evidenceFile,
        evidenceFileName: schema.criteriaResults.evidenceFileName,
        code: schema.criteria.code,
        name: schema.criteria.name,
        criteriaType: schema.criteria.criteriaType,
        maxScore: schema.criteria.maxScore,
        parentId: schema.criteria.parentId,
        level: schema.criteria.level,
      })
        .from(schema.criteriaResults)
        .leftJoin(schema.criteria, eq(schema.criteriaResults.criteriaId, schema.criteria.id))
        .where(
          and(
            eq(schema.criteriaResults.unitId, evalData.unitId),
            eq(schema.criteriaResults.periodId, evalData.periodId)
          )
        )
        .orderBy(schema.criteria.code);

      // Fetch targets for Type 1 criteria
      const targetData = await db.select()
        .from(schema.criteriaTargets)
        .where(
          and(
            eq(schema.criteriaTargets.unitId, evalData.unitId),
            eq(schema.criteriaTargets.periodId, evalData.periodId)
          )
        );

      const targetsMap = new Map(
        targetData.map(t => [t.criteriaId, { targetValue: t.targetValue }])
      );

      // Create Excel workbook
      const workbook = new ExcelJS.Workbook();
      const worksheet = workbook.addWorksheet("Kết quả chấm điểm");

      // Define columns
      worksheet.columns = [
        { header: "Mã tiêu chí", key: "code", width: 12 },
        { header: "Tên tiêu chí", key: "name", width: 45 },
        { header: "Loại", key: "type", width: 12 },
        { header: "Điểm tối đa", key: "maxScore", width: 12 },
        { header: "Chỉ tiêu", key: "targetValue", width: 12 },
        { header: "Kết quả", key: "actualValue", width: 12 },
        { header: "Điểm tự chấm", key: "selfScore", width: 14 },
        { header: "Điểm cụm chấm", key: "clusterScore", width: 14 },
        { header: "Điểm cuối cùng", key: "finalScore", width: 14 },
      ];

      // Style header row
      const headerRow = worksheet.getRow(1);
      headerRow.font = { bold: true };
      headerRow.fill = {
        type: "pattern",
        pattern: "solid",
        fgColor: { argb: "FFE0E0E0" },
      };
      headerRow.alignment = { vertical: "middle", horizontal: "center" };
      headerRow.height = 25;

      // Criteria type map
      const criteriaTypeMap: Record<number, string> = {
        1: "Định lượng",
        2: "Định tính",
        3: "Chấm thẳng",
        4: "+/-",
      };

      // Add data rows
      criteriaResults.forEach(result => {
        const indent = "  ".repeat(result.level || 0);
        const targets = targetsMap.get(result.criteriaId);
        
        // Determine display score (prioritize calculatedScore for Type 1)
        let displaySelfScore = "-";
        if (result.criteriaType === 1 && result.calculatedScore !== null) {
          displaySelfScore = parseFloat(result.calculatedScore).toFixed(2);
        } else if (result.selfScore !== null) {
          displaySelfScore = parseFloat(result.selfScore).toFixed(2);
        }

        worksheet.addRow({
          code: result.code || "-",
          name: indent + (result.name || ""),
          type: result.criteriaType !== null ? criteriaTypeMap[result.criteriaType] : "-",
          maxScore: result.maxScore ? parseFloat(result.maxScore).toFixed(2) : "-",
          targetValue: targets?.targetValue ? parseFloat(targets.targetValue).toFixed(2) : "-",
          actualValue: result.actualValue ? parseFloat(result.actualValue).toFixed(2) : "-",
          selfScore: displaySelfScore,
          clusterScore: result.clusterScore !== null ? parseFloat(result.clusterScore).toFixed(2) : "-",
          finalScore: result.finalScore !== null ? parseFloat(result.finalScore).toFixed(2) : "-",
        });
      });

      // Add borders to all cells
      worksheet.eachRow((row, rowNumber) => {
        row.eachCell((cell) => {
          cell.border = {
            top: { style: "thin" },
            left: { style: "thin" },
            bottom: { style: "thin" },
            right: { style: "thin" },
          };
          if (rowNumber > 1) {
            cell.alignment = { vertical: "middle" };
          }
        });
      });

      // Generate filename
      const filename = `KetQua_${unit.shortName}_${period.name.replace(/\s+/g, "_")}_${new Date().toISOString().split("T")[0]}.xlsx`;

      // Set response headers
      res.setHeader("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
      res.setHeader("Content-Disposition", `attachment; filename="${encodeURIComponent(filename)}"`);

      // Write to response
      await workbook.xlsx.write(res);
      res.end();
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Dữ liệu không hợp lệ", errors: error.errors });
      }
      next(error);
    }
  });

  const httpServer = createServer(app);

  return httpServer;
}

// Import and setup criteria tree routes
import { setupCriteriaTreeRoutes } from "./criteriaTreeRoutes";
export { setupCriteriaTreeRoutes };
