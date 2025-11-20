import { useState, useEffect } from "react";
import { useQuery, useMutation } from "@tanstack/react-query";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { ScoreDetailTable } from "@/components/ScoreDetailTable";
import { useToast } from "@/hooks/use-toast";
import { CheckCircle } from "lucide-react";
import type { CriteriaWithChildren, CriteriaResult } from "@shared/schema";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";

export default function ClusterReviewPage() {
  const { toast } = useToast();
  const [selectedPeriodId, setSelectedPeriodId] = useState<string>("");
  const [selectedClusterId, setSelectedClusterId] = useState<string>("");
  const [selectedUnitId, setSelectedUnitId] = useState<string>("");
  const [reviewModalOpen, setReviewModalOpen] = useState(false);
  const [selectedCriteria, setSelectedCriteria] = useState<CriteriaWithChildren | null>(null);
  const [selectedResult, setSelectedResult] = useState<CriteriaResult | null>(null);
  const [reviewDecision, setReviewDecision] = useState<"agree" | "disagree">("agree");
  const [reviewComment, setReviewComment] = useState("");

  // Fetch user info
  const { data: user } = useQuery<any>({
    queryKey: ["/api/auth/me"],
  });

  // Fetch clusters (for admin users)
  const { data: clusters = [] } = useQuery({
    queryKey: ["/api/clusters"],
    queryFn: async () => {
      const response = await fetch("/api/clusters");
      if (!response.ok) throw new Error("Failed to fetch clusters");
      return response.json();
    },
    enabled: user?.role === "admin"
  });

  // Set cluster from user or auto-select first for admin
  useEffect(() => {
    if (user?.clusterId && !selectedClusterId) {
      // For cluster_leader, use their cluster
      setSelectedClusterId(user.clusterId);
    } else if (user?.role === "admin" && clusters.length > 0 && !selectedClusterId) {
      // For admin, auto-select first cluster
      setSelectedClusterId(clusters[0].id);
    }
  }, [user, selectedClusterId, clusters]);

  // Reset unit selection when cluster changes (for admins)
  useEffect(() => {
    if (selectedClusterId) {
      setSelectedUnitId("");
    }
  }, [selectedClusterId]);

  // Fetch evaluation periods
  const { data: allPeriods = [] } = useQuery({
    queryKey: ["/api/evaluation-periods"],
    queryFn: async () => {
      const response = await fetch("/api/evaluation-periods");
      if (!response.ok) throw new Error("Failed to fetch periods");
      return response.json();
    }
  });

  const periods = allPeriods.filter((p: any) => p.status === "active").concat(
    allPeriods.filter((p: any) => p.status !== "active")
  );

  // Auto-select first period
  useEffect(() => {
    if (periods.length > 0 && !selectedPeriodId) {
      setSelectedPeriodId(periods[0].id);
    }
  }, [periods, selectedPeriodId]);

  // Fetch units in cluster
  const { data: units = [] } = useQuery({
    queryKey: ["/api/units", selectedClusterId],
    queryFn: async () => {
      const response = await fetch(`/api/units`);
      if (!response.ok) throw new Error("Failed to fetch units");
      const allUnits = await response.json();
      return allUnits.filter((u: any) => u.clusterId === selectedClusterId);
    },
    enabled: !!selectedClusterId
  });

  // Auto-select first unit
  useEffect(() => {
    if (units.length > 0 && !selectedUnitId) {
      setSelectedUnitId(units[0].id);
    }
  }, [units, selectedUnitId]);

  // Fetch criteria tree
  const { data: tree = [] } = useQuery<CriteriaWithChildren[]>({
    queryKey: ["/api/criteria/tree", selectedPeriodId, selectedClusterId],
    queryFn: async () => {
      const params = new URLSearchParams();
      params.append("periodId", selectedPeriodId);
      if (selectedClusterId) {
        params.append("clusterId", selectedClusterId);
      }
      const response = await fetch(`/api/criteria/tree?${params.toString()}`);
      if (!response.ok) throw new Error("Failed to fetch criteria tree");
      return response.json();
    },
    enabled: !!selectedPeriodId && !!selectedClusterId
  });

  // Fetch results for selected unit
  const { data: results = [] } = useQuery<CriteriaResult[]>({
    queryKey: ["/api/criteria-results", selectedUnitId, selectedPeriodId],
    queryFn: async () => {
      const params = new URLSearchParams();
      params.append("unitId", selectedUnitId);
      params.append("periodId", selectedPeriodId);
      const response = await fetch(`/api/criteria-results?${params.toString()}`);
      if (!response.ok) throw new Error("Failed to fetch results");
      return response.json();
    },
    enabled: !!selectedUnitId && !!selectedPeriodId
  });

  // Review mutation
  const reviewMutation = useMutation({
    mutationFn: async (data: {
      criteriaId: string;
      unitId: string;
      periodId: string;
      reviewType: "cluster" | "final";
      clusterScore?: number;
      finalScore?: number;
      reviewComment?: string;
    }) => {
      return await apiRequest("POST", "/api/criteria-results/review", data);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/criteria-results"] });
      toast({ title: "Thành công", description: "Đã lưu thẩm định" });
      closeReviewModal();
    },
    onError: (error: Error) => {
      toast({ 
        title: "Lỗi", 
        description: error.message || "Không thể lưu thẩm định",
        variant: "destructive" 
      });
    },
  });

  // Build criteria map
  const buildCriteriaMap = (nodes: CriteriaWithChildren[], map: Map<string, { name: string; code: string; criteriaType: number; maxScore: number }> = new Map()) => {
    nodes.forEach(node => {
      map.set(node.id, {
        name: node.name,
        code: node.code || "",
        criteriaType: node.criteriaType,
        maxScore: Number(node.maxScore)
      });
      if (node.children && node.children.length > 0) {
        buildCriteriaMap(node.children, map);
      }
    });
    return map;
  };

  const criteriaMap = buildCriteriaMap(tree);

  const openReviewModal = (result: CriteriaResult) => {
    const criteria = criteriaMap.get(result.criteriaId);
    if (!criteria) return;

    setSelectedResult(result);
    // Store only what we need for the modal
    setSelectedCriteria({
      id: result.criteriaId,
      name: criteria.name,
      code: criteria.code,
      criteriaType: criteria.criteriaType,
      maxScore: criteria.maxScore.toString(),
    } as any);

    // Initialize from existing review data based on role
    const existingScore = user?.role === "admin" 
      ? Number(result.finalScore || 0)
      : Number(result.clusterScore || 0);
    
    const existingComment = result.note || "";
    
    // For criteriaType=2, determine decision from existing review score (not selfScore!)
    if (criteria.criteriaType === 2) {
      const maxScore = Number(criteria.maxScore);
      // If no review yet, initialize from selfScore
      if (!result.clusterScore && !result.finalScore) {
        const selfScore = Number(result.selfScore || 0);
        setReviewDecision(selfScore === maxScore ? "agree" : "disagree");
      } else {
        // Load from existing review score
        if (existingScore > 0 && !isNaN(maxScore) && Math.abs(existingScore - maxScore) < 0.01) {
          setReviewDecision("agree");
        } else {
          setReviewDecision("disagree");
        }
      }
    }
    
    setReviewComment(existingComment);
    setReviewModalOpen(true);
  };

  const closeReviewModal = () => {
    setReviewModalOpen(false);
    setSelectedCriteria(null);
    setSelectedResult(null);
    setReviewDecision("agree");
    setReviewComment("");
  };

  const handleReviewSubmit = () => {
    if (!selectedCriteria || !selectedResult) return;

    let reviewScore: number;
    const maxScore = Number(selectedCriteria.maxScore);

    if (selectedCriteria.criteriaType === 2) {
      // Qualitative: agree = maxScore, disagree = 0
      if (isNaN(maxScore) || maxScore <= 0) {
        toast({ 
          title: "Lỗi", 
          description: "Điểm tối đa không hợp lệ",
          variant: "destructive" 
        });
        return;
      }
      reviewScore = reviewDecision === "agree" ? maxScore : 0;
      
      // Validate comment for qualitative criteria
      if (!reviewComment.trim()) {
        toast({ 
          title: "Lỗi", 
          description: "Vui lòng nhập nhận xét cho tiêu chí định tính",
          variant: "destructive" 
        });
        return;
      }
    } else {
      // Other types: use existing review score if available, otherwise calculated score
      const existingScoreField = user?.role === "admin" 
        ? selectedResult.finalScore
        : selectedResult.clusterScore;
      
      // Check if review exists (not null/undefined), even if score is 0
      if (existingScoreField !== null && existingScoreField !== undefined && existingScoreField !== "") {
        reviewScore = Number(existingScoreField);
      } else {
        // First review: use calculated score
        reviewScore = Number(selectedResult.calculatedScore || selectedResult.selfScore || 0);
      }
    }

    // Determine review type based on user role
    const reviewType = user?.role === "admin" ? "final" : "cluster";

    reviewMutation.mutate({
      criteriaId: selectedResult.criteriaId,
      unitId: selectedUnitId,
      periodId: selectedPeriodId,
      reviewType,
      clusterScore: reviewType === "cluster" ? reviewScore : undefined,
      finalScore: reviewType === "final" ? reviewScore : undefined,
      reviewComment: reviewComment || undefined // Only send if not empty
    });
  };

  if (!user || (user.role !== "cluster_leader" && user.role !== "admin")) {
    return (
      <div className="container mx-auto p-6">
        <Card>
          <CardContent className="pt-6">
            <div className="text-center py-12 text-muted-foreground">
              Chỉ cán bộ cụm mới có quyền truy cập trang này
            </div>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="container mx-auto p-6 space-y-6">
      <Card>
        <CardHeader>
          <CardTitle>Thẩm định điểm thi đua - Cấp cụm</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <Label>Kỳ thi đua</Label>
              <Select value={selectedPeriodId} onValueChange={setSelectedPeriodId}>
                <SelectTrigger>
                  <SelectValue placeholder="Chọn kỳ thi đua" />
                </SelectTrigger>
                <SelectContent>
                  {periods.map((p: any) => (
                    <SelectItem key={p.id} value={p.id}>
                      {p.name} - {p.year}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {/* Cluster Selection (for admin only) */}
            {user?.role === "admin" && (
              <div>
                <Label>Cụm</Label>
                <Select value={selectedClusterId} onValueChange={setSelectedClusterId}>
                  <SelectTrigger>
                    <SelectValue placeholder="Chọn cụm" />
                  </SelectTrigger>
                  <SelectContent>
                    {clusters.map((cluster: any) => (
                      <SelectItem key={cluster.id} value={cluster.id}>
                        {cluster.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            )}

            <div>
              <Label>Đơn vị</Label>
              <Select value={selectedUnitId} onValueChange={setSelectedUnitId}>
                <SelectTrigger>
                  <SelectValue placeholder="Chọn đơn vị" />
                </SelectTrigger>
                <SelectContent>
                  {units.map((u: any) => (
                    <SelectItem key={u.id} value={u.id}>
                      {u.shortName} - {u.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>

          {selectedUnitId && selectedPeriodId ? (
            <div className="space-y-4">
              <div className="p-4 bg-blue-50 rounded-lg">
                <h3 className="font-semibold mb-2">Hướng dẫn thẩm định:</h3>
                <ul className="text-sm space-y-1 text-muted-foreground">
                  <li>• <strong>Tiêu chí định lượng:</strong> Điểm đã được tự động tính toán, click vào để xem và xác nhận</li>
                  <li>• <strong>Tiêu chí định tính:</strong> Chọn Đồng ý/Không đồng ý và nhập nhận xét</li>
                  <li>• <strong>Tiêu chí khác:</strong> Xem điểm tự chấm và xác nhận hoặc điều chỉnh</li>
                </ul>
              </div>

              <ScoreDetailTable 
                results={results} 
                criteriaMap={criteriaMap}
                onReview={openReviewModal}
              />
            </div>
          ) : (
            <div className="text-center py-12 text-muted-foreground">
              Vui lòng chọn kỳ thi đua và đơn vị
            </div>
          )}
        </CardContent>
      </Card>

      {/* Review Modal */}
      <Dialog open={reviewModalOpen} onOpenChange={setReviewModalOpen}>
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle>Thẩm định: {selectedCriteria?.name}</DialogTitle>
            <DialogDescription>
              {selectedCriteria?.code && `Mã: ${selectedCriteria.code}`}
            </DialogDescription>
          </DialogHeader>

          {selectedCriteria && selectedResult && (
            <div className="space-y-4">
              {/* Show self-score */}
              <div className="p-3 bg-gray-50 rounded-lg">
                <div className="text-sm font-medium mb-1">Thông tin tự chấm:</div>
                <div className="space-y-1 text-sm">
                  {selectedCriteria.criteriaType === 1 && (
                    <div>Giá trị thực tế: <span className="font-semibold">{selectedResult.actualValue}</span></div>
                  )}
                  <div>Điểm tự chấm: <span className="font-semibold">{Number(selectedResult.selfScore || 0).toFixed(2)}</span></div>
                  {selectedResult.calculatedScore && (
                    <div>Điểm tính toán: <span className="font-semibold text-blue-600">{Number(selectedResult.calculatedScore).toFixed(2)}</span></div>
                  )}
                  <div>Điểm tối đa: <span className="font-semibold">{Number(selectedCriteria.maxScore).toFixed(2)}</span></div>
                </div>
              </div>

              {/* For criteriaType=2 (Qualitative): Radio buttons */}
              {selectedCriteria.criteriaType === 2 && (
                <div className="space-y-2">
                  <Label>Quyết định thẩm định *</Label>
                  <RadioGroup value={reviewDecision} onValueChange={(val) => setReviewDecision(val as "agree" | "disagree")}>
                    <div className="flex items-center space-x-2">
                      <RadioGroupItem value="agree" id="agree" />
                      <Label htmlFor="agree" className="font-normal cursor-pointer">
                        Đồng ý (điểm = {Number(selectedCriteria.maxScore).toFixed(2)})
                      </Label>
                    </div>
                    <div className="flex items-center space-x-2">
                      <RadioGroupItem value="disagree" id="disagree" />
                      <Label htmlFor="disagree" className="font-normal cursor-pointer">
                        Không đồng ý (điểm = 0)
                      </Label>
                    </div>
                  </RadioGroup>
                </div>
              )}

              {/* For other types: Show calculated or self score */}
              {selectedCriteria.criteriaType !== 2 && (
                <div className="p-3 bg-green-50 rounded-lg">
                  <div className="text-sm font-medium mb-1">Điểm thẩm định:</div>
                  <div className="text-lg font-bold text-green-600">
                    {Number(selectedResult.calculatedScore || selectedResult.selfScore || 0).toFixed(2)} điểm
                  </div>
                  <div className="text-xs text-muted-foreground mt-1">
                    Điểm này đã được tự động tính toán và sẽ được áp dụng
                  </div>
                </div>
              )}

              {/* Comment field */}
              <div className="space-y-2">
                <Label htmlFor="review-comment">Nhận xét / Giải trình {selectedCriteria.criteriaType === 2 && "*"}</Label>
                <Textarea
                  id="review-comment"
                  value={reviewComment}
                  onChange={(e) => setReviewComment(e.target.value)}
                  placeholder="Nhập nhận xét hoặc giải trình..."
                  rows={3}
                />
              </div>
            </div>
          )}

          <DialogFooter>
            <Button variant="outline" onClick={closeReviewModal}>
              Hủy
            </Button>
            <Button onClick={handleReviewSubmit}>
              <CheckCircle className="w-4 h-4 mr-2" />
              Lưu thẩm định
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
