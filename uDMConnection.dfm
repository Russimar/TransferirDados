object DMConnection: TDMConnection
  OldCreateOrder = False
  Height = 213
  Width = 413
  object FDOrigem: TFDConnection
    Params.Strings = (
      'CharacterSet=WIN1252'
      'User_Name=sysdba'
      'Password=masterkey'
      'Port=3050'
      'DriverID=FB')
    FormatOptions.AssignedValues = [fvDefaultParamDataType]
    FormatOptions.DefaultParamDataType = ftString
    LoginPrompt = False
    Transaction = FDTOrigem
    Left = 32
    Top = 32
  end
  object FDDestino: TFDConnection
    Params.Strings = (
      'CharacterSet=WIN1252'
      'DriverID=FB'
      'User_Name=sysdba'
      'Password=masterkey')
    LoginPrompt = False
    Transaction = FDTDestino
    Left = 32
    Top = 88
  end
  object qryTabelas: TFDQuery
    Connection = FDOrigem
    FetchOptions.AssignedValues = [evRowsetSize]
    FetchOptions.RowsetSize = 500
    SQL.Strings = (
      'select trim(cast(RDB$RELATION_NAME as varchar(50))) TABELAS'
      'from RDB$RELATIONS'
      'where ((RDB$SYSTEM_FLAG = 0) or (RDB$SYSTEM_FLAG is null)) and'
      '      (RDB$VIEW_SOURCE is null) and'
      'substring(RDB$RELATION_NAME from 1 for 3) <> '#39'FR_'#39' '
      'order by RDB$RELATION_NAME ')
    Left = 272
    Top = 32
    object qryTabelasTABELAS: TStringField
      DisplayLabel = 'Tabela'
      FieldName = 'TABELAS'
      Origin = 'RDB$RELATION_NAME'
      FixedChar = True
      Size = 31
    end
  end
  object dsTabelas: TDataSource
    DataSet = qryTabelas
    Left = 336
    Top = 32
  end
  object FDTOrigem: TFDTransaction
    Connection = FDOrigem
    Left = 104
    Top = 32
  end
  object FDTDestino: TFDTransaction
    Connection = FDDestino
    Left = 104
    Top = 88
  end
end
