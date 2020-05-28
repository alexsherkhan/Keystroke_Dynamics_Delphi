unit Feature_Extractor;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,Clipbrd,Data_Time,Vcl.Grids,DateUtils,Math,
  Lib_TRED2_TQLI2, TypesForKD;

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
      /// <summary>
      ///   Ковариляционная матрица
      /// </summary>
      CovarMatrix : TMatrixDouble;
      /// <summary>
      ///   Корреляционная матрица
      /// </summary>
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
      procedure LoadCSVFile(FileName: String; separator: char; NumCol:Integer = 14; Ext :Boolean = false);
      /// <summary>
      ///   Извлечение характеристик ввода текста с клавиатуры из файла
      /// </summary>
      /// <param name="FileName">
      ///   Имя файла
      /// </param>
      procedure Extract(FileName: String);

      constructor Create();
      destructor Destroy; override;
  end;

  /// <summary>
  ///   Сторона нажатия клавиши
  /// </summary>
  function LatencySide(x:string):string;
  /// <summary>
  ///   Категория задержки
  /// </summary>
  function Categorize(CodeChar1:string; Shift1:string;CodeChar2:string;Shift2:string):integer;

  /// <summary>
  ///   Категория времени удержания
  /// </summary>
  function HoldtimeCategorize(CodeChar1:string; Shift:string):integer;

  /// <summary>
  ///   Сбор нескольких файлов в один
  /// </summary>
  /// <param name="FileName">
  ///   Имя создаваемого файла
  /// </param>
  /// <param name="FileArray">
  ///   Массив имен файлов
  /// </param>
  procedure CollectFiles(FileName: String; FileArray :array of String);

  /// <summary>
  ///   Сумма вектора
  /// </summary>
  /// <param name="v">
  ///   Вектор
  /// </param>
  function SumVestor(v:TVector):Double;


  var Side_dict : array [0..58,0..1] of string
 =
  (
   ('192','l'),('49','l'),('50','l'),('51','l'),('52','l'),('53','l'),
   ('9','l'),('81','l'),('87','l'),('69','l'),('82','l'),('84','l'),
   ('20','l'),('65','l'),('83','l'),('68','l'),('70','l'),('71','l'),
   ('160','l'),('90','l'),('80','l'),('67','l'),('86','l'),('66','l'),
   ('17','l'),

   ('54','r'),('55','r'),('56','r'),('57','r'),('58','r'),('189','r'),('197','r'),('8','r'),
   ('89','r'),('85','r'),('73','r'),('79','r'),('80','r'),('219','r'),('221','r'),('13','r'),
   ('72','r'),('74','r'),('75','r'),('76','r'),('186','r'),('222','r'),
   ('78','r'),('77','r'),('188','r'),('190','r'),('191','r'),('161','r'),('38','r'),
   ('93','r'),('163','r'),('37','r'),('40','r'),('39','r')
  );
  HoldtimeCategory: array [0..5,0..1] of string
  =
  (
    ('l','F'),('r','F'),('l','T'),('r','T'),('E','F'),('E','T')
  );

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

function LatencySide(x:string):string;
var i: integer;
begin
  for i := 0 to Length(Side_dict)-1 do
      begin
        if Side_dict[i,0] = x then
          Result := Side_dict[i,1]
        else
          continue;
      end;
end;

function Categorize(CodeChar1:string; Shift1:string;CodeChar2:string;Shift2:string):integer;
var
  s, c1,c2: string;
begin
  c1 := LatencySide(CodeChar1);
  if (Shift1 ='128') or (Shift1 ='129') then
     c1:= UpperCase(c1);

  c2 := LatencySide(CodeChar2);
  if (Shift2 ='128') or (Shift2 ='129') then
     c1:= UpperCase(c2);

     //latency  lr,rl,Lr,Rl,Ll,Rr,ll,rr
  s := c1+ c2;

   if s = 'lr' then Result :=0
   else if s = 'rl' then Result :=1
   else if s = 'Lr' then Result :=2
   else if s = 'Rl' then Result :=3
   else if s = 'Ll' then Result :=4
   else if s = 'Rr' then Result :=5
   else if s = 'll' then Result :=6
   else if s = 'rr' then Result :=7;


end;

function HoldtimeCategorize(CodeChar1:string; Shift:string):integer;
var
  s: string;
begin
  s := LatencySide(CodeChar1);
  if (Shift ='128') or (Shift ='129') then
     s:= UpperCase(s);

   if s = 'l' then Result :=0
   else if s = 'r' then Result :=1
   else if s = 'L' then Result :=2
   else if s = 'R' then Result :=3;

   if (CodeChar1 ='13') then
      Result :=4
end;

procedure TExtractor.LoadCSVFile(FileName: String; separator: char; NumCol:Integer = 14; Ext :Boolean = false);
var f: TextFile;
    s1, s2: string;
    i, j: integer;
    Value: Double;
begin
  FMinValue := MaxDouble;
  FMaxValue := MinDouble;

   if Ext then
    SetLength(ExtractData,NumCol);
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

 if Ext then
 for i := 0 to DataGrid.ColCount-1 do
 begin
   if ExtractData[i] = nil then DataGrid.ColCount := DataGrid.ColCount-1;
    SetLength(ExtractData,DataGrid.ColCount);
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

procedure CollectFiles(FileName: String; FileArray :array of String);
var f,f2: TextFile;
i :Integer;
s : String;
k : Boolean;
begin

   AssignFile(f,'./Data/'+FileName +'_all' + '.csv');
   Rewrite(f);
   k:= false;

   for i := 0 to High(FileArray) do
   begin
    AssignFile(f2,FileArray[i]);
    if FileExists(FileArray[i]) then
      Reset(f2);

    while (not EOF(f2)) do begin
      Readln(f2, s);
      if i = 0 then k:=true;
      
      if k then
        WriteLn(f, s);
      k := true;
    end;
    k:= false;
      Close(f2);
   end;

   Close(f);
end;

procedure TExtractor.Extract(FileName: String);
var f: TextFile;
    i,j,Row1, Row2,Count: integer;
    Time1,Time2: TDateTime;
    //latency,
    SumLatency,SumHoldTime, {HoldTime,}CPM : double;
    latency,HoldTime : TVector;  //lr,rl,Lr,Rl,Ll,Rr,ll,rr
    CodeChar : integer;
    Characters: integer;
    LatencyCategory,HCategory: integer;
    latencyStr,HoldTimeStr,FileStr : string;
    SumVestors : TVector;
begin
    FMinValue := MaxDouble;
    FMaxValue := MinDouble;
    Count := 0;
    SetLength(ExtractData,14);
    SetLength(latency,8);
    SetLength(HoldTime,5);

   AssignFile(f,Copy(FileName,0,Length(FileName)-4) +'_feature' + '.csv');
    if FileExists(Copy(FileName,0,Length(FileName)-4) +'_feature' + '.csv') = False then
    begin
      Rewrite(f);
      WriteLn(f,'lr;rl;Lr;Rl;Ll;Rr;ll;rr;l;r;L;R;E;CPM');
    end
    else
      Append(f);

  Characters :=0;
  for Row1 :=1 to DataGrid.RowCount-1 do
  begin
    if DataGrid.Cells[0,Row1] = '256' then
     begin
        Time1 := ExtractDateTime(DataGrid.Cells[6,Row1]);
        CodeChar := StrToInt(DataGrid.Cells[2,Row1]);
        if (CodeChar = 160) or (CodeChar = 161) or ('Timestamp' = DataGrid.Cells[2,Row1]) then
          continue;
        for Row2 := Row1+1 to DataGrid.RowCount-1 do
        begin
          if (DataGrid.Cells[0,Row2] = '256') and (CodeChar <> StrToInt(DataGrid.Cells[2,Row2]))
          and ('Timestamp' <> DataGrid.Cells[2,Row2]) then
            begin
              Time2 := ExtractDateTime(DataGrid.Cells[6,Row2]);
              LatencyCategory := Categorize(DataGrid.Cells[2,Row1],
                  DataGrid.Cells[3,Row1],DataGrid.Cells[2,Row2],
                  DataGrid.Cells[3,Row2]);
              if  ('Timestamp' <> DataGrid.Cells[6,Row2-1]) and ('Timestamp' <> DataGrid.Cells[6,Row2]) then
              latency[LatencyCategory] := MilliSecondsBetween(ExtractDateTime(DataGrid.Cells[6,Row2-1]),Time2)/1000;
                  if latency[LatencyCategory] < FMinValue then
                    FMinValue := latency[LatencyCategory];
                  if latency[LatencyCategory] > FMaxValue then
                    FMaxValue := latency[LatencyCategory];
              break;
            end;
        end;

        for Row2 := Row1+1 to DataGrid.RowCount-1 do
        begin
          if (DataGrid.Cells[0,Row2] = '257') and (CodeChar = StrToInt(DataGrid.Cells[2,Row2]))then
            begin
              Characters := Characters + 1;

              if MilliSecondsBetween(ExtractDateTime(DataGrid.Cells[6,1]),(ExtractDateTime(DataGrid.Cells[6,Row2]))) >600 then
              begin
                CPM := Characters/(MilliSecondsBetween(ExtractDateTime(DataGrid.Cells[6,1]),(ExtractDateTime(DataGrid.Cells[6,Row2])))/60000);
                  if CPM < FMinValue then
                    FMinValue := CPM;
                  if CPM > FMaxValue then
                    FMaxValue := CPM;
              end;

              Time2 := ExtractDateTime(DataGrid.Cells[6,Row2]);
              HCategory:= HoldtimeCategorize(DataGrid.Cells[2,Row1],
                  DataGrid.Cells[3,Row1]);
              HoldTime[HCategory]:= MilliSecondsBetween(Time1,Time2)/1000;
                  if HoldTime[HCategory] < FMinValue then
                    FMinValue := HoldTime[HCategory];
                  if HoldTime[HCategory] > FMaxValue then
                    FMaxValue := HoldTime[HCategory];
              if (latency[LatencyCategory] < 1500) and (HoldTime[HCategory] < 1500) and (CPM <>0) then
              begin
                SumLatency := SumVestor(latency);
                SumHoldTime := SumVestor(HoldTime);
                {
                for i :=0 to High(latency) do
                   if i<>LatencyCategory then
                    latency[i] := (SumLatency+ SumHoldTime +CPM)/(Length(latency)+Length(HoldTime)+1);

                for i :=0 to High(HoldTime) do
                   if i<>HCategory then
                    HoldTime[i] := (SumLatency+ SumHoldTime +CPM)/(Length(latency)+Length(HoldTime)+1);
                }
                latencyStr :='';
                HoldTimeStr := '';

                for i :=0 to High(latency) do
                begin
                  SetLength(ExtractData[i],Count + 1);
                 // if i<High(latency)+1 then
                  begin
                    ExtractData[i,Count] := latency[i];
                   // latencyStr :=latencyStr + latency[i].ToString()+';'
                  end;
                end;

                for i :=0 to High(HoldTime) do
                begin
                  SetLength(ExtractData[i+High(latency)+1],Count + 1);

                    ExtractData[i+High(latency)+1,Count] := HoldTime[i];
                   // HoldTimeStr :=HoldTimeStr + HoldTime[i-High(latency)].ToString()+';'
                end;

                //WriteLn(f,latencyStr+HoldTimeStr+ CPM.ToString()+';');
                  SetLength(ExtractData[High(latency)+High(HoldTime)+2],Count + 1);
                  ExtractData[High(latency)+High(HoldTime)+2,Count] := CPM;

                  for i :=0 to High(latency) do
                  begin
                    latency[i] := 0;
                  end;

                  for i :=0 to High(HoldTime) do
                  begin
                    HoldTime[i] := 0;
                  end;

                Count := Count + 1;
              end;


              break;
            end;
        end;
     end;
  end;

  SetLength(SumVestors,Length(ExtractData));
  for i :=0 to High(ExtractData) do
    SumVestors[i] := SumVestor(TVector(ExtractData[i]));

  for i :=0 to High(ExtractData) do
    for j :=0 to High(ExtractData[i]) do
      if ExtractData[i,j]=0 then
        ExtractData[i,j] := SumVestors[i] / High(ExtractData[i]);

  for i :=0 to High(ExtractData[1]) do
  begin
    for j :=0 to High(ExtractData) do
    begin
      FileStr :=FileStr + ExtractData[j,i].ToString()+';';
    end;
   WriteLn(f,FileStr);
   FileStr :='';
  end;



 CloseFile(f);
end;

end.
