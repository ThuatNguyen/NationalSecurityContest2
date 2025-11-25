import FilterPanel from "@/components/FilterPanel";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { FileDown, Printer, FileSpreadsheet } from "lucide-react";
import { useQuery } from "@tanstack/react-query";
import { useState } from "react";
import { CriteriaMatrixTable } from "@/components/CriteriaMatrixTable";
import { Link } from "wouter";

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
  approvedScore: number;
  maxScoreAssigned: number;
  totalMaxScore: number;
  status: string;
  ranking: number;
}

interface Period {
  id: string;
  name: string;
  year: number;
  startDate: string;
  endDate: string;
  status: string;
}

interface Cluster {
  id: string;
  name: string;
  shortName: string;
  clusterType: string;
}

export default function Reports() {
  const [filters, setFilters] = useState<{ periodId: string; clusterId: string } | null>(null);

  // Fetch current user
  const { data: user } = useQuery<User>({
    queryKey: ["/api/auth/me"],
  });

  // Extract IDs for safe access in queryFn
  const periodId = filters?.periodId;
  const clusterId = filters?.clusterId;

  // Fetch selected period details for print layout
  const { data: selectedPeriod } = useQuery<Period>({
    queryKey: ["/api/evaluation-periods", periodId],
    queryFn: async () => {
      const res = await fetch(`/api/evaluation-periods/${periodId}`, {
        credentials: "include",
      });
      if (!res.ok) throw new Error("Failed to fetch period");
      return res.json();
    },
    enabled: !!periodId,
  });

  // Fetch selected cluster details for print layout
  const { data: selectedCluster } = useQuery<Cluster>({
    queryKey: ["/api/clusters", clusterId],
    queryFn: async () => {
      const res = await fetch(`/api/clusters/${clusterId}`, {
        credentials: "include",
      });
      if (!res.ok) throw new Error("Failed to fetch cluster");
      return res.json();
    },
    enabled: !!clusterId,
  });

  // Fetch cluster summary data
  const { data: scores, isLoading } = useQuery<UnitScore[]>({
    queryKey: ["/api/reports/cluster-summary", filters?.periodId, filters?.clusterId],
    queryFn: async () => {
      if (!filters?.periodId || !filters?.clusterId) return [];
      const res = await fetch(
        `/api/reports/cluster-summary?periodId=${filters.periodId}&clusterId=${filters.clusterId}`,
        { credentials: "include" }
      );
      if (!res.ok) throw new Error("Không thể tải dữ liệu");
      return res.json();
    },
    enabled: !!filters?.periodId && !!filters?.clusterId,
  });

  // Fetch criteria matrix data
  const { data: matrixData, isLoading: isMatrixLoading } = useQuery({
    queryKey: ["/api/reports/criteria-matrix", periodId, clusterId],
    queryFn: async () => {
      const res = await fetch(
        `/api/reports/criteria-matrix?periodId=${periodId}&clusterId=${clusterId}`,
        { credentials: "include" }
      );
      if (!res.ok) throw new Error("Failed to fetch criteria matrix");
      return res.json();
    },
    enabled: !!periodId && !!clusterId,
  });

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

  const totalUnits = scores?.length || 0;
  const completedUnits = scores?.filter(s => 
    s.status === "finalized" || 
    s.status === "submitted" || 
    s.status === "review1_completed" || 
    s.status === "review2_completed" ||
    s.status === "explanation_submitted"
  ).length || 0;
  const averageScore = totalUnits > 0 
    ? scores!.reduce((sum, s) => sum + s.clusterScore, 0) / totalUnits 
    : 0;

  const handleExport = async () => {
    if (!filters?.periodId || !filters?.clusterId) {
      alert("Vui lòng chọn kỳ thi đua và cụm");
      return;
    }

    try {
      const response = await fetch(
        `/api/reports/cluster-summary/export?periodId=${filters.periodId}&clusterId=${filters.clusterId}`,
        { credentials: "include" }
      );

      if (!response.ok) {
        throw new Error("Không thể xuất file Excel");
      }

      // Get filename from Content-Disposition header
      const contentDisposition = response.headers.get("Content-Disposition");
      let filename = "BaoCao.xlsx";
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

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Báo cáo thi đua</h1>
          <p className="text-muted-foreground mt-1">Tổng hợp kết quả chấm điểm theo cụm</p>
        </div>
        <Link href="/reports/comprehensive">
          <Button variant="outline">
            <FileSpreadsheet className="mr-2 h-4 w-4" />
            Báo cáo tổng hợp mới
          </Button>
        </Link>
      </div>

      <FilterPanel 
        role={user?.role || "user"} 
        userClusterId={user?.clusterId}
        onFilterChange={setFilters}
      />

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
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

      <Card>
        <CardHeader className="flex flex-row flex-wrap items-center justify-between gap-4">
          <CardTitle>Bảng điểm đơn vị trong cụm</CardTitle>
          <div className="flex gap-2">
            <Button variant="outline" size="sm" data-testid="button-print" onClick={() => window.print()}>
              <Printer className="w-4 h-4 mr-2" />
              In báo cáo
            </Button>
            <Button size="sm" data-testid="button-export" onClick={handleExport}>
              <FileDown className="w-4 h-4 mr-2" />
              Xuất Excel
            </Button>
          </div>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="text-center py-8 text-muted-foreground">Đang tải dữ liệu...</div>
          ) : !filters?.periodId || !filters?.clusterId ? (
            <div className="text-center py-8 text-muted-foreground">
              Vui lòng chọn kỳ thi đua và cụm để xem báo cáo
            </div>
          ) : !scores || scores.length === 0 ? (
            <div className="text-center py-8 text-muted-foreground">
              Không có dữ liệu đơn vị trong cụm này
            </div>
          ) : (
            <div className="border rounded-md overflow-hidden">
              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead className="bg-muted">
                    <tr className="border-b">
                      <th className="px-4 py-3 text-center text-xs font-semibold uppercase tracking-wide w-16">
                        STT
                      </th>
                      <th className="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide min-w-[250px]">
                        Tên đơn vị
                      </th>
                      <th className="px-4 py-3 text-center text-xs font-semibold uppercase tracking-wide w-32">
                        Tự chấm
                      </th>
                      <th className="px-4 py-3 text-center text-xs font-semibold uppercase tracking-wide w-32">
                        Thẩm định
                      </th>
                      <th className="px-4 py-3 text-center text-xs font-semibold uppercase tracking-wide w-32">
                        Tỷ lệ
                      </th>
                      <th className="px-4 py-3 text-center text-xs font-semibold uppercase tracking-wide w-24">
                        Thứ hạng
                      </th>
                      <th className="px-4 py-3 text-center text-xs font-semibold uppercase tracking-wide w-40 no-print">
                        Trạng thái
                      </th>
                    </tr>
                  </thead>
                  <tbody>
                    {scores.map((score, index) => (
                      <tr key={score.unitId} className="border-b hover-elevate" data-testid={`row-unit-${score.unitId}`}>
                        <td className="px-4 py-3 text-center text-sm font-medium">
                          {index + 1}
                        </td>
                        <td className="px-4 py-3 text-sm font-medium" data-testid={`text-unit-${score.unitId}`}>
                          {score.unitName}
                        </td>
                        <td className="px-4 py-3 text-center text-sm font-medium" data-testid={`text-selfscore-${score.unitId}`}>
                          {score.selfScore > 0 && score.maxScoreAssigned != null
                            ? `${score.selfScore.toFixed(1)}/${score.maxScoreAssigned.toFixed(1)}` 
                            : score.selfScore > 0 
                            ? score.selfScore.toFixed(1)
                            : '-'}
                        </td>
                        <td className="px-4 py-3 text-center text-sm font-medium" data-testid={`text-clusterscore-${score.unitId}`}>
                          {score.clusterScore > 0 && score.maxScoreAssigned != null
                            ? `${score.clusterScore.toFixed(1)}/${score.maxScoreAssigned.toFixed(1)}` 
                            : score.clusterScore > 0 
                            ? score.clusterScore.toFixed(1)
                            : '-'}
                        </td>
                        <td className="px-4 py-3 text-center text-sm text-muted-foreground">
                          {score.clusterScore > 0 && score.maxScoreAssigned != null && score.maxScoreAssigned > 0
                            ? `${((score.clusterScore / score.maxScoreAssigned) * 100).toFixed(1)}%`
                            : '-'}
                        </td>
                        <td className="px-4 py-3 text-center text-sm font-medium">
                          <div className="flex items-center justify-center">
                            <div className={`w-8 h-8 rounded-full flex items-center justify-center font-bold text-sm ${
                              score.ranking === 1 ? 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200' :
                              score.ranking === 2 ? 'bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-200' :
                              score.ranking === 3 ? 'bg-orange-100 text-orange-800 dark:bg-orange-900 dark:text-orange-200' :
                              'bg-muted text-foreground'
                            }`}>
                              {score.ranking}
                            </div>
                          </div>
                        </td>
                        <td className="px-4 py-3 text-center no-print">
                          {getStatusBadge(score.status)}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Criteria Matrix Table */}
      {filters?.periodId && filters?.clusterId && (
        <div className="no-print">
          {isMatrixLoading ? (
            <Card>
              <CardContent className="py-8">
                <div className="text-center text-muted-foreground">Đang tải bảng điểm chi tiết...</div>
              </CardContent>
            </Card>
          ) : matrixData ? (
            <CriteriaMatrixTable 
              data={matrixData} 
              periodId={filters.periodId}
              clusterId={filters.clusterId}
            />
          ) : null}
        </div>
      )}

      {/* Print-Only Section */}
      {selectedPeriod && selectedCluster && scores && scores.length > 0 && (
        <div className="print-only">
          <div className="print-header">
            <h1 className="text-2xl font-bold text-center mb-6">
              BÁO CÁO BẢNG ĐIỂM KỲ THI ĐUA TRONG CỤM
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
            </div>
          </div>

          <table className="w-full border-collapse">
            <thead>
              <tr className="border">
                <th className="border px-2 py-2 text-center text-xs font-semibold uppercase w-12">
                  STT
                </th>
                <th className="border px-2 py-2 text-left text-xs font-semibold uppercase">
                  Tên đơn vị
                </th>
                <th className="border px-2 py-2 text-center text-xs font-semibold uppercase w-24">
                  Tự chấm
                </th>
                <th className="border px-2 py-2 text-center text-xs font-semibold uppercase w-24">
                  Thẩm định
                </th>
                <th className="border px-2 py-2 text-center text-xs font-semibold uppercase w-20">
                  Tỷ lệ
                </th>
                <th className="border px-2 py-2 text-center text-xs font-semibold uppercase w-16">
                  Thứ hạng
                </th>
              </tr>
            </thead>
            <tbody>
              {scores.map((score, index) => {
                return (
                  <tr key={score.unitId} className="border">
                    <td className="border px-2 py-2 text-center text-sm">
                      {index + 1}
                    </td>
                    <td className="border px-2 py-2 text-sm">
                      {score.unitName}
                    </td>
                    <td className="border px-2 py-2 text-center text-sm">
                      {score.selfScore > 0 && score.maxScoreAssigned != null
                        ? `${score.selfScore.toFixed(1)}/${score.maxScoreAssigned.toFixed(1)}` 
                        : score.selfScore > 0 
                        ? score.selfScore.toFixed(1)
                        : '-'}
                    </td>
                    <td className="border px-2 py-2 text-center text-sm">
                      {score.clusterScore > 0 && score.maxScoreAssigned != null
                        ? `${score.clusterScore.toFixed(1)}/${score.maxScoreAssigned.toFixed(1)}` 
                        : score.clusterScore > 0 
                        ? score.clusterScore.toFixed(1)
                        : '-'}
                    </td>
                    <td className="border px-2 py-2 text-center text-sm">
                      {score.clusterScore > 0 && score.maxScoreAssigned != null && score.maxScoreAssigned > 0
                        ? `${((score.clusterScore / score.maxScoreAssigned) * 100).toFixed(1)}%`
                        : '-'}
                    </td>
                    <td className="border px-2 py-2 text-center text-sm font-semibold">
                      {score.ranking}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>

          {/* Criteria Matrix in Print */}
          {matrixData && matrixData.criteriaHierarchy.length > 0 && (() => {
            type CriteriaType = typeof matrixData.criteriaHierarchy[0];
            
            // Group by Level 1
            const groupedByLevel1 = matrixData.criteriaHierarchy.reduce((groups: Map<string, { name: string; count: number }>, criteria: CriteriaType) => {
              const level1Id = criteria.parentChain.length > 0 ? criteria.parentChain[0].id : 'root';
              const level1Name = criteria.parentChain.length > 0 ? criteria.parentChain[0].name : 'Tiêu chí';
              if (!groups.has(level1Id)) {
                groups.set(level1Id, { name: level1Name, count: 0 });
              }
              groups.get(level1Id)!.count += 1;
              return groups;
            }, new Map<string, { name: string; count: number }>());

            // Group by Level 2
            const groupedByLevel2 = matrixData.criteriaHierarchy.reduce((groups: Map<string, { name: string; count: number }>, criteria: CriteriaType) => {
              const level2Id = criteria.parentChain.length > 1
                ? criteria.parentChain[1].id
                : (criteria.parentChain.length > 0 ? criteria.parentChain[0].id : 'root');
              const level2Name = criteria.parentChain.length > 1
                ? criteria.parentChain[1].name
                : (criteria.parentChain.length > 0 ? criteria.parentChain[0].name : 'Tiêu chí');
              if (!groups.has(level2Id)) {
                groups.set(level2Id, { name: level2Name, count: 0 });
              }
              groups.get(level2Id)!.count += 1;
              return groups;
            }, new Map<string, { name: string; count: number }>());

            return (
              <div className="mt-8" style={{ pageBreakBefore: 'always' }}>
                <h2 className="text-xl font-bold mb-4">BẢNG ĐIỂM CHI TIẾT THEO TIÊU CHÍ</h2>
                <table className="w-full border-collapse text-xs">
                  <thead>
                    {/* Row 1: Level 1 headers */}
                    <tr className="border bg-gray-100">
                      <th 
                        rowSpan={4} 
                        className="border px-2 py-2 text-center font-semibold"
                      >
                        Đơn vị
                      </th>
                      {[...groupedByLevel1.entries()].map(([level1Id, data]) => (
                        <th
                          key={level1Id}
                          colSpan={data.count * 2}
                          className="border px-2 py-2 text-center font-semibold"
                        >
                          {data.name}
                        </th>
                      ))}
                    </tr>

                    {/* Row 2: Level 2 headers */}
                    <tr className="border bg-gray-50">
                      {[...groupedByLevel2.entries()].map(([level2Id, data]) => (
                        <th
                          key={level2Id}
                          colSpan={data.count * 2}
                          className="border px-2 py-1 text-center font-medium"
                        >
                          {data.name}
                        </th>
                      ))}
                    </tr>

                    {/* Row 3: Leaf criteria codes */}
                    <tr className="border bg-gray-50">
                      {matrixData.criteriaHierarchy.map((criteria: typeof matrixData.criteriaHierarchy[0]) => (
                        <th
                          key={criteria.id}
                          colSpan={2}
                          className="border px-2 py-1 text-center font-medium"
                        >
                          {criteria.displayCode}
                        </th>
                      ))}
                    </tr>

                    {/* Row 4: ĐTC / TĐ sub-columns */}
                    <tr className="border bg-gray-50">
                      {matrixData.criteriaHierarchy.flatMap((criteria: typeof matrixData.criteriaHierarchy[0]) => [
                        <th key={`print-dtc-${criteria.id}`} className="border px-1 py-1 text-center text-xs font-medium">
                          ĐTC
                        </th>,
                        <th key={`print-td-${criteria.id}`} className="border px-1 py-1 text-center text-xs font-medium">
                          TĐ
                        </th>
                      ])}
                    </tr>
                  </thead>

                <tbody>
                  {matrixData.units.map((unit: typeof matrixData.units[0]) => (
                    <tr key={unit.unitId} className="border">
                      <td className="border px-2 py-1 font-medium">
                        {unit.unitShortName}
                      </td>
                      {matrixData.criteriaHierarchy.flatMap((criteria: typeof matrixData.criteriaHierarchy[0]) => {
                        const scores = unit.scoresByCriteria[criteria.id];
                        const hasResult = scores?.hasResult === true;
                        const isAssigned = scores?.isAssigned !== false;
                        const shouldMarkNotAssigned = hasResult && !isAssigned;
                        
                        return [
                          <td 
                            key={`print-self-${unit.unitId}-${criteria.id}`} 
                            className={`border px-1 py-1 text-center ${shouldMarkNotAssigned ? 'bg-orange-100' : ''}`}
                          >
                            {shouldMarkNotAssigned && '⊘ '}
                            {scores?.selfScore !== null && scores?.selfScore !== undefined 
                              ? scores.selfScore.toFixed(1) 
                              : "-"}
                          </td>,
                          <td 
                            key={`print-cluster-${unit.unitId}-${criteria.id}`} 
                            className={`border px-1 py-1 text-center ${shouldMarkNotAssigned ? 'bg-orange-100' : ''}`}
                          >
                            {shouldMarkNotAssigned && '⊘ '}
                            {scores?.clusterScore !== null && scores?.clusterScore !== undefined 
                              ? scores.clusterScore.toFixed(1) 
                              : "-"}
                          </td>
                        ];
                      })}
                    </tr>
                  ))}
                </tbody>
                </table>
                <div className="mt-2 text-xs">
                  <p><strong>ĐTC:</strong> Điểm tự chấm | <strong>TĐ:</strong> Điểm thẩm định</p>
                  <p><strong>⊘:</strong> Đơn vị không được giao tiêu chí (ô màu cam) | <strong>-:</strong> Chưa chấm điểm</p>
                </div>
              </div>
            );
          })()}
        </div>
      )}
    </div>
  );
}
