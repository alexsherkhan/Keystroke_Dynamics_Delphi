unit UnitKeystrokeDynamics;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Generics.Collections,Keylogger,
  Vcl.StdCtrls, Vcl.Grids, VCLTee.Chart,Feature_Extractor
  ,Data_Time,DateUtils, TypesForKD, Vcl.Imaging.pngimage, VCLTee.Series,
  Vcl.ComCtrls, Lib_TRED2_TQLI2,PCA,FCM, VclTee.TeeGDIPlus, VCLTee.TeEngine,
  Vcl.ExtCtrls, VCLTee.TeeProcs,Math, UnitDataAfterPCA;

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
    PCA: TPointSeries;
    CheckBox4: TCheckBox;
    Button4: TButton;
    GroupBox2: TGroupBox;
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

  fileArray : array [0..2] of String =
  (
    '.\Data\keylog_kirill_feature.csv',
    '.\Data\keylog_alex_feature.csv',
    '.\Data\keylog_witaly_feature.csv'
  );
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
    ext := TExtractor.Create();
    //CollectFiles('data',fileArray);
    ext.LoadCSVFile(opendialog1.FileName,';',2,true);
    PCObj := TPCA.Create(ext);
    PCObj.CalcPC(true,10);

    SetLength(PC_Data,Length(fileArray));

    PC_Data[0] := PCObj.PC;
      for i :=0 to Length(PCObj.PC)-1 do
      begin
       for j :=0 to Length(PCObj.PC[0])-1 do
        begin
           Chart1.Series[0].AddXY(PCObj.PC[0,j] ,PCObj.PC[1,j]);
        end;
      end;

  end;
      for j :=0 to Length(PC_Data[0])-1 do
    begin
       ComboBox1.Items.Add((j+1).ToString());
       ComboBox2.Items.Add((j+1).ToString());
    end;

    ComboBox1.ItemIndex := 0;
    ComboBox2.ItemIndex := 1;
  ShowMessage('Рассчет PCA успешен');
  FormDataPCA.ObjPCA := PCObj;
  FormDataPCA.left:=FormKeystrokeDynamics.left;
  FormDataPCA.top:=FormKeystrokeDynamics.top;
  FormDataPCA.Show;

  FreeAndNil(ext);
  FreeAndNil(PCObj);

  ButtonShowClick(nil);
end;

procedure TFormKeystrokeDynamics.Button4Click(Sender: TObject);
var
  i,j,Row, color,index: integer;
  fcmObj : TFCM;
  v,centrs :TVectorPoints;
  matrix : TMatrixDouble;
  vec,dis: TVector;
  minv ,maxdis: Double;
begin


  Button3Click(nil);

  SetLength(v,Length(PC_Data[0][0]));
  for Row :=0 to Length(PC_Data[0][0])-1 do
        begin
           v[Row].x:= PC_Data[0][0,Row];
           v[Row].y:= PC_Data[0][1,Row];
        end;

  // FCM
  fcmObj := TFCM.Create(0.1,1000,Length(v),3);

   matrix := fcmObj.DistributeOverMatrixU(v,fcmObj.Fuzz,centrs);


   for i :=0 to Length(v)-1 do
        begin
        //  Memo1.Lines.Add(i.ToString()+'|  '+v[i].x.ToString()+'|  '+v[i].y.ToString());
        end;

       for i :=0 to Length(matrix)-1 do
        begin
       //   Memo1.Lines.Add(i.ToString()+'|  '+matrix[i,0].ToString()+'|  '+matrix[i,1].ToString()+'|  '+matrix[i,2].ToString());
        end;
  Chart1.Series[1].Clear;

        SetLength(vec,fcmObj.ClustersNum);
        SetLength(dis,fcmObj.ClustersNum);
       for Row :=0 to Length(v)-1 do
        begin

            for i :=0 to Length(vec)-1 do
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

           Chart1.Series[1].AddXY(v[Row].x ,v[Row].y,'',color);
        end;

     Chart1.Series[1].AddXY(centrs[0].x,centrs[0].y,'',32768);
     Chart1.Series[1].AddXY(centrs[1].x,centrs[1].y,'',16776960);
     Chart1.Series[1].AddXY(centrs[2].x,centrs[2].y,'',32896);

  FormDataPCA.ObjPCA := PCObj;
  FormDataPCA.left:=FormKeystrokeDynamics.left;
  FormDataPCA.top:=FormKeystrokeDynamics.top;
  FormDataPCA.Show;

  FreeAndNil(ext);
  FreeAndNil(PCObj);
  FreeAndNil(fcmObj);
end;

procedure TFormKeystrokeDynamics.ButtonShowClick(Sender: TObject);
 var
  Row,i: integer;
begin
  Chart1.Series[0].Clear;

   for Row :=0 to Length(PC_Data[0][ComboBox1.ItemIndex])-1 do
    begin
       Chart1.Series[0].AddXY(PC_Data[0][ComboBox1.ItemIndex,Row] ,PC_Data[0][ComboBox2.ItemIndex,Row]);
    end;
 Chart1.Series[1].Clear;
    for Row :=0 to Length(PC_Data[0][ComboBox1.ItemIndex])-1 do
    begin
       Chart1.Series[1].AddXY(PC_Data[0][ComboBox1.ItemIndex,Row] ,PC_Data[0][ComboBox2.ItemIndex,Row]);
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
   PCA.Visible := CheckBox4.Checked;
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
