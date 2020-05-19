unit Feature_Extractor;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,Clipbrd,Data_Time,Vcl.Grids,DateUtils,Math,
  Lib_TRED2_TQLI2;

type
  TExtractor = class(TObject)
    private
      FDataGrid : TStringGrid;
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
      ///   Матрица нормализованых и центрированных данных
      /// </summary>
      NormData : TMatrixDouble;
      /// <summary>
      ///   Средние значения столбцов (переменных) исходных данных
      /// </summary>
      AvgValue: Array of Double;
      CovarMatrix : TMatrixDouble;
      CorrelMatrix : TMatrixDouble;
      property DataGrid: TStringGrid read FDataGrid write FDataGrid;
      //property NormData: Array of Array of Double read FNormData write FNormData;
      property MinValue: Double read FMinValue write FMinValue;
      property MaxValue: Double read FMaxValue write FMaxValue;
      //property AvgValue: Array of Double read FAvgValue write FAvgValue;
      property ColCount: Integer read FColCount write FColCount;
      property RowCount: Integer read FRowCount write FRowCount;

      /// <summary>
      ///   Загрузка файлов CSV
      /// </summary>
      /// <param name="FileName">
      ///   Имя файла
      /// </param>
      /// <param name="separator">
      ///   Разделитель
      /// </param>
      /// <param name="Ext">
      ///   Извлеченные характеристики(True) или нет(False)
      /// </param>
      procedure LoadCSVFile(FileName: String; separator: char; Ext :Boolean = false);
      /// <summary>
      ///   Извлечение характеристик ввода текста с клавиатуры из файла
      /// </summary>
      /// <param name="FileName">
      ///   Имя файла
      /// </param>
      procedure Extract(FileName: String);
      /// <summary>
      ///   Нормализация и центрирование
      /// </summary>
      procedure NormalizationAndCenter();
      /// <summary>
      ///   Рассчет характеристик данных: средние значения столбцов, дисперсии
      ///   столбцов
      /// </summary>
      /// <param name="AData">
      ///   Матрица данных
      /// </param>
      procedure CalcStats(AData: TMatrixDouble);
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
                  var ACovarMatrix: TMatrixDouble;var ACorrelMatrix: TMatrixDouble);
      /// <summary>
      ///   Тест нормализации и центрирования
      /// </summary>
      function TestNormalizationAndCenter():Boolean;

      constructor Create();
      destructor Destroy; override;
  end;
 { procedure Trans(var AData: TMatrixDouble);}
implementation

constructor TExtractor.Create();
begin
   DataGrid := TStringGrid.Create(nil);
end;

destructor TExtractor.Destroy;
begin
  inherited;
  FreeAndNil(FDataGrid);
end;

procedure TExtractor.LoadCSVFile(FileName: String; separator: char; Ext :Boolean = false);
var f: TextFile;
    s1, s2: string;
    i, j: integer;
    Value: Double;
begin
  FMinValue := MaxDouble;
  FMaxValue := MinDouble;

   if Ext then
    SetLength(ExtractData,10);
 i := 0;

 AssignFile (f, FileName);
 Reset(f);
 while not eof(f) do
  begin
   readln (f, s1);
   i := i + 1;
   j := 0;

   while pos(separator, s1)<>0 do
    begin
     s2 := copy(s1,1,pos(separator, s1)-1);
     j := j + 1;
     delete (s1, 1, pos(separator, S1));
     DataGrid.Cells[j-1, i-1] := s2;
     if TryStrToFloat(s2, Value) then
      begin
       if Ext then
         begin
            SetLength(ExtractData[j-1],i);
            ExtractData[j-1, i-1]:= Value;
         end;
        if Value < FMinValue then
          FMinValue := Value;
        if Value > FMaxValue then
          FMaxValue := Value;
      end;
    end;

   if pos (separator, s1)=0 then
    begin
     j := j + 1;
     DataGrid.Cells[j-1, i-1] := s1;
     if TryStrToFloat(s1, Value) then
      begin
        if Ext then
         begin
            SetLength(ExtractData[j-1],i);
            ExtractData[j-1, i-1]:= Value;
         end;
        if Value < FMinValue then
          FMinValue := Value;
        if Value > FMaxValue then
          FMaxValue := Value;
      end;
    end;
   DataGrid.ColCount := j;
    if Ext then
    SetLength(ExtractData,DataGrid.ColCount);
   FColCount := DataGrid.ColCount;
   DataGrid.RowCount := i+1;
   FRowCount := DataGrid.RowCount;
  end;
 CloseFile(f);

 for i := 0 to DataGrid.ColCount-1 do
 begin
   if ExtractData[i] = nil then DataGrid.ColCount := DataGrid.ColCount-1;
    SetLength(ExtractData,DataGrid.ColCount);
 end;

end;


procedure TExtractor.Extract(FileName: String);
var f: TextFile;
//    s1, s2: string;
    Row1, Row2,Count: integer;
    Time1,Time2: TDateTime;
    latency,HoldTime,CPM : double;
    CodeChar : integer;
    Characters: integer;
begin
    FMinValue := MaxDouble;
    FMaxValue := MinDouble;
    Count := 0;
    SetLength(ExtractData,DataGrid.ColCount);

    AssignFile(f, ExtractFilePath(Application.ExeName) + 'feature_'+ FileName + '.csv');
    if FileExists(ExtractFilePath(Application.ExeName) + 'feature_'+ FileName + '.csv') = False then
    begin
      Rewrite(f);
      WriteLn(f,'Latency;HoldTime;CPM');
    end
    else
      Append(f);

  Characters :=0;
  //Row1 :=1;
  //while Row1 < DataGrid.RowCount-1  do
  for Row1 :=1 to DataGrid.RowCount-1 do
  begin
    if DataGrid.Cells[0,Row1] = '256' then
     begin
        Time1 := ExtractDateTime(DataGrid.Cells[6,Row1]);
        CodeChar := StrToInt(DataGrid.Cells[2,Row1]);
        for Row2 := Row1+1 to DataGrid.RowCount-1 do
        begin
          if (DataGrid.Cells[0,Row2] = '256') and (CodeChar <> StrToInt(DataGrid.Cells[2,Row2]))then
            begin
              Time2 := ExtractDateTime(DataGrid.Cells[6,Row2]);
              latency := MilliSecondsBetween(Time1,Time2);
                  if latency < FMinValue then
                    FMinValue := latency;
                  if latency > FMaxValue then
                    FMaxValue := latency;
              break;
            end;
        end;

        for Row2 := Row1+1 to DataGrid.RowCount-1 do
        begin
          if (DataGrid.Cells[0,Row2] = '257') and (CodeChar = StrToInt(DataGrid.Cells[2,Row2]))then
            begin
              Characters := Characters + 1;
              if MilliSecondsBetween(ExtractDateTime(DataGrid.Cells[6,1]),(ExtractDateTime(DataGrid.Cells[6,Row2]))) >60000 then
              begin
                CPM := Characters/(MilliSecondsBetween(ExtractDateTime(DataGrid.Cells[6,1]),(ExtractDateTime(DataGrid.Cells[6,Row2])))/60000);
                  if CPM < FMinValue then
                    FMinValue := CPM;
                  if CPM > FMaxValue then
                    FMaxValue := CPM;
              end;

              Time2 := ExtractDateTime(DataGrid.Cells[6,Row2]);
              HoldTime:= MilliSecondsBetween(Time1,Time2);
                  if HoldTime < FMinValue then
                    FMinValue := HoldTime;
                  if HoldTime > FMaxValue then
                    FMaxValue := HoldTime;
              if (latency < 1500) and (HoldTime < 1500) then
              begin
                WriteLn(f,latency.ToString() +';'+HoldTime.ToString()+';'+ CPM.ToString()+';');
                ExtractData[0,Count] := latency;
                ExtractData[1,Count] := HoldTime;
                ExtractData[2,Count] := CPM;
                SetLength(ExtractData,Count + 1);
                Count := Count + 1;
              end;


              break;
            end;
        end;
     end;
  end;


                   {
                if tmp_df.Event_Type[256]DataGrid=='KeyDown':
                    flag=1
                    chars=[tmp_df.Key_Code[j],tmp_df.Shift[j],tmp_df.Key_Code[k],tmp_df.Shift[k]]
                    latency=tmp_df.Time[k]-tmp_df.Time[j]
                    break
 {i := 0;

    AssignFile(f, ExtractFilePath(Application.ExeName) +  FileNameLog + '.csv');
    if FileExists(ExtractFilePath(Application.ExeName) +  FileNameLog + '.csv') = False then
      Rewrite(f)
    else
      Append(f);
    WriteLn(f,'Latency;HoldTime;CPM');



    for I := Low to High do
            }
 CloseFile(f);
end;

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

procedure TExtractor.CalcStats(AData: TMatrixDouble);
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

procedure TExtractor.NormalizationAndCenter();
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
 {
procedure Trans(var AData: TMatrixDouble);
var Col,Row: integer;
  tempData: TMatrixDouble;
begin
  SetLength(tempData,Length(AData));
  for Col := 0 to Length(AData)-1 do
    for Row := 0 to Length(AData[Col])-1 do
    begin
      SetLength(tempData[Col],Length(AData[Col]));
      tempData[Row,Col]:= AData[Col, Row];
    end;

  AData := tempData;
end; }

function TExtractor.TestNormalizationAndCenter():Boolean;
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

procedure TExtractor.CalcCovarAndCorrel(AData: TMatrixDouble; AAvgValue: Array of Double;
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

end.
