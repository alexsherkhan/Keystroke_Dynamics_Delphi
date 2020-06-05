unit UnitKeystrokeDynamics;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Generics.Collections,Keylogger,
  Vcl.StdCtrls, Vcl.Grids, VCLTee.Chart,Feature_Extractor
  ,Data_Time,DateUtils, TypesForKD, Vcl.Imaging.pngimage, VCLTee.Series,
  Vcl.ComCtrls, Lib_TRED2_TQLI2,PCA,FCM, VclTee.TeeGDIPlus, VCLTee.TeEngine,
  Vcl.ExtCtrls, VCLTee.TeeProcs,Math, UnitDataAfterPCA,AuthKD;

type
  TFormKeystrokeDynamics = class(TForm)
    Button1: TButton;
    GroupBox1: TGroupBox;
    EditNameUser: TEdit;
    EditUserText: TEdit;
    ButtonStart: TButton;
    Button2: TButton;
    LabelStatus: TLabel;
    Memo1: TMemo;
    Button3: TButton;
    CheckBox1: TCheckBox;
    Chart1: TChart;
    FCM: TPointSeries;
    OpenDialog1: TOpenDialog;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ButtonShow: TButton;
    Label4: TLabel;
    Label5: TLabel;
    A: TPointSeries;
    CheckBox4: TCheckBox;
    Button4: TButton;
    GroupBox2: TGroupBox;
    Button5: TButton;
    B: TPointSeries;
    Button6: TButton;
    C: TPointSeries;
    New: TPointSeries;
    LabelAuth: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure EditNameUserClick(Sender: TObject);
    procedure EditUserTextClick(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ButtonShowClick(Sender: TObject);
    procedure ComboBox1Select(Sender: TObject);
    procedure ComboBox2Select(Sender: TObject);
    procedure CheckBox4Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormKeystrokeDynamics: TFormKeystrokeDynamics;
  logger : TKeylogger;
  f: TextFile;
  ext: TExtractor;
  PCObj: TPCA;
  PC_Data :array of TMatrixDouble;
  new_PC_Data : array of TMatrixDouble;
  split:TMatrixDouble;
  countClasters : Integer;
  Users: array [0..2] of String =
  (
    'A',
    'B',
    'C'
  );
  fileArray : array [0..2] of String =
  (
    '.\Data\keylog_alina_feature.csv',
    '.\Data\keylog_alex_new_feature.csv',
    '.\Data\keylog_witaly_feature.csv'
  );
  const PC_x =7;
  PC_y = 11;
implementation

{$R *.dfm}


procedure TFormKeystrokeDynamics.Button1Click(Sender: TObject);
var
  ext: TExtractor ;
begin
  ext := TExtractor.Create();
  if opendialog1.Execute then
  begin
    ext.LoadCSVFile( opendialog1.FileName ,';');
    ext.Extract(opendialog1.FileName);
    ShowMessage('Успешно');
  end;
 FreeAndNil(ext);
end;

procedure TFormKeystrokeDynamics.Button2Click(Sender: TObject);
begin
  logger.Active := false;
  LabelStatus.Caption := 'Статус: Нет сбора данных';
end;

procedure TFormKeystrokeDynamics.Button3Click(Sender: TObject);
var
  i,j: integer;
begin
   {
  for i :=0 to Length(fileArray)-1 do
  begin
    Chart1.Series[i].Clear;
    ext := TExtractor.Create();
    ext.LoadCSVFile(fileArray[i],';',14,true);
    //ext.CalcStats(ext.ExtractData);
    PCObj := TPCA.Create(ext);
    PCObj.CalcPC(true,10);

    SetLength(PC_Data,Length(fileArray));

    PC_Data[i] := PCObj.PC;

    FreeAndNil(ext);
    FreeAndNil(PCObj);
  end; }

   if opendialog1.Execute then
  begin
    Chart1.Series[0].Clear;
    Chart1.Series[1].Clear;
    Chart1.Series[2].Clear;
    Chart1.Series[3].Clear;
    ext := TExtractor.Create();
    //CollectFiles('data',fileArray);
    ext.LoadCSVFile(opendialog1.FileName,';',2,true);
    PCObj := TPCA.Create(ext);
    PCObj.CalcPC(true,14);

    SetLength(PC_Data,Length(fileArray));

    PC_Data[0] := PCObj.PC;
     // for i :=0 to Length(PCObj.PC)-1 do
     // begin
       for j :=0 to 161-1 do
        begin
           Chart1.Series[0].AddXY(PCObj.PC[0,j] ,PCObj.PC[1,j]);
        end;
         for j :=162 to 322-1 do
        begin
           Chart1.Series[1].AddXY(PCObj.PC[0,j] ,PCObj.PC[1,j]);
        end;
        for j :=323 to 501-1 do
        begin
           Chart1.Series[2].AddXY(PCObj.PC[0,j] ,PCObj.PC[1,j]);
        end;
     //end;


      for j :=0 to Length(PC_Data[0])-1 do
    begin
       ComboBox1.Items.Add((j+1).ToString());
       ComboBox2.Items.Add((j+1).ToString());
    end;

    ComboBox1.ItemIndex := PC_x;
    ComboBox2.ItemIndex := PC_y;
  ShowMessage('Рассчет PCA успешен');
  FormDataPCA.ObjPCA := PCObj;
  FormDataPCA.left:=FormKeystrokeDynamics.left;
  FormDataPCA.top:=FormKeystrokeDynamics.top;
  FormDataPCA.Show;

  //FreeAndNil(ext);
  //FreeAndNil(PCObj);

  ButtonShowClick(nil);
  end;
end;



procedure TFormKeystrokeDynamics.Button4Click(Sender: TObject);
var
  i,Row, color,index, count: integer;
  fcmObj : TFCM;
  v,centrs :TVectorPoints;
  matrix,temp_matrix : TMatrixDouble;
  vec,dis: TVector;
begin
  count :=0;

  Button3Click(nil);

  SetLength(v,Length(PC_Data[0][0]));
  for Row :=0 to Length(PC_Data[0][0])-1 do // while T do
        begin
          if (PC_Data[0][PC_y,Row]>1.5) or (PC_Data[0][PC_y,Row]<-1.5)
          or (PC_Data[0][PC_x,Row]>1.5) or (PC_Data[0][PC_x,Row]<-1.5) then
          Continue;

           v[count].x:= PC_Data[0][PC_x,Row];
           v[count].y:= PC_Data[0][PC_y,Row];
           count := count +1;
        end;

   SetLength(v,count+1);
  // FCM
  fcmObj := TFCM.Create(0.1,1000,Length(v),3);

   matrix := fcmObj.DistributeOverMatrixU(v,fcmObj.Fuzz,centrs);
   countClasters := fcmObj.ClustersNum;
   SortMatrixPoint(matrix,centrs,'y');


       FindMatrixPoint(matrix,v,split);
       for Row :=0 to Length(v)-1 do
        begin

            for i :=0 to Length(matrix[row])-1 do
            begin
              if matrix[row,i]>0.5 then
              begin
                index := i;
                break;
              end;
            end;

            if index = 0 then  color :=  $00359CF3;
            if index = 1 then  color := $00144CF1;
            if index = 2  then  color := $00A8974E;

           Chart1.Series[3].AddXY(v[Row].x ,v[Row].y,'',color);
        end;

     Chart1.Series[3].AddXY(centrs[0].x,centrs[0].y,'',32768);
     Chart1.Series[3].AddXY(centrs[1].x,centrs[1].y,'',16776960);
     Chart1.Series[3].AddXY(centrs[2].x,centrs[2].y,'',32896);

  FormDataPCA.ObjPCA := PCObj;
  FormDataPCA.left:=FormKeystrokeDynamics.left;
  FormDataPCA.top:=FormKeystrokeDynamics.top;
  FormDataPCA.Show;

  FreeAndNil(ext);
  //FreeAndNil(PCObj);
  FreeAndNil(fcmObj);
end;

procedure TFormKeystrokeDynamics.Button5Click(Sender: TObject);
var
  i,j: Integer;
  new_ext: TExtractor;
  new_PCObj: TPCA;
  auth_index: Integer;
  User_str: string;
begin

  if opendialog1.Execute then
  begin
    new_ext := TExtractor.Create();
    new_ext.LoadCSVFile(opendialog1.FileName,';',14,true);
    if PCObj = nil then
    begin
      ShowMessage('Ошибка загрузите первичные данные');
      FreeAndNil(new_ext);
      exit;
    end;

    new_PCObj := TPCA.Create(new_ext);
    new_PCObj.CalcStats(new_PCObj.ExtractData);
    SetLength(new_PC_Data,Length(fileArray));
    auth_index := AuthUser(PCObj,new_PCObj,new_PC_Data[0],countClasters,PC_y,split);

     Chart1.Series[4].Clear;

       for j :=0 to Length(new_PC_Data[0][0])-1 do
        begin
           Chart1.Series[4].AddXY(new_PC_Data[0][PC_x,j] ,new_PC_Data[0][PC_y,j]);
        end;

    if auth_index<>-1 then
        User_str := Users[auth_index]
      else
        User_str := 'неизвестен';

    LabelAuth.Caption := 'Пользователь ' +User_str;

    ShowMessage('Пользователь ' +User_str);
    FreeAndNil(new_PCObj);
    FreeAndNil(new_ext);
  end;

end;

procedure TFormKeystrokeDynamics.Button6Click(Sender: TObject);
begin
  CollectFiles('data_test',fileArray);
  ShowMessage('Успешно');
end;

procedure TFormKeystrokeDynamics.ButtonShowClick(Sender: TObject);
 var
  Row,i,j: integer;
begin
 { Chart1.Series[2].Clear;
   if new_PC_Data <>nil then
   for Row :=0 to Length(new_PC_Data[0][ComboBox1.ItemIndex])-1 do
    begin
       Chart1.Series[2].AddXY(new_PC_Data[0][ComboBox1.ItemIndex,Row] ,new_PC_Data[0][ComboBox2.ItemIndex,Row]);
    end;}
 {Chart1.Series[1].Clear;
    for Row :=0 to Length(PC_Data[0][ComboBox1.ItemIndex])-1 do
    begin
       Chart1.Series[1].AddXY(PC_Data[0][ComboBox1.ItemIndex,Row] ,PC_Data[0][ComboBox2.ItemIndex,Row]);
    end;                    }
    Chart1.Series[0].Clear;
    Chart1.Series[1].Clear;
    Chart1.Series[2].Clear;
     { for j :=0 to 161{Length(PCObj.PC[0])-1 do
      {  begin
           Chart1.Series[0].AddXY(PC_Data[0][ComboBox1.ItemIndex,j] ,PC_Data[0][ComboBox2.ItemIndex,j]);
        end;
         for j :=162 to 322{Length(PCObj.PC[0])-1 do
     {   begin
           Chart1.Series[1].AddXY(PC_Data[0][ComboBox1.ItemIndex,j] ,PC_Data[0][ComboBox2.ItemIndex,j]);
        end;
        for j :=323 to 501{Length(PCObj.PC[0])-1 do
      {  begin
           Chart1.Series[2].AddXY(PC_Data[0][ComboBox1.ItemIndex,j] ,PC_Data[0][ComboBox2.ItemIndex,j]);
        end;
               }
               Chart1.Series[4].Clear;
      if new_PC_Data <>nil then
        for j :=0 to Length(new_PC_Data[0][0])-1 do
       begin
           Chart1.Series[4].AddXY(new_PC_Data[0][ComboBox1.ItemIndex,j] ,new_PC_Data[0][ComboBox2.ItemIndex,j]);
        end;
end;

procedure TFormKeystrokeDynamics.ButtonStartClick(Sender: TObject);
begin
  logger.FileName := 'keylog_'+EditNameUser.Text;
  logger.Active := true;
  LabelStatus.Caption := 'Статус: Идет сбор данных...';
end;

procedure TFormKeystrokeDynamics.CheckBox1Click(Sender: TObject);
begin
  FCM.Visible := CheckBox1.Checked;
end;


procedure TFormKeystrokeDynamics.CheckBox4Click(Sender: TObject);
begin
   A.Visible := CheckBox4.Checked;
end;

procedure TFormKeystrokeDynamics.ComboBox1Select(Sender: TObject);
begin
  Label4.Caption := 'PC'+(TComboBox(Sender).ItemIndex+1).ToString();
  ButtonShowClick(nil);
end;

procedure TFormKeystrokeDynamics.ComboBox2Select(Sender: TObject);
begin
  Label5.Caption := 'PC'+(TComboBox(Sender).ItemIndex+1).ToString();
  ButtonShowClick(nil);
end;

procedure TFormKeystrokeDynamics.EditNameUserClick(Sender: TObject);
begin
  EditNameUser.Text := '';
end;

procedure TFormKeystrokeDynamics.EditUserTextClick(Sender: TObject);
begin
  EditUserText.Text := '';
end;

procedure TFormKeystrokeDynamics.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FreeAndNil(logger);
end;

procedure TFormKeystrokeDynamics.FormCreate(Sender: TObject);
begin

   // AssignFile(f, 'outfile.csv');
   // Rewrite(f); // Создать файл, если его ещё нет или очистить файл, если он есть
   // WriteLn(f,'Event_Type;Key_Code;Shift;Alt;Control;Time');
   logger := TKeylogger.Create(nil);
   LabelStatus.Caption := 'Статус: Нет сбора данных';
   //logger.Active := true;
end;

procedure TFormKeystrokeDynamics.FormDestroy(Sender: TObject);
begin
  FreeAndNil(ext);
  FreeAndNil(PCObj);
  //logger.Active := false;
 // FreeAndNil(logger);
  //CloseFile(f); // Закрыть файл
end;


end.
