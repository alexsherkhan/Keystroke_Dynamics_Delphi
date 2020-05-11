unit Feature_Extractor;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,Clipbrd,Data_Time,Vcl.Grids,DateUtils,Math;
type
  TArrayDouble = Array Of Array Of Double;

type
  TExtractor = class(TObject)
    private
      FDataGrid : TStringGrid;
      FMinValue: Double;
      FMaxValue: Double;
      FAvgValue: Array of Double;
      FDispersion: Array of Double;
      FColCount: Integer;
      FRowCount: Integer;
    public
      ExtractData : TArrayDouble;
      NormData : TArrayDouble;
      property DataGrid: TStringGrid read FDataGrid write FDataGrid;
      //property NormData: Array of Array of Double read FNormData write FNormData;
      property MinValue: Double read FMinValue write FMinValue;
      property MaxValue: Double read FMaxValue write FMaxValue;
      //property AvgValue: Array of Double read FAvgValue write FAvgValue;
      property ColCount: Integer read FColCount write FColCount;
      property RowCount: Integer read FRowCount write FRowCount;

      procedure LoadCSVFile(FileName: String; separator: char; Ext :Boolean = false);
      procedure Extract(FileName: String);
      procedure NormalizationAndCenter();
      procedure CalcStats(AData: TArrayDouble);
      function TestNormalizationAndCenter():Boolean;

      constructor Create();
      destructor Destroy; override;
  end;
implementation

constructor TExtractor.Create();
begin
   DataGrid := TStringGrid.Create(nil);
   //NormDataGrid := TStringGrid.Create(nil);
end;

destructor TExtractor.Destroy;
begin
  inherited;
  FreeAndNil(FDataGrid);
  //FreeAndNil(FNormDataGrid);
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

procedure CalcDispersion(AData:TArrayDouble; AvgValue:Array of Double; var Dispersion:Array of Double );
var
  Col, Row, Count: Integer;
  Value: Double;
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

procedure TExtractor.CalcStats(AData: TArrayDouble);
var
  Col, Row, Count: Integer;
  Value: Double;
  Sum2Difference: Array of Double;
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
  Value: Double;
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

function TExtractor.TestNormalizationAndCenter():Boolean;
var Col,Row: integer;
  Av: Array of Double;
  Disp: Array of Double;
begin
  SetLength(Av,Length(NormData));
  SetLength(Disp,Length(NormData));

  for Col := 0 to Length(NormData)-1 do
    for Row := 0 to Length(NormData[Col])-1 do
      Av[Col]:= Av[Col] + NormData[Col, Row];

   for Col := 0 to Length(NormData)-1 do
   begin
      Av[Col]:= Av[Col] / Length(NormData[Col]);
      Av[Col]:= abs(RoundTo(Av[Col],-3));
   end;

   CalcDispersion(NormData,Av,Disp);

   for Col := 0 to Length(NormData)-1 do
   begin
      Disp[Col]:= abs(RoundTo(Disp[Col],-3));
   end;

   Result := (Av[0]=0) and (Disp[0]=1);

end;



end.
