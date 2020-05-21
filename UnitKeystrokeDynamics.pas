unit UnitKeystrokeDynamics;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Generics.Collections,Keylogger,
  Vcl.StdCtrls, Vcl.Grids, VclTee.TeeGDIPlus, VCLTee.TeEngine,
  Vcl.ExtCtrls, VCLTee.TeeProcs, VCLTee.Chart,Feature_Extractor
  ,Data_Time,DateUtils, Vcl.Imaging.pngimage, VCLTee.Series,
  Vcl.ComCtrls, Lib_TRED2_TQLI2,PCA;

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
    CheckBox2: TCheckBox;
    TrackBarRotation: TTrackBar;
    TrackBarElevation: TTrackBar;
    TrackBarZoom: TTrackBar;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Chart1: TChart;
    Data1: TPointSeries;
    Data2: TPointSeries;
    OpenDialog1: TOpenDialog;
    Data3: TPointSeries;
    CheckBox3: TCheckBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ButtonShow: TButton;
    Label4: TLabel;
    Label5: TLabel;
    DataAll: TPointSeries;
    CheckBox4: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure EditNameUserClick(Sender: TObject);
    procedure EditUserTextClick(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure TrackBarRotationChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CheckBox3Click(Sender: TObject);
    procedure ButtonShowClick(Sender: TObject);
    procedure ComboBox1Select(Sender: TObject);
    procedure ComboBox2Select(Sender: TObject);
    procedure CheckBox4Click(Sender: TObject);
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
    '.\Data\keylog_alina_feature.csv',
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

  for i :=0 to Length(fileArray)-1 do
  begin
    Chart1.Series[i].Clear;
    ext := TExtractor.Create();
    ext.LoadCSVFile(fileArray[i],';',true);
    ext.CalcStats(ext.ExtractData);
    PCObj := TPCA.Create(ext);
    PCObj.CalcPC();

    SetLength(PC_Data,Length(fileArray));

    PC_Data[i] := PCObj.PC;

    FreeAndNil(ext);
    FreeAndNil(PCObj);
  end;
      for j :=0 to Length(PC_Data[0])-1 do
    begin
       ComboBox1.Items.Add((j+1).ToString());
       ComboBox2.Items.Add((j+1).ToString());
    end;

    ComboBox1.ItemIndex := 0;
    ComboBox2.ItemIndex := 1;
  ShowMessage('Рассчет PCA успешен');
  ButtonShowClick(nil);
end;

procedure TFormKeystrokeDynamics.ButtonShowClick(Sender: TObject);
 var
  Row,i: integer;
begin
  Chart1.Series[0].Clear;
  for i :=0 to Length(fileArray)-1 do
  begin
   for Row :=0 to Length(PC_Data[i][ComboBox1.ItemIndex])-1 do
    begin
       Chart1.Series[0].AddXY(PC_Data[i][ComboBox1.ItemIndex,Row] ,PC_Data[i][ComboBox2.ItemIndex,Row]);
    end;
  end;

  for i :=0 to Length(fileArray)-1 do
  begin
   Chart1.Series[i+1].Clear;
   Chart1.Series[i+1].Title := Copy(fileArray[i],15,Length(fileArray[i])-14);
   for Row :=0 to Length(PC_Data[i][ComboBox1.ItemIndex])-1 do
    begin
       Chart1.Series[i+1].AddXY(PC_Data[i][ComboBox1.ItemIndex,Row] ,PC_Data[i][ComboBox2.ItemIndex,Row]);
    end;
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
  Data1.Visible := CheckBox1.Checked;
end;

procedure TFormKeystrokeDynamics.CheckBox2Click(Sender: TObject);
begin
   Data2.Visible := CheckBox2.Checked;
end;

procedure TFormKeystrokeDynamics.CheckBox3Click(Sender: TObject);
begin
   Data3.Visible := CheckBox3.Checked;
end;

procedure TFormKeystrokeDynamics.CheckBox4Click(Sender: TObject);
begin
   DataAll.Visible := CheckBox4.Checked;
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
  // TrackBarRotation.Position := Chart1.View3DOptions.Rotation;
  // TrackBarElevation.Position := Chart1.View3DOptions.Elevation;
  // TrackBarZoom.Position := Chart1.View3DOptions.Zoom;
   // AssignFile(f, 'outfile.csv');
   // Rewrite(f); // Создать файл, если его ещё нет или очистить файл, если он есть
   // WriteLn(f,'Event_Type;Key_Code;Shift;Alt;Control;Time');
   logger := TKeylogger.Create(nil);
   LabelStatus.Caption := 'Статус: Нет сбора данных';
   //logger.Active := true;
end;

procedure TFormKeystrokeDynamics.FormDestroy(Sender: TObject);
begin
  //logger.Active := false;
 // FreeAndNil(logger);
  //CloseFile(f); // Закрыть файл
end;

procedure TFormKeystrokeDynamics.TrackBarRotationChange(Sender: TObject);
begin
  // Chart1.View3DOptions.Rotation := TrackBarRotation.Position;
  // Chart1.View3DOptions.Elevation := TrackBarElevation.Position;
  // Chart1.View3DOptions.Zoom := TrackBarZoom.Position;
  Chart1.ZoomPercent(100 - TrackBarZoom.Position);
  Chart1.LeftAxis.Minimum:= -100;
  Chart1.LeftAxis.Maximum:= 100;
  Chart1.BottomAxis.PositionPercent:= 50;
end;

end.
