program keystrokeDynamics;

uses
  Vcl.Forms,
  UnitKeystrokeDynamics in 'UnitKeystrokeDynamics.pas' {FormKeystrokeDynamics},
  Keylogger in 'Keylogger.pas',
  Data_Time in 'Data_Time.pas',
  Feature_Extractor in 'Feature_Extractor.pas',
  PCA in 'PCA.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormKeystrokeDynamics, FormKeystrokeDynamics);
  Application.Run;
end.
