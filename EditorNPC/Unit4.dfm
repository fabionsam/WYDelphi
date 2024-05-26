object F_Conversor: TF_Conversor
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Converter NPC'
  ClientHeight = 198
  ClientWidth = 296
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 79
    Top = 29
    Width = 135
    Height = 13
    Caption = 'Diret'#243'rio de NPCs da TMSRV'
  end
  object Label2: TLabel
    Left = 104
    Top = 93
    Width = 84
    Height = 13
    Caption = 'Pasta para salvar'
  end
  object Edit1: TEdit
    Left = 64
    Top = 48
    Width = 161
    Height = 21
    TabOrder = 0
    OnDblClick = Edit1DblClick
  end
  object Edit2: TEdit
    Left = 64
    Top = 112
    Width = 161
    Height = 21
    TabOrder = 1
    OnDblClick = Edit2DblClick
  end
  object Button2: TButton
    Left = 104
    Top = 144
    Width = 75
    Height = 25
    Caption = 'Converter'
    TabOrder = 2
    OnClick = Button2Click
  end
end
