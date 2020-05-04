unit uDMConnection;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Phys.FB, FireDAC.Phys.FBDef,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, Datasnap.DBClient;

  type
  TEnumConexao = (tpOrigem, tpDestino);

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
    { Private declarations }
  public
    { Public declarations }
    vTabela : String;
    ListaTipo : TStringList;
    function conectar : boolean;
    function Abrir_Tabela(Conexao: TEnumConexao) : TFDQuery;
    function Count : Integer;
  end;

var
  DMConnection: TDMConnection;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TDataModule1 }

function TDMConnection.Abrir_Tabela(Conexao: TEnumConexao): TFDQuery;
var
  Consulta : TFDQuery;
begin
  Consulta := TFDQuery.Create(nil);
  case Conexao of
   tpOrigem : Consulta.Connection := FDOrigem;
   tpDestino : Consulta.Connection := FDDestino;
  end;
  Consulta.Close;
  Consulta.SQL.Clear;
  Consulta.SQL.Add('SELECT * FROM ' + vTabela + ' WHERE 0=0 ');
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

function TDMConnection.Count: Integer;
var
  Consulta : TFDQuery;
begin
  Consulta := TFDQuery.Create(nil);
  Consulta.Connection := FDOrigem;
  Consulta.Close;
  Consulta.SQL.Clear;
  Consulta.SQL.Add('SELECT COUNT(1) CONTAGEM FROM ' + vTabela);
  Consulta.Open;
  Result := Consulta.FieldByName('CONTAGEM').AsInteger;
end;

end.
