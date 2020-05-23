//Метод главных компонент (principal component analysis)
unit PCA;

interface

uses
    Lib_TRED2_TQLI2,Feature_Extractor,Math;
type
  TPCA = class
      /// <summary>
      ///   Нормированые данные
      /// </summary>
      NormData : TMatrixDouble;
      /// <summary>
      ///   Ковариационная матрица
      /// </summary>
      CovarMatrix : TMatrixDouble;
      /// <summary>
      ///   Корреляционная матрица
      /// </summary>
      CorrelMatrix : TMatrixDouble;
      /// <summary>
      ///   Собственные вектора
      /// </summary>
      Eigenvectors: TMatrixDouble;
      /// <summary>
      ///   Собственные значения
      /// </summary>
      Eigenvalues : TVector;
      /// <summary>
      ///   Главные компоненты
      /// </summary>
      PC : TMatrixDouble;
      /// <summary>
      ///   Количество компонент
      /// </summary>
      CountPC : Integer;
      /// <summary>
      ///   Доля компоненты (%)
      /// </summary>
      ProportionPC : TVector;
      constructor Create(ext :TExtractor);
      /// <summary>
      ///   Рассчет доли компонент
      /// </summary>
      procedure CalcProportionPC();
      /// <summary>
      ///   Рассчет компонент
      /// </summary>
      procedure CalcPC(SortB:Boolean = true);
      /// <summary>
      ///   Сортировка компонент по доли вклада
      /// </summary>
      procedure SortPC();
  end;

implementation


constructor TPCA.Create(ext :TExtractor) overload;
begin
  ext.NormalizationAndCenter;
  NormData := ext.NormData;
  ext.CalcCovarAndCorrel(ext.NormData,ext.FAvgValue,ext.CovarMatrix,ext.CorrelMatrix);

  CovarMatrix :=  ext.CovarMatrix;
  CorrelMatrix := ext.CorrelMatrix;
end;

procedure TPCA.CalcProportionPC();
var
  i: integer;
  function Sum( v:TVector ):Double;
  var i: integer;
      Sum: Double;
  begin
    Sum := 0;
    for i := 0 to High(v) do
    begin
      Sum := Sum + v[i];
    end;
    Result := Sum;
  end;

begin
  SetLength(ProportionPC,Length(Eigenvalues));
  for i := 0 to High(Eigenvalues) do
  begin
    ProportionPC[i] := RoundTo((Eigenvalues[i]/Sum(Eigenvalues))*100,-2);
  end;

end;
{
procedure TPCA.SortPC();
var
  i,j: integer;
  temp,temp2: TMatrixDouble;
  p,index: Double;
begin
  SetLength(temp,Length(ProportionPC));

  for i:=0 to High(ProportionPC) do
  begin
    SetLength(temp[i],2);
    temp[i,0] := ProportionPC[i];
    temp[i,1] := i;
  end;

  for i:=0 to High(ProportionPC) do
    for j:=0 to High(ProportionPC)-i-1 do
    if temp[j,0]<temp[j+1,0] then
    begin
      p:= temp[j,0];
      index := temp[j,1];
      temp[j,0]:=temp[j+1,0];
      temp[j,1]:=temp[j+1,1];
      ProportionPC[j]:=temp[j+1,0];

      temp[j+1,0]:=p;
      temp[j+1,1]:=index;
      ProportionPC[j+1]:=p;
    end;

  SetLength(temp2,Length(PC));
  for i:=0 to High(ProportionPC) do
  begin
      SetLength(temp2,Length(PC[i]));
      temp2[i]:= PC[i];
  end;  Ъ

  for i:=0 to High(ProportionPC) do
  begin
     PC[i] := temp2[round(temp[i,1])] ;
  end;
end;
}

procedure BubbleSort( var a: TVector);
var
i, j: integer;
tmp : Double;
begin
for i:=0 to High(a) do
  for j:=0 to High(a)-i do
    if A[j]>A[j+1] then
    begin
      tmp:=A[j];
      A[j]:=A[j+1];
      A[j+1]:=tmp;
    end;
end;

procedure RBubbleSort( var a: TVector);
var
i, j: integer;
tmp : Double;
begin
for i:=0 to High(a) do
  for j:=0 to High(a)-i do
    if A[j]<A[j+1] then
    begin
      tmp:=A[j];
      A[j]:=A[j+1];
      A[j+1]:=tmp;
    end;
end;

function GetIndexEigenvalues(var a:TMatrixDouble;b:Double):integer;
var
i: integer;
begin
for i:=0 to High(a) do
  if a[i,0] = b then Result := Round(a[i,1])
  else continue;
end;

procedure TPCA.SortPC();
var
  i: integer;
  temp,temp2: TMatrixDouble;
begin
  SetLength(temp,Length(Eigenvalues));

  for i:=0 to High(Eigenvalues) do
  begin
    SetLength(temp[i],2);
    temp[i,0] := Eigenvalues[i];
    temp[i,1] := i;
  end;

  RBubbleSort(Eigenvalues);

  SetLength(temp2,Length(Eigenvectors));

  for i:=0 to High(Eigenvalues) do
  begin
      SetLength(temp2,Length(Eigenvectors[i]));
      temp2[i]:= Eigenvectors[GetIndexEigenvalues(temp,Eigenvalues[i])];
  end;
   Eigenvectors  := temp2;

  {
   SetLength(temp2,Length(PC));

  for i:=0 to High(Eigenvalues) do
  begin
      SetLength(temp2,Length(Eigenvectors[i]));
      temp2[i]:= PC[GetIndexEigenvalues(temp,Eigenvalues[i])];
  end;
   PC  := temp2; }
end;

procedure TPCA.CalcPC(SortB:Boolean);
var
  i,j,err: integer;
  e : TVector;
  function Sum( ):Double;
  var
    k: integer;
    Sum: Double;
  begin
    Sum := 0;
    for k := 0 to High(Eigenvectors[i]) do
    begin
      Sum := Sum + Eigenvectors[i,k]* NormData[k,j];
    end;
    Result := Sum;
  end;
begin
  Eigenvectors := CovarMatrix;
  SetLength(Eigenvalues,Length(CovarMatrix));
  SetLength(e,Length(CovarMatrix));

  err := 0;
  tred2(Length(CovarMatrix),1,Eigenvectors,Eigenvalues,e);
  tqli2(Length(CovarMatrix),30,Eigenvectors,Eigenvalues,e,err);

  CalcProportionPC();

  CountPC := Length(Eigenvectors);
  SortPC();
  SetLength(PC,CountPC);

  for i := 0 to Length(NormData)-1 do
    for j := 0 to Length(NormData[i])-1 do
  begin
    SetLength(PC[i],Length(NormData[i]));
    PC[i,j] := Sum();
  end;
  if SortB then
  //  SortPC();
end;

end.
