object DM_DataSnap: TDM_DataSnap
  OldCreateOrder = False
  Height = 271
  Width = 415
  object DSConn: TSQLConnection
    DriverName = 'DataSnap'
    LoginPrompt = False
    Params.Strings = (
      'DriverUnit=Data.DBXDataSnap'
      'HostName=localhost'
      'Port=25565'
      'CommunicationProtocol=tcp/ip'
      'DatasnapContext=datasnap/'
      
        'DriverAssemblyLoader=Borland.Data.TDBXClientDriverLoader,Borland' +
        '.Data.DbxClientDriver,Version=24.0.0.0,Culture=neutral,PublicKey' +
        'Token=91d62ebb5b0d1b1b'
      'Filters={}')
    Left = 48
    Top = 40
    UniqueId = '{3A2EF979-3C94-4E08-A269-E995C48A7B32}'
  end
  object FDStanStorageJSONLink1: TFDStanStorageJSONLink
    Left = 128
    Top = 40
  end
  object FDStanStorageBinLink1: TFDStanStorageBinLink
    Left = 224
    Top = 40
  end
end
