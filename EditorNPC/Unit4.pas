unit Unit4;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.IOUtils,
  FileCtrl,
  PlayerData, MiscData;

type
  TF_Conversor = class(TForm)
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Edit2: TEdit;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Edit1DblClick(Sender: TObject);
    procedure Edit2DblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  F_Conversor: TF_Conversor;
  sourceDirectory: string;
  destinationDirectory: string;

implementation

Uses Unit1;

{$R *.dfm}

function IsNumber(text: string): boolean;
begin
  try
    strtoint(text);
  except on EConvertError do
    begin
      result:=false;
      exit;
    end;
  end;
  result:=true;
end;

procedure TF_Conversor.Button1Click(Sender: TObject);
var DataFile : TextFile;
lineFile : String;
local123,diretorio:string;
fileStrings : TStringList;
f2: file of TOldNpc;
f3: file of TCharacter;
aux: TOldNpc;
aux2: TCharacter;
ID,ID2,j,i,px,py:integer;
error: boolean;
begin
  diretorio := GetCurrentDir;
  error:=false;

  {
  AssignFile(DataFile, 'npc.csv');

  Reset(DataFile);

  fileStrings := TStringList.Create;
  ID:=1;
  ID2:=1001;
  j:=0;
  while not EOF (DataFile) do
  begin
    Readln(DataFile, lineFile);
    ExtractStrings([','],[' '],pChar(Linefile),fileStrings);

    if(IsNumber(fileStrings.strings[0]) = false)then begin
      filestrings.Clear;
      continue;
    end;

    //Adiciona na estrutura;
    Npcs[ID].MinuteGenerate := strtoint(fileStrings.Strings[0]);
    Npcs[ID].Leader_Name := fileStrings.Strings[1];//nome
    Npcs[ID].Follower_Name := fileStrings.Strings[2];
    Npcs[ID].Leader_Count := strtoint(fileStrings.Strings[3]);
    Npcs[ID].Follower_Count := strtoint(fileStrings.Strings[4]);//
    Npcs[ID].RouteType := strtoint(fileStrings.Strings[5]);//
    Npcs[ID].SpawnPosx := strtoint(fileStrings.Strings[6]);//
    Npcs[ID].SpawnPosY := strtoint(fileStrings.Strings[7]);//
    Npcs[ID].SpawnWait := strtoint(fileStrings.Strings[8]);//
    Npcs[ID].SpawnSay := fileStrings.Strings[9];//
    Npcs[ID].Destx := strtoint(fileStrings.Strings[10]);//
    Npcs[ID].Desty := strtoint(fileStrings.Strings[11]);//
    Npcs[ID].DestSay := fileStrings.Strings[12];//
    Npcs[ID].DestWait := strtoint(fileStrings.Strings[13]);//
    Npcs[ID].ReviveTime:=strtoint(fileStrings.Strings[14]);
    filestrings.Clear;
    local123:=diretorio+'\npc\'+Npcs[ID].Leader_Name;
    if(fileexists(local123) = false) then begin
      Showmessage('Npc: '+Npcs[ID].Leader_Name+' não encontrado.');
      error:=true;
      inc(j);
      continue;
    end;
    AssignFile(f2, local123);
    Reset(f2);
    Read(f2, aux);
    CloseFile(f2);
    inc(ID);
    aux2.Race := aux.Race;
    aux2.Merchant := aux.Merchant;
    aux2.Classe := aux.Classe;
    aux2.gold := aux.gold;
    aux2.exp := aux.exp;
    aux2.x := aux.x;
    aux2.y := aux.y;
    aux2.Stat := aux.Stat;
    aux2.bStat := aux.bStat;
    move(aux.Equip, aux2.Equip, sizeof(item)*16);
    move(aux.Inventory,aux2.Inventory, sizeof(item)*65);
    move(aux.unk,aux2.GuildIndex,2);
    move(aux.Name,aux2.Name,12);
    AssignFile(f3, local123);
    ReWrite(f3);
    Write(f3,aux2);
    CloseFile(f3);
  end;
  fileStrings.Free;
  CloseFile(DataFile);
  }
end;

procedure TF_Conversor.Button2Click(Sender: TObject);
var
lineFile, filePath : String;
f2: file of TOldNpc;
f3: file of TCharacter;
aux: TOldNpc;
aux2: TCharacter;
cnt: Integer;
begin
  cnt := 0;
  for filePath in TDirectory.GetFiles(Edit1.Text) do
  begin
    AssignFile(f2, filePath);
    Reset(f2);
    Read(f2, aux);
    CloseFile(f2);

    ZeroMemory(@aux2, sizeof(TCharacter));

    Move(aux, aux2, sizeOf(TOldNpc));
    move(aux.Equip, aux2.Equip, sizeof(TItem)*16);
    move(aux.Inventory,aux2.Inventory, sizeof(TItem)*64);
    aux2.CurrentScore.Level := aux.Stat.Level;
    aux2.CurrentScore.Defense := aux.Stat.Defense;
    aux2.CurrentScore.Attack := aux.Stat.Attack;
    aux2.CurrentScore.MoveSpeed := aux.Stat.MoveSpeed;
    aux2.CurrentScore.Merchant := aux.Stat.Merchant;
    aux2.CurrentScore.ChaosRate := aux.Stat.ChaosRate;
    aux2.CurrentScore.Direction := aux.Stat.Direction;

    aux2.CurrentScore.MaxHP := aux.Stat.MaxHP;
    aux2.CurrentScore.MaxMP := aux.Stat.MaxMP;
    aux2.CurrentScore.CurHP := aux.Stat.CurHP;
    aux2.CurrentScore.CurMP := aux.Stat.CurMP;

    aux2.CurrentScore.Str := aux.Stat.Str;
    aux2.CurrentScore.Int := aux.Stat.Int;
    aux2.CurrentScore.Dex := aux.Stat.Dex;
    aux2.CurrentScore.Con := aux.Stat.Con;

    aux2.CurrentScore.wMaster := aux.Stat.wMaster;
    aux2.CurrentScore.fMaster := aux.Stat.fMaster;
    aux2.CurrentScore.sMaster := aux.Stat.sMaster;
    aux2.CurrentScore.tMaster := aux.Stat.tMaster;

    aux2.BaseScore.Level := aux.bStat.Level;
    aux2.BaseScore.Defense := aux.bStat.Defense;
    aux2.BaseScore.Attack := aux.bStat.Attack;
    aux2.BaseScore.MoveSpeed := aux.bStat.MoveSpeed;
    aux2.BaseScore.Merchant := aux.bStat.Merchant;
    aux2.BaseScore.ChaosRate := aux.bStat.ChaosRate;
    aux2.BaseScore.Direction := aux.bStat.Direction;

    aux2.BaseScore.MaxHP := aux.bStat.MaxHP;
    aux2.BaseScore.MaxMP := aux.bStat.MaxMP;
    aux2.BaseScore.CurHP := aux.bStat.CurHP;
    aux2.BaseScore.CurMP := aux.bStat.CurMP;

    aux2.BaseScore.Str := aux.bStat.Str;
    aux2.BaseScore.Int := aux.bStat.Int;
    aux2.BaseScore.Dex := aux.bStat.Dex;
    aux2.BaseScore.Con := aux.bStat.Con;

    aux2.BaseScore.wMaster := aux.bStat.wMaster;
    aux2.BaseScore.fMaster := aux.bStat.fMaster;
    aux2.BaseScore.sMaster := aux.bStat.sMaster;
    aux2.BaseScore.tMaster := aux.bStat.tMaster;

    aux2.Learn := aux.Learn;
    aux2.pStatus := aux.pStatus;
    aux2.pMaster := aux.pMaster;
    aux2.pSkill := aux.pSkill;
    aux2.Critical := aux.Critical;
    aux2.SaveMana := aux.SaveMana;

    aux2.GuildMemberType := aux.GuildMemberType;

    aux2.MagicIncrement := aux.MagicIncrement;
    aux2.RegenHP := aux.RegenHP;
    aux2.RegenMP := aux.RegenMP;

    aux2.Resist[0] := aux.Resist[0];
    aux2.Resist[1] := aux.Resist[1];
    aux2.Resist[2] := aux.Resist[2];
    aux2.Resist[3] := aux.Resist[3];
//    aux2.Name := Trim(aux2.Name);
{
    aux2.CapeInfo := aux.Race;
    aux2.Merchant := aux.Merchant;
    aux2.ClassInfo := aux.Classe;
    aux2.gold := aux.gold;
    aux2.exp := aux.exp;
    aux2.Last.X := aux.x;
    aux2.Last.Y := aux.y;
    aux2.CurrentScore := aux.Stat;
    aux2.BaseScore := aux.bStat;
    move(aux.Equip, aux2.Equip, sizeof(TItem)*16);
    move(aux.Inventory,aux2.Inventory, sizeof(TItem)*64);
    move(aux.unk,aux2.GuildIndex,2);
    move(aux.Name,aux2.Name,16);
}
    AssignFile(f3, Edit2.Text+'\'+aux2.Name);
//    if FileExists(Edit2.Text+'\'+aux2.Name) then
    ReWrite(f3);
//    else
//      CreateFile()
    Write(f3,aux2);
    CloseFile(f3);
    Inc(cnt);
  end;
  MessageDlg('[' + IntToStr(cnt) + '] arquivos foram convertidos!', mtConfirmation, [mbOK], 0);
end;

procedure TF_Conversor.Edit1DblClick(Sender: TObject);
var options : TSelectDirOpts;
begin
  if not SelectDirectory(sourceDirectory, options, 0) then
    exit;

  Edit1.Text := sourceDirectory;
end;


procedure TF_Conversor.Edit2DblClick(Sender: TObject);
var options : TSelectDirOpts;
begin
  if not SelectDirectory(destinationDirectory, options, 0) then
    exit;
  Edit2.Text := destinationDirectory;
end;

procedure TF_Conversor.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TF_Conversor.FormCreate(Sender: TObject);
begin
  sourceDirectory := GetCurrentDir;
  destinationDirectory := GetCurrentDir;
end;

end.
