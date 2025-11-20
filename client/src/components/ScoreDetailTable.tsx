import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import type { CriteriaResult } from "@shared/schema";

interface ScoreDetailTableProps {
  results: CriteriaResult[];
  criteriaMap: Map<string, { name: string; code: string; criteriaType: number; maxScore: number }>;
  onReview?: (result: CriteriaResult) => void;
}

export function ScoreDetailTable({ results, criteriaMap, onReview }: ScoreDetailTableProps) {
  const getCriteriaTypeLabel = (type: number) => {
    switch (type) {
      case 1: return "Định lượng";
      case 2: return "Định tính";
      case 3: return "Chấm thẳng";
      case 4: return "Cộng/Trừ";
      default: return "Khác";
    }
  };

  const getCriteriaTypeBadgeColor = (type: number) => {
    switch (type) {
      case 1: return "bg-blue-500";
      case 2: return "bg-green-500";
      case 3: return "bg-purple-500";
      case 4: return "bg-orange-500";
      default: return "bg-gray-500";
    }
  };

  const formatScore = (score: string | null | undefined) => {
    if (score === null || score === undefined) return "-";
    const num = Number(score);
    return isNaN(num) ? "-" : num.toFixed(2);
  };

  return (
    <div className="rounded-md border">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead className="w-[60px]">Mã</TableHead>
            <TableHead className="min-w-[300px]">Tên tiêu chí</TableHead>
            <TableHead className="w-[100px]">Loại</TableHead>
            <TableHead className="w-[100px] text-right">Giá trị TT</TableHead>
            <TableHead className="w-[100px] text-right">Tự chấm</TableHead>
            <TableHead className="w-[100px] text-right">Tính toán</TableHead>
            <TableHead className="w-[100px] text-right bg-blue-50">TĐ lần 1</TableHead>
            <TableHead className="w-[100px] text-right bg-green-50">TĐ lần 2</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {results.length === 0 ? (
            <TableRow>
              <TableCell colSpan={8} className="text-center text-muted-foreground">
                Chưa có kết quả chấm điểm
              </TableCell>
            </TableRow>
          ) : (
            results.map((result) => {
              const criteria = criteriaMap.get(result.criteriaId);
              if (!criteria) return null;

              return (
                <TableRow 
                  key={result.id}
                  className={onReview ? "cursor-pointer hover:bg-muted/50" : ""}
                  onClick={() => onReview && onReview(result)}
                >
                  <TableCell className="font-medium">{criteria.code}</TableCell>
                  <TableCell>{criteria.name}</TableCell>
                  <TableCell>
                    <Badge className={`${getCriteriaTypeBadgeColor(criteria.criteriaType)} text-white text-xs`}>
                      {getCriteriaTypeLabel(criteria.criteriaType)}
                    </Badge>
                  </TableCell>
                  <TableCell className="text-right">
                    {result.actualValue !== null && result.actualValue !== undefined 
                      ? Number(result.actualValue).toFixed(2) 
                      : "-"}
                  </TableCell>
                  <TableCell className="text-right">
                    {formatScore(result.selfScore)}
                  </TableCell>
                  <TableCell className="text-right font-semibold text-blue-600">
                    {formatScore(result.calculatedScore)}
                  </TableCell>
                  <TableCell className="text-right font-semibold text-blue-700 bg-blue-50">
                    {formatScore(result.clusterScore)}
                  </TableCell>
                  <TableCell className="text-right font-semibold text-green-700 bg-green-50">
                    {formatScore(result.finalScore)}
                  </TableCell>
                </TableRow>
              );
            })
          )}
        </TableBody>
      </Table>
    </div>
  );
}
