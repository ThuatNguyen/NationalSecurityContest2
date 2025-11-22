import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import { FileText, RefreshCw, Send, FileSpreadsheet, Printer } from "lucide-react";
import { useState, useMemo, useEffect, Fragment, useCallback, useRef } from "react";
import { useQuery, useMutation } from "@tanstack/react-query";
import { useSession } from "@/lib/useSession";
import { Skeleton } from "@/components/ui/skeleton";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Badge } from "@/components/ui/badge";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import ScoringModal from "@/components/ScoringModal";
import ReviewModal from "@/components/ReviewModal";
import QualitativeReviewModal from "@/components/QualitativeReviewModal";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";

interface Criteria {
  id: string;
  parentId?: string | null; // Parent criteria ID for hierarchy
  name: string;
  code: string;
  level: number;
  criteriaType: number; // 0 = parent/branch node, 1-4 = leaf node (scorable)
  maxScore: number;
  displayOrder: number;
  // New criteriaResults fields
  selfScore?: number;
  calculatedScore?: number;
  actualValue?: number;
  targetValue?: number; // Chỉ tiêu được giao (cho tiêu chí định lượng)
  evidenceFile?: string | null; // Đường dẫn server (không hiển thị)
  evidenceFileName?: string | null; // Tên file gốc (hiển thị cho user)
  note?: string | null;
  status?: string;
  // Legacy fields for backwards compatibility
  selfScoreFile?: string;
  review1Score?: number;
  review1Comment?: string;
  review1File?: string;
  review2Score?: number;
  review2Comment?: string;
  review2File?: string;
  finalScore?: number;
}

interface CriteriaGroup {
  id: string;
  name: string;
  displayOrder: number;
  criteria: Criteria[];
}

interface EvaluationSummary {
  period: {
    id: string;
    name: string;
    year: number;
    startDate: string;
    endDate: string;
    status: string;
  };
  evaluation: {
    id: string;
    periodId: string;
    unitId: string;
    status: string;
    submittedAt?: string;
  } | null;
  criteriaGroups: CriteriaGroup[];
}

export default function EvaluationPeriods() {
  const { user } = useSession();
  const { toast } = useToast();
  const [scoringModalOpen, setScoringModalOpen] = useState(false);
  const [reviewModalOpen, setReviewModalOpen] = useState(false);
  const [qualitativeReviewModalOpen, setQualitativeReviewModalOpen] = useState(false);
  const [explanationModalOpen, setExplanationModalOpen] = useState(false);
  const [selectedCriteria, setSelectedCriteria] = useState<Criteria | null>(
    null,
  );
  const [reviewType, setReviewType] = useState<"review1" | "review2">(
    "review1",
  );
  const [selectedPeriodId, setSelectedPeriodId] = useState<string>("");
  const [selectedClusterId, setSelectedClusterId] = useState<string>("");
  const [selectedUnitId, setSelectedUnitId] = useState<string>("");
  const [submitDialogOpen, setSubmitDialogOpen] = useState(false);
  
  // Refs for debouncing
  const periodChangeTimeoutRef = useRef<NodeJS.Timeout | null>(null);
  const clusterChangeTimeoutRef = useRef<NodeJS.Timeout | null>(null);
  const unitChangeTimeoutRef = useRef<NodeJS.Timeout | null>(null);

  // Query all evaluation periods
  const {
    data: periods = [],
    isLoading: loadingPeriods,
    error: periodsError,
    refetch: refetchPeriods,
  } = useQuery<any[]>({
    queryKey: ["/api/evaluation-periods"],
    enabled: !!user,
    staleTime: 5 * 60 * 1000, // Consider data fresh for 5 minutes
    gcTime: 10 * 60 * 1000, // Keep in cache for 10 minutes
  });

  // Query clusters for selected period
  const { data: clusters = [], isLoading: loadingClusters } = useQuery<any[]>({
    queryKey: [`/api/evaluation-periods/${selectedPeriodId}/clusters`],
    enabled: !!selectedPeriodId,
    staleTime: 5 * 60 * 1000, // Consider data fresh for 5 minutes
    gcTime: 10 * 60 * 1000, // Keep in cache for 10 minutes
  });

  // Query units (filtered by cluster)
  const { data: units = [], isLoading: loadingUnits } = useQuery<any[]>({
    queryKey: ["/api/units", selectedClusterId],
    queryFn: async () => {
      const res = await fetch(
        `/api/units${selectedClusterId ? `?clusterId=${selectedClusterId}` : ""}`,
        {
          credentials: "include",
        },
      );
      if (!res.ok) throw new Error("Failed to fetch units");
      return res.json();
    },
    enabled: !!selectedClusterId,
    staleTime: 5 * 60 * 1000, // Consider data fresh for 5 minutes
    gcTime: 10 * 60 * 1000, // Keep in cache for 10 minutes
  });

  // Get selected period from periods list
  const selectedPeriod = useMemo(() => {
    if (!periods || periods.length === 0) return null;
    if (selectedPeriodId) {
      return periods.find((p) => p.id === selectedPeriodId) || null;
    }
    return null;
  }, [periods, selectedPeriodId]);

  // Get selected cluster from clusters list
  const selectedCluster = useMemo(() => {
    if (!clusters || clusters.length === 0) return null;
    if (selectedClusterId) {
      return clusters.find((c) => c.id === selectedClusterId) || null;
    }
    return null;
  }, [clusters, selectedClusterId]);

  // Get selected unit from units list
  const selectedUnit = useMemo(() => {
    if (!units || units.length === 0) return null;
    if (selectedUnitId) {
      return units.find((u) => u.id === selectedUnitId) || null;
    }
    return null;
  }, [units, selectedUnitId]);

  // Cleanup timeouts on unmount
  useEffect(() => {
    return () => {
      if (periodChangeTimeoutRef.current) clearTimeout(periodChangeTimeoutRef.current);
      if (clusterChangeTimeoutRef.current) clearTimeout(clusterChangeTimeoutRef.current);
      if (unitChangeTimeoutRef.current) clearTimeout(unitChangeTimeoutRef.current);
    };
  }, []);

  // Step 1: Auto-select first period when periods are loaded
  useEffect(() => {
    if (periods && periods.length > 0 && !selectedPeriodId) {
      setSelectedPeriodId(periods[0].id);
    }
  }, [periods, selectedPeriodId]);

  // Step 1b: Reset cluster and unit when period changes
  useEffect(() => {
    if (selectedPeriodId) {
      setSelectedClusterId("");
      setSelectedUnitId("");
    }
  }, [selectedPeriodId]);

  // Step 2: Auto-select cluster based on user role
  useEffect(() => {
    if (!user || !selectedPeriod || !clusters || clusters.length === 0) return;

    // Check if current cluster is valid for this period
    const currentClusterValid =
      selectedClusterId && clusters.some((c) => c.id === selectedClusterId);

    // For unit users: use their cluster from user object (if it exists in period)
    if (user.role === "user" && user.clusterId) {
      const userClusterValid = clusters.some((c) => c.id === user.clusterId);
      if (userClusterValid && selectedClusterId !== user.clusterId) {
        setSelectedClusterId(user.clusterId);
      } else if (!userClusterValid && !currentClusterValid) {
        // User's cluster not in this period, select first available
        setSelectedClusterId(clusters[0].id);
      }
      return;
    }

    // For cluster leaders: use their cluster (if it exists in period)
    if (user.role === "cluster_leader" && user.clusterId) {
      const userClusterValid = clusters.some((c) => c.id === user.clusterId);
      if (userClusterValid && selectedClusterId !== user.clusterId) {
        setSelectedClusterId(user.clusterId);
      } else if (!userClusterValid && !currentClusterValid) {
        // User's cluster not in this period, select first available
        setSelectedClusterId(clusters[0].id);
      }
      return;
    }

    // For admin: auto-select first cluster if current selection is invalid
    if (user.role === "admin" && !currentClusterValid) {
      setSelectedClusterId(clusters[0].id);
    }
  }, [user, selectedPeriod, clusters, selectedClusterId]);

  // Step 3: Auto-select unit based on user role
  useEffect(() => {
    if (!user || !selectedClusterId || !units || units.length === 0) return;

    // Get units in current cluster
    const unitsInCluster = units.filter(
      (u) => u.clusterId === selectedClusterId,
    );
    if (unitsInCluster.length === 0) return;

    // Check if current unit is valid for this cluster
    const currentUnitValid =
      selectedUnitId && unitsInCluster.some((u) => u.id === selectedUnitId);

    // For unit users: use their unit from user object (if it exists in cluster)
    if (user.role === "user" && user.unitId) {
      const userUnitValid = unitsInCluster.some((u) => u.id === user.unitId);
      if (userUnitValid && selectedUnitId !== user.unitId) {
        setSelectedUnitId(user.unitId);
      } else if (!userUnitValid && !currentUnitValid) {
        // User's unit not in this cluster, select first available
        setSelectedUnitId(unitsInCluster[0].id);
      }
      return;
    }

    // For cluster leaders and admin: auto-select first unit if current selection is invalid
    if (!currentUnitValid) {
      setSelectedUnitId(unitsInCluster[0].id);
    }
  }, [user, selectedClusterId, units, selectedUnitId]);

  // Memoize filtered units by selected cluster
  const filteredUnits = useMemo(() => {
    if (!units || !selectedClusterId) return [];
    return units.filter((u) => u.clusterId === selectedClusterId);
  }, [units, selectedClusterId]);

  // Handle cluster change (only for admin) - with debounce
  const handleClusterChange = useCallback((clusterId: string) => {
    if (clusterChangeTimeoutRef.current) {
      clearTimeout(clusterChangeTimeoutRef.current);
    }
    
    clusterChangeTimeoutRef.current = setTimeout(() => {
      setSelectedClusterId(clusterId);
      setSelectedUnitId(""); // Reset unit when cluster changes
    }, 150); // Debounce 150ms
  }, []);
  
  // Handle unit change - with debounce
  const handleUnitChange = useCallback((unitId: string) => {
    if (unitChangeTimeoutRef.current) {
      clearTimeout(unitChangeTimeoutRef.current);
    }
    
    unitChangeTimeoutRef.current = setTimeout(() => {
      setSelectedUnitId(unitId);
    }, 150); // Debounce 150ms
  }, []);
  
  // Handle period change - with debounce
  const handlePeriodChange = useCallback((periodId: string) => {
    if (periodChangeTimeoutRef.current) {
      clearTimeout(periodChangeTimeoutRef.current);
    }
    
    periodChangeTimeoutRef.current = setTimeout(() => {
      setSelectedPeriodId(periodId);
    }, 150); // Debounce 150ms
  }, []);

  // Query evaluation summary (only when period and unit are available)
  const {
    data: summary,
    isLoading: loadingSummary,
    error: summaryError,
    refetch: refetchSummary,
  } = useQuery<EvaluationSummary>({
    queryKey: [
      "/api/evaluation-periods",
      selectedPeriod?.id,
      "units",
      selectedUnitId,
      "summary",
    ],
    enabled: !!selectedPeriod?.id && !!selectedUnitId,
    staleTime: 2 * 60 * 1000, // Data fresh for 2 minutes (shorter since scores change)
    gcTime: 5 * 60 * 1000, // Keep in cache for 5 minutes
    select: (data) => {
      // Log review scores for debugging
      console.log("[SUMMARY DATA] Loaded evaluation summary");
      data.criteriaGroups.forEach((group) => {
        group.criteria.forEach((item) => {
          if (item.review1Score !== undefined || item.review2Score !== undefined) {
            console.log(`[REVIEW SCORES] ${item.name}:`, {
              review1Score: item.review1Score,
              review2Score: item.review2Score,
              review1Comment: item.review1Comment,
              review2Comment: item.review2Comment,
            });
          }
        });
      });
      return data;
    },
  });

  const handleOpenScoringModal = useCallback((criteria: Criteria) => {
    setSelectedCriteria(criteria);
    setScoringModalOpen(true);
  }, []);

  const handleOpenExplanationModal = useCallback((criteria: Criteria) => {
    setSelectedCriteria(criteria);
    setExplanationModalOpen(true);
  }, []);

  const handleOpenReviewModal = useCallback((
    criteria: Criteria,
    type: "review1" | "review2",
  ) => {
    setSelectedCriteria(criteria);
    setReviewType(type);
    
    // Open different modal based on criteria type
    // criteriaType 2 = qualitative (định tính) - use QualitativeReviewModal
    // Other types - use regular ReviewModal with score input and file upload
    if (criteria.criteriaType === 2) {
      setQualitativeReviewModalOpen(true);
    } else {
      setReviewModalOpen(true);
    }
  }, []);

  // OLD saveScoreMutation removed - now using handleSaveScore with new API

  const handleSaveScore = async (data: {
    score?: number;
    file?: File | null;
    targetValue?: number;
    actualValue?: number;
    achieved?: boolean;
  }) => {
    if (!selectedCriteria || !selectedPeriod || !selectedUnitId) return;
    
    const criteriaType = selectedCriteria.criteriaType || 3;
    
    try {
      // Upload file if provided
      let fileUrl: string | undefined;
      let originalFileName: string | undefined;
      if (data.file) {
        const formData = new FormData();
        formData.append("file", data.file);
        const uploadRes = await fetch("/api/upload", {
          method: "POST",
          body: formData,
          credentials: "include",
        });
        if (!uploadRes.ok) throw new Error("Upload file thất bại");
        const uploadData = await uploadRes.json();
        fileUrl = uploadData.fileUrl;
        originalFileName = uploadData.originalName; // Tên file gốc
      }

      // Build payload based on criteriaType
      const payload: any = {
        criteriaId: selectedCriteria.id,
        unitId: selectedUnitId,
        periodId: selectedPeriod.id,
        // Preserve existing evidenceFile/evidenceFileName when no new upload
        evidenceFile: fileUrl || selectedCriteria.evidenceFile || selectedCriteria.selfScoreFile, // Fallback order: new → evidenceFile → legacy
        evidenceFileName: originalFileName || selectedCriteria.evidenceFileName, // Preserve display name
      };

      if (criteriaType === 1) {
        // Type 1: Quantitative - Calculate preliminary score on frontend
        payload.targetValue = data.targetValue;
        payload.actualValue = data.actualValue;
        
        // Calculate preliminary score using frontend logic
        const A = data.actualValue || 0;
        const T = data.targetValue || 0;
        const MS = selectedCriteria.maxScore;
        let preliminaryScore = 0;
        
        if (T > 0 && A >= 0) {
          // Unit has target - use standard formulas
          if (A < T) {
            // Formula 1: A < T → Score = 0.5 × MS × (A/T)
            preliminaryScore = 0.5 * MS * (A / T);
          } else if (A === T) {
            // Formula 2: A = T → Score = 0.5 × MS
            preliminaryScore = 0.5 * MS;
          } else {
            // Formula 3: A > T → Score = MS
            preliminaryScore = MS;
          }
        } else if (T === 0 && A > 0) {
          // Unit has NO target but has actual result
          // Temporarily give full score (MS) to encourage effort
          // Will be recalculated accurately during "Tính lại điểm cụm" 
          // based on ratio to highest actual in no-target group
          preliminaryScore = MS;
        }
        
        // Round to 2 decimal places
        payload.selfScore = Math.round(preliminaryScore * 100) / 100;
      } else if (criteriaType === 2) {
        // Type 2: Qualitative  
        payload.selfScore = data.achieved ? selectedCriteria.maxScore : 0;
      } else if (criteriaType === 3 || criteriaType === 4) {
        // Type 3/4: Direct score
        payload.selfScore = data.score;
      }

      // Call new API
      const res = await apiRequest("POST", "/api/criteria-results", payload);
      const responseData = await res.json();
      console.log('[SAVE SCORE] Response:', responseData);

      // Refresh data and wait for it to complete
      await queryClient.invalidateQueries({
        queryKey: ["/api/evaluation-periods", selectedPeriod.id, "units", selectedUnitId, "summary"],
      });

      // Force refetch to ensure data is updated immediately
      await queryClient.refetchQueries({
        queryKey: ["/api/evaluation-periods", selectedPeriod.id, "units", selectedUnitId, "summary"],
      });

      toast({ title: "Thành công", description: "Đã lưu điểm thành công" });
      setScoringModalOpen(false);
    } catch (error: any) {
      toast({
        title: "Lỗi",
        description: error.message || "Không thể lưu điểm",
        variant: "destructive",
      });
    }
  };

  // Mutation for saving review scores
  const saveReviewMutation = useMutation({
    mutationFn: async ({
      score,
      comment,
      file,
      criteriaId,
      reviewType,
      existingFileUrl,
    }: {
      score: number;
      comment: string;
      file: File | null;
      criteriaId: string;
      reviewType: "review1" | "review2";
      existingFileUrl?: string | null;
    }) => {
      let fileUrl: string | undefined = existingFileUrl || undefined; // Preserve existing file

      // Upload file if provided (overwrites existing)
      if (file) {
        console.log(
          "[REVIEW SAVE] Uploading file:",
          file.name,
          "size:",
          file.size,
        );
        const formData = new FormData();
        formData.append("file", file);

        const uploadRes = await fetch("/api/upload", {
          method: "POST",
          body: formData,
          credentials: "include",
        });

        if (!uploadRes.ok) {
          console.error(
            "[REVIEW SAVE] Upload failed:",
            uploadRes.status,
            uploadRes.statusText,
          );
          throw new Error("Upload file thất bại");
        }

        const uploadData = await uploadRes.json();
        fileUrl = uploadData.fileUrl;
        console.log("[REVIEW SAVE] Upload successful, fileUrl:", fileUrl);
      } else {
        console.log("[REVIEW SAVE] No new file, preserving existing:", fileUrl);
      }

      // Capture current periodId and unitId for invalidation
      const currentPeriodId = selectedPeriod?.id;
      const currentUnitId = selectedUnitId;

      // Ensure evaluation exists (create if needed)
      let evaluationId = summary?.evaluation?.id;
      if (!evaluationId) {
        console.log(
          "[REVIEW SAVE] No evaluation found, creating one via ensure endpoint",
        );
        const ensureRes = await apiRequest("POST", "/api/evaluations/ensure", {
          periodId: currentPeriodId,
          unitId: currentUnitId,
        });
        const ensureData = await ensureRes.json();
        evaluationId = ensureData.id;
        console.log("[REVIEW SAVE] Evaluation ensured, id:", evaluationId);
      }

      // Build score data based on review type
      const scoreData: any = {
        criteriaId,
      };

      if (reviewType === "review1") {
        scoreData.review1Score = score;
        scoreData.review1Comment = comment;
        if (fileUrl) {
          scoreData.review1File = fileUrl;
        }
      } else {
        scoreData.review2Score = score;
        scoreData.review2Comment = comment;
        if (fileUrl) {
          scoreData.review2File = fileUrl;
        }
      }

      console.log("[REVIEW SAVE] Sending scores update:", [scoreData]);
      const res = await apiRequest(
        "PUT",
        `/api/evaluations/${evaluationId}/scores`,
        { scores: [scoreData] },
      );
      const result = await res.json();
      console.log("[REVIEW SAVE] Update successful, result:", result);

      // Return captured IDs for invalidation
      return { result, periodId: currentPeriodId, unitId: currentUnitId };
    },
    onSuccess: (data) => {
      console.log(
        "[REVIEW SAVE] onSuccess called, invalidating cache for:",
        data.periodId,
        data.unitId,
      );
      // Invalidate using captured IDs to ensure correct query is invalidated
      queryClient.invalidateQueries({
        queryKey: [
          "/api/evaluation-periods",
          data.periodId,
          "units",
          data.unitId,
          "summary",
        ],
      });
      toast({
        title: "Thành công",
        description: "Đã lưu điểm thẩm định thành công",
      });
      setReviewModalOpen(false);
      setQualitativeReviewModalOpen(false);
    },
    onError: (error: any) => {
      toast({
        title: "Lỗi",
        description: error.message || "Không thể lưu điểm thẩm định",
        variant: "destructive",
      });
    },
  });

  const handleSaveReview = (
    score: number,
    comment: string,
    file: File | null,
  ) => {
    if (!selectedCriteria) return;

    // Determine existing file URL based on review type
    const existingFileUrl =
      reviewType === "review1"
        ? selectedCriteria.review1File
        : selectedCriteria.review2File;

    saveReviewMutation.mutate({
      score,
      comment,
      file,
      criteriaId: selectedCriteria.id,
      reviewType,
      existingFileUrl,
    });
  };

  // Mutation for saving qualitative review scores to criteria_results table
  const saveQualitativeReviewMutation = useMutation({
    mutationFn: async ({
      score,
      comment,
      criteriaId,
      reviewType,
    }: {
      score: number;
      comment: string;
      criteriaId: string;
      reviewType: "review1" | "review2";
    }) => {
      const currentPeriodId = selectedPeriod?.id;
      const currentUnitId = selectedUnitId;

      if (!currentPeriodId || !currentUnitId) {
        throw new Error("Thiếu thông tin kỳ thi đua hoặc đơn vị");
      }

      console.log("[QUALITATIVE REVIEW] Calling /api/criteria-results/review:", {
        criteriaId,
        unitId: currentUnitId,
        periodId: currentPeriodId,
        reviewType,
        score,
        comment,
      });

      const res = await apiRequest(
        "PUT",
        "/api/criteria-results/review",
        {
          criteriaId,
          unitId: currentUnitId,
          periodId: currentPeriodId,
          reviewType,
          score,
          comment,
        },
      );
      const result = await res.json();
      console.log("[QUALITATIVE REVIEW] Save successful, result:", result);

      return { result, periodId: currentPeriodId, unitId: currentUnitId };
    },
    onSuccess: (data) => {
      console.log(
        "[QUALITATIVE REVIEW] onSuccess, invalidating cache for:",
        data.periodId,
        data.unitId,
      );
      queryClient.invalidateQueries({
        queryKey: [
          "/api/evaluation-periods",
          data.periodId,
          "units",
          data.unitId,
          "summary",
        ],
      });
      toast({
        title: "Thành công",
        description: "Đã lưu điểm thẩm định thành công",
      });
      setQualitativeReviewModalOpen(false);
    },
    onError: (error: any) => {
      toast({
        title: "Lỗi",
        description: error.message || "Không thể lưu điểm thẩm định",
        variant: "destructive",
      });
    },
  });

  // Handler for qualitative review (no file upload)
  const handleSaveQualitativeReview = (score: number, comment: string) => {
    if (!selectedCriteria) return;

    console.log("[QUALITATIVE REVIEW] Saving:", {
      criteriaId: selectedCriteria.id,
      criteriaName: selectedCriteria.name,
      score,
      comment,
      reviewType,
    });

    saveQualitativeReviewMutation.mutate({
      score,
      comment,
      criteriaId: selectedCriteria.id,
      reviewType,
    });
  };

  // Mutation for submitting evaluation
  const handleSaveExplanation = async (data: {
    comment: string;
    file?: string;
  }) => {
    // TODO: Implement explanation save logic
    console.log("Explanation saved:", data);
    setExplanationModalOpen(false);
    toast({
      title: "Thành công",
      description: "Lưu giải trình thành công",
    });
  };

  const submitEvaluationMutation = useMutation({
    mutationFn: async () => {
      // Validate context
      const currentPeriodId = selectedPeriod?.id;
      const currentUnitId = selectedUnitId;

      if (!currentPeriodId || !currentUnitId) {
        throw new Error("Thiếu thông tin kỳ thi đua hoặc đơn vị.");
      }

      // Ensure evaluation exists (create if needed)
      let evaluationId = summary?.evaluation?.id;
      if (!evaluationId) {
        console.log(
          "[SUBMIT] No evaluation found, creating one via ensure endpoint",
        );
        const ensureRes = await apiRequest("POST", "/api/evaluations/ensure", {
          periodId: currentPeriodId,
          unitId: currentUnitId,
        });
        const ensureData = await ensureRes.json();
        evaluationId = ensureData.id;
        console.log("[SUBMIT] Evaluation ensured, id:", evaluationId);
      }

      // apiRequest will throw on non-2xx, so we can safely await the response
      const res = await apiRequest(
        "POST",
        `/api/evaluations/${evaluationId}/submit`,
        {},
      );

      // If we get here, response is 2xx, safe to parse
      if (!res.ok) {
        throw new Error("Không thể nộp bài. Vui lòng thử lại.");
      }

      const result = await res.json();

      return { result, periodId: currentPeriodId, unitId: currentUnitId };
    },
    onSuccess: async (data) => {
      // Step 1: Recalculate scores for the cluster
      try {
        console.log("[SUBMIT] Recalculating scores for cluster after submission");
        const unit = await fetch(`/api/units/${data.unitId}`, { credentials: "include" }).then(r => r.json());
        
        if (unit && unit.clusterId) {
          const recalcRes = await apiRequest("POST", "/api/criteria-results/recalculate", {
            periodId: data.periodId,
            clusterId: unit.clusterId,
          });
          
          if (recalcRes.ok) {
            console.log("[SUBMIT] Scores recalculated successfully");
            
            // Step 2: Copy calculatedScore to review1Score and review2Score
            // This is done on the server side - just need to refresh data
          }
        }
      } catch (error) {
        console.error("[SUBMIT] Error recalculating scores:", error);
        // Don't block the submission success, just log the error
      }
      
      // Step 3: Invalidate and refetch to show updated scores
      queryClient.invalidateQueries({
        queryKey: [
          "/api/evaluation-periods",
          data.periodId,
          "units",
          data.unitId,
          "summary",
        ],
      });
      
      await queryClient.refetchQueries({
        queryKey: [
          "/api/evaluation-periods",
          data.periodId,
          "units",
          data.unitId,
          "summary",
        ],
      });
      
      toast({
        title: "Thành công",
        description: "Đã nộp bài thành công. Điểm đã được tính lại và cập nhật.",
      });
      setSubmitDialogOpen(false);
    },
    onError: (error: any) => {
      toast({
        title: "Lỗi",
        description: error.message || "Không thể nộp bài",
        variant: "destructive",
      });
      setSubmitDialogOpen(false);
    },
  });

  const handleSubmitEvaluation = () => {
    submitEvaluationMutation.mutate();
  };

  // Mutation for batch recalculating scores
  const recalculateScoresMutation = useMutation({
    mutationFn: async () => {
      const currentPeriodId = selectedPeriod?.id;
      const currentClusterId = selectedClusterId;

      console.log("[RECALCULATE] Starting recalculation", { currentPeriodId, currentClusterId });

      if (!currentPeriodId) {
        throw new Error("Vui lòng chọn kỳ thi đua");
      }

      if (!currentClusterId) {
        throw new Error("Vui lòng chọn cụm thi đua");
      }

      const res = await apiRequest("POST", "/api/criteria-results/recalculate", {
        periodId: currentPeriodId,
        clusterId: currentClusterId,
      });
      return await res.json();
    },
    onSuccess: async (data) => {
      console.log("[RECALCULATE] Success", data);
      
      // Refetch data immediately to show updated scores
      console.log("[RECALCULATE] Refetching data...");
      
      // 1. Refetch general units query
      await queryClient.refetchQueries({
        queryKey: ["/api/evaluation-periods", selectedPeriod?.id, "units"],
      });
      
      // 2. Refetch specific summary for current unit
      if (selectedUnitId) {
        await queryClient.refetchQueries({
          queryKey: [
            "/api/evaluation-periods",
            selectedPeriod?.id,
            "units",
            selectedUnitId,
            "summary",
          ],
        });
      }
      
      console.log("[RECALCULATE] Data refetched successfully");
      
      toast({
        title: "Thành công",
        description: data.message || "Đã tính lại điểm thành công. Dữ liệu đã được cập nhật.",
      });
    },
    onError: (error: any) => {
      console.error("[RECALCULATE] Error", error);
      toast({
        title: "Lỗi",
        description: error.message || "Không thể tính lại điểm",
        variant: "destructive",
      });
    },
  });

  const handleRecalculateScores = () => {
    recalculateScoresMutation.mutate();
  };

  // Helper: Get display score (ONLY from selfScore for self-scoring column)
  const getDisplayScore = (item: Criteria): number => {
    // Only use selfScore for display in "Điểm tự chấm" column
    if (item.selfScore != null && !isNaN(Number(item.selfScore))) {
      return Number(item.selfScore);
    }
    return 0;
  };

  // Calculate group totals - only sum items with code (scoring items, not parent containers)
  const calculateGroupTotal = (items: Criteria[], field: keyof Criteria) => {
    if (items.length === 0) return 0;

    // Special handling for selfScore - use display score logic
    if (field === "selfScore") {
      return items
        .filter((item) => item.code?.trim())
        .reduce((sum, item) => sum + getDisplayScore(item), 0);
    }

    // Only sum items that have a code (these are the actual scoring criteria)
    // Parent items without codes are just containers and shouldn't be counted
    return items
      .filter((item) => item.code?.trim())
      .reduce((sum, item) => {
        const value = item[field];
        return sum + (typeof value === "number" ? value : 0);
      }, 0);
  };

  // Calculate overall totals
  const calculateOverallTotal = (field: keyof Criteria) => {
    if (!summary?.criteriaGroups) return 0;
    
    // Đối với maxScore: CHỈ tính tiêu chí gốc (parentId = null)
    if (field === "maxScore") {
      let total = 0;
      summary.criteriaGroups.forEach((group) => {
        // Chỉ lấy tiêu chí có parentId = null (tiêu chí gốc nhất)
        const rootCriteria = group.criteria.find(c => !c.parentId || c.parentId === null);
        if (rootCriteria) {
          const value = rootCriteria[field] as number || 0;
          total += value;
        }
      });
      return total;
    }
    
    // Các cột điểm khác: tính tổng tất cả như cũ
    return (
      summary.criteriaGroups.reduce((sum, group) => {
        return sum + calculateGroupTotal(group.criteria, field);
      }, 0) || 0
    );
  };

  // Calculate total assigned maxScore (excluding criteria with no target)
  const calculateAssignedMaxScore = () => {
    if (!summary?.criteriaGroups) return { totalMax: 0, assignedMax: 0 };
    
    let totalMax = 0;
    let notAssignedTotal = 0;
    
    summary.criteriaGroups.forEach((group) => {
      const rootCriteria = group.criteria.find(c => !c.parentId || c.parentId === null);
      if (!rootCriteria) return;
      
      const maxScore = rootCriteria.maxScore as number || 0;
      totalMax += maxScore;
      
      // Check ALL leaf criteria in this group for "no target" status
      // A leaf criteria is one with criteriaType 1-4 (not 0 which is parent)
      group.criteria.forEach((criteria) => {
        // Only check leaf criteria (criteriaType 1-4)
        if (criteria.criteriaType && criteria.criteriaType >= 1 && criteria.criteriaType <= 4) {
          const hasTarget = criteria.targetValue !== null && criteria.targetValue !== undefined;
          const hasActual = criteria.actualValue !== null && criteria.actualValue !== undefined;
          const isNoTargetButHasResult = hasTarget && criteria.targetValue === 0 && hasActual && Number(criteria.actualValue) > 0;
          
          // If it's a "no target" case, add to notAssignedTotal
          if (isNoTargetButHasResult) {
            const criteriaMaxScore = criteria.maxScore as number || 0;
            notAssignedTotal += criteriaMaxScore;
          }
        }
      });
    });
    
    return {
      totalMax,
      assignedMax: totalMax - notAssignedTotal,
    };
  };

  // Helper: Calculate sum of children's scores (only leaf nodes to avoid double counting)
  // A parent node has criteriaType = 0, leaf nodes have criteriaType = 1-4
  // Uses parentId to identify direct and indirect children, with fallback to level-based calculation
  const calculateChildrenTotal = (item: Criteria, allItems: Criteria[], currentIndex: number, field: keyof Criteria) => {
    let total = 0;
    
    // Find all descendants (direct and indirect children) by checking parentId chain
    const isDescendantOf = (criteria: Criteria, ancestorId: string, allCriteria: Criteria[]): boolean => {
      if (!criteria.parentId) return false;
      if (criteria.parentId === ancestorId) return true;
      
      // Check if parent is descendant of ancestor (recursive)
      const parent = allCriteria.find(c => c.id === criteria.parentId);
      if (!parent) return false;
      return isDescendantOf(parent, ancestorId, allCriteria);
    };
    
    // Check if a node is a leaf (has no children)
    const isLeafNode = (nodeId: string, allCriteria: Criteria[]): boolean => {
      return !allCriteria.some(c => c.parentId === nodeId);
    };
    
    // Method 1: Try using parentId (most accurate) - only sum leaf nodes
    let foundByParentId = false;
    allItems.forEach((criteria) => {
      // Check if this criteria is a descendant of current item
      if (criteria.parentId === item.id || isDescendantOf(criteria, item.id, allItems)) {
        foundByParentId = true;
        
        // Only count LEAF nodes (nodes with no children) to avoid double counting
        if (isLeafNode(criteria.id, allItems)) {
          const scoreToAdd = field === 'selfScore' ? getDisplayScore(criteria) : (criteria[field] as number || 0);
          if (typeof scoreToAdd === 'number' && scoreToAdd > 0) {
            total += scoreToAdd;
          }
        }
      }
    });
    
    // Method 2: Fallback to level-based calculation if no children found by parentId
    if (!foundByParentId || total === 0) {
      const currentLevel = item.level || 1;
      let inChildrenRange = false;
      
      for (let i = currentIndex + 1; i < allItems.length; i++) {
        const nextItem = allItems[i];
        const nextLevel = nextItem.level || 1;
        
        // If next level is greater, we're in children range
        if (nextLevel > currentLevel) {
          inChildrenRange = true;
          
          // Only count leaf nodes
          if (isLeafNode(nextItem.id, allItems)) {
            const scoreToAdd = field === 'selfScore' ? getDisplayScore(nextItem) : (nextItem[field] as number || 0);
            if (typeof scoreToAdd === 'number' && scoreToAdd > 0) {
              total += scoreToAdd;
            }
          }
        } else if (nextLevel <= currentLevel) {
          // Back to same or lower level - exit children range
          if (inChildrenRange) {
            break;
          }
        }
      }
    }
    
    return total;
  };

  // Format criteria name with result info for Type 1 (Quantitative) and Type 2 (Qualitative)
  const formatCriteriaNameWithResult = (item: Criteria): JSX.Element => {
    const baseName = item.name;
    
    // Only add result info for leaf nodes (criteriaType 1-4)
    if (item.criteriaType === 0) {
      return <span>{baseName}</span>;
    }
    
    // Type 1: Định lượng (Quantitative)
    if (item.criteriaType === 1 && (item.targetValue !== undefined || item.actualValue !== undefined)) {
      const hasTarget = item.targetValue !== undefined && item.targetValue !== null && item.targetValue > 0;
      const hasActual = item.actualValue !== undefined && item.actualValue !== null;
      
      const T = hasTarget ? item.targetValue : '?';
      const A = hasActual ? item.actualValue : '?';
      
      // Đơn vị KHÔNG được giao chỉ tiêu: T=0 hoặc null nhưng CÓ kết quả
      const isNoTargetButHasResult = !hasTarget && hasActual && Number(item.actualValue) > 0;
      
      return (
        <span>
          {baseName}
          {(T !== '?' || A !== '?') && (
            <span className="text-xs text-muted-foreground ml-2">
              (T: {T}, A: {A})
              {isNoTargetButHasResult && (
                <span className="ml-1 inline-flex items-center px-1.5 py-0.5 rounded text-xs font-medium bg-blue-100 text-blue-800 border border-blue-200">
                  Không giao CT
                </span>
              )}
            </span>
          )}
        </span>
      );
    }
    
    // Type 2: Định tính (Qualitative)
    if (item.criteriaType === 2 && item.selfScore !== undefined && item.selfScore !== null) {
      const achieved = Number(item.selfScore) > 0;
      return (
        <span>
          {baseName}
          <span className={`text-xs ml-2 ${achieved ? 'text-green-600' : 'text-gray-500'}`}>
            ({achieved ? 'Đạt' : 'Chưa đạt'})
          </span>
        </span>
      );
    }
    
    // Type 3, 4 or no data: Just show name
    return <span>{baseName}</span>;
  };

  // Render permission check
  const canReview1 = user?.role === "admin" || user?.role === "cluster_leader";
  const canReview2 = user?.role === "admin";

  if (!user) {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold">Kỳ thi đua</h1>
          <p className="text-muted-foreground mt-1">Đang tải...</p>
        </div>
      </div>
    );
  }

  const handleExportResults = async () => {
    if (!summary?.evaluation?.id) {
      alert("Vui lòng chọn đơn vị để xuất kết quả");
      return;
    }

    try {
      const response = await fetch(
        `/api/evaluations/${summary.evaluation.id}/export`,
        { credentials: "include" }
      );

      if (!response.ok) {
        throw new Error("Không thể xuất file Excel");
      }

      // Get filename from Content-Disposition header
      const contentDisposition = response.headers.get("Content-Disposition");
      let filename = "KetQua.xlsx";
      if (contentDisposition) {
        const filenameMatch = contentDisposition.match(/filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/);
        if (filenameMatch && filenameMatch[1]) {
          filename = decodeURIComponent(filenameMatch[1].replace(/['"]/g, ""));
        }
      }

      // Download file
      const blob = await response.blob();
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = filename;
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      document.body.removeChild(a);
    } catch (error) {
      alert("Không thể xuất file Excel. Vui lòng thử lại.");
      console.error(error);
    }
  };

  const handlePrint = () => {
    if (!summary?.evaluation?.id) {
      alert("Vui lòng chọn đơn vị để in báo cáo");
      return;
    }

    window.print();
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Kỳ thi đua</h1>
        <p className="text-muted-foreground mt-1">
          Xem và quản lý điểm thi đua theo kỳ
        </p>
      </div>

      <div className="flex flex-wrap gap-4 p-4 bg-card border rounded-md">
        {/* Kỳ thi đua */}
        <div className="flex-1 min-w-[200px]">
          <Label
            htmlFor="filter-period"
            className="text-xs font-semibold uppercase tracking-wide mb-2 block"
          >
            Kỳ thi đua
          </Label>
          {loadingPeriods ? (
            <Skeleton className="h-10 w-full" />
          ) : periods.length > 0 ? (
            <Select
              value={selectedPeriodId}
              onValueChange={handlePeriodChange}
            >
              <SelectTrigger id="filter-period" data-testid="select-period">
                <SelectValue placeholder="Chọn kỳ thi đua" />
              </SelectTrigger>
              <SelectContent>
                {periods.map((period) => (
                  <SelectItem key={period.id} value={period.id}>
                    {period.name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          ) : (
            <div className="h-10 px-3 py-2 border rounded-md bg-muted text-sm text-muted-foreground">
              Chưa có kỳ thi đua
            </div>
          )}
        </div>

        {/* Cụm thi đua */}
        <div className="flex-1 min-w-[200px]">
          <Label
            htmlFor="filter-cluster"
            className="text-xs font-semibold uppercase tracking-wide mb-2 block"
          >
            Cụm thi đua
          </Label>
          {loadingClusters ? (
            <Skeleton className="h-10 w-full" />
          ) : user.role === "admin" ? (
            <Select
              value={selectedClusterId}
              onValueChange={handleClusterChange}
            >
              <SelectTrigger id="filter-cluster" data-testid="select-cluster">
                <SelectValue placeholder="Chọn cụm" />
              </SelectTrigger>
              <SelectContent>
                {clusters?.map((cluster) => (
                  <SelectItem key={cluster.id} value={cluster.id}>
                    {cluster.name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          ) : (
            <div
              className="h-10 px-3 py-2 border rounded-md bg-muted text-sm"
              data-testid="text-cluster"
            >
              {clusters?.find((c) => c.id === selectedClusterId)?.name ||
                "Chưa có cụm"}
            </div>
          )}
        </div>

        {/* Đơn vị */}
        <div className="flex-1 min-w-[200px]">
          <Label
            htmlFor="filter-unit"
            className="text-xs font-semibold uppercase tracking-wide mb-2 block"
          >
            Đơn vị
          </Label>
          {loadingUnits ? (
            <Skeleton className="h-10 w-full" />
          ) : user.role === "user" ? (
            <div
              className="h-10 px-3 py-2 border rounded-md bg-muted text-sm"
              data-testid="text-unit"
            >
              {units?.find((u) => u.id === selectedUnitId)?.name ||
                "Chưa có đơn vị"}
            </div>
          ) : (
            <Select value={selectedUnitId} onValueChange={handleUnitChange}>
              <SelectTrigger id="filter-unit" data-testid="select-unit">
                <SelectValue placeholder="Chọn đơn vị" />
              </SelectTrigger>
              <SelectContent>
                {filteredUnits.map((unit) => (
                  <SelectItem key={unit.id} value={unit.id}>
                    {unit.name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          )}
        </div>
      </div>

      {periodsError && (
        <Alert variant="destructive">
          <AlertDescription className="flex items-center justify-between">
            <span>Không thể tải danh sách kỳ thi đua. Vui lòng thử lại.</span>
            <Button
              variant="outline"
              size="sm"
              onClick={() => refetchPeriods()}
              data-testid="button-retry-periods"
            >
              <RefreshCw className="w-4 h-4 mr-2" />
              Thử lại
            </Button>
          </AlertDescription>
        </Alert>
      )}

      {summaryError && selectedPeriod && (
        <Alert variant="destructive">
          <AlertDescription className="flex items-center justify-between">
            <span>Không thể tải dữ liệu thi đua. Vui lòng thử lại.</span>
            <Button
              variant="outline"
              size="sm"
              onClick={() => refetchSummary()}
              data-testid="button-retry-summary"
            >
              <RefreshCw className="w-4 h-4 mr-2" />
              Thử lại
            </Button>
          </AlertDescription>
        </Alert>
      )}

      {loadingPeriods || loadingSummary ? (
        <div className="space-y-4">
          <Skeleton className="h-[400px] w-full" />
        </div>
      ) : !selectedPeriod ? (
        <div className="border rounded-md p-8 text-center">
          <p className="text-muted-foreground">
            Vui lòng chọn kỳ thi đua để xem dữ liệu
          </p>
        </div>
      ) : !summary ? (
        <div className="border rounded-md p-8 text-center">
          <p className="text-muted-foreground">
            Không có dữ liệu thi đua cho kỳ này
          </p>
        </div>
      ) : (
        <>
          {/* Status and Action Strip */}
          {summary.evaluation && (
            <div className="flex items-center justify-between gap-4 p-4 bg-card border rounded-md mb-4">
              <div className="flex items-center gap-3">
                <span className="text-sm font-medium text-muted-foreground">
                  Trạng thái:
                </span>
                <Badge
                  variant={
                    summary.evaluation.status === "draft"
                      ? "secondary"
                      : summary.evaluation.status === "submitted"
                        ? "default"
                        : summary.evaluation.status === "review1_completed"
                          ? "default"
                          : summary.evaluation.status ===
                              "explanation_submitted"
                            ? "default"
                            : summary.evaluation.status === "review2_completed"
                              ? "default"
                              : summary.evaluation.status === "finalized"
                                ? "default"
                                : "secondary"
                  }
                  data-testid="badge-evaluation-status"
                >
                  {summary.evaluation.status === "draft"
                    ? "Nháp"
                    : summary.evaluation.status === "submitted"
                      ? "Đã nộp"
                      : summary.evaluation.status === "review1_completed"
                        ? "Đã thẩm định lần 1"
                        : summary.evaluation.status === "explanation_submitted"
                          ? "Đã giải trình"
                          : summary.evaluation.status === "review2_completed"
                            ? "Đã thẩm định lần 2"
                            : summary.evaluation.status === "finalized"
                              ? "Hoàn tất"
                              : summary.evaluation.status}
                </Badge>
              </div>

              {user.role === "user" &&
                summary.evaluation.status === "draft" &&
                selectedPeriod &&
                selectedUnitId && (
                  <Button
                    variant="default"
                    onClick={() => setSubmitDialogOpen(true)}
                    disabled={submitEvaluationMutation.isPending}
                    data-testid="button-submit-evaluation"
                  >
                    <Send className="w-4 h-4 mr-2" />
                    {submitEvaluationMutation.isPending
                      ? "Đang nộp..."
                      : "Nộp bài"}
                  </Button>
                )}
              
              {/* Batch recalculate button for admin and cluster_leader */}
              {(user.role === "admin" || user.role === "cluster_leader") &&
                selectedPeriod &&
                selectedClusterId && (
                  <Button
                    variant="outline"
                    onClick={handleRecalculateScores}
                    disabled={recalculateScoresMutation.isPending}
                    data-testid="button-recalculate-scores"
                  >
                    <RefreshCw className={`w-4 h-4 mr-2 ${recalculateScoresMutation.isPending ? 'animate-spin' : ''}`} />
                    {recalculateScoresMutation.isPending
                      ? "Đang tính..."
                      : "Tính lại điểm cụm"}
                  </Button>
                )}
            </div>
          )}

          {/* Disable scoring info when not in draft */}
          {summary.evaluation &&
            summary.evaluation.status !== "draft" &&
            user.role === "user" && (
              <Alert className="mb-4">
                <AlertDescription>
                  Đánh giá đã được nộp. Bạn không thể chỉnh sửa điểm tự chấm.
                </AlertDescription>
              </Alert>
            )}

          {/* Export and Print Actions */}
          <div className="flex gap-2 mb-3">
            <Tooltip>
              <TooltipTrigger asChild>
                <Button
                  size="icon"
                  variant="outline"
                  data-testid="button-export-results"
                  onClick={handleExportResults}
                  disabled={!summary?.evaluation?.id}
                >
                  <FileSpreadsheet className="w-4 h-4" />
                </Button>
              </TooltipTrigger>
              <TooltipContent>
                <p>Xuất Excel kết quả</p>
              </TooltipContent>
            </Tooltip>

            <Tooltip>
              <TooltipTrigger asChild>
                <Button
                  size="icon"
                  variant="outline"
                  data-testid="button-print"
                  onClick={handlePrint}
                  disabled={!summary?.evaluation?.id}
                >
                  <Printer className="w-4 h-4" />
                </Button>
              </TooltipTrigger>
              <TooltipContent>
                <p>In báo cáo</p>
              </TooltipContent>
            </Tooltip>
          </div>

          <div className="border rounded-md overflow-hidden">
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="sticky top-0 bg-muted">
                  <tr className="border-b">
                    <th
                      className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide w-12"
                      rowSpan={2}
                    >
                      STT
                    </th>
                    <th
                      className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide min-w-[300px]"
                      rowSpan={2}
                    >
                      Tên tiêu chí
                    </th>
                    <th
                      className="px-4 py-3 text-center text-xs font-semibold uppercase tracking-wide w-24"
                      rowSpan={2}
                    >
                      Điểm tối đa
                    </th>
                    <th
                      className="px-4 py-3 text-center text-xs font-semibold uppercase tracking-wide border-l"
                      colSpan={2}
                    >
                      Điểm tự chấm
                    </th>
                    <th
                      className="px-4 py-3 text-center text-xs font-semibold uppercase tracking-wide border-l"
                      colSpan={2}
                    >
                      Thẩm định lần 1
                    </th>
                    <th
                      className="px-4 py-3 text-center text-xs font-semibold uppercase tracking-wide w-40 border-l"
                      rowSpan={2}
                    >
                      Giải trình
                    </th>
                    <th
                      className="px-4 py-3 text-center text-xs font-semibold uppercase tracking-wide w-32 border-l"
                      rowSpan={2}
                    >
                      Thẩm định lần 2
                    </th>
                  </tr>
                  <tr className="border-b">
                    <th className="px-4 py-2 text-center text-xs font-semibold uppercase tracking-wide w-24 border-l">
                      Điểm
                    </th>
                    <th className="px-4 py-2 text-center text-xs font-semibold uppercase tracking-wide w-24">
                      File
                    </th>
                    <th className="px-4 py-2 text-center text-xs font-semibold uppercase tracking-wide w-24 border-l">
                      Điểm
                    </th>
                    <th className="px-4 py-2 text-center text-xs font-semibold uppercase tracking-wide w-40">
                      Nhận xét
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {summary.criteriaGroups.map((group, groupIndex) => {
                    const groupTotals = {
                      maxScore: calculateGroupTotal(group.criteria, "maxScore"),
                      selfScore: calculateGroupTotal(
                        group.criteria,
                        "selfScore",
                      ),
                      review1Score: calculateGroupTotal(
                        group.criteria,
                        "review1Score",
                      ),
                      review2Score: calculateGroupTotal(
                        group.criteria,
                        "review2Score",
                      ),
                      finalScore: calculateGroupTotal(
                        group.criteria,
                        "finalScore",
                      ),
                    };

                    // Get filtered criteria list for this group
                    const filteredCriteria = group.criteria.filter((item) => item.code?.trim());

                    return (
                      <Fragment key={group.id}>
                        {filteredCriteria.map((item, itemIndex) => {
                            // Calculate indent based on level (level 1 = no indent, level 2 = 1rem, level 3 = 2rem, etc.)
                            const indentLevel = (item.level || 1) - 1;
                            const indentPx = 8 + indentLevel * 24; // Base 8px + 24px per level

                            // Check if this item is a parent node (criteriaType = 0) or leaf node (criteriaType = 1-4)
                            const isParentNode = item.criteriaType === 0;
                            
                            // If it's a parent, calculate sum of children's scores for all columns
                            const childrenSelfScoreTotal = isParentNode 
                              ? calculateChildrenTotal(item, filteredCriteria, itemIndex, 'selfScore')
                              : 0;
                            const childrenReview1ScoreTotal = isParentNode 
                              ? calculateChildrenTotal(item, filteredCriteria, itemIndex, 'review1Score')
                              : 0;
                            const childrenReview2ScoreTotal = isParentNode 
                              ? calculateChildrenTotal(item, filteredCriteria, itemIndex, 'review2Score')
                              : 0;
                            const childrenFinalScoreTotal = isParentNode 
                              ? calculateChildrenTotal(item, filteredCriteria, itemIndex, 'finalScore')
                              : 0;

                            return (
                              <tr
                                key={item.id}
                                className="border-b hover-elevate"
                                data-testid={`row-criteria-${item.id}`}
                              >
                                <td className="px-4 py-3 text-sm text-center">
                                  {item.code ||
                                    `${groupIndex + 1}.${itemIndex + 1}`}
                                </td>
                                <td
                                  className="px-4 py-3 text-sm"
                                  style={{ paddingLeft: `${indentPx}px` }}
                                >
                                  <span
                                    className={
                                      indentLevel > 0
                                        ? "text-muted-foreground"
                                        : "font-medium"
                                    }
                                  >
                                    {formatCriteriaNameWithResult(item)}
                                  </span>
                                </td>
                                <td
                                  className="px-4 py-3 text-sm text-center font-medium"
                                  data-testid={`text-maxscore-${item.id}`}
                                >
                                  {item.maxScore}
                                </td>
                                <td className="px-4 py-3 text-center border-l">
                                  {isParentNode ? (
                                    // Parent node (criteriaType = 0) - show sum of children's scores (read-only)
                                    <span
                                      className="font-medium text-sm text-muted-foreground"
                                      data-testid={`text-selfscore-total-${item.id}`}
                                    >
                                      {childrenSelfScoreTotal > 0 ? childrenSelfScoreTotal.toFixed(2) : '-'}
                                    </span>
                                  ) : user.role === "user" &&
                                    summary.evaluation?.status === "draft" &&
                                    selectedPeriod &&
                                    selectedUnitId ? (
                                    // Leaf node (criteriaType 1-4) - show scoring button
                                    <Button
                                      variant="ghost"
                                      size="sm"
                                      onClick={() =>
                                        handleOpenScoringModal(item)
                                      }
                                      className={`font-medium text-sm ${
                                        (item.calculatedScore != null && !isNaN(Number(item.calculatedScore))) ||
                                        (item.selfScore != null && !isNaN(Number(item.selfScore)))
                                          ? 'text-primary hover:text-primary/80'
                                          : ''
                                      }`}
                                      data-testid={`button-selfscore-${item.id}`}
                                    >
                                      {/* Display only selfScore */}
                                      {item.selfScore != null &&
                                      !isNaN(Number(item.selfScore))
                                        ? Number(item.selfScore).toFixed(2)
                                        : "Chấm điểm"}
                                    </Button>
                                  ) : (
                                    // Read-only view for non-draft or non-user roles
                                    <span
                                      className="font-medium text-sm"
                                      data-testid={`text-selfscore-${item.id}`}
                                    >
                                      {/* Display only selfScore */}
                                      {item.selfScore != null &&
                                      !isNaN(Number(item.selfScore))
                                        ? Number(item.selfScore).toFixed(2)
                                        : "-"}
                                    </span>
                                  )}
                                </td>
                                <td className="px-4 py-3 text-center">
                                  {/* Prioritize evidenceFile (new), fallback to selfScoreFile (legacy) */}
                                  {(item.evidenceFile || item.selfScoreFile) ? (
                                    <a
                                      href={item.evidenceFile || item.selfScoreFile}
                                      target="_blank"
                                      rel="noopener noreferrer"
                                      className="inline-flex items-center justify-center h-8 w-8 rounded-md hover:bg-accent transition-colors"
                                      title="Xem file minh chứng"
                                      data-testid={`button-view-self-file-${item.id}`}
                                    >
                                      <FileText className="w-4 h-4 text-primary" />
                                    </a>
                                  ) : (
                                    <span className="text-xs text-muted-foreground">
                                      -
                                    </span>
                                  )}
                                </td>
                                <td className="px-4 py-3 text-center border-l">
                                  {isParentNode ? (
                                    // Parent node - show sum of children's review1 scores
                                    <span
                                      className="font-medium text-sm text-muted-foreground"
                                      data-testid={`text-review1-total-${item.id}`}
                                    >
                                      {childrenReview1ScoreTotal > 0 ? childrenReview1ScoreTotal.toFixed(2) : '-'}
                                    </span>
                                  ) : canReview1 && user.role === "cluster_leader" && 
                                       summary.evaluation?.status !== "draft" &&
                                       (item.selfScore !== null && item.selfScore !== undefined) ? (
                                    // Review permission: Show score if exists, otherwise show button
                                    item.review1Score != null && !isNaN(Number(item.review1Score)) ? (
                                      // Already reviewed - show score as clickable text (can re-review)
                                      <Button
                                        variant="ghost"
                                        size="sm"
                                        onClick={() => handleOpenReviewModal(item, "review1")}
                                        className="font-medium text-sm text-primary hover:text-primary/80"
                                        data-testid={`button-review1-edit-${item.id}`}
                                      >
                                        {Number(item.review1Score).toFixed(2)}
                                      </Button>
                                    ) : (
                                      // Not reviewed yet - show "Thẩm định" button
                                      <Button
                                        variant="outline"
                                        size="sm"
                                        onClick={() => handleOpenReviewModal(item, "review1")}
                                        className="font-medium text-sm"
                                        data-testid={`button-review1-${item.id}`}
                                      >
                                        Thẩm định
                                      </Button>
                                    )
                                  ) : (
                                    // No permission - show score or dash
                                    <span
                                      className="font-medium text-sm"
                                      data-testid={`text-review1-${item.id}`}
                                    >
                                      {item.review1Score != null &&
                                      !isNaN(Number(item.review1Score))
                                        ? Number(item.review1Score).toFixed(2)
                                        : "-"}
                                    </span>
                                  )}
                                </td>
                                <td className="px-4 py-3 text-center">
                                  <span
                                    className="text-sm text-muted-foreground"
                                    data-testid={`text-review1-comment-${item.id}`}
                                  >
                                    {item.review1Comment || "-"}
                                  </span>
                                </td>
                                <td className="px-4 py-3 text-center border-l">
                                  {isParentNode ? (
                                    <span className="text-xs text-muted-foreground">-</span>
                                  ) : (() => {
                                    // Chỉ hiển thị nút giải trình khi:
                                    // 1. Tiêu chí có type = 2, 3, hoặc 4
                                    // 2. Có nhận xét thẩm định HOẶC điểm tự chấm khác điểm thẩm định lần 1
                                    const isQualifiableType = item.criteriaType === 2 || item.criteriaType === 3 || item.criteriaType === 4;
                                    const hasReviewComment = item.review1Comment && item.review1Comment.trim() !== "";
                                    const scoresDiffer = item.selfScore != null && 
                                                        item.review1Score != null && 
                                                        Number(item.selfScore) !== Number(item.review1Score);
                                    
                                    const shouldShowExplanation = isQualifiableType && (hasReviewComment || scoresDiffer);
                                    
                                    return shouldShowExplanation ? (
                                      <Button
                                        variant="outline"
                                        size="sm"
                                        onClick={() => handleOpenExplanationModal(item)}
                                        className="text-xs"
                                        data-testid={`button-explanation-${item.id}`}
                                      >
                                        Giải trình
                                      </Button>
                                    ) : (
                                      <span className="text-xs text-muted-foreground">-</span>
                                    );
                                  })()}
                                </td>
                                <td className="px-4 py-3 text-center border-l">
                                  {isParentNode ? (
                                    // Parent node - show sum of children's review2 scores
                                    <span
                                      className="font-medium text-sm text-muted-foreground"
                                      data-testid={`text-review2-total-${item.id}`}
                                    >
                                      {childrenReview2ScoreTotal > 0 ? childrenReview2ScoreTotal.toFixed(2) : '-'}
                                    </span>
                                  ) : canReview2 && user.role === "admin" && 
                                       summary.evaluation?.status !== "draft" &&
                                       (item.selfScore !== null && item.selfScore !== undefined) ? (
                                    // Review permission: Show score if exists, otherwise show button
                                    item.review2Score != null && !isNaN(Number(item.review2Score)) ? (
                                      // Already reviewed - show score as clickable text (can re-review)
                                      <Button
                                        variant="ghost"
                                        size="sm"
                                        onClick={() => handleOpenReviewModal(item, "review2")}
                                        className="font-medium text-sm text-primary hover:text-primary/80"
                                        data-testid={`button-review2-edit-${item.id}`}
                                      >
                                        {Number(item.review2Score).toFixed(2)}
                                      </Button>
                                    ) : (
                                      // Not reviewed yet - show "Thẩm định" button
                                      <Button
                                        variant="outline"
                                        size="sm"
                                        onClick={() => handleOpenReviewModal(item, "review2")}
                                        className="font-medium text-sm"
                                        data-testid={`button-review2-${item.id}`}
                                      >
                                        Thẩm định
                                      </Button>
                                    )
                                  ) : (
                                    // No permission - show score or dash
                                    <span
                                      className="font-medium text-sm"
                                      data-testid={`text-review2-${item.id}`}
                                    >
                                      {item.review2Score != null &&
                                      !isNaN(Number(item.review2Score))
                                        ? Number(item.review2Score).toFixed(2)
                                        : "-"}
                                    </span>
                                  )}
                                </td>
                              </tr>
                            );
                          })}
                      </Fragment>
                    );
                  })}
                  <tr className="bg-muted font-bold">
                    <td colSpan={2} className="px-4 py-3 text-sm">
                      TỔNG CỘNG
                    </td>
                    <td className="px-4 py-3 text-sm text-center">
                      {(() => {
                        const { totalMax, assignedMax } = calculateAssignedMaxScore();
                        if (assignedMax < totalMax) {
                          return `${assignedMax.toFixed(1)}/${totalMax.toFixed(1)}`;
                        }
                        return totalMax.toFixed(1);
                      })()}
                    </td>
                    <td className="px-4 py-3 text-sm text-center border-l">
                      {calculateOverallTotal("selfScore").toFixed(2)}
                    </td>
                    <td className="px-4 py-3 text-sm text-center"></td>
                    <td className="px-4 py-3 text-sm text-center border-l">
                      {calculateOverallTotal("review1Score").toFixed(2)}
                    </td>
                    <td className="px-4 py-3 text-sm text-center"></td>
                    <td className="px-4 py-3 text-sm text-center border-l"></td>
                    <td className="px-4 py-3 text-sm text-center border-l">
                      {calculateOverallTotal("review2Score").toFixed(2)}
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
            
            {/* Chú thích các ký tự viết tắt */}
            <div className="mt-4 p-3 bg-muted/50 border rounded-md text-sm">
              <div className="font-semibold mb-2 text-foreground">Chú thích:</div>
              <div className="space-y-1 text-xs text-muted-foreground">
                <div><span className="font-medium text-foreground">T:</span> Chỉ tiêu (Target) - Chỉ tiêu được giao cho đơn vị (áp dụng cho tiêu chí định lượng)</div>
                <div><span className="font-medium text-foreground">A:</span> Thực hiện (Actual) - Kết quả thực tế đơn vị đạt được (áp dụng cho tiêu chí định lượng)</div>
                <div><span className="font-medium text-foreground">Đạt/Chưa đạt:</span> Trạng thái hoàn thành tiêu chí định tính</div>
                <div className="flex items-center gap-2">
                  <span className="inline-flex items-center px-1.5 py-0.5 rounded text-xs font-medium bg-blue-100 text-blue-800 border border-blue-200">
                    Không giao CT
                  </span>
                  <span>Đơn vị không được giao chỉ tiêu nhưng có kết quả. Điểm tính theo tỷ lệ so với đơn vị có kết quả cao nhất cùng nhóm (tối đa 100% điểm).</span>
                </div>
              </div>
            </div>
          </div>

          {/* Submit Confirmation Dialog */}
          <AlertDialog
            open={submitDialogOpen}
            onOpenChange={setSubmitDialogOpen}
          >
            <AlertDialogContent data-testid="dialog-submit-confirmation">
              <AlertDialogHeader>
                <AlertDialogTitle>Xác nhận nộp bài</AlertDialogTitle>
                <AlertDialogDescription>
                  Bạn có chắc chắn muốn nộp bài đánh giá không? Sau khi nộp, bạn
                  sẽ không thể chỉnh sửa điểm tự chấm cho đến khi có yêu cầu
                  giải trình.
                </AlertDialogDescription>
              </AlertDialogHeader>
              <AlertDialogFooter>
                <AlertDialogCancel data-testid="button-cancel-submit">
                  Hủy
                </AlertDialogCancel>
                <AlertDialogAction
                  onClick={handleSubmitEvaluation}
                  disabled={submitEvaluationMutation.isPending}
                  data-testid="button-confirm-submit"
                >
                  {submitEvaluationMutation.isPending
                    ? "Đang nộp..."
                    : "Xác nhận nộp"}
                </AlertDialogAction>
              </AlertDialogFooter>
            </AlertDialogContent>
          </AlertDialog>

          {selectedCriteria && (
            <>
              <ScoringModal
                open={scoringModalOpen}
                onClose={() => setScoringModalOpen(false)}
                criteriaName={selectedCriteria.name}
                maxScore={selectedCriteria.maxScore}
                criteriaType={selectedCriteria.criteriaType || 3} 
                currentScore={selectedCriteria.selfScore}
                currentFile={selectedCriteria.evidenceFileName || selectedCriteria.selfScoreFile}
                onSave={handleSaveScore}
              />
              <ReviewModal
                open={reviewModalOpen}
                onClose={() => setReviewModalOpen(false)}
                criteriaName={selectedCriteria.name}
                maxScore={selectedCriteria.maxScore}
                selfScore={selectedCriteria.selfScore}
                currentReviewScore={
                  reviewType === "review1"
                    ? selectedCriteria.review1Score
                    : selectedCriteria.review2Score
                }
                currentComment={
                  reviewType === "review1"
                    ? selectedCriteria.review1Comment
                    : selectedCriteria.review2Comment
                }
                currentFile={
                  reviewType === "review1"
                    ? selectedCriteria.review1File
                    : selectedCriteria.review2File
                }
                reviewType={reviewType}
                onSave={handleSaveReview}
              />
              <QualitativeReviewModal
                open={qualitativeReviewModalOpen}
                onClose={() => setQualitativeReviewModalOpen(false)}
                criteriaName={selectedCriteria.name}
                maxScore={selectedCriteria.maxScore}
                selfScore={selectedCriteria.selfScore}
                currentReviewScore={
                  reviewType === "review1"
                    ? selectedCriteria.review1Score
                    : selectedCriteria.review2Score
                }
                currentComment={
                  reviewType === "review1"
                    ? selectedCriteria.review1Comment
                    : selectedCriteria.review2Comment
                }
                reviewType={reviewType}
                onSave={handleSaveQualitativeReview}
              />
              <Dialog open={explanationModalOpen} onOpenChange={setExplanationModalOpen}>
                <DialogContent className="max-w-md">
                  <DialogHeader>
                    <DialogTitle>Giải trình</DialogTitle>
                    <DialogDescription>
                      Nhập ý kiến giải trình cho tiêu chí: {selectedCriteria?.name}
                    </DialogDescription>
                  </DialogHeader>
                  <div className="space-y-4">
                    <div>
                      <label className="text-sm font-medium">Ý kiến giải trình</label>
                      <textarea 
                        className="w-full mt-1 p-2 border rounded-md"
                        rows={4}
                        placeholder="Nhập ý kiến giải trình..."
                      />
                    </div>
                    <div>
                      <label className="text-sm font-medium">File đính kèm</label>
                      <input
                        type="file"
                        className="w-full mt-1 p-2 border rounded-md"
                        accept=".pdf,.doc,.docx,.jpg,.png"
                      />
                    </div>
                  </div>
                  <DialogFooter>
                    <Button variant="outline" onClick={() => setExplanationModalOpen(false)}>
                      Hủy
                    </Button>
                    <Button onClick={() => handleSaveExplanation({ comment: "Giải trình test" })}>
                      Lưu
                    </Button>
                  </DialogFooter>
                </DialogContent>
              </Dialog>
            </>
          )}
        </>
      )}

      {/* Print-Only Section */}
      {summary && selectedPeriod && selectedCluster && selectedUnit && (
        <div className="print-only">
          <div className="print-header">
            <h1 className="text-2xl font-bold text-center mb-6">
              BÁO CÁO KẾT QUẢ THI ĐUA
            </h1>
            <div className="mb-6 space-y-2">
              <div className="flex gap-4">
                <span className="font-semibold min-w-[140px]">Kỳ thi đua:</span>
                <span>{selectedPeriod.name}</span>
              </div>
              <div className="flex gap-4">
                <span className="font-semibold min-w-[140px]">Cụm thi đua:</span>
                <span>{selectedCluster.name}</span>
              </div>
              <div className="flex gap-4">
                <span className="font-semibold min-w-[140px]">Đơn vị:</span>
                <span>{selectedUnit.name}</span>
              </div>
            </div>
          </div>

          <table className="w-full border-collapse">
            <thead>
              <tr className="border">
                <th className="border px-2 py-2 text-center text-xs font-semibold uppercase w-12">
                  STT
                </th>
                <th className="border px-2 py-2 text-left text-xs font-semibold uppercase">
                  Tên tiêu chí
                </th>
                <th className="border px-2 py-2 text-center text-xs font-semibold uppercase w-20">
                  Điểm tối đa
                </th>
                <th className="border px-2 py-2 text-center text-xs font-semibold uppercase w-20">
                  Điểm tự chấm
                </th>
                <th className="border px-2 py-2 text-center text-xs font-semibold uppercase w-20">
                  Thẩm định lần 1
                </th>
                <th className="border px-2 py-2 text-center text-xs font-semibold uppercase w-20">
                  Thẩm định lần 2
                </th>
              </tr>
            </thead>
            <tbody>
              {summary.criteriaGroups.map((group, groupIndex) => {
                const filteredCriteria = group.criteria.filter((item) => item.code?.trim());
                
                return filteredCriteria.map((item, itemIndex) => {
                  const indentLevel = (item.level || 1) - 1;
                  const indentPx = 8 + indentLevel * 24;
                  const isParentNode = item.criteriaType === 0;
                  
                  // If it's a parent, calculate sum of children's scores for all columns
                  const childrenSelfScoreTotal = isParentNode 
                    ? calculateChildrenTotal(item, filteredCriteria, itemIndex, 'selfScore')
                    : 0;
                  const childrenReview1ScoreTotal = isParentNode 
                    ? calculateChildrenTotal(item, filteredCriteria, itemIndex, 'review1Score')
                    : 0;
                  const childrenReview2ScoreTotal = isParentNode 
                    ? calculateChildrenTotal(item, filteredCriteria, itemIndex, 'review2Score')
                    : 0;
                  const childrenFinalScoreTotal = isParentNode 
                    ? calculateChildrenTotal(item, filteredCriteria, itemIndex, 'finalScore')
                    : 0;
                  
                  return (
                    <tr key={item.id} className="border">
                      <td className="border px-2 py-2 text-sm text-center">
                        {item.code || `${groupIndex + 1}.${itemIndex + 1}`}
                      </td>
                      <td 
                        className="border px-2 py-2 text-sm"
                        style={{ paddingLeft: `${indentPx}px` }}
                      >
                        <span className={indentLevel > 0 ? "" : "font-medium"}>
                          {formatCriteriaNameWithResult(item)}
                        </span>
                      </td>
                      <td className="border px-2 py-2 text-sm text-center font-medium">
                        {item.maxScore}
                      </td>
                      <td className="border px-2 py-2 text-sm text-center">
                        {isParentNode ? (
                          childrenSelfScoreTotal > 0 ? childrenSelfScoreTotal.toFixed(2) : '-'
                        ) : (
                          item.calculatedScore != null && !isNaN(Number(item.calculatedScore))
                            ? Number(item.calculatedScore).toFixed(2)
                            : item.selfScore != null && !isNaN(Number(item.selfScore))
                            ? Number(item.selfScore).toFixed(2)
                            : '-'
                        )}
                      </td>
                      <td className="border px-2 py-2 text-sm text-center">
                        {isParentNode ? (
                          childrenReview1ScoreTotal > 0 ? childrenReview1ScoreTotal.toFixed(2) : '-'
                        ) : (
                          item.review1Score?.toFixed(2) || '-'
                        )}
                      </td>
                      <td className="border px-2 py-2 text-sm text-center">
                        {isParentNode ? (
                          childrenReview2ScoreTotal > 0 ? childrenReview2ScoreTotal.toFixed(2) : '-'
                        ) : (
                          item.review2Score?.toFixed(2) || '-'
                        )}
                      </td>
                    </tr>
                  );
                });
              })}
            </tbody>
          </table>
          
          {/* Chú thích các ký tự viết tắt */}
          <div className="mt-4 p-3 bg-gray-50 border rounded-md text-sm">
            <div className="font-semibold mb-2">Chú thích:</div>
            <div className="space-y-1 text-xs">
              <div><span className="font-medium">T:</span> Chỉ tiêu (Target) - Chỉ tiêu được giao cho đơn vị (áp dụng cho tiêu chí định lượng)</div>
              <div><span className="font-medium">A:</span> Thực hiện (Actual) - Kết quả thực tế đơn vị đạt được (áp dụng cho tiêu chí định lượng)</div>
              <div><span className="font-medium">Đạt/Chưa đạt:</span> Trạng thái hoàn thành tiêu chí định tính</div>
              <div className="flex items-center gap-2">
                <span className="inline-flex items-center px-1.5 py-0.5 rounded text-xs font-medium bg-blue-100 text-blue-800 border border-blue-200">
                  Không giao CT
                </span>
                <span>Đơn vị không được giao chỉ tiêu nhưng có kết quả. Điểm tính theo tỷ lệ so với đơn vị có kết quả cao nhất cùng nhóm (tối đa 100% điểm).</span>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
