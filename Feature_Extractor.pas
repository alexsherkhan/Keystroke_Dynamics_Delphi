unit Feature_Extractor;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,Clipbrd,Data_Time,Vcl.Grids,DateUtils,Math;

type
  TExtractor = class(TObject)
    private
      FDataGrid : TStringGrid;
      FNormDataGrid : TStringGrid;
      FMinValue: Double;
      FMaxValue: Double;
      FAvgValue: Double;
      FColCount: Integer;
      FRowCount: Integer;
    public
      property DataGrid: TStringGrid read FDataGrid write FDataGrid;
      property NormDataGrid: TStringGrid read FNormDataGrid write FNormDataGrid;
      property MinValue: Double read FMinValue write FMinValue;
      property MaxValue: Double read FMaxValue write FMaxValue;
      property AvgValue: Double read FAvgValue write FAvgValue;
      property ColCount: Integer read FColCount write FColCount;
      property RowCount: Integer read FRowCount write FRowCount;

      procedure LoadCSVFile(FileName: String; separator: char);
      procedure Extract(FileName: String);
      procedure Normalization();
      procedure CalcStats(AStringGrid: TStringGrid);

      constructor Create();
      destructor Destroy; override;
  end;
implementation

constructor TExtractor.Create();
begin
   DataGrid := TStringGrid.Create(nil);
   NormDataGrid := TStringGrid.Create(nil);
end;

destructor TExtractor.Destroy;
begin
  inherited;
  FreeAndNil(FDataGrid);
  FreeAndNil(FNormDataGrid);
end;

procedure TExtractor.LoadCSVFile(FileName: String; separator: char);
var f: TextFile;
    s1, s2: string;
    i, j: integer;
    Value: Double;
begin
  FMinValue := MaxDouble;
  FMaxValue := MinDouble;
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
        if Value < FMinValue then
          FMinValue := Value;
        if Value > FMaxValue then
          FMaxValue := Value;
      end;
    end;

   if pos (separator, s1)=0 then
    begin
     j := j + 1;
     DataGrid .Cells[j-1, i-1] := s1;
     if TryStrToFloat(s1, Value) then
      begin
        if Value < FMinValue then
          FMinValue := Value;
        if Value > FMaxValue then
          FMaxValue := Value;
      end;
    end;
   DataGrid.ColCount := j;
   FColCount := DataGrid.ColCount;
   DataGrid.RowCount := i+1;
   FRowCount := DataGrid.RowCount;
  end;
 CloseFile(f);
end;


procedure TExtractor.Extract(FileName: String);
var f: TextFile;
//    s1, s2: string;
    Row1, Row2: integer;
    Time1,Time2: TDateTime;
    latency,HoldTime,CPM : double;
    CodeChar : integer;
    Characters: integer;
    Value: Double;
begin
    FMinValue := MaxDouble;
    FMaxValue := MinDouble;

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
                WriteLn(f,latency.ToString() +';'+HoldTime.ToString()+';'+ CPM.ToString()+';');

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


procedure TExtractor.CalcStats(AStringGrid: TStringGrid);
var
  Col, Row, Count: Integer;
  Value: Double;
begin
  Count := 0;
  FMinValue := MaxDouble;
  FMaxValue := MinDouble;
  FAvgValue := 0;

  for Col := AStringGrid.Selection.Left to AStringGrid.Selection.Right do
    for Row := AStringGrid.Selection.Top to AStringGrid.Selection.Bottom do
    begin
      if TryStrToFloat(AStringGrid.Cells[Col, Row], Value) then
      begin
        Inc(Count);
        if Value < FMinValue then
          FMinValue := Value;
        if Value > FMaxValue then
          FMaxValue := Value;
        FAvgValue := FAvgValue + Value;
      end;
    end;

  if Count > 0 then
  begin
    FMinValue := FMinValue;
    FMaxValue := FMaxValue;
    FAvgValue := FAvgValue / Count;
  end;
end;

procedure TExtractor.Normalization();
var Col, Row: integer;
str : string;
begin

 for Row :=1 to DataGrid.RowCount-1 do
  begin
    for Col := 0 to DataGrid.ColCount-1 do
    begin
       if not (DataGrid.Cells[Col,Row] = '') then
       NormDataGrid.Cells[Col,Row]:= FloatToStr((StrToFloat(DataGrid.Cells[Col,Row])- MinValue)/(MaxValue-MinValue));
    end;
  end;

end;

end.
