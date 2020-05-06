unit uTransferirDados;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.FileCtrl, Vcl.ExtCtrls,
  Vcl.Buttons, uDMConnection, Data.DB, Vcl.Grids, Vcl.DBGrids, Vcl.ComCtrls,
  FireDAC.Comp.Client, Vcl.DBCGrids, SMDBGrid, Vcl.Samples.Gauges;

type
  TfrmTransfereDados = class(TForm)
    pnlPrincipal: TPanel;
    pnlTop: TPanel;
    OpenDialog1: TOpenDialog;
    Panel2: TPanel;
    ProgressBar1: TProgressBar;
    Label1: TLabel;
    Label2: TLabel;
    edtOrigem: TEdit;
    edtDestino: TEdit;
    btnOrigem: TSpeedButton;
    btnDestino: TSpeedButton;
    BitBtn1: TBitBtn;
    btnTransferir: TBitBtn;
    gridTabelas: TSMDBGrid;
    Gauge1: TGauge;
    procedure btnOrigemClick(Sender: TObject);
    procedure btnDestinoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure btnTransferirClick(Sender: TObject);
  private
    { Private declarations }
    BaseOrigem : String;
    BaseDestino : String;
    DataHoraInicial : TDateTime;
    DataHoraFinal : TDateTime;
    fDMConnection : TDMConnection;
    QryDadosOrigem : TFDQuery;
    QryDadosDestino : TFDQuery;
    procedure Transferir;
  public
    { Public declarations }
  end;

var
  frmTransfereDados: TfrmTransfereDados;

const
   DriverName : String = 'FB';
   UserName   : String = 'SYSDBA';
   PassWord   : String = 'masterkey';
   IP         : String = '127.0.0.1';

implementation

{$R *.dfm}

procedure TfrmTransfereDados.btnOrigemClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    edtOrigem.Text := OpenDialog1.FileName;
    BaseOrigem := OpenDialog1.FileName;

    fDMConnection.FDOrigem.Connected := False;
    fDMConnection.FDOrigem.Params.Clear;
    fDMConnection.FDOrigem.DriverName := 'FB';
    fDMConnection.FDOrigem.Params.Values['DriveId'] := DriverName;
    fDMConnection.FDOrigem.Params.Values['DataBase'] := BaseOrigem;
    fDMConnection.FDOrigem.Params.Values['User_Name'] := UserName;
    fDMConnection.FDOrigem.Params.Values['Password'] := PassWord;
  end;

end;

procedure TfrmTransfereDados.btnTransferirClick(Sender: TObject);
begin
  if fDMConnection.qryTabelas.IsEmpty then
  begin
    MessageDlg('Banco n�o conectado',mtWarning,[mbOK],0);
    Exit;
  end;
  Transferir;
end;

procedure TfrmTransfereDados.FormCreate(Sender: TObject);
begin
  fDMConnection := TDMConnection.Create(nil);
end;

procedure TfrmTransfereDados.Transferir;
var
  i : integer;
  NumeroRegistros : Integer;
begin
  with fDMConnection do
  begin
    ProgressBar1.Max := qryTabelas.RecordCount;
    ProgressBar1.Update;
    qryTabelas.First;
    qryTabelas.DisableControls;
    while not qryTabelas.Eof do
    begin
      if gridTabelas.SelectedRows.CurrentRowSelected then
        begin
        QryDadosOrigem := TFDQuery.Create(nil);
        QryDadosOrigem.Connection := fDMConnection.FDOrigem;
        QryDadosOrigem.FetchOptions.RowsetSize := 500;

        QryDadosDestino := TFDQuery.Create(nil);
        QryDadosDestino.Connection := fDMConnection.FDDestino;
        QryDadosDestino.FetchOptions.RowsetSize := 500;

        ProgressBar1.Position := ProgressBar1.Position + 1;
        vTabela := qryTabelasTABELAS.AsString;
        try
          Gauge1.MinValue := 1;
          pnlTop.Caption := 'Contando Registros ' + vTabela;
          pnlTop.Update;
          NumeroRegistros := Count;
          if NumeroRegistros > 0 then
          begin
            Gauge1.MaxValue := NumeroRegistros;
          end;
          pnlTop.Caption := 'Transferindo Registros da Tabela  ' + vTabela;
          pnlTop.Update;
          vSkip := 0;

          while vSkip < NumeroRegistros  do
          begin
            QryDadosOrigem := Abrir_Tabela(tpOrigem);
            QryDadosDestino := Abrir_Tabela(tpDestino);

            while not QryDadosOrigem.Eof do
            begin
              QryDadosDestino.Insert;
              Gauge1.AddProgress(1);
              Gauge1.Update;
              QryDadosDestino.CachedUpdates := True;
              for I := 0 to QryDadosOrigem.FieldCount - 1 do
              begin
                try
                  QryDadosDestino.FindField(QryDadosOrigem.Fields[i].FieldName).AsVariant :=
                     QryDadosOrigem.Fields[i].AsVariant;
                except
                  Application.ProcessMessages;
                end;
              end;
              QryDadosDestino.Post;
              QryDadosOrigem.Next;
              if QryDadosDestino.ChangeCount >= 100 then
              begin
                QryDadosDestino.ApplyUpdates(0);
                QryDadosDestino.CommitUpdates;
              end;
            end;
            QryDadosDestino.ApplyUpdates(0);
            QryDadosDestino.CommitUpdates;
            Inc (vSkip,15000);
            QryDadosOrigem.Free;
            QryDadosDestino.Free;
          end;
        except
          on E : Exception do
          begin
            ShowMessage(e.Message);
          end;

        end;
      end;
      qryTabelas.Next;
    end;
  end;
  fDMConnection.qryTabelas.EnableControls;
  DataHoraFinal := Now;
  ShowMessage('Iniciou o processo: '   +  FormatDateTime('dd/mm/yyyy hh:mm:ss',DataHoraInicial)+ #13 +
              'Terminou o Processo: ' + FormatDateTime('dd/mm/yyyy hh:mm:ss', DataHoraFinal)+ #13 +
              'Tempo dura��o: ' + FormatDateTime('hh:mm:ss', DataHoraInicial - DataHoraFinal));

end;

procedure TfrmTransfereDados.BitBtn1Click(Sender: TObject);
begin
  if fDMConnection.conectar then
  begin
    fDMConnection.qryTabelas.Close;
    fDMConnection.qryTabelas.Open;
  end;
end;

procedure TfrmTransfereDados.btnDestinoClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    edtDestino.Text := OpenDialog1.FileName;
    BaseDestino := OpenDialog1.FileName;
    fDMConnection.FDDestino.Connected := False;
    fDMConnection.FDDestino.Params.Clear;
    fDMConnection.FDDestino.DriverName := 'FB';
    fDMConnection.FDDestino.Params.Values['DriveId'] := DriverName;
    fDMConnection.FDDestino.Params.Values['Database'] := BaseDestino;
    fDMConnection.FDDestino.Params.Values['Server'] := IP;
    fDMConnection.FDDestino.Params.Values['User_Name'] := UserName;
    fDMConnection.FDDestino.Params.Values['Password'] := PassWord;
  end;

end;

end.
