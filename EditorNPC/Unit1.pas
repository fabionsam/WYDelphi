unit Unit1;
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.Menus, Vcl.ComCtrls, Data.DB, Datasnap.DBClient,

  PlayerData, MiscData;

type TStatus = Record
  private
    function GetMerchDir(const Index: Integer): Byte;
    procedure SetMerchDir(const Index: Integer; const Value: Byte);
    function GetMoveChaos(const Index: Integer): Byte;
    procedure SetMoveChaos(const Index: Integer; const Value: Byte);
  public
    Level: WORD;
    Defense: WORD;
    Attack: WORD;
    (*
    struct
    {
      BYTE Merchant : 4;
      BYTE Direction : 4;
    } Merchant;
    *)
    _MerchDir: BYTE;
    (*
    struct
    {
      BYTE Speed : 4;
      BYTE ChaosRate : 4;
    } Move;
    *)
    _MoveChaos: BYTE;

    MaxHP, MaxMP: Word;
    CurHP, CurMP: Word;

    Str,Int: WORD;
    Dex,Con: WORD;

    wMaster: Byte;
    fMaster: Byte;
    sMaster: Byte;
    tMaster: Byte;

    property Merchant : Byte index $0004 read GetMerchDir write SetMerchDir;
    property Direction : Byte index $0404 read GetMerchDir write SetMerchDir;

    property MoveSpeed : Byte index $0004 read GetMoveChaos write SetMoveChaos;
    property ChaosRate : Byte index $0404 read GetMoveChaos write SetMoveChaos;
end;

type TOldTMSRVNpc = Record //conversor nao remover
    Name: array[0..15] of AnsiChar;
    Race: BYTE;

    Merchant: BYTE;

    unk: BYTE;

    unk2: byte;

    Classe: integer;

    gold: integer;

    exp: integer;

    x,y: word;

    Stat: TStatus;//56
    bStat: TStatus;

    Equip: array[0..15] of TItem;
    Inventory: array[0..63] of TItem;

    Learn: LongWord;
    pStatus: WORD;
    pMaster: WORD;
    pSkill: WORD;
    Critical: ShortInt;
    SaveMana: ShortInt;

    SkillBar1: array[0..3] of ShortInt;
    GuildMemberType: shortint;

    MagicIncrement: BYTE;
    RegenHP: BYTE;
    RegenMP: BYTE;

    Resist: array[0..3] of ShortInt;
end;

type
  TForm1 = class(TForm)
    OpenDialog1: TOpenDialog;
    MainMenu1: TMainMenu;
    Arquivo1: TMenuItem;
    Abrir1: TMenuItem;
    Salvar1: TMenuItem;
    Novo1: TMenuItem;
    Salvarcomo1: TMenuItem;
    Fechar1: TMenuItem;
    Sobre1: TMenuItem;
    Informaes1: TMenuItem;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    vNome: TEdit;
    Label1: TLabel;
    vExp: TEdit;
    Label6: TLabel;
    Label2: TLabel;
    vLevel: TEdit;
    vMerchant: TEdit;
    Label3: TLabel;
    vRace: TEdit;
    Label4: TLabel;
    vGold: TEdit;
    Label5: TLabel;
    TabSheet2: TTabSheet;
    cdsItems: TClientDataSet;
    cdsItemsID: TIntegerField;
    cdsItemsNome: TStringField;
    cdsItemsMesh: TIntegerField;
    cdsItemsSubMesh: TIntegerField;
    cdsItemsLevel: TIntegerField;
    cdsItemsSTR: TIntegerField;
    cdsItemsINT: TIntegerField;
    cdsItemsDEX: TIntegerField;
    cdsItemsCON: TIntegerField;
    cdsItemsUnique: TIntegerField;
    cdsItemsPos: TIntegerField;
    cdsItemsExtreme: TIntegerField;
    cdsItemsGrade: TIntegerField;
    cdsItemsEffect1: TSmallintField;
    cdsItemsvEffect1: TSmallintField;
    cdsItemsEffect2: TSmallintField;
    cdsItemsvEffect2: TSmallintField;
    cdsItemsEffect3: TSmallintField;
    cdsItemsvEffect3: TSmallintField;
    cdsItemsEffect4: TSmallintField;
    cdsItemsvEffect4: TSmallintField;
    cdsItemsEffect5: TSmallintField;
    cdsItemsvEffect5: TSmallintField;
    cdsItemsEffect6: TSmallintField;
    cdsItemsvEffect6: TSmallintField;
    cdsItemsEffect7: TSmallintField;
    cdsItemsvEffect7: TSmallintField;
    cdsItemsEffect8: TSmallintField;
    cdsItemsvEffect8: TSmallintField;
    cdsItemsEffect9: TSmallintField;
    cdsItemsvEffect9: TSmallintField;
    cdsItemsEffect10: TSmallintField;
    cdsItemsvEffect10: TSmallintField;
    cdsItemsEffect11: TSmallintField;
    cdsItemsvEffect11: TSmallintField;
    cdsItemsEffect12: TSmallintField;
    cdsItemsvEffect12: TSmallintField;
    cdsItemsPrice: TIntegerField;
    PageControl2: TPageControl;
    TabSheet3: TTabSheet;
    v0: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    v3: TEdit;
    v4: TEdit;
    Label14: TLabel;
    v1: TEdit;
    Label13: TLabel;
    v7: TEdit;
    Label15: TLabel;
    v6: TEdit;
    Label9: TLabel;
    Label10: TLabel;
    v9: TEdit;
    v10: TEdit;
    Label16: TLabel;
    Label17: TLabel;
    v13: TEdit;
    v12: TEdit;
    Label11: TLabel;
    Label12: TLabel;
    v14: TEdit;
    v11: TEdit;
    Label18: TLabel;
    v5: TEdit;
    v8: TEdit;
    Label19: TLabel;
    v2: TEdit;
    Label21: TLabel;
    Label20: TLabel;
    Label22: TLabel;
    v15: TEdit;
    TabSheet4: TTabSheet;
    vv0: TEdit;
    vv1: TEdit;
    vv2: TEdit;
    vv5: TEdit;
    vv4: TEdit;
    vv3: TEdit;
    vv6: TEdit;
    vv7: TEdit;
    vv8: TEdit;
    vv11: TEdit;
    vv10: TEdit;
    vv9: TEdit;
    vv12: TEdit;
    vv13: TEdit;
    vv14: TEdit;
    vv15: TEdit;
    vv16: TEdit;
    vv17: TEdit;
    TabSheet5: TTabSheet;
    Label23: TLabel;
    Label28: TLabel;
    Label35: TLabel;
    Label34: TLabel;
    Label29: TLabel;
    Label38: TLabel;
    Label39: TLabel;
    Label36: TLabel;
    Label33: TLabel;
    Label30: TLabel;
    Label27: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label37: TLabel;
    Label40: TLabel;
    Label41: TLabel;
    vv19: TEdit;
    Label42: TLabel;
    vv20: TEdit;
    Label43: TLabel;
    Label44: TLabel;
    vv23: TEdit;
    vv22: TEdit;
    Label45: TLabel;
    vv21: TEdit;
    Label46: TLabel;
    Label47: TLabel;
    Label48: TLabel;
    Label49: TLabel;
    vv26: TEdit;
    vv25: TEdit;
    vv24: TEdit;
    Label50: TLabel;
    Label51: TLabel;
    Label52: TLabel;
    vv29: TEdit;
    vv28: TEdit;
    vv27: TEdit;
    Label53: TLabel;
    vv30: TEdit;
    vv31: TEdit;
    Label54: TLabel;
    vv32: TEdit;
    Label55: TLabel;
    Label56: TLabel;
    vv35: TEdit;
    vv34: TEdit;
    Label57: TLabel;
    vv33: TEdit;
    Label58: TLabel;
    TabSheet6: TTabSheet;
    Label59: TLabel;
    vv36: TEdit;
    vv37: TEdit;
    Label60: TLabel;
    vv38: TEdit;
    Label61: TLabel;
    Label62: TLabel;
    vv41: TEdit;
    vv40: TEdit;
    Label63: TLabel;
    vv39: TEdit;
    Label64: TLabel;
    Label65: TLabel;
    Label66: TLabel;
    Label67: TLabel;
    vv44: TEdit;
    vv43: TEdit;
    vv42: TEdit;
    Label68: TLabel;
    Label69: TLabel;
    Label70: TLabel;
    vv47: TEdit;
    vv46: TEdit;
    vv45: TEdit;
    Label71: TLabel;
    vv48: TEdit;
    vv49: TEdit;
    Label72: TLabel;
    vv50: TEdit;
    Label73: TLabel;
    Label74: TLabel;
    vv53: TEdit;
    vv52: TEdit;
    Label75: TLabel;
    vv51: TEdit;
    Label76: TLabel;
    TabSheet7: TTabSheet;
    Label77: TLabel;
    vv54: TEdit;
    vv55: TEdit;
    Label78: TLabel;
    vv56: TEdit;
    Label79: TLabel;
    Label80: TLabel;
    vv59: TEdit;
    vv58: TEdit;
    Label81: TLabel;
    vv57: TEdit;
    Label82: TLabel;
    vv18: TEdit;
    vClasse: TEdit;
    Label83: TLabel;
    Label84: TLabel;
    vGuildIndex: TEdit;
    vX: TEdit;
    Label85: TLabel;
    vAttack: TEdit;
    Label86: TLabel;
    Label87: TLabel;
    vDefesa: TEdit;
    vHP: TEdit;
    Label88: TLabel;
    vMP: TEdit;
    Label89: TLabel;
    Label90: TLabel;
    vSTR: TEdit;
    vMaxHP: TEdit;
    Label92: TLabel;
    vMaxMP: TEdit;
    Label93: TLabel;
    vY: TEdit;
    Label94: TLabel;
    vINT: TEdit;
    Label95: TLabel;
    vDEX: TEdit;
    Label91: TLabel;
    vCON: TEdit;
    Label96: TLabel;
    vfMaster: TEdit;
    Label97: TLabel;
    Label98: TLabel;
    vwMaster: TEdit;
    vtMaster: TEdit;
    Label99: TLabel;
    Label100: TLabel;
    vsMaster: TEdit;
    vMoveSpeed: TEdit;
    Label101: TLabel;
    DataSource1: TDataSource;
    Converter1: TMenuItem;
    FecharNPC1: TMenuItem;
    SaveDialog1: TSaveDialog;
    TabSheet8: TTabSheet;
    af6: TEdit;
    af3: TEdit;
    af8: TEdit;
    af7: TEdit;
    af4: TEdit;
    af1: TEdit;
    af0: TEdit;
    af5: TEdit;
    af2: TEdit;
    af15: TEdit;
    af14: TEdit;
    af13: TEdit;
    af10: TEdit;
    af11: TEdit;
    af12: TEdit;
    af9: TEdit;
    Label103: TLabel;
    Label104: TLabel;
    Label105: TLabel;
    Label106: TLabel;
    Label107: TLabel;
    Label108: TLabel;
    Label109: TLabel;
    Label110: TLabel;
    Label111: TLabel;
    Label112: TLabel;
    Label114: TLabel;
    Label115: TLabel;
    Label116: TLabel;
    Label117: TLabel;
    Label118: TLabel;
    Label119: TLabel;
    procedure Abrir1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Salvar1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Fechar1Click(Sender: TObject);
    procedure Converter1Click(Sender: TObject);
    procedure FecharNPC1Click(Sender: TObject);
    procedure Salvarcomo1Click(Sender: TObject);
    procedure Novo1Click(Sender: TObject);
    procedure Informaes1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadItemList();
    procedure CarregarCampos;
    procedure SaveNPC(path:string);
    procedure ResetForm();
  end;

var
  Form1: TForm1; Npcs: array[0..30000] of TCharacterOld;
  Arquivo: TCharacterOld; Local : string;

implementation

{$R *.dfm}

uses Unit2, Unit3, Unit4, StrUtils, Util;

procedure TForm1.KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (key = VK_F1) then
  begin
    try
      Application.CreateForm(TF_Item, F_Item);
      F_Item.ShowModal;
      (Sender as TEdit).Text := F_Item.Edit1.Text;
      if ((Sender as TEdit).Parent).Name = 'TabSheet3' then
      begin
        Arquivo.Equip[(Sender as TEdit).TabOrder] := F_Item.mItem;
      end
      else
      begin
        if ((Sender as TEdit).Parent).Name = 'TabSheet5' then
        begin
          Arquivo.Inventory[(Sender as TEdit).TabOrder+18] := F_Item.mItem;
        end
        else
        begin
          if ((Sender as TEdit).Parent).Name = 'TabSheet6' then
          begin
            Arquivo.Inventory[(Sender as TEdit).TabOrder+36] := F_Item.mItem;
          end
          else
          begin
            if ((Sender as TEdit).Parent).Name = 'TabSheet7' then
            begin
              Arquivo.Inventory[(Sender as TEdit).TabOrder+54] := F_Item.mItem;
            end
            else
              Arquivo.Inventory[(Sender as TEdit).TabOrder] := F_Item.mItem;
          end;
        end;
      end;
      F_Item.Release;
    except
      showmessage('Erro ao criar form adicionais');
    end;
  end;
  if (ssCtrl in Shift) and (key = VK_F1) then
  begin
    Salvar1Click(Sender);
  end;
  if (ssCtrl in Shift) and (ssShift in Shift) and (key = 17) then
  begin
    Salvarcomo1Click(Sender);
  end;
end;

procedure TForm1.CarregarCampos;
var componente: TComponent; i: BYTE;
begin
  for I := 0 to 15 do
  begin
    componente := FindComponent('v'+inttostr(i));
    (componente as TEdit).Text := inttostr(Arquivo.Equip[i].Index) + ' ' + inttostr(Arquivo.Equip[i].Effects[0].Index) + ' ' + inttostr(Arquivo.Equip[i].Effects[0].Value) +
    ' ' + inttostr(Arquivo.Equip[i].Effects[1].Index) + ' ' + inttostr(Arquivo.Equip[i].Effects[1].Value) + ' ' + inttostr(Arquivo.Equip[i].Effects[2].Index) +
    ' ' + inttostr(Arquivo.Equip[i].Effects[2].Value);
  end;

  for I := 0 to 59 do
  begin
    componente := FindComponent('vv'+inttostr(i));
    (componente as TEdit).Text := inttostr(Arquivo.Inventory[i].Index) + ' ' + inttostr(Arquivo.Inventory[i].Effects[0].Index) + ' ' + inttostr(Arquivo.Inventory[i].Effects[0].Value) +
    ' ' + inttostr(Arquivo.Inventory[i].Effects[1].Index) + ' ' + inttostr(Arquivo.Inventory[i].Effects[1].Value) + ' ' + inttostr(Arquivo.Inventory[i].Effects[2].Index) +
    ' ' + inttostr(Arquivo.Inventory[i].Effects[2].Value);
  end;

  for I := 0 to 15 do
  begin
    componente := FindComponent('af'+inttostr(i));
    (componente as TEdit).Text := inttostr(Arquivo.Affects[i].Index) + ' ' + inttostr(Arquivo.Affects[i].Master) + ' ' + inttostr(Arquivo.Affects[i].Value) +
    ' ' + inttostr(Arquivo.Affects[i].Time);
  end;

  vNome.Text := Arquivo.Name;
  vLevel.Text := inttostr(Arquivo.BaseScore.Level);
  vMerchant.Text := inttostr(Arquivo.Merchant);
  vRace.Text := inttostr(Arquivo.CapeInfo);
  vGold.Text := inttostr(Arquivo.gold);
  vExp.Text := inttostr(Arquivo.exp);
  vClasse.Text := inttostr(Arquivo.ClassInfo);
  vGuildIndex.Text := inttostr(Arquivo.GuildIndex);
  vX.Text := inttostr(Arquivo.Last.x);
  vY.Text := inttostr(Arquivo.Last.y);
  vAttack.Text := inttostr(Arquivo.BaseScore.Attack);
  vDefesa.Text := inttostr(Arquivo.BaseScore.Defense);
  vHP.Text := inttostr(Arquivo.BaseScore.CurHP);
  vMaxHP.Text := inttostr(Arquivo.BaseScore.MaxHP);
  vMP.Text := inttostr(Arquivo.BaseScore.CurMP);
  vMaxMP.Text := inttostr(Arquivo.BaseScore.MaxMP);
  vSTR.Text := inttostr(Arquivo.BaseScore.Str);
  vDEX.Text := inttostr(Arquivo.BaseScore.Dex);
  vINT.Text := inttostr(Arquivo.BaseScore.Int);
  vCON.Text := inttostr(Arquivo.BaseScore.CON);
  vwMaster.Text := inttostr(Arquivo.BaseScore.wMaster);
  vsMaster.Text := inttostr(Arquivo.BaseScore.sMaster);
  vfMaster.Text := inttostr(Arquivo.BaseScore.fMaster);
  vtMaster.Text := inttostr(Arquivo.BaseScore.tMaster);
  vMoveSpeed.Text := inttostr(Arquivo.BaseScore.MoveSpeed);
end;

procedure TForm1.Converter1Click(Sender: TObject);
begin
  try
    Application.CreateForm(TF_Conversor, F_Conversor);
    F_Conversor.ShowModal;
    F_Conversor.Release;
  except
    showmessage('Erro ao criar form adicionais');
  end;
end;

procedure TForm1.LoadItemList();
var DataFile : TextFile;
lineFile : String;
fileStrings : TStringList;
ID,i,y:integer;
begin
  AssignFile(DataFile, 'Itemlist.csv');
  Reset(DataFile);

  fileStrings := TStringList.Create;
  cdsItems.CreateDataSet;
  while not EOF (DataFile) do
  begin
    Readln(DataFile, lineFile);
    ExtractStrings([';'],[' '],PChar(Linefile),fileStrings);
    // verifica qual id será colocado
    ID := strtoint(fileStrings.Strings[0]);
    //Adiciona na estrutura;
    cdsItems.Append;
    cdsItems.FieldByName('ID').AsInteger := ID;
    cdsItems.FieldByName('Nome').AsString  := fileStrings.Strings[1];//nome
    cdsItems.FieldByName('Mesh').AsInteger := strtoint(fileStrings.Strings[2]);//Mesh
    cdsItems.FieldByName('SubMesh').AsInteger := strtoint(fileStrings.Strings[3]);//Submesh
    cdsItems.FieldByName('Level').AsInteger := strtoint(fileStrings.Strings[4]);//
    cdsItems.FieldByName('STR').AsInteger := strtoint(fileStrings.Strings[5]);//
    cdsItems.FieldByName('INT').AsInteger := strtoint(fileStrings.Strings[6]);//
    cdsItems.FieldByName('DEX').AsInteger := strtoint(fileStrings.Strings[7]);//
    cdsItems.FieldByName('CON').AsInteger := strtoint(fileStrings.Strings[8]);//
    cdsItems.FieldByName('Unique').AsInteger := strtoint(fileStrings.Strings[9]);//
    cdsItems.FieldByName('Price').AsInteger := strtoint(fileStrings.Strings[10]);//
    cdsItems.FieldByName('Pos').AsInteger := strtoint(fileStrings.Strings[11]);//
    cdsItems.FieldByName('Extreme').AsInteger := strtoint(fileStrings.Strings[12]);//
    cdsItems.FieldByName('Grade').AsInteger := strtoint(fileStrings.Strings[13]);//
    y:= (fileStrings.Count-14) div 2;//define quantos Ef_ tem na linha
    for I := 0 to y-1 do //considera a contagem do 0, logo tem que reduzir 1 no Y
    begin
     cdsItems.FieldByName('Effect'+inttostr(i+1)).AsInteger  := strtoint(fileStrings[14+(i*2)]);// Loop de 2 linhas
     cdsItems.FieldByName('vEffect'+inttostr(i+1)).AsInteger := strtoint(fileStrings[15+(i*2)]);//
    end;
    cdsItems.Post;
    filestrings.Clear;
  end;
  fileStrings.Free;
  CloseFile(DataFile);
end;

procedure TForm1.Novo1Click(Sender: TObject);
begin
  ResetForm();
end;

procedure TForm1.Salvar1Click(Sender: TObject);
begin
  if (local = '') then
    exit;

  SaveNPC(local);
end;

procedure TForm1.Salvarcomo1Click(Sender: TObject);
begin
  if  not(SaveDialog1.Execute) then
    exit;

  Local := SaveDialog1.FileName;
  SaveNPC(Local);
end;

procedure TForm1.Abrir1Click(Sender: TObject);
var f3: file of TCharacterOld;
teste: file of BYTE;
begin
  if not OpenDialog1.Execute then
    exit;

  Local := OpenDialog1.FileName;
  AssignFile(teste, OpenDialog1.FileName);
  Reset(teste);

  if FileSize(teste) > sizeof(TCharacterOld) then // Obtém o tamanho do arquivo then
  begin
    Showmessage('Arquivo invalido!');
    exit;
  end;

  AssignFile(f3, OpenDialog1.FileName);
  Reset(f3);
  Read(f3, Arquivo);
  CloseFile(f3);

  CarregarCampos;
end;



procedure TForm1.Fechar1Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm1.FecharNPC1Click(Sender: TObject);
begin
  ResetForm();
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  LoadItemList();
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (key = 17) then
  begin
    Salvar1Click(Sender);
  end;
  if (ssCtrl in Shift) and (ssShift in Shift) and (key = 17) then
  begin
    Salvarcomo1Click(Sender);
  end;
end;

procedure TForm1.Informaes1Click(Sender: TObject);
begin
  showmessage('Desenvolvido para o projeto WYDelphi'+#13+'Versão: 1.0 Beta');
end;

procedure TForm1.SaveNPC(path: string);
var f3: file of TCharacterOld;
    i: BYTE; componente: TComponent;
    Splitted: TArray<String>;
    str: string;
    charArray : Array[0..0] of Char;
    a: Integer;
begin
  charArray[0] := ' ';
  for I := 0 to 15 do
  begin
    componente := FindComponent('v'+inttostr(i));
    str := (componente as TEdit).Text + '';
    Splitted := str.Split(charArray);

    Arquivo.Equip[i].Index := strtoint(Splitted[0]);

    for a := 0 to 2 do
    begin
      Arquivo.Equip[i].Effects[a].Index := strtoint(Splitted[2*a + 1]);
      Arquivo.Equip[i].Effects[a].Value := strtoint(Splitted[2*a + 2]);
    end;
  end;

  for I := 0 to 59 do
  begin
    componente := FindComponent('vv'+inttostr(i));
    str := (componente as TEdit).Text + '';
    Splitted := str.Split(charArray);

    Arquivo.Inventory[i].Index := strtoint(Splitted[0]);

    for a := 0 to 2 do
    begin
      Arquivo.Inventory[i].Effects[a].Index := strtoint(Splitted[2*a + 1]);
      Arquivo.Inventory[i].Effects[a].Value := strtoint(Splitted[2*a + 2]);
    end;
  end;

  for I := 0 to 15 do
  begin
    componente := FindComponent('af'+inttostr(i));
    str := (componente as TEdit).Text + '';
    Splitted := str.Split(charArray);

    Arquivo.Affects[i].Index := strtoint(Splitted[0]);
    Arquivo.Affects[i].Master := strtoint(Splitted[1]);
    Arquivo.Affects[i].Value := strtoint(Splitted[2]);
    Arquivo.Affects[i].Time := strtoint(Splitted[3]);
  end;

  StrPLCopy(Arquivo.Name, vNome.Text, 16);
//  Move(Nome, Arquivo.Name, 16);
  Arquivo.BaseScore.Level := strtointdef(vLevel.Text,0);
  Arquivo.Merchant := strtointdef(vMerchant.Text,0);
  Arquivo.CapeInfo := strtointdef(vRace.Text,0);
  Arquivo.gold := strtointdef(vGold.Text,0);
  Arquivo.exp := strtointdef(vExp.Text,0);
  Arquivo.ClassInfo := strtointdef(vClasse.Text,0);
  Arquivo.GuildIndex := strtointdef(vGuildIndex.Text,0);
  Arquivo.Last.x := strtointdef(vX.Text,2100);
  Arquivo.Last.y := strtointdef(vY.Text,2100);
  Arquivo.BaseScore.Attack := strtointdef(vAttack.Text,0);
  Arquivo.BaseScore.Defense := strtointdef(vDefesa.Text,0);
  Arquivo.BaseScore.CurHP := strtointdef(vHP.Text,0);
  Arquivo.BaseScore.MaxHP := strtointdef(vMaxHP.Text,0);
  Arquivo.BaseScore.CurMP := strtointdef(vMP.Text,0);
  Arquivo.BaseScore.MaxMP := strtointdef(vMaxMP.Text,0);
  Arquivo.BaseScore.Str := strtointdef(vSTR.Text,0);
  Arquivo.BaseScore.Dex := strtointdef(vDEX.Text,0);
  Arquivo.BaseScore.Int := strtointdef(vINT.Text,0);
  Arquivo.BaseScore.CON := strtointdef(vCON.Text,0);
  Arquivo.BaseScore.wMaster := strtointdef(vwMaster.Text,0);
  Arquivo.BaseScore.sMaster := strtointdef(vsMaster.Text,0);
  Arquivo.BaseScore.fMaster := strtointdef(vfMaster.Text,0);
  Arquivo.BaseScore.tMaster := strtointdef(vtMaster.Text,0);
  Arquivo.BaseScore.MoveSpeed := strtointdef(vMoveSpeed.Text,0);

  AssignFile(f3, Local);
  ReWrite(f3);
  Write(f3,Arquivo);
  CloseFile(f3);
end;

procedure TForm1.ResetForm();
var i: BYTE; componente: TComponent;
begin
  ZeroMemory(@Arquivo,sizeof(TCharacterOld));
  local := '';
  for I := 0 to 15 do
  begin
    componente := FindComponent('v'+inttostr(i));
    (componente as TEdit).Text := '0 0 0 0 0 0 0';
  end;

  for I := 0 to 59 do
  begin
    componente := FindComponent('vv'+inttostr(i));
    (componente as TEdit).Text := '0 0 0 0 0 0 0';
  end;

  for I := 0 to 15 do
  begin
    componente := FindComponent('af'+inttostr(i));
    (componente as TEdit).Text := '0 0 0 0';
  end;

  vNome.Text := Arquivo.Name;
  vLevel.Text := inttostr(Arquivo.BaseScore.Level);
  vMerchant.Text := inttostr(Arquivo.Merchant);
  vRace.Text := inttostr(Arquivo.CapeInfo);
  vGold.Text := inttostr(Arquivo.gold);
  vExp.Text := inttostr(Arquivo.exp);
  vClasse.Text := inttostr(Arquivo.ClassInfo);
  vGuildIndex.Text := inttostr(Arquivo.GuildIndex);
  vX.Text := inttostr(Arquivo.Last.x);
  vY.Text := inttostr(Arquivo.Last.y);
  vAttack.Text := inttostr(Arquivo.BaseScore.Attack);
  vDefesa.Text := inttostr(Arquivo.BaseScore.Defense);
  vHP.Text := inttostr(Arquivo.BaseScore.CurHP);
  vMaxHP.Text := inttostr(Arquivo.BaseScore.MaxHP);
  vMP.Text := inttostr(Arquivo.BaseScore.CurMP);
  vMaxMP.Text := inttostr(Arquivo.BaseScore.MaxMP);
  vSTR.Text := inttostr(Arquivo.BaseScore.Str);
  vDEX.Text := inttostr(Arquivo.BaseScore.Dex);
  vINT.Text := inttostr(Arquivo.BaseScore.Int);
  vCON.Text := inttostr(Arquivo.BaseScore.CON);
  vwMaster.Text := inttostr(Arquivo.BaseScore.wMaster);
  vsMaster.Text := inttostr(Arquivo.BaseScore.sMaster);
  vfMaster.Text := inttostr(Arquivo.BaseScore.fMaster);
  vtMaster.Text := inttostr(Arquivo.BaseScore.tMaster);
  vMoveSpeed.Text := inttostr(Arquivo.BaseScore.MoveSpeed);
end;

{ TStatus }
function TStatus.GetMerchDir(const Index: Integer): Byte;
begin
  Result := GetBits(_MerchDir, Index);
end;

procedure TStatus.SetMerchDir(const Index: Integer; const Value: Byte);
begin
  SetByteBits(_MerchDir, Index, Value);
end;

function TStatus.GetMoveChaos(const Index: Integer): Byte;
begin
  Result := Util.GetBits(_MoveChaos, Index);
end;

procedure TStatus.SetMoveChaos(const Index: Integer; const Value: Byte);
begin
  SetByteBits(_MoveChaos, Index, Value);
end;

end.
