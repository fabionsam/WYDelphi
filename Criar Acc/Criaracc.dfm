object Form1: TForm1
  Left = 500
  Top = 215
  Caption = 'Criar acc'
  ClientHeight = 123
  ClientWidth = 367
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 8
    Width = 26
    Height = 13
    Caption = 'Login'
  end
  object Label2: TLabel
    Left = 24
    Top = 56
    Width = 31
    Height = 13
    Caption = 'Senha'
  end
  object Edit1: TEdit
    Left = 24
    Top = 24
    Width = 121
    Height = 21
    MaxLength = 15
    TabOrder = 0
  end
  object Edit2: TEdit
    Left = 24
    Top = 72
    Width = 121
    Height = 21
    MaxLength = 11
    TabOrder = 1
    OnKeyPress = Edit2KeyPress
  end
  object Button1: TButton
    Left = 184
    Top = 24
    Width = 89
    Height = 65
    Caption = 'Criar'
    TabOrder = 2
    OnClick = Button1Click
  end
  object FDConnection1: TFDConnection
    Params.Strings = (
      'Server=localhost'
      'DriverID=Mongo')
    Left = 328
    Top = 16
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 328
    Top = 72
  end
end
