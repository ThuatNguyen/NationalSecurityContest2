import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Label } from "@/components/ui/label";
import { useQuery } from "@tanstack/react-query";
import { useEffect, useState } from "react";

interface FilterPanelProps {
  role: "admin" | "cluster_leader" | "user";
  userClusterId?: string | null;
  onFilterChange?: (filters: { periodId: string; clusterId: string }) => void;
}

interface EvaluationPeriod {
  id: string;
  name: string;
  year: number;
  startDate: string;
  endDate: string;
}

interface Cluster {
  id: string;
  name: string;
  shortName: string;
}

export default function FilterPanel({ role, userClusterId, onFilterChange }: FilterPanelProps) {
  const [selectedPeriodId, setSelectedPeriodId] = useState<string>("");
  const [selectedClusterId, setSelectedClusterId] = useState<string>("");

  // Fetch evaluation periods
  const { data: periods, isLoading: periodsLoading } = useQuery<EvaluationPeriod[]>({
    queryKey: ["/api/evaluation-periods"],
  });

  // Fetch clusters (for all roles to display cluster name)
  const { data: clusters, isLoading: clustersLoading } = useQuery<Cluster[]>({
    queryKey: ["/api/clusters"],
  });

  // Auto-select first period and cluster when data loads
  useEffect(() => {
    if (periods && periods.length > 0 && !selectedPeriodId) {
      setSelectedPeriodId(periods[0].id);
    }
  }, [periods, selectedPeriodId]);

  useEffect(() => {
    if (role === "admin" && clusters && clusters.length > 0 && !selectedClusterId) {
      // Admin: auto-select first cluster
      setSelectedClusterId(clusters[0].id);
    } else if ((role === "cluster_leader" || role === "user") && userClusterId && !selectedClusterId) {
      // Cluster leader/User: auto-select their cluster
      setSelectedClusterId(userClusterId);
    }
  }, [role, clusters, userClusterId, selectedClusterId]);

  // Notify parent when filters change
  useEffect(() => {
    if (selectedPeriodId && selectedClusterId) {
      onFilterChange?.({ periodId: selectedPeriodId, clusterId: selectedClusterId });
    }
  }, [selectedPeriodId, selectedClusterId, onFilterChange]);

  return (
    <div className="flex flex-wrap gap-4 p-4 bg-card border rounded-md">
      <div className="flex-1 min-w-[250px]">
        <Label htmlFor="filter-period" className="text-xs font-semibold uppercase tracking-wide mb-2 block">
          Kỳ thi đua
        </Label>
        <Select 
          value={selectedPeriodId} 
          onValueChange={setSelectedPeriodId}
          disabled={periodsLoading}
        >
          <SelectTrigger id="filter-period" data-testid="select-period">
            <SelectValue placeholder={periodsLoading ? "Đang tải..." : "Chọn kỳ thi đua"} />
          </SelectTrigger>
          <SelectContent>
            {periods?.map((period) => (
              <SelectItem key={period.id} value={period.id}>
                {period.name} ({period.year})
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      {role === "admin" && (
        <div className="flex-1 min-w-[250px]">
          <Label htmlFor="filter-cluster" className="text-xs font-semibold uppercase tracking-wide mb-2 block">
            Cụm thi đua
          </Label>
          <Select 
            value={selectedClusterId} 
            onValueChange={setSelectedClusterId}
            disabled={clustersLoading}
          >
            <SelectTrigger id="filter-cluster" data-testid="select-cluster">
              <SelectValue placeholder={clustersLoading ? "Đang tải..." : "Chọn cụm thi đua"} />
            </SelectTrigger>
            <SelectContent>
              {clusters?.map((cluster) => (
                <SelectItem key={cluster.id} value={cluster.id}>
                  {cluster.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      )}

      {(role === "cluster_leader" || role === "user") && userClusterId && (
        <div className="flex-1 min-w-[250px]">
          <Label className="text-xs font-semibold uppercase tracking-wide mb-2 block">
            Cụm thi đua
          </Label>
          <div className="h-9 px-3 py-2 bg-muted rounded-md flex items-center text-sm">
            <span className="text-muted-foreground">
              {clusters?.find(c => c.id === userClusterId)?.name || "Cụm của bạn"}
            </span>
          </div>
        </div>
      )}
    </div>
  );
}
