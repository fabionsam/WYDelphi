object DMDataBase: TDMDataBase
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 150
  Width = 215
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 31
    Top = 72
  end
  object FDConnection: TFDConnection
    Params.Strings = (
      'Server=localhost'
      'DriverID=Mongo')
    Connected = True
    Left = 31
    Top = 16
  end
end
