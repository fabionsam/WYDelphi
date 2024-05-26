object F_Principal: TF_Principal
  Left = 0
  Top = 0
  Caption = 'Leitor de ItemList Bin'#225'rio'
  ClientHeight = 445
  ClientWidth = 574
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    574
    445)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 160
    Top = 13
    Width = 36
    Height = 13
    Caption = 'Buscar:'
  end
  object Label2: TLabel
    Left = 160
    Top = 32
    Width = 334
    Height = 13
    Caption = 'Para buscar basta clicar na celula que deseja fazer a busca.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Ler'
    TabOrder = 0
    Visible = False
    OnClick = Button1Click
  end
  object DBGrid1: TDBGrid
    Left = 8
    Top = 56
    Width = 558
    Height = 381
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = DataSource1
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    OnCellClick = DBGrid1CellClick
  end
  object Edit1: TEdit
    Left = 216
    Top = 10
    Width = 169
    Height = 21
    Enabled = False
    TabOrder = 2
    OnChange = Edit1Change
  end
  object cdsItemList: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 520
    Top = 8
    object cdsItemListID: TIntegerField
      FieldName = 'ID'
    end
    object cdsItemListNome: TStringField
      FieldName = 'Nome'
      Size = 65
    end
    object cdsItemListMesh: TIntegerField
      FieldName = 'Mesh'
    end
    object cdsItemListSubMesh: TIntegerField
      FieldName = 'SubMesh'
    end
    object cdsItemListUnknow: TIntegerField
      FieldName = 'Unknow'
    end
    object cdsItemListLevel: TIntegerField
      FieldName = 'Level'
    end
    object cdsItemListSTR: TIntegerField
      FieldName = 'STR'
    end
    object cdsItemListINT: TIntegerField
      FieldName = 'INT'
    end
    object cdsItemListDEX: TIntegerField
      FieldName = 'DEX'
    end
    object cdsItemListCON: TIntegerField
      FieldName = 'CON'
    end
    object cdsItemListEffect1: TIntegerField
      FieldName = 'Effect1'
    end
    object cdsItemListvEffect1: TIntegerField
      FieldName = 'vEffect1'
    end
    object cdsItemListEffect2: TIntegerField
      FieldName = 'Effect2'
    end
    object cdsItemListvEffect2: TIntegerField
      FieldName = 'vEffect2'
    end
    object cdsItemListEffect3: TIntegerField
      FieldName = 'Effect3'
    end
    object cdsItemListvEffect3: TIntegerField
      FieldName = 'vEffect3'
    end
    object cdsItemListEffect4: TIntegerField
      FieldName = 'Effect4'
    end
    object cdsItemListvEffect4: TIntegerField
      FieldName = 'vEffect4'
    end
    object cdsItemListEffect5: TIntegerField
      FieldName = 'Effect5'
    end
    object cdsItemListvEffect5: TIntegerField
      FieldName = 'vEffect5'
    end
    object cdsItemListEffect6: TIntegerField
      FieldName = 'Effect6'
    end
    object cdsItemListvEffect6: TIntegerField
      FieldName = 'vEffect6'
    end
    object cdsItemListEffect7: TIntegerField
      FieldName = 'Effect7'
    end
    object cdsItemListvEffect7: TIntegerField
      FieldName = 'vEffect7'
    end
    object cdsItemListEffect8: TIntegerField
      FieldName = 'Effect8'
    end
    object cdsItemListvEffect8: TIntegerField
      FieldName = 'vEffect8'
    end
    object cdsItemListEffect9: TIntegerField
      FieldName = 'Effect9'
    end
    object cdsItemListvEffect9: TIntegerField
      FieldName = 'vEffect9'
    end
    object cdsItemListEffect10: TIntegerField
      FieldName = 'Effect10'
    end
    object cdsItemListvEffect10: TIntegerField
      FieldName = 'vEffect10'
    end
    object cdsItemListEffect11: TIntegerField
      FieldName = 'Effect11'
    end
    object cdsItemListvEffect11: TIntegerField
      FieldName = 'vEffect11'
    end
    object cdsItemListEffect12: TIntegerField
      FieldName = 'Effect12'
    end
    object cdsItemListvEffect12: TIntegerField
      FieldName = 'vEffect12'
    end
    object cdsItemListPrice: TIntegerField
      FieldName = 'Price'
    end
    object cdsItemListUnique: TIntegerField
      FieldName = 'Unique'
    end
    object cdsItemListPos: TIntegerField
      FieldName = 'Pos'
    end
    object cdsItemListExtreme: TIntegerField
      FieldName = 'Extreme'
    end
    object cdsItemListGrade: TIntegerField
      FieldName = 'Grade'
    end
  end
  object DataSource1: TDataSource
    DataSet = cdsItemList
    Left = 472
    Top = 8
  end
end
