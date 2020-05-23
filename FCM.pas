/// <summary>
///   �������� �������� ������������� Fuzzy c-means (FCM)
/// </summary>
unit FCM;

interface
uses  Lib_TRED2_TQLI2, Math;

  type TPoint = record
    x: Double;
    y: Double;
  end;

  type TVectorPoints = Array Of TPoint;
  type TMatrixPoints = Array Of TVectorPoints;

 type
  /// <summary>
  ///   ����� ��������� �������� ������������� Fuzzy c-means
  /// </summary>
  TFCM = class
      /// <summary>
      ///   ������������ �������� ���������� ������� ��������������
      /// </summary>
      Eplsion: Double;
      /// <summary>
      ///   ������������ ���������� �����
      /// </summary>
      MaxExecutionCycles: Integer;
      /// <summary>
      ///   ���������� �����
      /// </summary>
      PointsCount: Integer;
      /// <summary>
      ///   ����������� ���������
      /// </summary>
      ClustersNum: Integer;
      /// <summary>
      ///   ����������� ���������������
      /// </summary>
      Fuzz: Double;
      /// <param name="nEPLSION">
      ///   ������������ �������� ���������� ������� ��������������
      /// </param>
      /// <param name="nMAX_EXECUTION_CYCLES">
      ///   ������������ ���������� �����
      /// </param>
      /// <param name="nPOINTS_COUNT">
      ///   ���������� �����
      /// </param>
      /// <param name="nCLUSTERS_NUM">
      ///   ����������� ���������
      /// </param>
      /// <param name="nFUZZ">
      ///   ����������� ���������������
      /// </param>
      constructor Create(nEPLSION: Double = 0.1;
                          nMAX_EXECUTION_CYCLES: Integer = 150;
                          nPOINTS_COUNT: Integer = 100;
                          nCLUSTERS_NUM: Integer = 3;
                          nFUZZ: Double = 1.5);
      /// <summary>
      ///   ��������� ������� ��������� �����
      /// </summary>
      /// <param name="Count">
      ///   ���������� �����
      /// </param>
      /// <returns>
      ///   ������ ��������� �����
      /// </returns>
      function GenerateRandomPoints(Count: Integer): TVectorPoints;

      /// <summary>
      ///   ������������ ������ ������
      /// </summary>
      /// <param name="MatrixURow">
      ///   ������ ������
      /// </param>
      /// <returns>
      ///   ������������ ������ ������
      /// </returns>
      function NormalizeUMatrixRow(MatrixURow:TVector): TVector;

      /// <summary>
      ///   ���������� ������� ������������� �������������� ����� ���������
      /// </summary>
      /// <param name="PointsCount">
      ///   ���������� �����
      /// </param>
      /// <param name="ClustersCount">
      ///   ���������� ���������
      /// </param>
      /// <returns>
      ///   ������� ������������� �������������� ����� ���������
      /// </returns>
      function FillUMatrix(PointsCount: Integer; ClustersCount: Integer): TMatrixDouble;

      /// <summary>
      ///   ������� ����������� ���������� ����� ������� A � B
      /// </summary>
      /// <param name="pointA">
      ///   ����� A
      /// </param>
      /// <param name="pointB">
      ///   ����� B
      /// </param>
      /// <returns>
      ///   ��������� ���������� ����� ������� A � B
      /// </returns>
      function EvklidDistance( pointA:TPoint; pointB:TPoint) : Double;

      /// <summary>
      ///   ���������� ����� ������� ��������� <br />
      /// </summary>
      /// <param name="MatrixU">
      ///   ������� ������������� ��������������
      /// </param>
      /// <param name="m">
      ///   ����������� ��������������
      /// </param>
      /// <param name="points">
      ///   �����
      /// </param>
      /// <returns>
      ///   ������ ����� ������� ���������
      /// </returns>
      function CalculateCenters(MatrixU : TMatrixDouble; m:Double;
                points:TVectorPoints):TVectorPoints;

      /// <summary>
      ///   ������� ������������ �������������� u �������������� �� ������� <br />
      ///   u = (1/d)^(2/(m-1)) <br />
      /// </summary>
      /// <param name="Distance">
      ///   ���������� �� ������� �� ������ ��������
      /// </param>
      /// <param name="M">
      ///   ����������� ���������������
      /// </param>
      /// <returns>
      ///   ����������� �������������� ������ �� ������
      /// </returns>
      function PrepareU(Distance: Double; M: Double) :Double;

      /// <summary>
      ///   ��������� ������� �������� ������� <br />��� ���������� ����� ����
      ///   ���������� ���������� ������� ������� � ������� ������ ��������
      ///   ����������� �� ����������� ��������������
      /// </summary>
      /// <param name="MatrixPointX">
      ///   ������ �����
      /// </param>
      /// <param name="MatrixCentroids">
      ///   ������ ������� ���������
      /// </param>
      /// <param name="MatrixU">
      ///   ������� ������������� ��������������
      /// </param>
      /// <returns>
      ///   ����� ���� ���������� ���������� ������� ������� � ������� ������
      ///   �������� ����������� �� ����������� ��������������
      /// </returns>
      function CalculateDecisionFunction(MatrixPointX :TVectorPoints;
          MatrixCentroids: TVectorPoints; MatrixU:TMatrixDouble) : Double;

      /// <summary>
      ///   ������� �� ��������� FCM
      /// </summary>
      /// <param name="Points">
      ///   ������ �����
      /// </param>
      /// <param name="M">
      ///   ����������� ���������������
      /// </param>
      /// <param name="Centers">
      ///   ������ ������� ����������
      /// </param>
      /// <returns>
      ///   ������� ������������� �������������� ����� ���������
      /// </returns>
      function DistributeOverMatrixU(Points :TVectorPoints; M:Double;
                var Centers: TVectorPoints):TMatrixDouble;
  end;
implementation

constructor TFCM.Create(nEPLSION: Double = 0.1;
                        nMAX_EXECUTION_CYCLES: Integer = 150;
                        nPOINTS_COUNT: Integer = 100;
                        nCLUSTERS_NUM: Integer = 3;
                        nFUZZ: Double = 1.5);
begin
  Eplsion := nEPLSION;
  MaxExecutionCycles := nMAX_EXECUTION_CYCLES;
  PointsCount:= nPOINTS_COUNT;
  ClustersNum:= nCLUSTERS_NUM;
  Fuzz:= nFUZZ;
end;

function TFCM.GenerateRandomPoints(Count: Integer): TVectorPoints;
var
   Points : TVectorPoints;
   i :Integer;
begin
  SetLength(Points,Count);

  for i:=0 to Count-1 do
  begin
    Points[i].x := Random(1);
    Points[i].y := Random(1);
  end;

  Result := points;
end;

function TFCM.NormalizeUMatrixRow(MatrixURow:TVector): TVector;
var
  i : Integer;
  Sum: Double;
begin
    Sum := 0;
    for i:=0 to High(MatrixURow) do
      Sum := sum + MatrixURow[i];

    for i:=0 to High(MatrixURow) do
      MatrixURow[i] := MatrixURow[i]/Sum;

    Result := MatrixURow;
end;

function TFCM.FillUMatrix(PointsCount: Integer; ClustersCount: Integer): TMatrixDouble;
var
  i,j : Integer;
  MatrixU :TMatrixDouble;
begin
    SetLength(MatrixU,PointsCount);
    for i:=0 to PointsCount-1 do
    begin
        SetLength(MatrixU[i],ClustersCount);
        for j:=0 to ClustersCount-1 do
            MatrixU[i,j] := Random(1);

        TVector(MatrixU[i]) := normalizeUMatrixRow(TVector(MatrixU[i]));
    end;

  Result := MatrixU;
end;

function TFCM.EvklidDistance( pointA:TPoint; pointB:TPoint) : Double;
var
  distance1,distance2,distance : Double;
begin
    distance1 := Power((pointA.x - pointB.x),2);
    distance2 := Power((pointA.x - pointB.y),2);
    distance := distance1 + distance2;
    Result := sqrt(distance);
end;


function TFCM.CalculateCenters(MatrixU : TMatrixDouble; m:Double; points:TVectorPoints):TVectorPoints;
var
  clusterIndex,key: Integer;
  tempAx, tempBx, tempAy, tempBy : Double;
  MatrixCentroids :TVectorPoints;
begin
     SetLength(MatrixCentroids,ClustersNum);

    for clusterIndex :=0 to ClustersNum-1 do
    begin
        tempAx := 0;
        tempBx := 0;
        tempAy := 0;
        tempBy := 0;

        for key:=0 to High(MatrixU) do
        begin
            tempAx := tempAx + power(MatrixU[key, clusterIndex],m);
            tempBx := tempBx + power(MatrixU[key,clusterIndex],m) * points[key].x;

            tempAy := tempAy + power(MatrixU[key, clusterIndex],m);
            tempBy := tempBy + power(MatrixU[key,clusterIndex],m) * points[key].y;
        end;

        MatrixCentroids[clusterIndex].x := tempBx / tempAx;
        MatrixCentroids[clusterIndex].y := tempBy / tempAy;
    end;

    Result := MatrixCentroids;
end;

function TFCM.PrepareU(Distance: Double; M: Double) :Double;
begin
  Result := Power(1/Distance , 2/(M-1));
end;

function TFCM.CalculateDecisionFunction(MatrixPointX :TVectorPoints;
          MatrixCentroids: TVectorPoints; MatrixU:TMatrixDouble) : Double;
var
  index,clusterIndex : Integer;
  Sum: Double;
begin
    Sum := 0;
    for index :=0 to High(MatrixU) do
    begin
      for clusterIndex := 0 to High(MatrixU[index]) do
        Sum := Sum + MatrixU[index,clusterIndex]
          * evklidDistance(MatrixCentroids[clusterIndex], MatrixPointX[index]);
    end;
    Result := Sum;
end;

// Algorithm Fuzzy C-Means(FCM)
function TFCM.DistributeOverMatrixU(Points :TVectorPoints; M:Double; var Centers: TVectorPoints):TMatrixDouble;
var
   a,key,clusterIndex:Integer;
   distance,previousDecisionValue, currentDecisionValue : Double;
   MatrixU :TMatrixDouble;
   uRow :TVector;
begin
    Centers := generateRandomPoints(ClustersNum);
    MatrixU := fillUMatrix(Length(Points),Length(centers));

    previousDecisionValue := 0;
    currentDecisionValue := 1;

    a := 0;
    while ((a < MaxExecutionCycles)
        and (abs(previousDecisionValue - currentDecisionValue) > EPLSION)) do
    begin
       previousDecisionValue := currentDecisionValue;
       centers := calculateCenters(MatrixU, m, Points);

        for key := 0 to High(MatrixU) do
        begin
          uRow := TVector(MatrixU[key]);
           for clusterIndex:=0 to High(MatrixU[key]) do
           begin
             distance := evklidDistance(Points[key], centers[clusterIndex]);
             uRow[key] := prepareU(distance, M);
           end;

            uRow := normalizeUMatrixRow(uRow);
        end;
        currentDecisionValue := calculateDecisionFunction(Points, centers, MatrixU);
      a  := a + 1;
    end;

    Result := MatrixU;
end;


end.
