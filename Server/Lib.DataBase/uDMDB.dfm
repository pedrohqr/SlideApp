object DMDB: TDMDB
  OldCreateOrder = False
  OnCreate = DSServerModuleCreate
  Height = 641
  Width = 897
  object FDConn: TFDConnection
    Params.Strings = (
      
        'Database=C:\Users\pedro\Desktop\projeto_slide\Server\DataBase\SE' +
        'RVER.FDB'
      'User_Name=SYSDBA'
      'Password=oraculo'
      'CharacterSet=ISO8859_1'
      'DriverID=FB')
    LoginPrompt = False
    BeforeConnect = FDConnBeforeConnect
    Left = 128
    Top = 32
  end
  object FDStanStorageJSONLink1: TFDStanStorageJSONLink
    Left = 216
    Top = 32
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    VendorLib = 
      'C:\Users\pedro\Desktop\projeto_slide\Server\DataBase\fbclient.dl' +
      'l'
    Left = 336
    Top = 32
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 440
    Top = 32
  end
  object Query: TFDQuery
    Connection = FDConn
    Left = 40
    Top = 32
  end
  object SP: TFDStoredProc
    Connection = FDConn
    Left = 48
    Top = 96
  end
  object FDStanStorageBinLink1: TFDStanStorageBinLink
    Left = 568
    Top = 40
  end
  object FDManager: TFDManager
    DriverDefFileName = 'C:\Users\pedro\Desktop\projeto_slide\Server\DataBase\DB.ini'
    FormatOptions.AssignedValues = [fvMapRules]
    FormatOptions.OwnMapRules = True
    FormatOptions.MapRules = <>
    Active = True
    Left = 208
    Top = 112
  end
end
