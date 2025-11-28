import { useState, useMemo } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useSession } from "@/lib/useSession";
import { apiRequest } from "@/lib/queryClient";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Checkbox } from "@/components/ui/checkbox";
import { Skeleton } from "@/components/ui/skeleton";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { useToast } from "@/hooks/use-toast";
import { Save, AlertCircle } from "lucide-react";

interface Criteria {
  id: string;
  name: string;
  parentId: string | null;
  level: number;
  criteriaType: number;
  periodId: string;
  orderIndex: number;
}

interface Unit {
  id: string;
  name: string;
  clusterId: string;
}

interface AssignmentMatrix {
  [criteriaId: string]: {
    [unitId: string]: {
      id: string;
      isAssigned: boolean;
    };
  };
}

interface AssignmentData {
  criteria: Criteria[];
  units: Unit[];
  matrix: AssignmentMatrix;
}

export default function CriteriaAssignment() {
  const { user } = useSession();
  const { toast } = useToast();
  const queryClient = useQueryClient();

  const [selectedPeriodId, setSelectedPeriodId] = useState<string>("");
  const [selectedClusterId, setSelectedClusterId] = useState<string>("");
  const [changedAssignments, setChangedAssignments] = useState<Map<string, boolean>>(new Map());

  // Fetch evaluation periods
  const { data: periods } = useQuery<any[]>({
    queryKey: ["/api/evaluation-periods"],
    queryFn: async () => {
      const res = await apiRequest("GET", "/api/evaluation-periods");
      return await res.json();
    },
  });

  // Auto-select first period when data loads
  if (periods && periods.length > 0 && !selectedPeriodId) {
    setSelectedPeriodId(periods[0].id);
  }

  // Fetch clusters
  const { data: clusters } = useQuery<any[]>({
    queryKey: ["/api/clusters"],
    queryFn: async () => {
      const res = await apiRequest("GET", "/api/clusters");
      return await res.json();
    },
  });

  // Auto-select first cluster for admin when data loads
  if (user?.role === "admin" && clusters && clusters.length > 0 && !selectedClusterId) {
    setSelectedClusterId(clusters[0].id);
  }

  // Auto-select cluster for cluster_leader (from user's clusterId)
  const effectiveClusterId = user?.role === "cluster_leader" 
    ? user.clusterId 
    : selectedClusterId;

  // Fetch assignment matrix
  const { data: assignmentData, isLoading } = useQuery<AssignmentData>({
    queryKey: ["/api/criteria-assignments", selectedPeriodId, effectiveClusterId],
    queryFn: async () => {
      const res = await apiRequest(
        "GET",
        `/api/criteria-assignments?periodId=${selectedPeriodId}&clusterId=${effectiveClusterId}`
      );
      return await res.json();
    },
    enabled: !!selectedPeriodId && !!effectiveClusterId,
  });

  // Build tree structure
  const criteriaTree = useMemo(() => {
    if (!assignmentData?.criteria) return [];

    const buildTree = (parentId: string | null = null): Criteria[] => {
      return assignmentData.criteria
        .filter((c) => c.parentId === parentId)
        .sort((a, b) => a.orderIndex - b.orderIndex)
        .map((c) => ({
          ...c,
          children: buildTree(c.id),
        }));
    };

    return buildTree(null);
  }, [assignmentData?.criteria]);

  // Mutation to save changes
  const saveMutation = useMutation({
    mutationFn: async (updates: Array<{ id: string; isAssigned: boolean }>) => {
      const res = await apiRequest("PATCH", "/api/criteria-assignments/batch", {
        updates,
      });
      return await res.json();
    },
    onSuccess: () => {
      toast({
        title: "Thành công",
        description: "Đã cập nhật gán tiêu chí",
      });
      setChangedAssignments(new Map());
      queryClient.invalidateQueries({
        queryKey: ["/api/criteria-assignments"],
      });
    },
    onError: (error: any) => {
      toast({
        variant: "destructive",
        title: "Lỗi",
        description: error.message || "Không thể cập nhật",
      });
    },
  });

  const handleCheckboxChange = (criteriaId: string, unitId: string, isAssigned: boolean) => {
    const resultId = assignmentData?.matrix[criteriaId]?.[unitId]?.id;
    if (!resultId) return;

    const newChanges = new Map(changedAssignments);
    newChanges.set(resultId, isAssigned);
    setChangedAssignments(newChanges);
  };

  const handleSaveAll = () => {
    const updates = Array.from(changedAssignments.entries()).map(([id, isAssigned]) => ({
      id,
      isAssigned,
    }));

    if (updates.length === 0) {
      toast({
        title: "Thông báo",
        description: "Không có thay đổi nào để lưu",
      });
      return;
    }

    saveMutation.mutate(updates);
  };

  const renderCriteriaRow = (criteria: any, depth: number = 0): JSX.Element[] => {
    const isLeaf = !criteria.children || criteria.children.length === 0;
    const rows: JSX.Element[] = [];

    rows.push(
      <tr key={criteria.id} className={depth > 0 ? "bg-gray-50" : ""}>
        <td className="border px-4 py-2" style={{ paddingLeft: `${depth * 20 + 16}px` }}>
          <span className="font-medium">{criteria.name}</span>
          {!isLeaf && <span className="text-xs text-gray-500 ml-2">(Nhóm)</span>}
        </td>
        {assignmentData?.units.map((unit) => (
          <td key={unit.id} className="border px-4 py-2 text-center">
            {isLeaf ? (
              <Checkbox
                checked={
                  changedAssignments.has(assignmentData.matrix[criteria.id]?.[unit.id]?.id)
                    ? changedAssignments.get(assignmentData.matrix[criteria.id]?.[unit.id]?.id)
                    : assignmentData.matrix[criteria.id]?.[unit.id]?.isAssigned ?? false
                }
                onCheckedChange={(checked) =>
                  handleCheckboxChange(criteria.id, unit.id, checked as boolean)
                }
              />
            ) : (
              <span className="text-gray-400">-</span>
            )}
          </td>
        ))}
      </tr>
    );

    if (criteria.children) {
      criteria.children.forEach((child: any) => {
        rows.push(...renderCriteriaRow(child, depth + 1));
      });
    }

    return rows;
  };

  if (user?.role !== "admin" && user?.role !== "cluster_leader") {
    return (
      <div className="container mx-auto p-6">
        <Alert variant="destructive">
          <AlertCircle className="h-4 w-4" />
          <AlertDescription>
            Bạn không có quyền truy cập trang này
          </AlertDescription>
        </Alert>
      </div>
    );
  }

  return (
    <div className="container mx-auto p-6">
      <h1 className="text-3xl font-bold mb-6">Gán tiêu chí cho đơn vị</h1>

      <div className="bg-white rounded-lg shadow p-6 mb-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
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
            {user?.role === "cluster_leader" ? (
              <Select value={effectiveClusterId || ""} disabled>
                <SelectTrigger>
                  <SelectValue>
                    {clusters?.find(c => c.id === effectiveClusterId)?.name || "Đang tải..."}
                  </SelectValue>
                </SelectTrigger>
              </Select>
            ) : (
              <Select value={selectedClusterId} onValueChange={setSelectedClusterId}>
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
            )}
          </div>
        </div>
      </div>

      {isLoading && (
        <div className="space-y-2">
          <Skeleton className="h-12 w-full" />
          <Skeleton className="h-12 w-full" />
          <Skeleton className="h-12 w-full" />
        </div>
      )}

      {assignmentData && !isLoading && (
        <>
          <div className="bg-white rounded-lg shadow overflow-x-auto mb-4">
            <table className="w-full border-collapse">
              <thead>
                <tr className="bg-gray-100">
                  <th className="border px-4 py-3 text-left font-semibold">Tiêu chí</th>
                  {assignmentData.units.map((unit) => (
                    <th key={unit.id} className="border px-4 py-3 text-center font-semibold min-w-[120px]">
                      {unit.name}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {criteriaTree.map((criteria) => renderCriteriaRow(criteria))}
              </tbody>
            </table>
          </div>

          <div className="flex justify-end gap-2">
            <Button
              variant="outline"
              onClick={() => {
                setChangedAssignments(new Map());
                toast({
                  title: "Đã hủy",
                  description: "Các thay đổi đã được hủy bỏ",
                });
              }}
              disabled={changedAssignments.size === 0}
            >
              Hủy thay đổi
            </Button>
            <Button
              onClick={handleSaveAll}
              disabled={changedAssignments.size === 0 || saveMutation.isPending}
            >
              <Save className="w-4 h-4 mr-2" />
              {saveMutation.isPending ? "Đang lưu..." : `Lưu tất cả (${changedAssignments.size})`}
            </Button>
          </div>
        </>
      )}

      {!selectedPeriodId && (
        <Alert>
          <AlertCircle className="h-4 w-4" />
          <AlertDescription>Vui lòng chọn kỳ thi đua</AlertDescription>
        </Alert>
      )}

      {user?.role === "admin" && selectedPeriodId && !selectedClusterId && (
        <Alert>
          <AlertCircle className="h-4 w-4" />
          <AlertDescription>Vui lòng chọn cụm thi đua</AlertDescription>
        </Alert>
      )}
    </div>
  );
}
