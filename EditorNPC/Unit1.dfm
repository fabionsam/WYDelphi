object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'NPC Editor'
  ClientHeight = 356
  ClientWidth = 476
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu1
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 8
    Top = 8
    Width = 460
    Height = 385
    ActivePage = TabSheet1
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'Status'
      object Label1: TLabel
        Left = 16
        Top = 16
        Width = 27
        Height = 13
        Caption = 'Nome'
      end
      object Label6: TLabel
        Left = 320
        Top = 65
        Width = 18
        Height = 13
        Caption = 'Exp'
      end
      object Label2: TLabel
        Left = 168
        Top = 16
        Width = 25
        Height = 13
        Caption = 'Level'
      end
      object Label3: TLabel
        Left = 320
        Top = 16
        Width = 45
        Height = 13
        Caption = 'Merchant'
      end
      object Label4: TLabel
        Left = 16
        Top = 65
        Width = 24
        Height = 13
        Caption = 'Race'
      end
      object Label5: TLabel
        Left = 168
        Top = 65
        Width = 21
        Height = 13
        Caption = 'Gold'
      end
      object Label83: TLabel
        Left = 16
        Top = 117
        Width = 31
        Height = 13
        Caption = 'Classe'
      end
      object Label84: TLabel
        Left = 168
        Top = 117
        Width = 51
        Height = 13
        Caption = 'GuildIndex'
      end
      object Label85: TLabel
        Left = 320
        Top = 117
        Width = 6
        Height = 13
        Caption = 'X'
      end
      object Label86: TLabel
        Left = 16
        Top = 165
        Width = 31
        Height = 13
        Caption = 'Attack'
      end
      object Label87: TLabel
        Left = 168
        Top = 165
        Width = 34
        Height = 13
        Caption = 'Defesa'
      end
      object Label88: TLabel
        Left = 320
        Top = 165
        Width = 13
        Height = 13
        Caption = 'HP'
      end
      object Label89: TLabel
        Left = 16
        Top = 214
        Width = 14
        Height = 13
        Caption = 'MP'
      end
      object Label90: TLabel
        Left = 169
        Top = 214
        Width = 19
        Height = 13
        Caption = 'STR'
      end
      object Label92: TLabel
        Left = 384
        Top = 165
        Width = 33
        Height = 13
        Caption = 'MaxHP'
      end
      object Label93: TLabel
        Left = 80
        Top = 214
        Width = 34
        Height = 13
        Caption = 'MaxMP'
      end
      object Label94: TLabel
        Left = 384
        Top = 117
        Width = 6
        Height = 13
        Caption = 'Y'
      end
      object Label95: TLabel
        Left = 232
        Top = 214
        Width = 17
        Height = 13
        Caption = 'INT'
      end
      object Label91: TLabel
        Left = 320
        Top = 214
        Width = 19
        Height = 13
        Caption = 'DEX'
      end
      object Label96: TLabel
        Left = 383
        Top = 214
        Width = 22
        Height = 13
        Caption = 'CON'
      end
      object Label97: TLabel
        Left = 80
        Top = 264
        Width = 37
        Height = 13
        Caption = 'fMaster'
      end
      object Label98: TLabel
        Left = 16
        Top = 264
        Width = 41
        Height = 13
        Caption = 'wMaster'
      end
      object Label99: TLabel
        Left = 232
        Top = 264
        Width = 37
        Height = 13
        Caption = 'tMaster'
      end
      object Label100: TLabel
        Left = 168
        Top = 264
        Width = 38
        Height = 13
        Caption = 'sMaster'
      end
      object Label101: TLabel
        Left = 320
        Top = 264
        Width = 59
        Height = 13
        Caption = 'Move Speed'
      end
      object vNome: TEdit
        Left = 16
        Top = 35
        Width = 121
        Height = 21
        TabOrder = 0
        OnKeyDown = KeyDown
      end
      object vExp: TEdit
        Left = 320
        Top = 84
        Width = 121
        Height = 21
        TabOrder = 1
        OnKeyDown = KeyDown
      end
      object vLevel: TEdit
        Left = 168
        Top = 35
        Width = 121
        Height = 21
        TabOrder = 2
        OnKeyDown = KeyDown
      end
      object vMerchant: TEdit
        Left = 320
        Top = 35
        Width = 121
        Height = 21
        TabOrder = 3
        OnKeyDown = KeyDown
      end
      object vRace: TEdit
        Left = 16
        Top = 84
        Width = 121
        Height = 21
        TabOrder = 4
        OnKeyDown = KeyDown
      end
      object vGold: TEdit
        Left = 168
        Top = 84
        Width = 121
        Height = 21
        TabOrder = 5
        OnKeyDown = KeyDown
      end
      object vClasse: TEdit
        Left = 16
        Top = 136
        Width = 121
        Height = 21
        TabOrder = 6
        OnKeyDown = KeyDown
      end
      object vGuildIndex: TEdit
        Left = 168
        Top = 136
        Width = 121
        Height = 21
        TabOrder = 7
        OnKeyDown = KeyDown
      end
      object vX: TEdit
        Left = 320
        Top = 136
        Width = 58
        Height = 21
        TabOrder = 8
        OnKeyDown = KeyDown
      end
      object vAttack: TEdit
        Left = 16
        Top = 184
        Width = 121
        Height = 21
        TabOrder = 9
        OnKeyDown = KeyDown
      end
      object vDefesa: TEdit
        Left = 168
        Top = 184
        Width = 121
        Height = 21
        TabOrder = 10
        OnKeyDown = KeyDown
      end
      object vHP: TEdit
        Left = 320
        Top = 184
        Width = 57
        Height = 21
        TabOrder = 11
        OnKeyDown = KeyDown
      end
      object vMP: TEdit
        Left = 17
        Top = 233
        Width = 57
        Height = 21
        TabOrder = 12
        OnKeyDown = KeyDown
      end
      object vSTR: TEdit
        Left = 169
        Top = 233
        Width = 57
        Height = 21
        TabOrder = 13
        OnKeyDown = KeyDown
      end
      object vMaxHP: TEdit
        Left = 384
        Top = 184
        Width = 57
        Height = 21
        TabOrder = 14
        OnKeyDown = KeyDown
      end
      object vMaxMP: TEdit
        Left = 80
        Top = 233
        Width = 57
        Height = 21
        TabOrder = 15
        OnKeyDown = KeyDown
      end
      object vY: TEdit
        Left = 384
        Top = 136
        Width = 57
        Height = 21
        TabOrder = 16
        OnKeyDown = KeyDown
      end
      object vINT: TEdit
        Left = 232
        Top = 233
        Width = 57
        Height = 21
        TabOrder = 17
        OnKeyDown = KeyDown
      end
      object vDEX: TEdit
        Left = 320
        Top = 233
        Width = 57
        Height = 21
        TabOrder = 18
        OnKeyDown = KeyDown
      end
      object vCON: TEdit
        Left = 383
        Top = 233
        Width = 57
        Height = 21
        TabOrder = 19
        OnKeyDown = KeyDown
      end
      object vfMaster: TEdit
        Left = 80
        Top = 283
        Width = 57
        Height = 21
        TabOrder = 20
        OnKeyDown = KeyDown
      end
      object vwMaster: TEdit
        Left = 17
        Top = 283
        Width = 57
        Height = 21
        TabOrder = 21
        OnKeyDown = KeyDown
      end
      object vtMaster: TEdit
        Left = 232
        Top = 283
        Width = 57
        Height = 21
        TabOrder = 22
        OnKeyDown = KeyDown
      end
      object vsMaster: TEdit
        Left = 169
        Top = 283
        Width = 57
        Height = 21
        TabOrder = 23
        OnKeyDown = KeyDown
      end
      object vMoveSpeed: TEdit
        Left = 320
        Top = 283
        Width = 121
        Height = 21
        TabOrder = 24
        OnKeyDown = KeyDown
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Itens'
      ImageIndex = 1
      object PageControl2: TPageControl
        Left = 3
        Top = 3
        Width = 446
        Height = 350
        ActivePage = TabSheet3
        TabOrder = 0
        object TabSheet3: TTabSheet
          Caption = 'Equip'
          object Label7: TLabel
            Left = 16
            Top = 5
            Width = 23
            Height = 13
            Caption = 'Face'
          end
          object Label8: TLabel
            Left = 16
            Top = 53
            Width = 26
            Height = 13
            Caption = 'Cal'#231'a'
          end
          object Label14: TLabel
            Left = 168
            Top = 53
            Width = 23
            Height = 13
            Caption = 'Luva'
          end
          object Label13: TLabel
            Left = 168
            Top = 5
            Width = 22
            Height = 13
            Caption = 'Elmo'
          end
          object Label15: TLabel
            Left = 16
            Top = 101
            Width = 59
            Height = 13
            Caption = 'Arma Direita'
          end
          object Label9: TLabel
            Left = 312
            Top = 53
            Width = 22
            Height = 13
            Caption = 'Bota'
          end
          object Label10: TLabel
            Left = 312
            Top = 101
            Width = 29
            Height = 13
            Caption = 'Brinco'
          end
          object Label16: TLabel
            Left = 16
            Top = 157
            Width = 39
            Height = 13
            Caption = 'Amuleto'
          end
          object Label17: TLabel
            Left = 16
            Top = 214
            Width = 23
            Height = 13
            Caption = 'Guild'
          end
          object Label11: TLabel
            Left = 312
            Top = 157
            Width = 45
            Height = 13
            Caption = 'Amuleto2'
          end
          object Label12: TLabel
            Left = 168
            Top = 214
            Width = 24
            Height = 13
            Caption = 'Fada'
          end
          object Label18: TLabel
            Left = 168
            Top = 157
            Width = 18
            Height = 13
            Caption = 'Orb'
          end
          object Label19: TLabel
            Left = 168
            Top = 101
            Width = 73
            Height = 13
            Caption = 'Arma Esquerda'
          end
          object Label21: TLabel
            Left = 312
            Top = 5
            Width = 24
            Height = 13
            Caption = 'Peito'
          end
          object Label20: TLabel
            Left = 312
            Top = 216
            Width = 42
            Height = 13
            Caption = 'Montaria'
          end
          object Label22: TLabel
            Left = 16
            Top = 269
            Width = 25
            Height = 13
            Caption = 'Capa'
          end
          object v0: TEdit
            Left = 16
            Top = 24
            Width = 121
            Height = 21
            TabOrder = 0
            OnKeyDown = KeyDown
          end
          object v3: TEdit
            Left = 16
            Top = 72
            Width = 121
            Height = 21
            TabOrder = 3
            OnKeyDown = KeyDown
          end
          object v4: TEdit
            Left = 168
            Top = 72
            Width = 121
            Height = 21
            TabOrder = 4
            OnKeyDown = KeyDown
          end
          object v1: TEdit
            Left = 168
            Top = 24
            Width = 121
            Height = 21
            TabOrder = 1
            OnKeyDown = KeyDown
          end
          object v7: TEdit
            Left = 168
            Top = 120
            Width = 121
            Height = 21
            TabOrder = 7
            OnKeyDown = KeyDown
          end
          object v6: TEdit
            Left = 16
            Top = 120
            Width = 121
            Height = 21
            TabOrder = 6
            OnKeyDown = KeyDown
          end
          object v9: TEdit
            Left = 16
            Top = 176
            Width = 121
            Height = 21
            TabOrder = 9
            OnKeyDown = KeyDown
          end
          object v10: TEdit
            Left = 168
            Top = 176
            Width = 121
            Height = 21
            TabOrder = 10
            OnKeyDown = KeyDown
          end
          object v13: TEdit
            Left = 168
            Top = 232
            Width = 121
            Height = 21
            TabOrder = 13
            OnKeyDown = KeyDown
          end
          object v12: TEdit
            Left = 16
            Top = 232
            Width = 121
            Height = 21
            TabOrder = 12
            OnKeyDown = KeyDown
          end
          object v14: TEdit
            Left = 312
            Top = 232
            Width = 121
            Height = 21
            TabOrder = 14
            OnKeyDown = KeyDown
          end
          object v11: TEdit
            Left = 312
            Top = 176
            Width = 121
            Height = 21
            TabOrder = 11
            OnKeyDown = KeyDown
          end
          object v5: TEdit
            Left = 312
            Top = 72
            Width = 121
            Height = 21
            TabOrder = 5
            OnKeyDown = KeyDown
          end
          object v8: TEdit
            Left = 312
            Top = 120
            Width = 121
            Height = 21
            TabOrder = 8
            OnKeyDown = KeyDown
          end
          object v2: TEdit
            Left = 312
            Top = 24
            Width = 121
            Height = 21
            TabOrder = 2
            OnKeyDown = KeyDown
          end
          object v15: TEdit
            Left = 16
            Top = 285
            Width = 121
            Height = 21
            TabOrder = 15
            OnKeyDown = KeyDown
          end
        end
        object TabSheet4: TTabSheet
          Caption = 'Invent'#225'rio'
          ImageIndex = 1
          object Label23: TLabel
            Left = 16
            Top = 5
            Width = 6
            Height = 13
            Caption = '1'
          end
          object Label28: TLabel
            Left = 16
            Top = 53
            Width = 6
            Height = 13
            Caption = '4'
          end
          object Label35: TLabel
            Left = 16
            Top = 214
            Width = 12
            Height = 13
            Caption = '13'
          end
          object Label34: TLabel
            Left = 16
            Top = 157
            Width = 12
            Height = 13
            Caption = '10'
          end
          object Label29: TLabel
            Left = 16
            Top = 101
            Width = 6
            Height = 13
            Caption = '7'
          end
          object Label38: TLabel
            Left = 16
            Top = 272
            Width = 12
            Height = 13
            Caption = '16'
          end
          object Label39: TLabel
            Left = 168
            Top = 272
            Width = 12
            Height = 13
            Caption = '17'
          end
          object Label36: TLabel
            Left = 168
            Top = 214
            Width = 12
            Height = 13
            Caption = '14'
          end
          object Label33: TLabel
            Left = 168
            Top = 157
            Width = 12
            Height = 13
            Caption = '11'
          end
          object Label30: TLabel
            Left = 168
            Top = 101
            Width = 6
            Height = 13
            Caption = '8'
          end
          object Label27: TLabel
            Left = 168
            Top = 53
            Width = 6
            Height = 13
            Caption = '5'
          end
          object Label24: TLabel
            Left = 168
            Top = 5
            Width = 6
            Height = 13
            Caption = '2'
          end
          object Label25: TLabel
            Left = 312
            Top = 5
            Width = 6
            Height = 13
            Caption = '3'
          end
          object Label26: TLabel
            Left = 312
            Top = 53
            Width = 6
            Height = 13
            Caption = '6'
          end
          object Label31: TLabel
            Left = 312
            Top = 101
            Width = 6
            Height = 13
            Caption = '9'
          end
          object Label32: TLabel
            Left = 312
            Top = 157
            Width = 12
            Height = 13
            Caption = '12'
          end
          object Label37: TLabel
            Left = 312
            Top = 216
            Width = 12
            Height = 13
            Caption = '15'
          end
          object Label40: TLabel
            Left = 312
            Top = 272
            Width = 12
            Height = 13
            Caption = '18'
          end
          object vv0: TEdit
            Left = 16
            Top = 24
            Width = 121
            Height = 21
            TabOrder = 0
            OnKeyDown = KeyDown
          end
          object vv1: TEdit
            Left = 168
            Top = 24
            Width = 121
            Height = 21
            TabOrder = 1
            OnKeyDown = KeyDown
          end
          object vv2: TEdit
            Left = 312
            Top = 24
            Width = 121
            Height = 21
            TabOrder = 2
            OnKeyDown = KeyDown
          end
          object vv5: TEdit
            Left = 312
            Top = 72
            Width = 121
            Height = 21
            TabOrder = 5
            OnKeyDown = KeyDown
          end
          object vv4: TEdit
            Left = 168
            Top = 72
            Width = 121
            Height = 21
            TabOrder = 4
            OnKeyDown = KeyDown
          end
          object vv3: TEdit
            Left = 16
            Top = 72
            Width = 121
            Height = 21
            TabOrder = 3
            OnKeyDown = KeyDown
          end
          object vv6: TEdit
            Left = 16
            Top = 120
            Width = 121
            Height = 21
            TabOrder = 6
            OnKeyDown = KeyDown
          end
          object vv7: TEdit
            Left = 168
            Top = 120
            Width = 121
            Height = 21
            TabOrder = 7
            OnKeyDown = KeyDown
          end
          object vv8: TEdit
            Left = 312
            Top = 120
            Width = 121
            Height = 21
            TabOrder = 8
            OnKeyDown = KeyDown
          end
          object vv11: TEdit
            Left = 312
            Top = 176
            Width = 121
            Height = 21
            TabOrder = 11
            OnKeyDown = KeyDown
          end
          object vv10: TEdit
            Left = 168
            Top = 176
            Width = 121
            Height = 21
            TabOrder = 10
            OnKeyDown = KeyDown
          end
          object vv9: TEdit
            Left = 16
            Top = 176
            Width = 121
            Height = 21
            TabOrder = 9
            OnKeyDown = KeyDown
          end
          object vv12: TEdit
            Left = 16
            Top = 232
            Width = 121
            Height = 21
            TabOrder = 12
            OnKeyDown = KeyDown
          end
          object vv13: TEdit
            Left = 168
            Top = 232
            Width = 121
            Height = 21
            TabOrder = 13
            OnKeyDown = KeyDown
          end
          object vv14: TEdit
            Left = 312
            Top = 232
            Width = 121
            Height = 21
            TabOrder = 14
            OnKeyDown = KeyDown
          end
          object vv15: TEdit
            Left = 16
            Top = 288
            Width = 121
            Height = 21
            TabOrder = 15
            OnKeyDown = KeyDown
          end
          object vv16: TEdit
            Left = 168
            Top = 288
            Width = 121
            Height = 21
            TabOrder = 16
            OnKeyDown = KeyDown
          end
          object vv17: TEdit
            Left = 312
            Top = 288
            Width = 121
            Height = 21
            TabOrder = 17
            OnKeyDown = KeyDown
          end
        end
        object TabSheet5: TTabSheet
          Caption = 'Invent'#225'rio 2'
          ImageIndex = 2
          object Label41: TLabel
            Left = 16
            Top = 5
            Width = 12
            Height = 13
            Caption = '19'
          end
          object Label42: TLabel
            Left = 168
            Top = 5
            Width = 12
            Height = 13
            Caption = '20'
          end
          object Label43: TLabel
            Left = 312
            Top = 5
            Width = 12
            Height = 13
            Caption = '21'
          end
          object Label44: TLabel
            Left = 312
            Top = 53
            Width = 12
            Height = 13
            Caption = '24'
          end
          object Label45: TLabel
            Left = 168
            Top = 53
            Width = 12
            Height = 13
            Caption = '23'
          end
          object Label46: TLabel
            Left = 16
            Top = 53
            Width = 12
            Height = 13
            Caption = '22'
          end
          object Label47: TLabel
            Left = 16
            Top = 101
            Width = 12
            Height = 13
            Caption = '25'
          end
          object Label48: TLabel
            Left = 168
            Top = 101
            Width = 12
            Height = 13
            Caption = '26'
          end
          object Label49: TLabel
            Left = 312
            Top = 101
            Width = 12
            Height = 13
            Caption = '27'
          end
          object Label50: TLabel
            Left = 16
            Top = 157
            Width = 12
            Height = 13
            Caption = '28'
          end
          object Label51: TLabel
            Left = 168
            Top = 157
            Width = 12
            Height = 13
            Caption = '29'
          end
          object Label52: TLabel
            Left = 312
            Top = 157
            Width = 12
            Height = 13
            Caption = '30'
          end
          object Label53: TLabel
            Left = 16
            Top = 214
            Width = 12
            Height = 13
            Caption = '31'
          end
          object Label54: TLabel
            Left = 168
            Top = 214
            Width = 12
            Height = 13
            Caption = '32'
          end
          object Label55: TLabel
            Left = 312
            Top = 216
            Width = 12
            Height = 13
            Caption = '33'
          end
          object Label56: TLabel
            Left = 312
            Top = 272
            Width = 12
            Height = 13
            Caption = '36'
          end
          object Label57: TLabel
            Left = 168
            Top = 272
            Width = 12
            Height = 13
            Caption = '35'
          end
          object Label58: TLabel
            Left = 16
            Top = 272
            Width = 12
            Height = 13
            Caption = '34'
          end
          object vv19: TEdit
            Left = 168
            Top = 24
            Width = 121
            Height = 21
            TabOrder = 1
            OnKeyDown = KeyDown
          end
          object vv20: TEdit
            Left = 312
            Top = 24
            Width = 121
            Height = 21
            TabOrder = 2
            OnKeyDown = KeyDown
          end
          object vv23: TEdit
            Left = 312
            Top = 72
            Width = 121
            Height = 21
            TabOrder = 5
            OnKeyDown = KeyDown
          end
          object vv22: TEdit
            Left = 168
            Top = 72
            Width = 121
            Height = 21
            TabOrder = 4
            OnKeyDown = KeyDown
          end
          object vv21: TEdit
            Left = 16
            Top = 72
            Width = 121
            Height = 21
            TabOrder = 3
            OnKeyDown = KeyDown
          end
          object vv26: TEdit
            Left = 312
            Top = 120
            Width = 121
            Height = 21
            TabOrder = 8
            OnKeyDown = KeyDown
          end
          object vv25: TEdit
            Left = 168
            Top = 120
            Width = 121
            Height = 21
            TabOrder = 7
            OnKeyDown = KeyDown
          end
          object vv24: TEdit
            Left = 16
            Top = 120
            Width = 121
            Height = 21
            TabOrder = 6
            OnKeyDown = KeyDown
          end
          object vv29: TEdit
            Left = 312
            Top = 176
            Width = 121
            Height = 21
            TabOrder = 11
            OnKeyDown = KeyDown
          end
          object vv28: TEdit
            Left = 168
            Top = 176
            Width = 121
            Height = 21
            TabOrder = 10
            OnKeyDown = KeyDown
          end
          object vv27: TEdit
            Left = 16
            Top = 176
            Width = 121
            Height = 21
            TabOrder = 9
            OnKeyDown = KeyDown
          end
          object vv30: TEdit
            Left = 16
            Top = 232
            Width = 121
            Height = 21
            TabOrder = 12
            OnKeyDown = KeyDown
          end
          object vv31: TEdit
            Left = 168
            Top = 232
            Width = 121
            Height = 21
            TabOrder = 13
            OnKeyDown = KeyDown
          end
          object vv32: TEdit
            Left = 312
            Top = 232
            Width = 121
            Height = 21
            TabOrder = 14
            OnKeyDown = KeyDown
          end
          object vv35: TEdit
            Left = 312
            Top = 288
            Width = 121
            Height = 21
            TabOrder = 17
            OnKeyDown = KeyDown
          end
          object vv34: TEdit
            Left = 168
            Top = 288
            Width = 121
            Height = 21
            TabOrder = 16
            OnKeyDown = KeyDown
          end
          object vv33: TEdit
            Left = 16
            Top = 288
            Width = 121
            Height = 21
            TabOrder = 15
            OnKeyDown = KeyDown
          end
          object vv18: TEdit
            Left = 16
            Top = 24
            Width = 121
            Height = 21
            TabOrder = 0
            OnKeyDown = KeyDown
          end
        end
        object TabSheet6: TTabSheet
          Caption = 'Invent'#225'rio 3'
          ImageIndex = 3
          object Label59: TLabel
            Left = 16
            Top = 5
            Width = 12
            Height = 13
            Caption = '37'
          end
          object Label60: TLabel
            Left = 168
            Top = 5
            Width = 12
            Height = 13
            Caption = '38'
          end
          object Label61: TLabel
            Left = 312
            Top = 5
            Width = 12
            Height = 13
            Caption = '39'
          end
          object Label62: TLabel
            Left = 312
            Top = 53
            Width = 12
            Height = 13
            Caption = '42'
          end
          object Label63: TLabel
            Left = 168
            Top = 53
            Width = 12
            Height = 13
            Caption = '41'
          end
          object Label64: TLabel
            Left = 16
            Top = 53
            Width = 12
            Height = 13
            Caption = '40'
          end
          object Label65: TLabel
            Left = 16
            Top = 101
            Width = 12
            Height = 13
            Caption = '43'
          end
          object Label66: TLabel
            Left = 168
            Top = 101
            Width = 12
            Height = 13
            Caption = '44'
          end
          object Label67: TLabel
            Left = 312
            Top = 101
            Width = 12
            Height = 13
            Caption = '45'
          end
          object Label68: TLabel
            Left = 16
            Top = 157
            Width = 12
            Height = 13
            Caption = '46'
          end
          object Label69: TLabel
            Left = 168
            Top = 157
            Width = 12
            Height = 13
            Caption = '47'
          end
          object Label70: TLabel
            Left = 312
            Top = 157
            Width = 12
            Height = 13
            Caption = '48'
          end
          object Label71: TLabel
            Left = 16
            Top = 214
            Width = 12
            Height = 13
            Caption = '49'
          end
          object Label72: TLabel
            Left = 168
            Top = 214
            Width = 12
            Height = 13
            Caption = '50'
          end
          object Label73: TLabel
            Left = 312
            Top = 216
            Width = 12
            Height = 13
            Caption = '51'
          end
          object Label74: TLabel
            Left = 312
            Top = 272
            Width = 12
            Height = 13
            Caption = '54'
          end
          object Label75: TLabel
            Left = 168
            Top = 272
            Width = 12
            Height = 13
            Caption = '53'
          end
          object Label76: TLabel
            Left = 16
            Top = 272
            Width = 12
            Height = 13
            Caption = '52'
          end
          object vv36: TEdit
            Left = 16
            Top = 24
            Width = 121
            Height = 21
            TabOrder = 0
            OnKeyDown = KeyDown
          end
          object vv37: TEdit
            Left = 168
            Top = 24
            Width = 121
            Height = 21
            TabOrder = 1
            OnKeyDown = KeyDown
          end
          object vv38: TEdit
            Left = 312
            Top = 24
            Width = 121
            Height = 21
            TabOrder = 2
            OnKeyDown = KeyDown
          end
          object vv41: TEdit
            Left = 312
            Top = 72
            Width = 121
            Height = 21
            TabOrder = 5
            OnKeyDown = KeyDown
          end
          object vv40: TEdit
            Left = 168
            Top = 72
            Width = 121
            Height = 21
            TabOrder = 4
            OnKeyDown = KeyDown
          end
          object vv39: TEdit
            Left = 16
            Top = 72
            Width = 121
            Height = 21
            TabOrder = 3
            OnKeyDown = KeyDown
          end
          object vv44: TEdit
            Left = 312
            Top = 120
            Width = 121
            Height = 21
            TabOrder = 8
            OnKeyDown = KeyDown
          end
          object vv43: TEdit
            Left = 168
            Top = 120
            Width = 121
            Height = 21
            TabOrder = 7
            OnKeyDown = KeyDown
          end
          object vv42: TEdit
            Left = 16
            Top = 120
            Width = 121
            Height = 21
            TabOrder = 6
            OnKeyDown = KeyDown
          end
          object vv47: TEdit
            Left = 312
            Top = 176
            Width = 121
            Height = 21
            TabOrder = 11
            OnKeyDown = KeyDown
          end
          object vv46: TEdit
            Left = 168
            Top = 176
            Width = 121
            Height = 21
            TabOrder = 10
            OnKeyDown = KeyDown
          end
          object vv45: TEdit
            Left = 16
            Top = 176
            Width = 121
            Height = 21
            TabOrder = 9
            OnKeyDown = KeyDown
          end
          object vv48: TEdit
            Left = 16
            Top = 232
            Width = 121
            Height = 21
            TabOrder = 12
            OnKeyDown = KeyDown
          end
          object vv49: TEdit
            Left = 168
            Top = 232
            Width = 121
            Height = 21
            ParentShowHint = False
            ShowHint = False
            TabOrder = 13
            OnKeyDown = KeyDown
          end
          object vv50: TEdit
            Left = 312
            Top = 232
            Width = 121
            Height = 21
            TabOrder = 14
            OnKeyDown = KeyDown
          end
          object vv53: TEdit
            Left = 312
            Top = 288
            Width = 121
            Height = 21
            TabOrder = 17
            OnKeyDown = KeyDown
          end
          object vv52: TEdit
            Left = 168
            Top = 288
            Width = 121
            Height = 21
            TabOrder = 16
            OnKeyDown = KeyDown
          end
          object vv51: TEdit
            Left = 16
            Top = 288
            Width = 121
            Height = 21
            TabOrder = 15
            OnKeyDown = KeyDown
          end
        end
        object TabSheet7: TTabSheet
          Caption = 'Invent'#225'rio 4'
          ImageIndex = 4
          object Label77: TLabel
            Left = 16
            Top = 5
            Width = 12
            Height = 13
            Caption = '55'
          end
          object Label78: TLabel
            Left = 168
            Top = 5
            Width = 12
            Height = 13
            Caption = '56'
          end
          object Label79: TLabel
            Left = 312
            Top = 5
            Width = 12
            Height = 13
            Caption = '57'
          end
          object Label80: TLabel
            Left = 312
            Top = 53
            Width = 12
            Height = 13
            Caption = '60'
          end
          object Label81: TLabel
            Left = 168
            Top = 53
            Width = 12
            Height = 13
            Caption = '59'
          end
          object Label82: TLabel
            Left = 16
            Top = 53
            Width = 12
            Height = 13
            Caption = '58'
          end
          object vv54: TEdit
            Left = 16
            Top = 24
            Width = 121
            Height = 21
            TabOrder = 0
            OnKeyDown = KeyDown
          end
          object vv55: TEdit
            Left = 168
            Top = 24
            Width = 121
            Height = 21
            TabOrder = 1
            OnKeyDown = KeyDown
          end
          object vv56: TEdit
            Left = 312
            Top = 24
            Width = 121
            Height = 21
            TabOrder = 2
            OnKeyDown = KeyDown
          end
          object vv59: TEdit
            Left = 312
            Top = 72
            Width = 121
            Height = 21
            TabOrder = 5
            OnKeyDown = KeyDown
          end
          object vv58: TEdit
            Left = 168
            Top = 72
            Width = 121
            Height = 21
            TabOrder = 4
            OnKeyDown = KeyDown
          end
          object vv57: TEdit
            Left = 16
            Top = 72
            Width = 121
            Height = 21
            TabOrder = 3
            OnKeyDown = KeyDown
          end
        end
      end
    end
    object TabSheet8: TTabSheet
      Caption = 'Affects'
      ImageIndex = 2
      object Label103: TLabel
        Left = 24
        Top = 280
        Width = 12
        Height = 13
        Caption = '16'
      end
      object Label104: TLabel
        Left = 176
        Top = 165
        Width = 12
        Height = 13
        Caption = '11'
      end
      object Label105: TLabel
        Left = 176
        Top = 222
        Width = 12
        Height = 13
        Caption = '14'
      end
      object Label106: TLabel
        Left = 24
        Top = 109
        Width = 6
        Height = 13
        Caption = '7'
      end
      object Label107: TLabel
        Left = 24
        Top = 61
        Width = 6
        Height = 13
        Caption = '4'
      end
      object Label108: TLabel
        Left = 24
        Top = 13
        Width = 6
        Height = 13
        Caption = '1'
      end
      object Label109: TLabel
        Left = 24
        Top = 165
        Width = 12
        Height = 13
        Caption = '10'
      end
      object Label110: TLabel
        Left = 24
        Top = 222
        Width = 12
        Height = 13
        Caption = '13'
      end
      object Label111: TLabel
        Left = 320
        Top = 165
        Width = 12
        Height = 13
        Caption = '12'
      end
      object Label112: TLabel
        Left = 320
        Top = 109
        Width = 6
        Height = 13
        Caption = '9'
      end
      object Label114: TLabel
        Left = 320
        Top = 224
        Width = 12
        Height = 13
        Caption = '15'
      end
      object Label115: TLabel
        Left = 320
        Top = 61
        Width = 6
        Height = 13
        Caption = '6'
      end
      object Label116: TLabel
        Left = 176
        Top = 61
        Width = 6
        Height = 13
        Caption = '5'
      end
      object Label117: TLabel
        Left = 176
        Top = 109
        Width = 6
        Height = 13
        Caption = '8'
      end
      object Label118: TLabel
        Left = 320
        Top = 13
        Width = 6
        Height = 13
        Caption = '3'
      end
      object Label119: TLabel
        Left = 176
        Top = 13
        Width = 6
        Height = 13
        Caption = '2'
      end
      object af6: TEdit
        Left = 24
        Top = 128
        Width = 121
        Height = 21
        TabOrder = 0
        OnKeyDown = KeyDown
      end
      object af3: TEdit
        Left = 24
        Top = 80
        Width = 121
        Height = 21
        TabOrder = 1
        OnKeyDown = KeyDown
      end
      object af8: TEdit
        Left = 320
        Top = 128
        Width = 121
        Height = 21
        TabOrder = 2
        OnKeyDown = KeyDown
      end
      object af7: TEdit
        Left = 176
        Top = 128
        Width = 121
        Height = 21
        TabOrder = 3
        OnKeyDown = KeyDown
      end
      object af4: TEdit
        Left = 176
        Top = 80
        Width = 121
        Height = 21
        TabOrder = 4
        OnKeyDown = KeyDown
      end
      object af1: TEdit
        Left = 176
        Top = 32
        Width = 121
        Height = 21
        TabOrder = 5
        OnKeyDown = KeyDown
      end
      object af0: TEdit
        Left = 24
        Top = 32
        Width = 121
        Height = 21
        TabOrder = 6
        OnKeyDown = KeyDown
      end
      object af5: TEdit
        Left = 320
        Top = 80
        Width = 121
        Height = 21
        TabOrder = 7
        OnKeyDown = KeyDown
      end
      object af2: TEdit
        Left = 320
        Top = 32
        Width = 121
        Height = 21
        TabOrder = 8
        OnKeyDown = KeyDown
      end
      object af15: TEdit
        Left = 24
        Top = 296
        Width = 121
        Height = 21
        TabOrder = 9
        OnKeyDown = KeyDown
      end
      object af14: TEdit
        Left = 320
        Top = 243
        Width = 121
        Height = 21
        TabOrder = 10
        OnKeyDown = KeyDown
      end
      object af13: TEdit
        Left = 176
        Top = 241
        Width = 121
        Height = 21
        TabOrder = 11
        OnKeyDown = KeyDown
      end
      object af10: TEdit
        Left = 176
        Top = 184
        Width = 121
        Height = 21
        TabOrder = 12
        OnKeyDown = KeyDown
      end
      object af11: TEdit
        Left = 320
        Top = 184
        Width = 121
        Height = 21
        TabOrder = 13
        OnKeyDown = KeyDown
      end
      object af12: TEdit
        Left = 24
        Top = 240
        Width = 121
        Height = 21
        TabOrder = 14
        OnKeyDown = KeyDown
      end
      object af9: TEdit
        Left = 24
        Top = 184
        Width = 121
        Height = 21
        TabOrder = 15
        OnKeyDown = KeyDown
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 368
    Top = 8
  end
  object MainMenu1: TMainMenu
    Left = 240
    Top = 8
    object Arquivo1: TMenuItem
      Caption = 'Arquivo'
      object Novo1: TMenuItem
        Caption = 'Novo'
        OnClick = Novo1Click
      end
      object Abrir1: TMenuItem
        Caption = 'Abrir'
        OnClick = Abrir1Click
      end
      object Salvar1: TMenuItem
        Caption = 'Salvar'
        OnClick = Salvar1Click
      end
      object Salvarcomo1: TMenuItem
        Caption = 'Salvar como'
        OnClick = Salvarcomo1Click
      end
      object Converter1: TMenuItem
        Caption = 'Converter'
        OnClick = Converter1Click
      end
      object FecharNPC1: TMenuItem
        Caption = 'Fechar NPC'
        OnClick = FecharNPC1Click
      end
      object Fechar1: TMenuItem
        Caption = 'Fechar'
        OnClick = Fechar1Click
      end
    end
    object Sobre1: TMenuItem
      Caption = 'Sobre'
      object Informaes1: TMenuItem
        Caption = 'Informa'#231#245'es'
        OnClick = Informaes1Click
      end
    end
  end
  object cdsItems: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 424
    Top = 8
    object cdsItemsID: TIntegerField
      FieldName = 'ID'
    end
    object cdsItemsNome: TStringField
      FieldName = 'Nome'
    end
    object cdsItemsMesh: TIntegerField
      FieldName = 'Mesh'
    end
    object cdsItemsSubMesh: TIntegerField
      FieldName = 'SubMesh'
    end
    object cdsItemsLevel: TIntegerField
      FieldName = 'Level'
    end
    object cdsItemsSTR: TIntegerField
      FieldName = 'STR'
    end
    object cdsItemsINT: TIntegerField
      FieldName = 'INT'
    end
    object cdsItemsDEX: TIntegerField
      FieldName = 'DEX'
    end
    object cdsItemsCON: TIntegerField
      FieldName = 'CON'
    end
    object cdsItemsUnique: TIntegerField
      FieldName = 'Unique'
    end
    object cdsItemsPrice: TIntegerField
      FieldName = 'Price'
    end
    object cdsItemsPos: TIntegerField
      FieldName = 'Pos'
    end
    object cdsItemsExtreme: TIntegerField
      FieldName = 'Extreme'
    end
    object cdsItemsGrade: TIntegerField
      FieldName = 'Grade'
    end
    object cdsItemsEffect1: TSmallintField
      FieldName = 'Effect1'
    end
    object cdsItemsvEffect1: TSmallintField
      FieldName = 'vEffect1'
    end
    object cdsItemsEffect2: TSmallintField
      FieldName = 'Effect2'
    end
    object cdsItemsvEffect2: TSmallintField
      FieldName = 'vEffect2'
    end
    object cdsItemsEffect3: TSmallintField
      FieldName = 'Effect3'
    end
    object cdsItemsvEffect3: TSmallintField
      FieldName = 'vEffect3'
    end
    object cdsItemsEffect4: TSmallintField
      FieldName = 'Effect4'
    end
    object cdsItemsvEffect4: TSmallintField
      FieldName = 'vEffect4'
    end
    object cdsItemsEffect5: TSmallintField
      FieldName = 'Effect5'
    end
    object cdsItemsvEffect5: TSmallintField
      FieldName = 'vEffect5'
    end
    object cdsItemsEffect6: TSmallintField
      FieldName = 'Effect6'
    end
    object cdsItemsvEffect6: TSmallintField
      FieldName = 'vEffect6'
    end
    object cdsItemsEffect7: TSmallintField
      FieldName = 'Effect7'
    end
    object cdsItemsvEffect7: TSmallintField
      FieldName = 'vEffect7'
    end
    object cdsItemsEffect8: TSmallintField
      FieldName = 'Effect8'
    end
    object cdsItemsvEffect8: TSmallintField
      FieldName = 'vEffect8'
    end
    object cdsItemsEffect9: TSmallintField
      FieldName = 'Effect9'
    end
    object cdsItemsvEffect9: TSmallintField
      FieldName = 'vEffect9'
    end
    object cdsItemsEffect10: TSmallintField
      FieldName = 'Effect10'
    end
    object cdsItemsvEffect10: TSmallintField
      FieldName = 'vEffect10'
    end
    object cdsItemsEffect11: TSmallintField
      FieldName = 'Effect11'
    end
    object cdsItemsvEffect11: TSmallintField
      FieldName = 'vEffect11'
    end
    object cdsItemsEffect12: TSmallintField
      FieldName = 'Effect12'
    end
    object cdsItemsvEffect12: TSmallintField
      FieldName = 'vEffect12'
    end
  end
  object DataSource1: TDataSource
    DataSet = cdsItems
    Left = 304
    Top = 8
  end
  object SaveDialog1: TSaveDialog
    Left = 184
    Top = 8
  end
end
