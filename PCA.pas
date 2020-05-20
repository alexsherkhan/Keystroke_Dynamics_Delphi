//����� ������� ��������� (principal component analysis)
unit PCA;

interface

uses
    Lib_TRED2_TQLI2,Feature_Extractor,Math;
type
  TPCA = class
      /// <summary>
      ///   ������������ ������
      /// </summary>
      NormData : TMatrixDouble;
      /// <summary>
      ///   �������������� �������
      /// </summary>
      CovarMatrix : TMatrixDouble;
      /// <summary>
      ///   �������������� �������
      /// </summary>
      CorrelMatrix : TMatrixDouble;
      /// <summary>
      ///   ����������� �������
      /// </summary>
      Eigenvectors: TMatrixDouble;
      /// <summary>
      ///   ����������� ��������
      /// </summary>
      Eigenvalues : TVector;
      /// <summary>
      ///   ������� ����������
      /// </summary>
      PC : TMatrixDouble;
      /// <summary>
      ///   ���������� ���������
      /// </summary>
      CountPC : Integer;
      /// <summary>
      ///   ���� ���������� (%)
      /// </summary>
      ProportionPC : TVector;
      constructor Create(ext :TExtractor);
      /// <summary>
      ///   ������� ���� ���������
      /// </summary>
      procedure CalcProportionPC();
      /// <summary>
      ///   ������� ���������
      /// </summary>
      procedure CalcPC(SortB:Boolean = true);
      /// <summary>
      ///   ���������� ��������� �� ���� ������
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
  end;

  for i:=0 to High(ProportionPC) do
  begin
     PC[i] := temp2[round(temp[i,1])] ;
  end;
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
  SetLength(PC,CountPC);

  for i := 0 to Length(NormData)-1 do
    for j := 0 to Length(NormData[i])-1 do
  begin
    SetLength(PC[i],Length(NormData[i]));
    PC[i,j] := Sum();
  end;
  if SortB then
    SortPC();
end;

end.
