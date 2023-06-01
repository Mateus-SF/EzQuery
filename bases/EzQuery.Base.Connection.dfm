object BaseConnection: TBaseConnection
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 98
  Width = 306
  PixelsPerInch = 120
  object DB: TFDConnection
    Params.Strings = (
      'Protocol='
      'DriverID=FB'
      'User_Name=sysdba'
      'Password=masterkey')
    LoginPrompt = False
    Left = 24
    Top = 16
  end
  object PhysFBDriverLink: TFDPhysFBDriverLink
    VendorLib = 'C:\Program Files (x86)\Firebird\Firebird_4_0\fbclient.dll'
    Left = 104
    Top = 16
  end
  object WaitCursor: TFDGUIxWaitCursor
    Provider = 'Console'
    Left = 224
    Top = 16
  end
end
