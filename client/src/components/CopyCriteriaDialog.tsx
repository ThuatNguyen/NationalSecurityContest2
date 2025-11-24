import { useState, useEffect } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
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
import { useToast } from "@/hooks/use-toast";
import { Copy, Loader2 } from "lucide-react";

interface CopyCriteriaDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export function CopyCriteriaDialog({ open, onOpenChange }: CopyCriteriaDialogProps) {
  const { toast } = useToast();
  const queryClient = useQueryClient();

  const [sourcePeriodId, setSourcePeriodId] = useState<string>("");
  const [sourceClusterId, setSourceClusterId] = useState<string>("");
  const [targetPeriodId, setTargetPeriodId] = useState<string>("");
  const [targetClusterIds, setTargetClusterIds] = useState<string[]>([]);
  const [criteriaCount, setCriteriaCount] = useState<number>(0);

  // Fetch evaluation periods
  const { data: periods = [] } = useQuery<any[]>({
    queryKey: ["/api/evaluation-periods"],
  });

  // Fetch clusters
  const { data: clusters = [] } = useQuery<any[]>({
    queryKey: ["/api/clusters"],
  });

  // Fetch criteria count for preview
  useEffect(() => {
    if (sourcePeriodId && sourceClusterId) {
      fetch(`/api/criteria/tree?periodId=${sourcePeriodId}&clusterId=${sourceClusterId}`)
        .then(res => res.json())
        .then(data => {
          // Count all criteria in tree
          const countCriteria = (items: any[]): number => {
            let count = items.length;
            items.forEach(item => {
              if (item.children && item.children.length > 0) {
                count += countCriteria(item.children);
              }
            });
            return count;
          };
          setCriteriaCount(countCriteria(data));
        })
        .catch(() => setCriteriaCount(0));
    } else {
      setCriteriaCount(0);
    }
  }, [sourcePeriodId, sourceClusterId]);

  // Copy mutation
  const copyMutation = useMutation({
    mutationFn: async (data: {
      sourcePeriodId: string;
      sourceClusterId: string;
      targetPeriodId: string;
      targetClusterIds: string[];
    }) => {
      const response = await fetch("/api/criteria/copy", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        credentials: "include",
        body: JSON.stringify(data),
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.message || "Copy thất bại");
      }

      return response.json();
    },
    onSuccess: (data) => {
      const successCount = data.results.filter((r: any) => r.success).length;
      const failCount = data.results.filter((r: any) => !r.success).length;

      toast({
        title: "Copy tiêu chí hoàn tất",
        description: `Thành công: ${successCount} cụm, Thất bại: ${failCount} cụm`,
      });

      // Invalidate criteria queries
      queryClient.invalidateQueries({ queryKey: ["/api/criteria/tree"] });
      
      // Reset and close
      handleReset();
      onOpenChange(false);
    },
    onError: (error: Error) => {
      toast({
        title: "Lỗi",
        description: error.message,
        variant: "destructive",
      });
    },
  });

  const handleToggleCluster = (clusterId: string) => {
    setTargetClusterIds(prev =>
      prev.includes(clusterId)
        ? prev.filter(id => id !== clusterId)
        : [...prev, clusterId]
    );
  };

  const handleSelectAll = () => {
    if (targetClusterIds.length === availableTargetClusters.length) {
      setTargetClusterIds([]);
    } else {
      setTargetClusterIds(availableTargetClusters.map((c: any) => c.id));
    }
  };

  const handleReset = () => {
    setSourcePeriodId("");
    setSourceClusterId("");
    setTargetPeriodId("");
    setTargetClusterIds([]);
    setCriteriaCount(0);
  };

  const handleCopy = () => {
    if (!sourcePeriodId || !sourceClusterId || !targetPeriodId || targetClusterIds.length === 0) {
      toast({
        title: "Thiếu thông tin",
        description: "Vui lòng điền đầy đủ thông tin",
        variant: "destructive",
      });
      return;
    }

    copyMutation.mutate({
      sourcePeriodId,
      sourceClusterId,
      targetPeriodId,
      targetClusterIds,
    });
  };

  // Filter available target clusters (exclude source if same period)
  const availableTargetClusters = clusters.filter((c: any) => {
    if (sourcePeriodId === targetPeriodId && c.id === sourceClusterId) {
      return false;
    }
    return true;
  });

  const canCopy = sourcePeriodId && sourceClusterId && targetPeriodId && targetClusterIds.length > 0 && criteriaCount > 0;

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-2xl max-h-[80vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <Copy className="w-5 h-5" />
            Copy Tiêu Chí Giữa Các Cụm
          </DialogTitle>
          <DialogDescription>
            Copy toàn bộ cấu trúc tiêu chí từ cụm nguồn sang các cụm đích
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-6 py-4">
          {/* Source Section */}
          <div className="space-y-4 p-4 border rounded-lg bg-muted/50">
            <h3 className="font-semibold text-sm">Nguồn</h3>
            
            <div className="space-y-2">
              <Label>Kỳ thi đua nguồn</Label>
              <Select value={sourcePeriodId} onValueChange={setSourcePeriodId}>
                <SelectTrigger>
                  <SelectValue placeholder="Chọn kỳ thi đua" />
                </SelectTrigger>
                <SelectContent>
                  {periods.map((period: any) => (
                    <SelectItem key={period.id} value={period.id}>
                      {period.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <Label>Cụm nguồn</Label>
              <Select 
                value={sourceClusterId} 
                onValueChange={setSourceClusterId}
                disabled={!sourcePeriodId}
              >
                <SelectTrigger>
                  <SelectValue placeholder="Chọn cụm" />
                </SelectTrigger>
                <SelectContent>
                  {clusters.map((cluster: any) => (
                    <SelectItem key={cluster.id} value={cluster.id}>
                      {cluster.shortName} - {cluster.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>

          {/* Target Section */}
          <div className="space-y-4 p-4 border rounded-lg">
            <h3 className="font-semibold text-sm">Đích</h3>
            
            <div className="space-y-2">
              <Label>Kỳ thi đua đích</Label>
              <Select value={targetPeriodId} onValueChange={setTargetPeriodId}>
                <SelectTrigger>
                  <SelectValue placeholder="Chọn kỳ thi đua" />
                </SelectTrigger>
                <SelectContent>
                  {periods.map((period: any) => (
                    <SelectItem key={period.id} value={period.id}>
                      {period.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <Label>Cụm đích</Label>
                <Button
                  type="button"
                  variant="ghost"
                  size="sm"
                  onClick={handleSelectAll}
                  disabled={!targetPeriodId || availableTargetClusters.length === 0}
                >
                  {targetClusterIds.length === availableTargetClusters.length ? "Bỏ chọn tất cả" : "Chọn tất cả"}
                </Button>
              </div>
              
              <div className="border rounded-md p-3 max-h-60 overflow-y-auto space-y-2">
                {!targetPeriodId ? (
                  <p className="text-sm text-muted-foreground">Vui lòng chọn kỳ thi đua đích</p>
                ) : availableTargetClusters.length === 0 ? (
                  <p className="text-sm text-muted-foreground">Không có cụm nào khả dụng</p>
                ) : (
                  availableTargetClusters.map((cluster: any) => (
                    <div key={cluster.id} className="flex items-center space-x-2">
                      <Checkbox
                        id={`cluster-${cluster.id}`}
                        checked={targetClusterIds.includes(cluster.id)}
                        onCheckedChange={() => handleToggleCluster(cluster.id)}
                      />
                      <label
                        htmlFor={`cluster-${cluster.id}`}
                        className="text-sm font-normal cursor-pointer"
                      >
                        {cluster.shortName} - {cluster.name}
                      </label>
                    </div>
                  ))
                )}
              </div>
            </div>
          </div>

          {/* Preview */}
          {criteriaCount > 0 && (
            <div className="p-4 bg-blue-50 border border-blue-200 rounded-lg">
              <p className="text-sm font-medium text-blue-900">
                📋 Preview: Sẽ copy <span className="font-bold">{criteriaCount}</span> tiêu chí 
                sang <span className="font-bold">{targetClusterIds.length}</span> cụm
              </p>
            </div>
          )}
        </div>

        <DialogFooter>
          <Button
            variant="outline"
            onClick={() => {
              handleReset();
              onOpenChange(false);
            }}
            disabled={copyMutation.isPending}
          >
            Hủy
          </Button>
          <Button
            onClick={handleCopy}
            disabled={!canCopy || copyMutation.isPending}
          >
            {copyMutation.isPending ? (
              <>
                <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                Đang copy...
              </>
            ) : (
              <>
                <Copy className="w-4 h-4 mr-2" />
                Copy Tiêu Chí
              </>
            )}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
