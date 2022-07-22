unit uDMConnection;

interface

uses
  System.SysUtils,
  System.Classes,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.VCLUI.Wait,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  Datasnap.DBClient;

type
  TEnumConexao = (tpOrigem, tpDestino);
  TEnumTipo = (tpSistema, tpGeral, tpTodas);

type
  TDMConnection = class(TDataModule)
    FDOrigem: TFDConnection;
    FDDestino: TFDConnection;
    qryTabelas: TFDQuery;
    dsTabelas: TDataSource;
    qryTabelasTABELAS: TStringField;
    FDTOrigem: TFDTransaction;
    FDTDestino: TFDTransaction;
  private
    FTipoTabela: TEnumTipo;
    procedure SetTipoTabela(const Value: TEnumTipo);
    { Private declarations }
  public
    { Public declarations }
    vTabela: String;
    vSkip: integer;
    ListaTipo: TStringList;
    property TipoTabela : TEnumTipo read FTipoTabela write SetTipoTabela;
    function conectar: boolean;
    function Abrir_Tabela(Conexao: TEnumConexao): TFDQuery;
    function Count: integer;
  end;

var
  DMConnection: TDMConnection;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}
{ TDataModule1 }

function TDMConnection.Abrir_Tabela(Conexao: TEnumConexao): TFDQuery;
var
  Consulta: TFDQuery;
begin
  Consulta := TFDQuery.Create(nil);
  case Conexao of
    tpOrigem:
      Consulta.Connection := FDOrigem;
    tpDestino:
      Consulta.Connection := FDDestino;
  end;
  Consulta.Close;
  Consulta.SQL.Clear;
  Consulta.SQL.Add('SELECT first(15000) skip(' + IntToStr(vSkip) + ') * FROM ' + vTabela +
    ' WHERE 0=0 ');
  Consulta.Open;
  Result := Consulta;
end;

function TDMConnection.conectar: boolean;
begin
  FDOrigem.Connected := False;
  try
    FDOrigem.Connected := True;
    Result := True;
  except
    FDOrigem.Connected := False;
    Result := False;
  end;

  FDDestino.Connected := False;
  try
    FDDestino.Connected := True;
    Result := True;
  except
    FDDestino.Connected := False;
    Result := False;
  end;
end;

function TDMConnection.Count: integer;
var
  Consulta: TFDQuery;
begin
  Consulta := TFDQuery.Create(nil);
  Consulta.Connection := FDOrigem;
  Consulta.Close;
  Consulta.SQL.Clear;
  Consulta.SQL.Add('SELECT COUNT(1) CONTAGEM FROM ' + vTabela);
  Consulta.Open;
  Result := Consulta.FieldByName('CONTAGEM').AsInteger;
end;

procedure TDMConnection.SetTipoTabela(const Value: TEnumTipo);
begin
  FTipoTabela := Value;
end;

end.
