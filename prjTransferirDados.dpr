program prjTransferirDados;

uses
  Vcl.Forms,
  uTransferirDados in 'uTransferirDados.pas' {frmTransfereDados},
  uDMConnection in 'uDMConnection.pas' {DMConnection: TDataModule},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10');
  Application.CreateForm(TfrmTransfereDados, frmTransfereDados);
  Application.CreateForm(TDMConnection, DMConnection);
  Application.Run;
end.
