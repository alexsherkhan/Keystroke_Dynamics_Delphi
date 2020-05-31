unit UnitDataAfterPCA;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VCLTee.TeEngine,
  VCLTee.Series, Vcl.ExtCtrls, VCLTee.TeeProcs, VCLTee.Chart, Vcl.ComCtrls,
  Vcl.StdCtrls, Vcl.Grids, PCA;

type
  TFormDataPCA = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    ChartEigenvalues: TChart;
    Eigenvalues: TLineSeries;
    StringGridEigenvalues: TStringGrid;
    StringGridEigenvectors: TStringGrid;
    StringGridCovarMatrix: TStringGrid;
    StringGridPC: TStringGrid;
    StringGridNormData: TStringGrid;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ObjPCA : TPCA;
  end;

var
  FormDataPCA: TFormDataPCA;

implementation

{$R *.dfm}

procedure TFormDataPCA.FormCreate(Sender: TObject);
begin
  ObjPCA := nil;
end;

procedure TFormDataPCA.FormDestroy(Sender: TObject);
begin
  //FreeAndNil(ObjPCA);
end;

procedure TFormDataPCA.FormShow(Sender: TObject);
var i,j :Integer;
begin

  StringGridCovarMatrix.RowCount :=  Length(ObjPCA.CovarMatrix[0]);
  StringGridCovarMatrix.ColCount :=  Length(ObjPCA.CovarMatrix);
  for i:=0 to High(ObjPCA.CovarMatrix) do
    for j:=0 to High(ObjPCA.CovarMatrix[i]) do
    begin
      StringGridCovarMatrix.Cells[i,j] :=  ObjPCA.CovarMatrix[i,j].ToString();
    end;

  StringGridEigenvalues.ColCount :=  Length(ObjPCA.Eigenvalues);
  StringGridEigenvalues.RowCount :=  2;
  for i:=0 to High(ObjPCA.Eigenvalues) do
  begin
    StringGridEigenvalues.Cells[i,0] := (i+1).ToString();
    StringGridEigenvalues.Cells[i,1] := ObjPCA.Eigenvalues[i].ToString();
    Eigenvalues.AddXY(i,ObjPCA.Eigenvalues[i]);
  end;



  StringGridEigenvectors.RowCount :=  Length(ObjPCA.Eigenvectors[0])+1;
  StringGridEigenvectors.ColCount :=  Length(ObjPCA.Eigenvectors);
  StringGridNormData.RowCount :=  Length(ObjPCA.NormData[0]);
  StringGridNormData.ColCount :=  Length(ObjPCA.NormData);
  for i:=0 to High(ObjPCA.Eigenvectors) do
    for j:=0 to High(ObjPCA.Eigenvectors[i]) do
    begin
      StringGridEigenvectors.Cells[i,0] := (i+1).ToString();
      StringGridEigenvectors.Cells[i,j+1] := ObjPCA.Eigenvectors[i,j].ToString();
      StringGridNormData.Cells[i,j] :=  ObjPCA.NormData[i,j].ToString();
    end;

  StringGridPC.RowCount :=  Length(ObjPCA.PC[0])+1;
  StringGridPC.ColCount :=  Length(ObjPCA.PC);
  for i:=0 to High(ObjPCA.PC) do
    for j:=0 to High(ObjPCA.PC[i]) do
    begin
      StringGridPC.Cells[i,0] := 'PC'+(i+1).ToString();
      StringGridPC.Cells[i,j+1] := ObjPCA.PC[i,j].ToString();
    end;
end;


end.
