unit UnitKeystrokeDynamics;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Generics.Collections,Keylogger,
  Vcl.StdCtrls, Vcl.Grids, VclTee.TeeGDIPlus, VCLTee.TeEngine, VCLTee.TeeSurfa,
  Vcl.ExtCtrls, VCLTee.TeeProcs, VCLTee.Chart, VCLTee.TeePoin3,Feature_Extractor
  ,Data_Time,DateUtils, Vcl.Imaging.pngimage, VCLTee.Series, VCLTee.ImaPoint;

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
var ext2: TExtractor;
  Col, Row: integer;
begin
  Series1.Clear;
  ext2 := TExtractor.Create();
  ext2.LoadCSVFile('feature_alex.csv',';');
  for Row :=1 to ext2.DataGrid.RowCount-2 do
  begin
      Series1.AddXYZ(StrToFloat(ext2.DataGrid.Cells[0,Row]) ,StrToFloat(ext2.DataGrid.Cells[1,Row]),StrToFloat(ext2.DataGrid.Cells[2,Row]));
  end;

  Series2.Clear;
  ext2 := TExtractor.Create();
  ext2.LoadCSVFile('feature_nata.csv',';');
  for Row :=1 to ext2.DataGrid.RowCount-2 do
  begin
      Series2.SeriesColor := clRed;
      Series2.AddXYZ(StrToFloat(ext2.DataGrid.Cells[0,Row]) ,StrToFloat(ext2.DataGrid.Cells[1,Row]),StrToFloat(ext2.DataGrid.Cells[2,Row]));

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

end.
