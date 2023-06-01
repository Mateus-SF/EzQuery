object BaseManager: TBaseManager
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 99
  Width = 108
  PixelsPerInch = 120
  object DBManager: TFDManager
    ConnectionDefFileName = '..\..\..\config\database.ini'
    FormatOptions.AssignedValues = [fvMapRules]
    FormatOptions.OwnMapRules = True
    FormatOptions.MapRules = <>
    Active = True
    Left = 33
    Top = 16
  end
end
