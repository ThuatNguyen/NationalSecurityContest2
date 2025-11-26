import { useState, useEffect } from "react";
import { useQuery } from "@tanstack/react-query";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Checkbox } from "@/components/ui/checkbox";
import { Label } from "@/components/ui/label";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Download, Printer, FileSpreadsheet } from "lucide-react";
import { useToast } from "@/hooks/use-toast";

interface EvaluationPeriod {
  id: string;
  name: string;
  year: number;
}

interface Cluster {
  id: string;
  name: string;
}

interface User {
  id: string;
  username: string;
  role: "admin" | "cluster_leader" | "user";
  clusterId: string | null;
  unitId: string | null;
}

interface UnitScore {
  unitId: string;
  unitName: string;
  selfScore: number;
  clusterScore: number;
  finalScore: number;
  maxScoreAssigned: number;
  totalMaxScore: number;
  status: string;
  ranking: number;
}

export default function ComprehensiveReportsPage() {
  const { toast } = useToast();
  const [selectedPeriodId, setSelectedPeriodId] = useState<string>("");
  const [selectedClusterId, setSelectedClusterId] = useState<string>("");
  const [selectedGroupId, setSelectedGroupId] = useState<string>("");

  // Fetch current user
  const { data: user } = useQuery<User>({
    queryKey: ["/api/auth/me"],
    queryFn: async () => {
      const res = await fetch("/api/auth/me");
      if (!res.ok) throw new Error("Failed to fetch user");
      return res.json();
    },
  });

  // Fetch evaluation periods
  const { data: periods } = useQuery<EvaluationPeriod[]>({
    queryKey: ["/api/evaluation-periods"],
    queryFn: async () => {
      const res = await fetch("/api/evaluation-periods");
      if (!res.ok) throw new Error("Failed to fetch periods");
      return res.json();
    },
  });

  // Fetch unit to get clusterId for regular users
  const { data: userUnit } = useQuery({
    queryKey: ["/api/units", user?.unitId],
    enabled: !!user?.unitId && user?.role === "user",
    queryFn: async () => {
      const res = await fetch(`/api/units/${user?.unitId}`);
      if (!res.ok) throw new Error("Failed to fetch unit");
      return res.json();
    },
  });

  // Fetch clusters for selected period
  const { data: clusters } = useQuery<Cluster[]>({
    queryKey: ["/api/evaluation-periods", selectedPeriodId, "clusters"],
    enabled: !!selectedPeriodId,
    queryFn: async () => {
      const res = await fetch(`/api/evaluation-periods/${selectedPeriodId}/clusters`);
      if (!res.ok) throw new Error("Failed to fetch clusters");
      return res.json();
    },
  });

  // Auto-select default period (first period in list)
  useEffect(() => {
    if (periods && periods.length > 0 && !selectedPeriodId) {
      setSelectedPeriodId(periods[0].id);
    }
  }, [periods, selectedPeriodId]);

  // Auto-select default cluster based on user role
  useEffect(() => {
    if (!clusters || clusters.length === 0 || selectedClusterId) return;

    // For cluster leader: select their cluster
    if (user?.role === "cluster_leader" && user.clusterId) {
      const userCluster = clusters.find(c => c.id === user.clusterId);
      if (userCluster) {
        setSelectedClusterId(userCluster.id);
        return;
      }
    }

    // For regular user: select their unit's cluster
    if (user?.role === "user" && userUnit?.clusterId) {
      const unitCluster = clusters.find(c => c.id === userUnit.clusterId);
      if (unitCluster) {
        setSelectedClusterId(unitCluster.id);
        return;
      }
    }

    // For admin or if no match found: select first cluster
    if (user?.role === "admin" || !selectedClusterId) {
      setSelectedClusterId(clusters[0].id);
    }
  }, [clusters, user, userUnit, selectedClusterId]);

  // Fetch summary report
  const { data: summaryData, isLoading: summaryLoading } = useQuery({
    queryKey: ["/api/reports/summary", selectedPeriodId, selectedClusterId],
    enabled: !!selectedPeriodId && !!selectedClusterId,
    queryFn: async () => {
      const res = await fetch(
        `/api/reports/summary?periodId=${selectedPeriodId}&clusterId=${selectedClusterId}`
      );
      if (!res.ok) throw new Error("Failed to fetch summary");
      return res.json();
    },
  });

  // Fetch unit scores for statistics
  const { data: unitScores, isLoading: scoresLoading } = useQuery<UnitScore[]>({
    queryKey: ["/api/reports/cluster-summary", selectedPeriodId, selectedClusterId],
    enabled: !!selectedPeriodId && !!selectedClusterId,
    queryFn: async () => {
      const res = await fetch(
        `/api/reports/cluster-summary?periodId=${selectedPeriodId}&clusterId=${selectedClusterId}`
      );
      if (!res.ok) throw new Error("Failed to fetch unit scores");
      return res.json();
    },
  });

  // Auto-select first group when summaryData loads
  useEffect(() => {
    if (summaryData?.criteriaGroups && summaryData.criteriaGroups.length > 0 && !selectedGroupId) {
      setSelectedGroupId(summaryData.criteriaGroups[0].id);
    }
  }, [summaryData, selectedGroupId]);

  // Fetch group detail report
  const { data: groupDetailData, isLoading: detailLoading } = useQuery({
    queryKey: ["/api/reports/group-detail", selectedPeriodId, selectedClusterId, selectedGroupId],
    enabled: !!selectedPeriodId && !!selectedClusterId && !!selectedGroupId,
    queryFn: async () => {
      const params = new URLSearchParams({
        periodId: selectedPeriodId,
        clusterId: selectedClusterId,
      });
      if (selectedGroupId !== "all") {
        params.append("groupId", selectedGroupId);
      }
      const res = await fetch(`/api/reports/group-detail?${params}`);
      if (!res.ok) throw new Error("Failed to fetch group detail");
      return res.json();
    },
  });

  // Calculate statistics
  const getStatusBadge = (status: string) => {
    const statusConfig: Record<string, { label: string; className: string }> = {
      finalized: { label: "Đã duyệt", className: "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200" },
      review2_completed: { label: "Chờ duyệt cuối", className: "bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200" },
      explanation_submitted: { label: "Đã giải trình", className: "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200" },
      review1_completed: { label: "Đã chấm cụm", className: "bg-cyan-100 text-cyan-800 dark:bg-cyan-900 dark:text-cyan-200" },
      submitted: { label: "Đã nộp", className: "bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-200" },
      draft: { label: "Chưa nộp", className: "bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-200" },
    };
    const config = statusConfig[status] || statusConfig.draft;
    return <span className={`px-2 py-1 rounded-md text-xs font-medium ${config.className}`}>{config.label}</span>;
  };

  const totalUnits = unitScores?.length || 0;
  const completedUnits = unitScores?.filter(s => 
    s.status === "finalized" || 
    s.status === "submitted" || 
    s.status === "review1_completed" || 
    s.status === "review2_completed" ||
    s.status === "explanation_submitted"
  ).length || 0;
  const averageScore = totalUnits > 0 
    ? unitScores!.reduce((sum, s) => sum + s.clusterScore, 0) / totalUnits 
    : 0;

  const handleExportExcel = async () => {
    try {
      const res = await fetch(
        `/api/reports/export-excel?periodId=${selectedPeriodId}&clusterId=${selectedClusterId}`
      );
      if (!res.ok) throw new Error("Failed to export");
      
      const blob = await res.blob();
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = `BaoCaoChiTiet_${new Date().toISOString().split('T')[0]}.xlsx`;
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      document.body.removeChild(a);
      
      toast({ title: "Thành công", description: "Đã xuất báo cáo Excel" });
    } catch (error: any) {
      toast({
        title: "Lỗi",
        description: error.message || "Không thể xuất Excel",
        variant: "destructive",
      });
    }
  };

  const handlePrint = () => {
    window.print();
  };

  const handlePrintUnitScores = () => {
    const table = document.getElementById('unit-scores-table');
    if (!table) return;
    
    // Create a print window with only the table content
    const printContent = table.cloneNode(true) as HTMLElement;
    
    // Remove buttons from cloned content
    const buttons = printContent.querySelectorAll('button');
    buttons.forEach(btn => btn.remove());
    
    const printWindow = window.open('', '', 'width=800,height=600');
    if (!printWindow) return;
    
    printWindow.document.write(`
      <!DOCTYPE html>
      <html>
        <head>
          <title>BẢNG ĐIỂM ĐƠN VỊ TRONG CỤM</title>
          <style>
            body { 
              font-family: system-ui, -apple-system, sans-serif; 
              padding: 20px;
              margin: 0;
            }
            h1, h2, h3 { 
              text-align: center; 
              text-transform: uppercase;
              margin: 10px 0;
              font-size: 18pt;
            }
            p {
              text-align: center;
              margin: 5px 0;
              font-size: 12pt;
              color: #666;
            }
            table { 
              width: 100%; 
              border-collapse: collapse; 
              margin-top: 20px;
            }
            th, td { 
              border: 1px solid #666; 
              padding: 8px; 
              text-align: left;
            }
            th { 
              background-color: #f3f4f6; 
              font-weight: 600;
            }
            .text-center { text-align: center; }
            .text-muted-foreground { color: #666; }
            @media print {
              body { padding: 0; }
            }
          </style>
        </head>
        <body>
          ${printContent.innerHTML}
        </body>
      </html>
    `);
    
    printWindow.document.close();
    printWindow.focus();
    setTimeout(() => {
      printWindow.print();
      printWindow.close();
    }, 250);
  };

  const handlePrintSummary = () => {
    const report = document.getElementById('summary-report');
    if (!report) return;
    
    const printContent = report.cloneNode(true) as HTMLElement;
    const buttons = printContent.querySelectorAll('button');
    buttons.forEach(btn => btn.remove());
    
    const printWindow = window.open('', '', 'width=1200,height=800');
    if (!printWindow) return;
    
    printWindow.document.write(`
      <!DOCTYPE html>
      <html>
        <head>
          <title>Bảng tổng hợp điểm thi đua</title>
          <style>
            body { 
              font-family: system-ui, -apple-system, sans-serif; 
              padding: 20px;
              margin: 0;
            }
            table { 
              width: 100%; 
              border-collapse: collapse; 
              font-size: 11pt;
            }
            th, td { 
              border: 1px solid #666; 
              padding: 6px; 
            }
            th { 
              background-color: #f3f4f6; 
              font-weight: 600;
            }
            .text-center { text-align: center; }
            .text-left { text-align: left; }
            .font-semibold { font-weight: 600; }
            .bg-gray-50 { background-color: #f9fafb; }
            .bg-gray-100 { background-color: #f3f4f6; }
            .bg-gray-200 { background-color: #e5e7eb; }
            h1 { text-align: center; font-size: 18pt; margin: 10px 0; }
            p { text-align: center; margin: 5px 0; }
            @media print {
              @page { size: A4 landscape; margin: 1cm; }
              body { padding: 0; }
            }
          </style>
        </head>
        <body>
          ${printContent.innerHTML}
        </body>
      </html>
    `);
    
    printWindow.document.close();
    printWindow.focus();
    setTimeout(() => {
      printWindow.print();
      printWindow.close();
    }, 250);
  };

  const handlePrintGroupDetail = () => {
    const report = document.getElementById('group-detail-report');
    if (!report) return;
    
    const printContent = report.cloneNode(true) as HTMLElement;
    const buttons = printContent.querySelectorAll('button');
    buttons.forEach(btn => btn.remove());
    const selects = printContent.querySelectorAll('.no-print');
    selects.forEach(el => el.remove());
    
    const printWindow = window.open('', '', 'width=1200,height=800');
    if (!printWindow) return;
    
    printWindow.document.write(`
      <!DOCTYPE html>
      <html>
        <head>
          <title>Báo cáo chi tiết theo nhóm</title>
          <style>
            body { 
              font-family: system-ui, -apple-system, sans-serif; 
              padding: 20px;
              margin: 0;
            }
            table { 
              width: 100%; 
              border-collapse: collapse; 
              font-size: 10pt;
              margin-bottom: 30px;
            }
            th, td { 
              border: 1px solid #666; 
              padding: 6px; 
            }
            th { 
              background-color: #f3f4f6; 
              font-weight: 600;
            }
            .text-center { text-align: center; }
            .text-left { text-align: left; }
            .font-semibold { font-weight: 600; }
            .bg-gray-50 { background-color: #f9fafb; }
            .bg-gray-100 { background-color: #f3f4f6; }
            h2 { text-align: center; font-size: 14pt; margin: 10px 0; }
            p { text-align: center; margin: 5px 0; font-size: 11pt; }
            @media print {
              @page { size: A4 landscape; margin: 1cm; }
              body { padding: 0; }
              .space-y-6 > * { page-break-after: always; }
              .space-y-6 > *:last-child { page-break-after: auto; }
            }
          </style>
        </head>
        <body>
          ${printContent.innerHTML}
        </body>
      </html>
    `);
    
    printWindow.document.close();
    printWindow.focus();
    setTimeout(() => {
      printWindow.print();
      printWindow.close();
    }, 250);
  };

  return (
    <div className="container mx-auto p-6 space-y-6">
      <div className="flex items-center justify-between no-print">
        <h1 className="text-3xl font-bold">Báo cáo tổng hợp</h1>
      </div>

      {/* Selection Controls */}
      <Card className="no-print">
        <CardHeader>
          <CardTitle>Chọn kỳ thi đua và cụm</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <Label>Kỳ thi đua</Label>
              <Select value={selectedPeriodId} onValueChange={setSelectedPeriodId}>
                <SelectTrigger>
                  <SelectValue placeholder="Chọn kỳ thi đua" />
                </SelectTrigger>
                <SelectContent>
                  {periods?.map((period) => (
                    <SelectItem key={period.id} value={period.id}>
                      {period.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div>
              <Label>Cụm thi đua</Label>
              {user?.role === "admin" ? (
                <Select 
                  value={selectedClusterId} 
                  onValueChange={setSelectedClusterId}
                  disabled={!selectedPeriodId}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Chọn cụm thi đua" />
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
                <Select 
                  value={selectedClusterId} 
                  disabled={true}
                >
                  <SelectTrigger>
                    <SelectValue>
                      {clusters?.find(c => c.id === selectedClusterId)?.name || "Đang tải..."}
                    </SelectValue>
                  </SelectTrigger>
                </Select>
              )}
            </div>
          </div>

        </CardContent>
      </Card>

      {/* Statistics Cards */}
      {selectedPeriodId && selectedClusterId && !scoresLoading && (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 no-print">
          <Card>
            <CardHeader className="pb-3">
              <CardTitle className="text-sm font-medium text-muted-foreground">Tổng số đơn vị</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-3xl font-bold">{totalUnits}</p>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="pb-3">
              <CardTitle className="text-sm font-medium text-muted-foreground">Đã hoàn thành</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-3xl font-bold">{completedUnits}/{totalUnits}</p>
              <p className="text-xs text-muted-foreground mt-1">
                {totalUnits > 0 ? ((completedUnits/totalUnits)*100).toFixed(1) : 0}%
              </p>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="pb-3">
              <CardTitle className="text-sm font-medium text-muted-foreground">Điểm trung bình</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-3xl font-bold">{averageScore.toFixed(2)}</p>
            </CardContent>
          </Card>
        </div>
      )}

      {/* Unit Scores Table */}
      {selectedPeriodId && selectedClusterId && unitScores && unitScores.length > 0 && (
        <Card id="unit-scores-table">
          <CardHeader className="flex flex-row items-center justify-between">
            <div className="flex-1">
              <CardTitle className="text-center text-xl uppercase">
                BẢNG ĐIỂM ĐƠN VỊ TRONG CỤM
              </CardTitle>
              <p className="text-center text-sm text-muted-foreground mt-1">
                {clusters?.find(c => c.id === selectedClusterId)?.name} - Năm {periods?.find(p => p.id === selectedPeriodId)?.year}
              </p>
            </div>
            <div className="flex gap-2">
              <Button onClick={handlePrintUnitScores} variant="outline" size="sm">
                <Printer className="mr-2 h-4 w-4" />
                In báo cáo
              </Button>
              <Button onClick={handleExportExcel} size="sm">
                <FileSpreadsheet className="mr-2 h-4 w-4" />
                Xuất Excel
              </Button>
            </div>
          </CardHeader>
          <CardContent>
            <div className="overflow-x-auto">
              <table className="w-full border-collapse">
                <thead>
                  <tr className="border-b">
                    <th className="text-left p-3 font-semibold">STT</th>
                    <th className="text-left p-3 font-semibold">Tên đơn vị</th>
                    <th className="text-center p-3 font-semibold">Tự chấm</th>
                    <th className="text-center p-3 font-semibold">Thẩm định</th>
                    <th className="text-center p-3 font-semibold">Tỷ lệ</th>
                    <th className="text-center p-3 font-semibold">Thứ hạng</th>
                    <th className="text-center p-3 font-semibold">Trạng thái</th>
                  </tr>
                </thead>
                <tbody>
                  {unitScores.map((score, index) => (
                    <tr key={score.unitId} className="border-b hover:bg-muted/50">
                      <td className="p-3">{index + 1}</td>
                      <td className="p-3 font-medium">{score.unitName}</td>
                      <td className="p-3 text-center">
                        {score.selfScore > 0 ? `${score.selfScore.toFixed(1)}/${score.maxScoreAssigned.toFixed(1)}` : "-"}
                      </td>
                      <td className="p-3 text-center">
                        {score.clusterScore > 0 ? `${score.clusterScore.toFixed(1)}/${score.maxScoreAssigned.toFixed(1)}` : "-"}
                      </td>
                      <td className="p-3 text-center">
                        {score.clusterScore > 0 && score.maxScoreAssigned > 0 
                          ? `${((score.clusterScore / score.maxScoreAssigned) * 100).toFixed(1)}%` 
                          : "-"}
                      </td>
                      <td className="p-3 text-center">
                        <span className={`inline-flex items-center justify-center w-8 h-8 rounded-full font-semibold ${
                          score.ranking === 1 ? "bg-yellow-100 text-yellow-800" :
                          score.ranking === 2 ? "bg-gray-100 text-gray-800" :
                          score.ranking === 3 ? "bg-orange-100 text-orange-800" :
                          "bg-gray-50 text-gray-600"
                        }`}>
                          {score.ranking || "-"}
                        </span>
                      </td>
                      <td className="p-3 text-center">
                        {getStatusBadge(score.status)}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Report Content */}
      {selectedPeriodId && selectedClusterId && (
        <Tabs defaultValue="summary" className="w-full">
          <TabsList className="grid w-full grid-cols-2 no-print">
            <TabsTrigger value="summary">Tổng quan</TabsTrigger>
            <TabsTrigger value="detail">Chi tiết theo nhóm</TabsTrigger>
          </TabsList>

          <TabsContent value="summary" className="space-y-4 print:block">
            <SummaryReport 
              data={summaryData} 
              loading={summaryLoading}
              onPrint={handlePrintSummary}
              onExportExcel={handleExportExcel}
            />
          </TabsContent>

          <TabsContent value="detail" className="space-y-4 print:block">
            <GroupDetailReport 
              data={groupDetailData} 
              loading={detailLoading}
              onPrint={handlePrintGroupDetail}
              onExportExcel={handleExportExcel}
              criteriaGroups={summaryData?.criteriaGroups}
              selectedGroupId={selectedGroupId}
              onGroupChange={setSelectedGroupId}
            />
          </TabsContent>
        </Tabs>
      )}
    </div>
  );
}

// Summary Report Component
function SummaryReport({ data, loading, onPrint, onExportExcel }: any) {
  if (loading) {
    return <Card><CardContent className="p-6">Đang tải dữ liệu...</CardContent></Card>;
  }

  if (!data) {
    return <Card><CardContent className="p-6">Chưa có dữ liệu</CardContent></Card>;
  }

  const { period, cluster, units, criteriaGroups } = data;

  return (
    <Card className="print:shadow-none print:border-0" id="summary-report">
      <CardHeader className="print:pb-2 print:pt-0">
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <CardTitle className="text-center text-xl print:text-lg">
              BẢNG TỔNG HỢP ĐIỂM THI ĐUA - {cluster.name}
            </CardTitle>
            <p className="text-center text-sm text-muted-foreground print:text-black">
              Kỳ thi đua: {period.name}
            </p>
          </div>
          <div className="flex gap-2 no-print">
            <Button onClick={onPrint} variant="outline" size="sm">
              <Printer className="mr-2 h-4 w-4" />
              In báo cáo
            </Button>
            <Button onClick={onExportExcel} size="sm">
              <FileSpreadsheet className="mr-2 h-4 w-4" />
              Xuất Excel
            </Button>
          </div>
        </div>
      </CardHeader>
      <CardContent className="print:p-0">
        <div className="overflow-x-auto">
          <table className="w-full border-collapse border border-gray-300 text-sm">
            <thead>
              <tr className="bg-gray-100">
                <th rowSpan={2} className="border border-gray-300 p-2 text-left font-semibold align-middle">
                  Đơn vị
                </th>
                {criteriaGroups.map((group: any) => (
                  <th key={group.id} colSpan={3} className="border border-gray-300 p-2 text-center font-semibold">
                    {group.name}
                    <br />
                    <span className="text-xs font-normal">({group.maxScore}đ)</span>
                  </th>
                ))}
                <th rowSpan={2} className="border border-gray-300 p-2 text-center font-semibold bg-gray-200 align-middle">
                  Tổng
                </th>
              </tr>
              <tr className="bg-gray-100">
                {criteriaGroups.map((group: any) => (
                  <>
                    <th key={`${group.id}-dtc`} className="border border-gray-300 p-1 text-center font-semibold text-xs">
                      ĐTC
                    </th>
                    <th key={`${group.id}-td1`} className="border border-gray-300 p-1 text-center font-semibold text-xs">
                      TĐ1
                    </th>
                    <th key={`${group.id}-td2`} className="border border-gray-300 p-1 text-center font-semibold text-xs">
                      TĐ2
                    </th>
                  </>
                ))}
              </tr>
            </thead>
            <tbody>
              {units.map((unit: any) => (
                <tr key={unit.unitId}>
                  <td className="border border-gray-300 p-2 font-semibold">
                    {unit.unitName}
                  </td>
                  {unit.groups.map((group: any) => (
                    <>
                      <td key={`${group.groupId}-self`} className="border border-gray-300 p-2 text-center">
                        {group.selfScore !== null ? group.selfScore.toFixed(1) : "-"}
                      </td>
                      <td key={`${group.groupId}-review1`} className="border border-gray-300 p-2 text-center">
                        {group.clusterScore !== null ? group.clusterScore.toFixed(1) : "-"}
                      </td>
                      <td key={`${group.groupId}-review2`} className="border border-gray-300 p-2 text-center">
                        {group.finalScore !== null ? group.finalScore.toFixed(1) : "-"}
                      </td>
                    </>
                  ))}
                  <td className="border border-gray-300 p-2 text-center font-semibold bg-gray-50">
                    {unit.totals.finalScore > 0 
                      ? unit.totals.finalScore.toFixed(1)
                      : unit.totals.clusterScore > 0
                      ? unit.totals.clusterScore.toFixed(1)
                      : unit.totals.selfScore > 0
                      ? unit.totals.selfScore.toFixed(1)
                      : "0.0"}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className="mt-4 text-sm text-muted-foreground print:mt-2">
          <p>Ghi chú:</p>
          <ul className="list-disc list-inside space-y-1">
            <li>ĐTC: Điểm tự chấm</li>
            <li>TĐ1: Điểm thẩm định lần 1 (cụm chấm)</li>
            <li>TĐ2: Điểm thẩm định lần 2 (sau giải trình)</li>
          </ul>
        </div>
      </CardContent>
    </Card>
  );
}

// Group Detail Report Component
function GroupDetailReport({ data, loading, onPrint, onExportExcel, criteriaGroups, selectedGroupId, onGroupChange }: any) {
  if (loading) {
    return <Card><CardContent className="p-6">Đang tải dữ liệu...</CardContent></Card>;
  }

  if (!data) {
    return <Card><CardContent className="p-6">Chưa có dữ liệu</CardContent></Card>;
  }

  const { period, cluster, units, groups } = data;

  return (
    <div className="space-y-6" id="group-detail-report">
      {groups.map((group: any) => (
        <Card key={group.groupId} className="print:shadow-none print:border-0 print:break-after-page">
          <CardHeader className="print:pb-2 print:pt-0">
            <div className="flex items-start justify-between gap-4">
              <div className="flex-1">
                <CardTitle className="text-center text-lg print:text-base">
                  {group.groupName} ({group.groupMaxScore} điểm)
                </CardTitle>
                <p className="text-center text-sm text-muted-foreground print:text-black">
                  {cluster.name} - {period.name}
                </p>
              </div>
              <div className="flex items-center gap-2 no-print">
                {criteriaGroups && criteriaGroups.length > 0 && (
                  <div className="flex items-center gap-2">
                    <Label className="text-sm whitespace-nowrap">Chọn nhóm:</Label>
                    <Select value={selectedGroupId} onValueChange={onGroupChange}>
                      <SelectTrigger className="w-[250px]">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        {criteriaGroups.map((g: any) => (
                          <SelectItem key={g.id} value={g.id}>
                            {g.name}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                )}
                <Button onClick={onPrint} variant="outline" size="sm">
                  <Printer className="mr-2 h-4 w-4" />
                  In báo cáo
                </Button>
                <Button onClick={onExportExcel} size="sm">
                  <FileSpreadsheet className="mr-2 h-4 w-4" />
                  Xuất Excel
                </Button>
              </div>
            </div>
          </CardHeader>
          <CardContent className="print:p-0">
            <div className="overflow-x-auto">
              <table className="w-full border-collapse border border-gray-300 text-sm">
                <thead>
                  <tr className="bg-gray-100">
                    <th rowSpan={2} className="border border-gray-300 p-2 text-left font-semibold w-1/3 align-middle">
                      Tiêu chí
                    </th>
                    {units.map((unit: any) => (
                      <th key={unit.id} colSpan={2} className="border border-gray-300 p-2 text-center font-semibold">
                        {unit.name}
                      </th>
                    ))}
                  </tr>
                  <tr className="bg-gray-100">
                    {units.map((unit: any) => (
                      <>
                        <th key={`${unit.id}-dtc`} className="border border-gray-300 p-1 text-center font-semibold text-xs">
                          ĐTC
                        </th>
                        <th key={`${unit.id}-td`} className="border border-gray-300 p-1 text-center font-semibold text-xs">
                          TĐ
                        </th>
                      </>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {group.criteriaRows.map((row: any) => {
                    const indent = '  '.repeat((row.level - 1) * 2);
                    const prefix = row.isParent ? '●' : '•';
                    
                    return (
                      <tr key={row.criteriaId} className={row.isParent ? "bg-gray-50" : ""}>
                        <td className={`border border-gray-300 p-2 ${row.isParent ? 'font-semibold' : ''}`}>
                          <span style={{ paddingLeft: `${(row.level - 1) * 16}px` }}>
                            {prefix} {row.criteriaNumber} {row.criteriaName} ({row.maxScore}đ)
                          </span>
                        </td>
                        {units.map((unit: any) => {
                          const unitData = row.units[unit.id];
                          
                          if (!unitData.isAssigned) {
                            return (
                              <>
                                <td key={`${unit.id}-dtc`} className="border border-gray-300 p-2 text-center text-gray-400">
                                  KP
                                </td>
                                <td key={`${unit.id}-td`} className="border border-gray-300 p-2 text-center text-gray-400">
                                  KP
                                </td>
                              </>
                            );
                          }

                          return (
                            <>
                              <td key={`${unit.id}-dtc`} className="border border-gray-300 p-2 text-center">
                                {unitData.selfScore !== null ? unitData.selfScore.toFixed(1) : "-"}
                              </td>
                              <td key={`${unit.id}-td`} className="border border-gray-300 p-2 text-center">
                                {unitData.clusterScore !== null ? unitData.clusterScore.toFixed(1) : "-"}
                              </td>
                            </>
                          );
                        })}
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </CardContent>
        </Card>
      ))}
    </div>
  );
}
