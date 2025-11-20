import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { CheckCircle2, XCircle } from "lucide-react";
import { useState, useEffect } from "react";
import { Badge } from "@/components/ui/badge";

interface QualitativeReviewModalProps {
  open: boolean;
  onClose: () => void;
  criteriaName: string;
  maxScore: number;
  selfScore?: number;
  currentReviewScore?: number;
  currentComment?: string;
  reviewType: "review1" | "review2";
  onSave: (score: number, comment: string) => void;
}

export default function QualitativeReviewModal({
  open,
  onClose,
  criteriaName,
  maxScore,
  selfScore,
  currentReviewScore,
  currentComment,
  reviewType,
  onSave,
}: QualitativeReviewModalProps) {
  const [approval, setApproval] = useState<"approve" | "reject" | "">("");
  const [comment, setComment] = useState(currentComment || "");

  useEffect(() => {
    if (open) {
      // Determine approval state from current score
      if (currentReviewScore !== undefined && currentReviewScore !== null) {
        setApproval(currentReviewScore > 0 ? "approve" : "reject");
      } else {
        setApproval("");
      }
      setComment(currentComment || "");
    }
  }, [open, currentReviewScore, currentComment]);

  const handleSave = () => {
    if (!approval) {
      alert("Vui lòng chọn Đồng ý hoặc Không đồng ý");
      return;
    }
    
    // Đồng ý = copy điểm tự chấm (selfScore), Không đồng ý = 0
    const score = approval === "approve" 
      ? (selfScore !== undefined && selfScore !== null ? selfScore : maxScore)
      : 0;
    onSave(score, comment);
    onClose();
  };

  const title = reviewType === "review1" ? "Thẩm định lần 1" : "Thẩm định lần 2";

  return (
    <Dialog open={open} onOpenChange={onClose}>
      <DialogContent className="sm:max-w-[600px]" data-testid="modal-qualitative-review">
        <DialogHeader>
          <div className="flex items-center gap-2">
            <DialogTitle className="text-xl font-semibold">{title}</DialogTitle>
            <Badge variant="outline" className="text-xs">
              Định tính
            </Badge>
          </div>
          <DialogDescription className="text-sm text-muted-foreground">{criteriaName}</DialogDescription>
        </DialogHeader>
        
        <div className="space-y-6 py-4">
          {/* Self Score Reference */}
          {typeof selfScore === 'number' && (
            <div className="flex items-center gap-3 p-4 bg-accent/30 rounded-md border">
              <div className="flex items-center justify-center w-10 h-10 rounded-full bg-primary/10">
                <CheckCircle2 className="w-5 h-5 text-primary" />
              </div>
              <div>
                <p className="text-xs font-medium text-muted-foreground uppercase tracking-wide">
                  Điểm tự chấm
                </p>
                <p className="text-2xl font-bold text-foreground">
                  {selfScore.toFixed(2)} <span className="text-sm text-muted-foreground font-normal">/ {maxScore}</span>
                </p>
              </div>
            </div>
          )}

          {/* Approval Radio Group */}
          <div className="space-y-3">
            <Label className="text-sm font-medium">
              Kết quả thẩm định <span className="text-destructive">*</span>
            </Label>
            <RadioGroup
              value={approval}
              onValueChange={(value) => setApproval(value as "approve" | "reject")}
              className="space-y-3"
            >
              <div className="flex items-center space-x-3 p-4 rounded-md border hover:bg-accent/30 cursor-pointer transition-colors">
                <RadioGroupItem value="approve" id="approve" data-testid="radio-approve" />
                <Label 
                  htmlFor="approve" 
                  className="flex items-center gap-2 cursor-pointer flex-1"
                >
                  <CheckCircle2 className="w-5 h-5 text-green-600" />
                  <div>
                    <p className="font-medium">Đồng ý</p>
                    <p className="text-xs text-muted-foreground">
                      Tiêu chí đạt yêu cầu - Điểm: {typeof selfScore === 'number' ? selfScore.toFixed(2) : maxScore}
                    </p>
                  </div>
                </Label>
              </div>
              
              <div className="flex items-center space-x-3 p-4 rounded-md border hover:bg-accent/30 cursor-pointer transition-colors">
                <RadioGroupItem value="reject" id="reject" data-testid="radio-reject" />
                <Label 
                  htmlFor="reject" 
                  className="flex items-center gap-2 cursor-pointer flex-1"
                >
                  <XCircle className="w-5 h-5 text-red-600" />
                  <div>
                    <p className="font-medium">Không đồng ý</p>
                    <p className="text-xs text-muted-foreground">
                      Tiêu chí không đạt yêu cầu - Điểm: 0
                    </p>
                  </div>
                </Label>
              </div>
            </RadioGroup>
          </div>

          {/* Comment Textarea */}
          <div className="space-y-2">
            <Label htmlFor="comment" className="text-sm font-medium">
              Nhận xét / Giải trình
            </Label>
            <Textarea
              id="comment"
              value={comment}
              onChange={(e) => setComment(e.target.value)}
              placeholder="Nhập nhận xét, đánh giá hoặc giải trình về tiêu chí này..."
              rows={5}
              className="resize-none"
              data-testid="textarea-qualitative-comment"
            />
            <p className="text-xs text-muted-foreground">
              {comment.length} ký tự
            </p>
          </div>
        </div>

        <DialogFooter className="gap-2">
          <Button variant="outline" onClick={onClose} data-testid="button-qualitative-cancel" className="h-10">
            Hủy
          </Button>
          <Button onClick={handleSave} data-testid="button-qualitative-save" className="h-10">
            Lưu thẩm định
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
