//Метод главных компонент (principal component analysis)
unit PCA;

interface

uses
    Lib_TRED2_TQLI2,TypesForKD,Feature_Extractor,Math;
type
  TPCA = class
     private
      FMinValue: Double;
      FMaxValue: Double;
      FDispersion: Array of Double;
      FColCount: Integer;
      FRowCount: Integer;
     public
      FAvgValue: Array of Double;
      /// <summary>
      ///   Матрица извлеченных данных
      /// </summary>
      ExtractData : TMatrixDouble;
      /// <summary>
      ///   Средние значения столбцов (переменных) исходных данных
      /// </summary>
      AvgValue: Array of Double;
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
      ///   Рассчет характеристик данных: средние значения столбцов, дисперсии
      ///   столбцов
      /// </summary>
      /// <param name="AData">
      ///   Матрица данных
      /// </param>
      procedure CalcStats(AData: TMatrixDouble);
      /// <summary>
      ///   Нормализация
      /// </summary>
      procedure Normalization();
      /// <summary>
      ///   Нормализация и центрирование
      /// </summary>
      procedure NormalizationAndCenter();
      /// <summary>
      ///   Тест нормализации и центрирования
      /// </summary>
      function TestNormalizationAndCenter():Boolean;
      /// <summary>
      ///   Рассчет матриц ковариаций и корреляции
      /// </summary>
      /// <param name="AData">
      ///   Матрица
      /// </param>
      /// <param name="AAvgValue">
      ///   Средние значения столбцов
      /// </param>
      /// <param name="CovarMatrix">
      ///   Ковариационная матрица
      /// </param>
      /// <param name="CorrelMatrix">
      ///   Корреляционная матрица
      /// </param>
      procedure CalcCovarAndCorrel(AData: TMatrixDouble; AAvgValue: Array of Double;
        var ACovarMatrix: TMatrixDouble; var ACorrelMatrix: TMatrixDouble);

      /// <summary>
      ///   Рассчет доли компонент
      /// </summary>
      procedure CalcProportionPC();
      /// <summary>
      ///   Рассчет компонент
      /// </summary>
      procedure CalcPC(SortB:Boolean; d: Integer);
      /// <summary>
      ///   Сортировка компонент по доли вклада
      /// </summary>
      procedure SortPC();
  end;

   /// <summary>
  ///   Сумма вектора
  /// </summary>
  /// <param name="v">
  ///   Вектор
  /// </param>
  function SumVestor(v:TVector):Double;

  /// <summary>
  ///   Рассчет дисперсии
  /// </summary>
  /// <param name="AData">
  ///   Матрица данных
  /// </param>
  /// <param name="AvgValue">
  ///   Массив средних значений
  /// </param>
  /// <param name="Dispersion">
  ///   Массив дисперсий
  /// </param>
  procedure CalcDispersion(AData:TMatrixDouble; AvgValue:Array of Double; var Dispersion:Array of Double );

  /// <summary>
  ///   Рассчет средних значений
  /// </summary>
  /// <param name="AData">
  ///   Матрица данных
  /// </param>
  /// <param name="Av">
  ///   Массив средних значению
  /// </param>
  procedure CalcAvg(AData: TMatrixDouble; var Av: Array of Double);

implementation


constructor TPCA.Create(ext :TExtractor) overload;
begin
  ExtractData := ext.ExtractData;
end;

procedure TPCA.CalcStats(AData: TMatrixDouble);
var
  Col, Row, Count: Integer;
  Value: Double;
begin
  Count := 0;
  FMinValue := MaxDouble;
  FMaxValue := MinDouble;
  SetLength(FAvgValue,Length(AData));
  SetLength(FDispersion,Length(AData));

  for Col := 0 to Length(AData)-1 do
    for Row := 0 to Length(AData[Col])-1 do
    begin
      Value := AData[Col, Row];
        Inc(Count);
        if Value < FMinValue then
          FMinValue := Value;
        if Value > FMaxValue then
          FMaxValue := Value;
        FAvgValue[Col] := FAvgValue[Col] + Value;
    end;

  if Count > 0 then
  begin
    // нахождение средних значений столбцов
    for Col := 0 to Length(AData)-1 do
      FAvgValue[Col] := FAvgValue[Col] /Length(AData[0]) ;
    CalcDispersion(AData,FAvgValue,FDispersion);
  end;

end;

procedure TPCA.Normalization();
var Col, Row: integer;
begin

  for Col := 0 to Length(ExtractData)-1 do
  begin
    SetLength(NormData,Length(ExtractData));
    for Row := 0 to Length(ExtractData[Col])-1 do
    begin
      SetLength(NormData[Col],Length(ExtractData[Col]));
      NormData[Col, Row] := (ExtractData[Col, Row] - FAvgValue[Col]);
    end;
  end;
end;

procedure TPCA.NormalizationAndCenter();
var Col, Row: integer;
begin

  for Col := 0 to Length(ExtractData)-1 do
  begin
    SetLength(NormData,Length(ExtractData));
    for Row := 0 to Length(ExtractData[Col])-1 do
    begin
      SetLength(NormData[Col],Length(ExtractData[Col]));
      NormData[Col, Row] := (ExtractData[Col, Row] - FAvgValue[Col])/sqrt(FDispersion[Col]);
    end;
  end;
end;

function SumVestor(v:TVector):Double;
  var i: integer;
      Sum: Double;
  begin
    Sum := 0;
    for i := 0 to Length(v)-1 do
    begin
     Sum := Sum + v[i];
    end;
    Result := Sum;
  end;

procedure CalcAvg(AData: TMatrixDouble; var Av: Array of Double);
var Col,Row: integer;
begin
  for Col := 0 to Length(AData)-1 do
    for Row := 0 to Length(AData[Col])-1 do
      Av[Col]:= Av[Col] + AData[Col, Row];

  for Col := 0 to Length(AData)-1 do
   begin
      Av[Col]:= Av[Col] / Length(AData[Col]);
   end;
end;

procedure CalcDispersion(AData:TMatrixDouble; AvgValue:Array of Double; var Dispersion:Array of Double );
var
  Col, Row: Integer;
  Sum2Difference: Array of Double;
begin
  SetLength(Sum2Difference,Length(AData));
// нахождение дисперсии столбцов
    for Col := 0 to Length(AData)-1 do
      for Row := 0 to Length(AData[Col])-1 do
      begin
          Sum2Difference[Col] := Sum2Difference[Col] + power((AData[Col, Row] - AvgValue[Col]),2);
      end;

    for Col := 0 to Length(AData)-1 do
      Dispersion[Col] := Sum2Difference[Col] / ((Length(AData[Col]))-1);
end;


function TPCA.TestNormalizationAndCenter():Boolean;
var Col: integer;
  Av: Array of Double;
  Disp: Array of Double;
begin
  SetLength(Av,Length(NormData));
  SetLength(Disp,Length(NormData));

   CalcAvg(NormData,Av);

   for Col := 0 to Length(NormData)-1 do
   begin
      Av[Col]:= abs(RoundTo(Av[Col],-3));
   end;

   CalcDispersion(NormData,Av,Disp);

   for Col := 0 to Length(NormData)-1 do
   begin
      Disp[Col]:= abs(RoundTo(Disp[Col],-3));
   end;

   Result := (Av[0]=0) and (Disp[0]=1);

end;

procedure TPCA.CalcCovarAndCorrel(AData: TMatrixDouble; AAvgValue: Array of Double;
    var ACovarMatrix: TMatrixDouble; var ACorrelMatrix: TMatrixDouble);
var
  Col, Row: Integer;
  Av: Array of Double;
  Disp: Array of Double;

  function SumRoW():Double;
  var i: integer;
      Sum: Double;
      mult: Double;
  begin
    Sum := 0;
    i:=0;
    for i := 0 to Length(AData[i])-1 do
    begin
      mult :=  (AData[Row,i] - Av[Row])*(AData[Col,i] - Av[Col]);
      Sum := Sum + mult;
    end;
    Result := Sum;
  end;
begin

  SetLength(ACovarMatrix,Length(AData));
  SetLength(ACorrelMatrix,Length(AData));

  SetLength(Av,Length(AData));
  SetLength(Disp,Length(AData));

  CalcAvg(AData,Av);

  for Col := 0 to Length(NormData)-1 do
   begin
      Av[Col]:= abs(RoundTo(Av[Col],-3));
   end;

  CalcDispersion(AData,Av,Disp);
   for Col := 0 to Length(NormData)-1 do
   begin
      Disp[Col]:= abs(RoundTo(Disp[Col],-3));
   end;

  for Col := 0 to Length(AData)-1 do
    for Row := 0 to Length(AData)-1 do
    begin
       SetLength(ACovarMatrix[Col],Row+1);
       SetLength(ACorrelMatrix[Col],Row+1);

       ACovarMatrix[Col,Row] := SumRow()/ (Length(AData[Col])-1);

       if (Col = Row) then
          CovarMatrix[Col,Row] := abs(RoundTo(ACovarMatrix[Col,Row],-1));

       ACorrelMatrix[Col,Row] := CovarMatrix[Col,Row]/(Disp[Col]*Disp[Row]);
    end;
       CovarMatrix := ACovarMatrix;
       CorrelMatrix := ACorrelMatrix;

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


   SetLength(temp2,Length(NormData));

  for i:=0 to High(Eigenvalues) do
  begin
      SetLength(temp2,Length(Eigenvectors[i]));
      temp2[i]:= NormData[GetIndexEigenvalues(temp,Eigenvalues[i])];
  end;
   NormData  := temp2;
end;

procedure TPCA.CalcPC(SortB:Boolean; d: Integer);
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
  CalcStats(ExtractData);
  NormalizationAndCenter;
  CalcCovarAndCorrel(NormData,FAvgValue,CovarMatrix,CorrelMatrix);

  Eigenvectors := CovarMatrix;
  SetLength(Eigenvalues,Length(CovarMatrix));
  SetLength(e,Length(CovarMatrix));

  err := 0;
  tred2(Length(CovarMatrix),1,Eigenvectors,Eigenvalues,e);
  tqli2(Length(CovarMatrix),30,Eigenvectors,Eigenvalues,e,err);



  CountPC := Length(Eigenvectors);
  SortPC();
  SetLength(PC,CountPC);

  CalcProportionPC();

  for i := 0 to d-1 do
    for j := 0 to Length(NormData[i])-1 do
  begin
    SetLength(PC[i],Length(NormData[i]));
    PC[i,j] := Sum();
  end;

end;

end.
