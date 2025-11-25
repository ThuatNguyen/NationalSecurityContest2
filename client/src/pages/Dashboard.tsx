import DashboardStats from "@/components/DashboardStats";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Building2, Users, CheckCircle, TrendingUp, AlertCircle } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useLocation } from "wouter";
import { useQuery } from "@tanstack/react-query";
import { useSession } from "@/lib/useSession";
import { useState, useEffect } from "react";

interface DashboardProps {
  role: "admin" | "cluster_leader" | "user";
}

interface Unit {
  id: string;
  name: string;
  clusterId: string;
}

interface Evaluation {
  id: string;
  unitId: string;
  status: string;
}

interface Cluster {
  id: string;
  name: string;
  shortName: string;
}

export default function Dashboard({ role }: DashboardProps) {
  const [, setLocation] = useLocation();
  const { user } = useSession();
  const [selectedClusterId, setSelectedClusterId] = useState<string>("ALL");
  
  // Fetch clusters
  const { data: clusters = [] } = useQuery<Cluster[]>({
    queryKey: ["/api/clusters"],
    queryFn: async () => {
      const res = await fetch("/api/clusters", { credentials: "include" });
      if (!res.ok) throw new Error("Failed to fetch clusters");
      return res.json();
    },
  });

  // Fetch all units in the system
  const { data: units = [] } = useQuery<Unit[]>({
    queryKey: ["/api/units"],
    queryFn: async () => {
      const res = await fetch("/api/units", { credentials: "include" });
      if (!res.ok) throw new Error("Failed to fetch units");
      return res.json();
    },
  });

  // Auto-select cluster based on role
  useEffect(() => {
    if (user?.role === "cluster_leader" && user.clusterId && selectedClusterId === "ALL") {
      setSelectedClusterId(user.clusterId);
    } else if (user?.role === "user" && user.unitId && selectedClusterId === "ALL" && units.length > 0) {
      // For user role, get clusterId from their unit
      const userUnit = units.find(u => u.id === user.unitId);
      if (userUnit?.clusterId) {
        setSelectedClusterId(userUnit.clusterId);
      }
    }
  }, [user, selectedClusterId, units]);

  // Fetch all evaluations to calculate submitted count
  const { data: evaluations = [] } = useQuery<Evaluation[]>({
    queryKey: ["/api/evaluations"],
    queryFn: async () => {
      const res = await fetch("/api/evaluations", { credentials: "include" });
      if (!res.ok) throw new Error("Failed to fetch evaluations");
      return res.json();
    },
  });

  // Filter units and evaluations by selected cluster
  const filteredUnits = selectedClusterId === "ALL" 
    ? units 
    : units.filter(u => u.clusterId === selectedClusterId);

  const filteredEvaluations = selectedClusterId === "ALL"
    ? evaluations
    : evaluations.filter(e => {
        const unit = units.find(u => u.id === e.unitId);
        return unit && unit.clusterId === selectedClusterId;
      });

  const totalUnits = filteredUnits.length;
  const submittedCount = filteredEvaluations.filter(e => 
    e.status === "submitted" || 
    e.status === "review1_completed" || 
    e.status === "review2_completed" ||
    e.status === "explanation_submitted" ||
    e.status === "finalized"
  ).length;
  const submittedPercent = totalUnits > 0 ? ((submittedCount / totalUnits) * 100).toFixed(1) : "0.0";

  const stats = [
    {
      title: "Tổng số đơn vị",
      value: totalUnits.toString(),
      icon: Building2,
      trend: "Trong hệ thống",
      trendUp: true,
      testId: "stat-units"
    },
    {
      title: "Đã tự chấm",
      value: `${submittedCount}/${totalUnits}`,
      icon: CheckCircle,
      trend: `${submittedPercent}% hoàn thành`,
      trendUp: true,
      testId: "stat-self-scored"
    },
    {
      title: "Đã chấm cụm",
      value: role === "admin" ? "38" : role === "cluster_leader" ? "8" : "Chờ duyệt",
      icon: Users,
      trend: "79.2% hoàn thành",
      testId: "stat-cluster-scored"
    },
    {
      title: "Điểm trung bình",
      value: role === "user" ? "8.7" : "8.4",
      icon: TrendingUp,
      trend: "+0.3 so với kỳ trước",
      trendUp: true,
      testId: "stat-average"
    },
  ];

  const recentActivities = [
    { unit: "Công an phường Đống Đa", action: "đã hoàn thành tự chấm", time: "5 phút trước" },
    { unit: "Công an phường Ba Đình", action: "đã cập nhật điểm", time: "1 giờ trước" },
    { unit: "Phòng An ninh chính trị", action: "đã gửi báo cáo", time: "2 giờ trước" },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Tổng quan</h1>
        <p className="text-muted-foreground mt-1">Kỳ thi đua năm 2025</p>
      </div>

      {/* Cluster Filter */}
      <div className="p-4 bg-card border rounded-md">
        <div className="flex-1 min-w-[250px] max-w-sm">
          <Label htmlFor="filter-cluster" className="text-xs font-semibold uppercase tracking-wide mb-2 block">
            Cụm thi đua
          </Label>
          {user?.role === "admin" ? (
            <Select 
              value={selectedClusterId} 
              onValueChange={setSelectedClusterId}
            >
              <SelectTrigger id="filter-cluster" data-testid="select-cluster">
                <SelectValue placeholder="Chọn cụm thi đua" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="ALL">Tất cả đơn vị</SelectItem>
                {clusters.map((cluster) => (
                  <SelectItem key={cluster.id} value={cluster.id}>
                    {cluster.name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          ) : (
            <div className="h-10 px-3 py-2 bg-muted rounded-md flex items-center text-sm" data-testid="text-cluster">
              <span className="text-muted-foreground">
                {clusters.find(c => c.id === selectedClusterId)?.name || "Cụm của bạn"}
              </span>
            </div>
          )}
        </div>
      </div>

      <DashboardStats stats={stats} />

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">Tiến độ chấm điểm</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <div className="flex justify-between text-sm mb-2">
                <span>Tự chấm</span>
                <span className="font-medium">42/48 (87.5%)</span>
              </div>
              <Progress value={87.5} className="h-2" />
            </div>
            <div>
              <div className="flex justify-between text-sm mb-2">
                <span>Chấm cụm</span>
                <span className="font-medium">38/48 (79.2%)</span>
              </div>
              <Progress value={79.2} className="h-2" />
            </div>
            <div>
              <div className="flex justify-between text-sm mb-2">
                <span>Đã duyệt</span>
                <span className="font-medium">35/48 (72.9%)</span>
              </div>
              <Progress value={72.9} className="h-2" />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-lg">Hoạt động gần đây</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {recentActivities.map((activity, idx) => (
                <div key={idx} className="flex items-start gap-3 text-sm">
                  <AlertCircle className="w-4 h-4 text-primary mt-0.5 flex-shrink-0" />
                  <div className="flex-1">
                    <p>
                      <span className="font-medium">{activity.unit}</span> {activity.action}
                    </p>
                    <p className="text-xs text-muted-foreground mt-1">{activity.time}</p>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>

      {role === "user" && (
        <Card className="border-primary/50">
          <CardContent className="pt-6">
            <div className="flex items-start gap-4">
              <div className="w-12 h-12 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0">
                <AlertCircle className="w-6 h-6 text-primary" />
              </div>
              <div className="flex-1">
                <h3 className="font-semibold mb-1">Nhắc nhở: Hoàn thành tự chấm điểm</h3>
                <p className="text-sm text-muted-foreground mb-4">
                  Hạn chót nộp điểm tự chấm là ngày 22/12/2025. Vui lòng hoàn thành đúng thời hạn.
                </p>
                <Button 
                  data-testid="button-start-scoring"
                  onClick={() => setLocation("/periods")}
                >
                  Bắt đầu chấm điểm
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
