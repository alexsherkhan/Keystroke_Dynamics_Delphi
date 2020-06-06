unit AuthKD;

interface
uses  Math,TypesForKD,PCA;

procedure BubbleSortPoint(var A: TVectorPoints; Axis:string);
function GetIndexCentrs(var a:TMatrixDouble;b:Double):integer;
procedure SortMatrixPoint(var aMatrix: TMatrixDouble; centrs :TVectorPoints;Axis:string);
procedure FindSplitClasters(aMatrix: TMatrixDouble; v :TVectorPoints;var split:TMatrixDouble);
function AuthUser(PCObj:TPCA; new_PCObj:TPCA;var Data:TMatrixDouble;
          countClasters:Integer; PC_y:Integer; split:TMatrixDouble): Integer;

implementation

procedure BubbleSortPoint(var A: TVectorPoints; Axis:string);
var
i, j: integer;
tmp : TPoint;
begin
  tmp.x := 0;
  tmp.y := 0;
for i:=0 to High(a) do
  for j:=0 to High(a)-i-1 do
  begin
    if Axis ='x' then
    begin
      if A[j].x<A[j+1].x then
      begin
        tmp:=A[j];
        A[j]:=A[j+1];
        A[j+1]:=tmp;
      end
    end
    else
    begin
      if A[j].y<A[j+1].y then
      begin
        tmp:=A[j];
        A[j]:=A[j+1];
        A[j+1]:=tmp;
      end;
    end;

  end;

end;

function GetIndexCentrs(var a:TMatrixDouble;b:Double):integer;
var
i: integer;
begin
for i:=0 to High(a) do
  if a[i,0] = b then Result := Round(a[i,1])
  else continue;
end;

procedure SortMatrixPoint(var aMatrix: TMatrixDouble; centrs :TVectorPoints;Axis:string);
var
  i,j: integer;
  temp,temp2: TMatrixDouble;

begin
  SetLength(temp,Length(centrs));

  for i:=0 to High(centrs) do
  begin
    SetLength(temp[i],2);
    temp[i,0] := centrs[i].x;
    temp[i,1] := i;
  end;

  if Axis ='x' then
    BubbleSortPoint(centrs,'x')
  else
    BubbleSortPoint(centrs,'y');

  SetLength(temp2,Length(aMatrix));

  for i:=0 to High(aMatrix) do
  begin
    for j:=0 to High(aMatrix[i]) do
    begin
        SetLength(temp2[i],Length(aMatrix[j]));
        temp2[i][j]:= aMatrix[i][GetIndexCentrs(temp,centrs[j].x)];
    end;
  end;
  aMatrix := temp2;

end;

procedure FindSplitClasters(aMatrix: TMatrixDouble; v :TVectorPoints;var split:TMatrixDouble);
var
  i,j,index: integer;
begin
   SetLength(split,Length(aMatrix[0]));

    for  i:=0 to Length(aMatrix[0])-1 do
    begin
      SetLength(split[i],2);
      split[i][0] := MinDouble;
      split[i][1] := MaxDouble;
    end;

    for  i:=0 to Length(v)-1 do
    begin
      for j :=0 to Length(aMatrix[i])-1 do
      begin
        if aMatrix[i,j]>0.5 then
        begin
          index := j;
          break;
        end;
      end;
        if ((v[i].x<1)and(v[i].x>-1)) and (split[index][0] < v[i].y) then  split[index][0] := v[i].y;
        if ((v[i].x<1)and(v[i].x>-1)) and (split[index][1] > v[i].y) then  split[index][1] := v[i].y;
    end;

end;

function AuthUser(PCObj:TPCA; new_PCObj:TPCA;var Data:TMatrixDouble;
          countClasters:Integer; PC_y:Integer; split:TMatrixDouble): Integer;
var
  i,j,k: Integer;
  count_in_Claster : array of Integer;
  auth_index, auth_max: Integer;
begin
    SetLength(count_in_Claster,countClasters);
    NormalizationAndCenter(PCObj,new_PCObj.ExtractData,new_PCObj.NormData);
    SCalcPC(PCObj,new_PCObj.NormData,14);
    Data := PCObj.PC;

       for j :=0 to Length(Data[0])-1 do
        begin
           for i :=0 to Length(split)-2 do
            if (Data[PC_y,j]< split[i][1]) and (Data[PC_y,j]> split[i+1][1]) then
               inc(count_in_Claster[i+1]);
            if (Data[PC_y,j]> split[0][1]) then
                inc(count_in_Claster[0]);
        end;

        auth_max := count_in_Claster[0];
        auth_index := 0;
        k := 0;
        for j :=0 to Length(count_in_Claster)-1 do
        begin
          if count_in_Claster[j]>auth_max then
          begin
            auth_max := count_in_Claster[j];
            auth_index := j;
          end;

          if count_in_Claster[j]>40 then
          begin
            inc(k);
          end;
        end;

      if k<=1 then
        Result := auth_index
      else
        Result := -1;
end;
end.
