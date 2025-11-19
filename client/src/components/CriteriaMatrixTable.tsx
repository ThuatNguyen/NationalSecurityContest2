import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { FileDown } from "lucide-react";

interface CriteriaMatrixData {
  criteriaHierarchy: Array<{
    id: string;
    code: string;
    displayCode: string;
    name: string;
    parentChain: Array<{ id: string; name: string; level: number }>;
    orderIndex: number;
  }>;
  units: Array<{
    unitId: string;
    unitShortName: string;
    unitName: string;
    scoresByCriteria: Record<string, { selfScore: number | null; clusterScore: number | null }>;
  }>;
}

interface CriteriaMatrixTableProps {
  data: CriteriaMatrixData;
  periodId?: string;
  clusterId?: string;
}

export function CriteriaMatrixTable({ data, periodId, clusterId }: CriteriaMatrixTableProps) {
  const { criteriaHierarchy, units } = data;

  const handleExport = () => {
    if (!periodId || !clusterId) {
      console.error('Missing periodId or clusterId for export');
      return;
    }
    
    const url = `/api/reports/criteria-matrix/export?periodId=${encodeURIComponent(periodId)}&clusterId=${encodeURIComponent(clusterId)}`;
    window.location.href = url;
  };

  if (criteriaHierarchy.length === 0) {
    return (
      <Card>
        <CardContent className="py-8">
          <p className="text-center text-muted-foreground">Chưa có tiêu chí nào được định nghĩa cho kỳ thi đua này.</p>
        </CardContent>
      </Card>
    );
  }

  // Group criteria by level 1 and level 2 parents for multi-level headers
  const groupedByLevel1 = new Map<string, typeof criteriaHierarchy>();
  const groupedByLevel2 = new Map<string, typeof criteriaHierarchy>();
  
  criteriaHierarchy.forEach(criteria => {
    // Level 1 grouping
    const level1Id = criteria.parentChain.length > 0 
      ? criteria.parentChain[0].id 
      : 'root';
    
    if (!groupedByLevel1.has(level1Id)) {
      groupedByLevel1.set(level1Id, []);
    }
    groupedByLevel1.get(level1Id)!.push(criteria);
    
    // Level 2 grouping
    const level2Id = criteria.parentChain.length > 1
      ? criteria.parentChain[1].id
      : (criteria.parentChain.length > 0 ? criteria.parentChain[0].id : 'root');
    
    if (!groupedByLevel2.has(level2Id)) {
      groupedByLevel2.set(level2Id, []);
    }
    groupedByLevel2.get(level2Id)!.push(criteria);
  });

  return (
    <Card className="overflow-hidden">
      <CardHeader className="flex flex-row items-center justify-between gap-2 flex-wrap">
        <CardTitle>Bảng điểm chi tiết theo tiêu chí</CardTitle>
        {periodId && clusterId && (
          <Button 
            variant="outline" 
            size="sm"
            onClick={handleExport}
            data-testid="button-export-matrix"
          >
            <FileDown className="w-4 h-4 mr-2" />
            Xuất Excel
          </Button>
        )}
      </CardHeader>
      <CardContent className="p-0">
        <div className="overflow-x-auto">
          <table className="w-full border-collapse text-sm">
            <thead>
              {/* Row 1: Level 1 (Top parent) headers */}
              <tr className="bg-muted/50">
                <th 
                  rowSpan={4} 
                  className="border border-border px-2 py-2 text-center font-semibold sticky left-0 bg-muted/50 z-10"
                >
                  Đơn vị
                </th>
                {Array.from(groupedByLevel1.entries()).map(([level1Id, children]) => {
                  const level1Name = children[0].parentChain.length > 0 
                    ? children[0].parentChain[0].name 
                    : 'Tiêu chí';
                  return (
                    <th
                      key={level1Id}
                      colSpan={children.length * 2}
                      className="border border-border px-2 py-2 text-center font-semibold text-xs"
                    >
                      {level1Name}
                    </th>
                  );
                })}
              </tr>

              {/* Row 2: Level 2 (Sub-parent) headers */}
              <tr className="bg-muted/40">
                {Array.from(groupedByLevel2.entries()).map(([level2Id, children]) => {
                  const level2Name = children[0].parentChain.length > 1
                    ? children[0].parentChain[1].name
                    : (children[0].parentChain.length > 0 ? children[0].parentChain[0].name : 'Tiêu chí');
                  return (
                    <th
                      key={level2Id}
                      colSpan={children.length * 2}
                      className="border border-border px-2 py-1.5 text-center font-medium text-xs"
                    >
                      {level2Name}
                    </th>
                  );
                })}
              </tr>

              {/* Row 3: Leaf criteria codes (TC1, TC2, ...) */}
              <tr className="bg-muted/30">
                {criteriaHierarchy.map(criteria => (
                  <th
                    key={criteria.id}
                    colSpan={2}
                    className="border border-border px-2 py-1 text-center font-medium text-xs"
                    title={criteria.name}
                  >
                    {criteria.displayCode}
                  </th>
                ))}
              </tr>

              {/* Row 4: ĐTC / TĐ sub-columns */}
              <tr className="bg-muted/30">
                {criteriaHierarchy.flatMap(criteria => [
                  <th key={`dtc-${criteria.id}`} className="border border-border px-1 py-1 text-center text-xs font-medium">
                    ĐTC
                  </th>,
                  <th key={`td-${criteria.id}`} className="border border-border px-1 py-1 text-center text-xs font-medium">
                    TĐ
                  </th>
                ])}
              </tr>
            </thead>

            <tbody>
              {units.map((unit, index) => (
                <tr 
                  key={unit.unitId}
                  className={index % 2 === 0 ? "bg-background" : "bg-muted/20"}
                  data-testid={`row-unit-${unit.unitId}`}
                >
                  <td className="border border-border px-2 py-1 font-medium sticky left-0 bg-inherit">
                    {unit.unitShortName}
                  </td>
                  {criteriaHierarchy.flatMap(criteria => {
                    const scores = unit.scoresByCriteria[criteria.id];
                    return [
                      <td key={`self-${unit.unitId}-${criteria.id}`} className="border border-border px-2 py-1 text-center">
                        {scores?.selfScore !== null && scores?.selfScore !== undefined 
                          ? scores.selfScore.toFixed(1) 
                          : "-"}
                      </td>,
                      <td key={`cluster-${unit.unitId}-${criteria.id}`} className="border border-border px-2 py-1 text-center">
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
        </div>

        {/* Legend */}
        <div className="border-t border-border p-4 text-xs text-muted-foreground space-y-1">
          <p><strong>ĐTC:</strong> Điểm tự chấm</p>
          <p><strong>TĐ:</strong> Điểm thẩm định (cluster review score)</p>
          <p><strong>Ghi chú:</strong> Hover vào mã tiêu chí (TC1, TC2...) để xem tên đầy đủ</p>
        </div>
      </CardContent>
    </Card>
  );
}
