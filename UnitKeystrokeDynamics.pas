unit UnitKeystrokeDynamics;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Generics.Collections,Keylogger,
  Vcl.StdCtrls, Vcl.Grids, VclTee.TeeGDIPlus, VCLTee.TeEngine, VCLTee.TeeSurfa,
  Vcl.ExtCtrls, VCLTee.TeeProcs, VCLTee.Chart, VCLTee.TeePoin3,Feature_Extractor
  ,Data_Time,DateUtils, Vcl.Imaging.pngimage, VCLTee.Series, VCLTee.ImaPoint,
  Vcl.ComCtrls;

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
    Chart1: TChart;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Series1: TPoint3DSeries;
    TrackBarRotation: TTrackBar;
    TrackBarElevation: TTrackBar;
    TrackBarZoom: TTrackBar;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Series2: TPoint3DSeries;
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
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormKeystrokeDynamics: TFormKeystrokeDynamics;
  logger : TKeylogger;
  f: TextFile;
implementation

{$R *.dfm}


procedure TFormKeystrokeDynamics.Button1Click(Sender: TObject);
var
  ext: TExtractor ;
  i:Double;
  i1,i2: TDateTime;
  diff : Double;
begin
 // i := ExtractSec('yy:mm:dd:hh:mm:22.103');
 // i := ExtractSec('yy:mm:dd:hh:mm:22.103');
// i1:= ExtractDateTime('20:02:24:21:34:52.149');
 //i2:= ExtractDateTime('20:02:24:21:34:52.589');
// diff := MilliSecondsBetween(i2,i1);
 //diff:= 1;
  ext := TExtractor.Create();
  ext.LoadCSVFile( EditNameUser.Text +'.csv',';');
  ext.Extract(EditNameUser.Text);
  ShowMessage('Успешно');
  //StringGrid1:= ext.DataGrid;
 // write('sd');
  // j := DateTimeToFileDate(Now);
   // AssignFile(f, 'outfile.csv');
 //   Rewrite(f); // Создать файл, если его ещё нет или очистить файл, если он есть
  // WriteLn(f,';;;;;'+FormatDateTime('yyyy:mm:dd:hh:mm:ss.zzz', Now));
  //WriteLn(f, 'lr;rl;lR;Lr;rL;Rl;lL;rR;ll;rr;l;r;L','R;Space;Enter;Backspace;cpm'); // Записать строку в файл

  //CloseFile(f); // Закрыть файл
end;

procedure TFormKeystrokeDynamics.Button2Click(Sender: TObject);
begin
  logger.Active := false;
  LabelStatus.Caption := 'Статус: Нет сбора данных';
end;

procedure TFormKeystrokeDynamics.Button3Click(Sender: TObject);
var ext2,ext3: TExtractor;
  Col, Row: integer;
  test :Boolean;
begin
  Series1.Clear;
  ext2 := TExtractor.Create();
  ext2.LoadCSVFile('feature_alex.csv',';',true);
  ext2.CalcStats(ext2.ExtractData);
  ext2.NormalizationAndCenter;
  test := ext2.TestNormalizationAndCenter;
  for Row :=0 to Length(ext2.NormData[0])-1 do
  begin
      Series1.AddXYZ(ext2.NormData[0,Row] ,ext2.NormData[1,Row],ext2.NormData[2,Row]);
  end;

  Series2.Clear;
  ext3 := TExtractor.Create();
  ext3.LoadCSVFile('feature_nata.csv',';',true);
  ext3.CalcStats(ext3.ExtractData);
  ext3.NormalizationAndCenter;
  test := ext3.TestNormalizationAndCenter;
  for Row :=0 to Length(ext3.NormData[0])-1 do
  begin
      Series2.AddXYZ(ext3.NormData[0,Row] ,ext3.NormData[1,Row],ext3.NormData[2,Row]);
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
  Series1.Visible := CheckBox1.Checked;
end;

procedure TFormKeystrokeDynamics.CheckBox2Click(Sender: TObject);
begin
   Series2.Visible := CheckBox2.Checked;
end;

procedure TFormKeystrokeDynamics.EditNameUserClick(Sender: TObject);
begin
  EditNameUser.Text := '';
end;

procedure TFormKeystrokeDynamics.EditUserTextClick(Sender: TObject);
begin
  EditUserText.Text := '';
end;

procedure TFormKeystrokeDynamics.FormCreate(Sender: TObject);
begin
   TrackBarRotation.Position := Chart1.View3DOptions.Rotation;
   TrackBarElevation.Position := Chart1.View3DOptions.Elevation;
   TrackBarZoom.Position := Chart1.View3DOptions.Zoom;
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
   Chart1.View3DOptions.Rotation := TrackBarRotation.Position;
   Chart1.View3DOptions.Elevation := TrackBarElevation.Position;
   Chart1.View3DOptions.Zoom := TrackBarZoom.Position;
end;

end.
