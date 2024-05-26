unit Player;

interface

uses Windows, ClientConnection, WinSock2, PlayerData, MiscData, BaseMob,
      SysUtils, Generics.Collections, Packets, Log, System.Threading;

type
  TPlayer = class(TBaseMob)
  published
    class constructor Create;
    constructor Create(clientId : WORD; conn: TClientConnection);
    destructor Destroy;

  private
    SelectedCharacterIndex : integer;

  public
    Status : TPlayerStatus;
    SubStatus : TPlayerStatus;
    PlayerCharacter : TPlayerCharacter;
    Account : TAccountFile;
    CountTime : TDateTime;
    Connection : TClientConnection;
    KnowInitItems: TList<integer>;
    isFirstAppear : Boolean;
    acceptedParty : Boolean;
    WaitingDbServer : Boolean;
    Disposing : Boolean;
    IsDiconnecting : Boolean;
    SND : String[95];

    class var Players : array[1..750] of TPlayer;
    class var InstantiatedPlayers: WORD;

    procedure Disconnect();
    procedure UpdateVisibleDropList();
    procedure SendPacket(packet : pointer; size : WORD);
    function RequestAccount(userName, passWord: string): Boolean;
    procedure SaveAccount();
    function BackToCharList() : Boolean;

    procedure GetCreateMobTrade(out packet : TSendCreateMobTradePacket);

    // Sends
    procedure RefreshMoney();
    procedure SendClientMessage(str: AnsiString);
    procedure RefreshInventory();
    procedure SendCharList(code: Word);
    procedure SendCharListFromLogin;
    function SendToWorld(charId : Byte) : Boolean;
    procedure SendWeather();
    procedure SendCreateItem(invType : smallint; invSlot : smallint; item: TItem);
    procedure SendItem(invType : smallint; invSlot : smallint);
    procedure SendCreateDropItem(initId: WORD);
    procedure SendDeleteDropItem(initId: WORD; sendSelf: Boolean = False);
    procedure SendDeleteItem(invType : smallint; invSlot : smallint);
    procedure SendEmotion(effType, effValue: integer);

    procedure CloseTrade;

    procedure SendAutoTrade(player : TPlayer);
    //procedure SendParty(leader, member : WORD);
    procedure SendExitParty(exitid: WORD);

    function ReceiveData() : Boolean;

    class function GetPlayer(index: WORD; out player: TPlayer): boolean; overload; static;
    class function GetPlayer(index: WORD): TPlayer; overload; static;
    class procedure ForEach(proc: TProc<TPlayer>); overload; static;
    class procedure ForEach(proc: TProc<TPlayer, TParallel.TLoopState>); overload; static;
end;


implementation
uses Functions, ItemFunctions, Position, BackgroundThread,
  FireDAC.Phys.MongoDBWrapper, System.Variants, System.JSON.Builders,
  System.JSON, GlobalDefs, ConstDefs, PacketsDbServer;

{ TPlayer }
class constructor TPlayer.Create;
begin
  ZeroMemory(@Players, SizeOf(Players));
  InstantiatedPlayers := 0;
end;


constructor TPlayer.Create(clientId : WORD; conn: TClientConnection);
begin
  inherited Create(clientId);
  self.Connection := conn;
  KnowInitItems := TList<integer>.Create;
  acceptedParty := False;
  Disposing := False;
end;

destructor TPlayer.Destroy;
begin
  Disposing := True;
  if (Status = Playing) then
    SendRemoveMob(DELETE_DISCONNECT);

  Account.Header.IsActive := false;
  if (self.Status > AccNotFound) and (DBClient.Started) then
    SaveAccount;

  Connection.Destroy;
  inherited Destroy;
end;

procedure TPlayer.Disconnect;
begin
  SendSignal(ClientId, $3EA);
  IsDiconnecting := True;
  //if (self.Status > AccNotFound) and (DBClient.Started) then
  //  SaveAccount;
  //Server.Disconnect(self);
end;

procedure TPlayer.UpdateVisibleDropList();
var
  initIdLocal : WORD;
  initItem: TInitItem;
begin
  if(KnowInitItems.Count > 0) then // Talvez possamos remover essa verificação
  begin
    for initIdLocal in KnowInitItems do
    begin
      initItem := InitItems[initIdLocal];
      if not(CurrentPosition.InRange(initItem.Pos, DISTANCE_TO_FORGET)) then
        KnowInitItems.Remove(initIdLocal);
    end;
  end;

  CurrentPosition.ForEach(DISTANCE_TO_WATCH, procedure(pos: TPosition)
  var
    initId : WORD;
  begin
    initId := ItemGrid[pos.Y][pos.X];
    if(initId = 0) or (KnowInitItems.Contains(initId)) then
      exit;

    KnowInitItems.Add(initId);
    SendCreateDropItem(initId);
  end);
end;

function TPlayer.BackToCharList : Boolean;
begin
  SaveAccount();
  MobGrid[CurrentPosition.Y][CurrentPosition.X] := 0;
  ZeroMemory(@Character, sizeof(TCharacter));
  Status := CharList;
  SelectedCharacterIndex := -1;
  SendSignal(self.ClientId, $116);
  Result := true;
  VisibleMobs.Clear;
end;

procedure TPlayer.CloseTrade;
var i: BYTE;
begin
  ZeroMemory(@self.PlayerCharacter.Trade, sizeof(TTrade));
  for i := 0 to 14 do
    self.PlayerCharacter.Trade.TradeItemSlot[i] := -1;
  self.SendSignal(ClientId, $384);
end;

class procedure TPlayer.ForEach(proc: TProc<TPlayer, TParallel.TLoopState>);
begin
  TParallel.For(1, InstantiatedPlayers, procedure(i : Integer; state : TParallel.TLoopState)
  var player: TPlayer;
  begin
    player := Players[i];
    if not(Assigned(player)) then
      exit;
    proc(player, state);
  end);
end;

class procedure TPlayer.ForEach(proc: TProc<TPlayer>);
var i: Integer;
  player: TPlayer;
begin
  TParallel.For(1, InstantiatedPlayers, procedure(i : Integer)
  var player: TPlayer;
  begin
    player := Players[i];
    if not(Assigned(player)) then
      exit;
    proc(player);
  end);
end;

procedure TPlayer.GetCreateMobTrade(out packet: TSendCreateMobTradePacket);
var pak : TSendCreateMobPacket;
begin
  GetCreateMob(pak);
  ZeroMemory(@packet, sizeof(TSendCreateMobTradePacket));
  Move(pak, packet, 132);

  packet.Header.Code  := $363;
  packet.Header.Size  := sizeof(TSendCreateMobTradePacket);
  packet.Header.Index := $7530;
  packet.spawnType    := $CC;
  packet.MemberType   := $CC;

  packet.StoreName    := PlayerCharacter.TradeStore.Name;
  packet.StoreName[0] := PlayerCharacter.TradeStore.Name[0];
  //Move(Player[index].TradeLoja.Name,packet.StoreName[0],24);
  //Player[index].TradeLoja.Name
  packet.x2       := packet.Position.X;
  packet.y2       := packet.Position.Y;
  packet.clientId := packet.Index;
  packet.Clock    := TFunctions.Clock;

  FillChar(packet.unk[0],13,$CC);
  FillChar(packet.unk3[0],8,$CC);
  FillChar(packet.unk4[0],4,$CC);
end;

class function TPlayer.GetPlayer(index: WORD; out player: TPlayer): boolean;
begin
  Result := false;
  if(index = 0) OR (index > MAX_CONNECTIONS) then
    exit;

  player := Players[index];
  Result := Assigned(player);
end;

class function TPlayer.GetPlayer(index: WORD): TPlayer;
begin
  if(index = 0) OR (index > MAX_CONNECTIONS) then
    exit;

  result := Players[index];
end;

procedure TPlayer.SendPacket(packet : pointer; size : WORD);
begin
  if(Connection.Socket = -1) then exit;
  Connection.SendPacket(packet, size);
end;

procedure TPlayer.SendEmotion(effType, effValue: integer);
var packet: TRequestEmotion;
begin
    packet.Header.Size  := sizeof(TRequestEmotion);
    packet.Header.Code  := $36A;
    packet.Header.Index := ClientId;

    packet.effType  := effType;
    packet.effValue := effValue;
    packet.Unknown1 := 0;

    SendToVisible(@packet, packet.Header.Size, true);
end;

procedure TPlayer.SendCharListFromLogin();
var
  packet: TSendToCharListFromLoginPacket;
  i : BYTE;
begin
  ZeroMemory(@packet, sizeof(TSendToCharListFromLoginPacket));

  packet.Header.Code := $10A;
  packet.Header.Index := 30002;

  for i := 0 to 3 do
  begin
    if(Account.Characters[i].Base.Equip[0].Index = 0) then
      continue;
    Move(Account.Characters[i].Base.Name, packet.CharactersData.Name[i][0], 15);
    Move(Account.Characters[i].Base.Equip, packet.CharactersData.Equip[i][0], sizeof(TItem) * MAX_EQUIPS);

    if (Account.Characters[i].Base.Equip[0].Index in [22,23,24,25,32]) then
      packet.CharactersData.Equip[i][0].Index := Account.Characters[i].Base.Equip[0].Effects[2].Value;

    packet.CharactersData.Status[i] := Account.Characters[i].Base.BaseScore;
    packet.CharactersData.GuildIndex[i] := Account.Characters[i].Base.GuildIndex;
    packet.CharactersData.Gold[i] := Account.Characters[i].Base.Gold;
    packet.CharactersData.Exp[i] := Account.Characters[i].Base.Exp;
  end;

  if(Status = CharList) then
  begin
    packet.Header.Size := sizeof(TUpdateCharacterListPacket);
    SendPacket(@packet, packet.Header.Size);
    exit;
  end;

  packet.Gold := Account.Header.StorageGold;
  Move(Account.Header.StorageItens[0], packet.Storage[0], sizeof(TItem) * MAX_CARGO);
  Move(Account.Header.Username, packet.Name[0], 12);
  Move(self.Connection.AdapterName, packet.Keys, 12);
  Status := CharList;
  SubStatus := Senha2;

  packet.Header.Size := sizeof(TSendToCharListFromLoginPacket);
  SendPacket(@packet, packet.Header.Size);
end;

procedure TPlayer.SendCharList(code: Word);
var
  packet: TSendToCharListPacket;
  i : BYTE;
begin
  ZeroMemory(@packet, sizeof(TSendToCharListPacket));

  packet.Header.Code := code;
  packet.Header.Index := 30002;
  for i := 0 to 3 do
  begin
    if(Account.Characters[i].Base.Equip[0].Index = 0) then
      continue;
    Move(Account.Characters[i].Base.Name, packet.CharactersData.Name[i][0], 15);
    Move(Account.Characters[i].Base.Equip, packet.CharactersData.Equip[i][0], sizeof(TItem) * MAX_EQUIPS);

    if (Account.Characters[i].Base.Equip[0].Index in [22,23,24,25,32]) then
      packet.CharactersData.Equip[i][0].Index := Account.Characters[i].Base.Equip[0].Effects[2].Value;

    packet.CharactersData.Status[i] := Account.Characters[i].Base.BaseScore;
    packet.CharactersData.GuildIndex[i] := Account.Characters[i].Base.GuildIndex;
    packet.CharactersData.Gold[i] := Account.Characters[i].Base.Gold;
    packet.CharactersData.Exp[i] := Account.Characters[i].Base.Exp;
  end;

  if(Status = CharList) then
  begin
    packet.Header.Size := sizeof(TUpdateCharacterListPacket);
    SendPacket(@packet, packet.Header.Size);
    exit;
  end;

  packet.Gold := Account.Header.StorageGold;
  Move(Account.Header.StorageItens[0], packet.Storage[0], sizeof(TItem) * MAX_CARGO);
  packet.Name := Account.Header.Username;
  packet.Keys := Account.Header.Password;
  Status := CharList;
  SubStatus := Senha2;

  packet.Header.Size := sizeof(TSendToCharListPacket);
  SendPacket(@packet, packet.Header.Size);
end;

function TPlayer.RequestAccount(userName, passWord: string): Boolean;
var
  packet: TResquestAccount;
begin
  self.Status := WaitingAccount;
  ZeroMemory(@packet, sizeof(TResquestAccount));
  packet.Header.Size := sizeof(TResquestAccount);
  packet.Header.Code := $3;
  packet.Header.Index:= DbClient.ServerId;
  StrPLCopy(packet.Login, userName, Length(userName));
  StrPLCopy(packet.PassWord, passWord, Length(passWord));
  packet.ClientId := self.ClientId;
  DbClient.SendPacket(@packet, packet.Header.Size);
end;

function TPlayer.SendToWorld(charId : Byte) : Boolean;
var packet : TSendToWorldPacket;
    spawnPosition : TPosition;
    direction: BYTE;
  I: BYTE;
begin
  Result := false;

  spawnPosition := TFunctions.GetStartXY(self, charId);

  if not(TFunctions.GetEmptyMobGrid(ClientId, spawnPosition.X, spawnPosition.Y)) then
  begin
    SendClientMessage('Falta espaço no mapa.');
    exit;
  end;

  ZeroMemory(@PlayerCharacter, sizeof(TPlayerCharacter));
  ZeroMemory(@packet, sizeof(TSendToWorldPacket));

  SelectedCharacterIndex := charId;

  packet.Header.Size := sizeof(TSendToWorldPacket);
  packet.Header.Code := $114;
  packet.Header.Index := $7532;

  Move(Account.Characters[charId], PlayerCharacter, sizeof(TCharacterDB));
  Move(Account.Characters[charId].Base, Character, sizeof(TCharacter));

  GetCurrentScore;
  if(IsDead) then
  begin
    Character.CurrentScore.CurHP := Character.CurrentScore.MaxHP;
  end;

  Character.Last := spawnPosition;
  CurrentPosition := spawnPosition;
  direction := Character.CurrentScore.Direction;

  MobGrid[Character.Last.Y][Character.Last.X] := Clientid;

  Character.ClientId := Clientid;
  Character.SlotIndex := charId;
  Character.CityId := 0;

  Character.Tab := 'WYDelphi';

  Move(Character, packet.Character, sizeof(TCharacter));
  packet.Point := spawnPosition;

  SendPacket(@packet, packet.Header.Size);

  isFirstAppear := True;

//  UpdateVisibleDropList;

  SendCreateMob(SPAWN_TELEPORT);

  SendCreateMob(SPAWN_TELEPORT, self.ClientId);
  SendGridMob(SPAWN_TELEPORT);

  isFirstAppear := False;

  SendAffects;
  SendScore;
  SendWeather;

  if(Character.Equip[14].Index >= 2330) and (Character.Equip[14].Index <= 2359) then
    GenerateBabyMob;

  Status := Playing;
  //SendSignal(0, $3A0);

  if not(PlayersNick.ContainsKey(Character.Name)) then
    PlayersNick.Add(Character.Name, ClientId)
  else
  begin
    PlayersNick.Remove(Character.Name);
    PlayersNick.Add(Character.Name, ClientId);
  end;

  Result := true;
end;

procedure TPlayer.SendWeather;
var packet : TSendWeatherPacket;
begin
  packet.Header.Size := sizeof(TSendWeatherPacket);
  packet.Header.Code := $18B;
  packet.Header.Index := ClientId;
  packet.WeatherId := BYTE(CityWeather[BYTE(PlayerCharacter.CurrentCity)].Condition);
  SendPacket(@packet, packet.Header.Size);
end;

procedure TPlayer.SaveAccount;
var
  packet : TSaveAccount;
begin
  ZeroMemory(@packet, sizeof(TSaveAccount));
  packet.Header.Size := sizeof(TSaveAccount);
  packet.Header.Code := $7;
  packet.Header.Index := DbClient.ServerId;
  if (self.status = Playing) then
  begin
    Move(Character, self.PlayerCharacter.Base, sizeof(TCharacter));
    Move(self.PlayerCharacter, self.Account.Characters[SelectedCharacterIndex], sizeof(TCharacterDB));
  end;
  Move(self.Account, packet.Acc, sizeof(TAccountFile));
  DbClient.SendPacket(@packet, packet.Header.Size);
end;

procedure TPlayer.RefreshMoney;
var packet : TRefreshMoneyPacket;
begin
  ZeroMemory(@packet, sizeof(TRefreshMoneyPacket));

  packet.Header.Size := sizeof(TRefreshMoneyPacket);
	packet.Header.Code := $3AF;
	packet.Header.Index := Clientid;
	packet.Gold := (self as TBaseMob).Character.Gold;

  SendPacket(@packet, packet.Header.Size);
end;

procedure TPlayer.SendClientMessage(str: AnsiString);
var packet: TClientMessagePacket;
begin
  ZeroMemory(@packet, sizeof(TClientMessagePacket));

  packet.Header.Size := sizeof(TClientMessagePacket);
  packet.Header.Code := $101;
  packet.Header.Index := 0;

  FillChar(packet.Message, 96, #0);
  StrPLCopy(packet.Message, str, 96);

  SendPacket(@packet, packet.Header.Size);
end;

function TPlayer.ReceiveData() : Boolean;
var ReceivedBytes : integer;
begin
  Result := false;
	ZeroMemory(@Connection.RecvBuffer, 3000);
	ReceivedBytes := Recv(Connection.Socket, Connection.RecvBuffer, 3000, 0);
	if(ReceivedBytes <= 0) then
  begin
    exit;
  end;
  Result := Server.OnReceivePacket(self, Connection.RecvBuffer, ReceivedBytes);
end;

procedure TPlayer.RefreshInventory;
var packet: TRefreshInventoryPacket;
begin
  ZeroMemory(@packet, sizeof(TRefreshInventoryPacket));

  packet.Header.Size := sizeof(TRefreshInventoryPacket);
	packet.Header.Code := $185;
	packet.Header.Index := Clientid;

	packet.Gold := (self as TBaseMob).Character.Gold;

  //packet.Inventory := Character.Base.Inventory;
  Move((self as TBaseMob).Character.Inventory[0], packet.Inventory[0], sizeof(TItem) * MAX_INV);

  SendPacket(@packet, packet.Header.Size)
end;

procedure TPlayer.SendCreateItem(invType : smallint; invSlot : smallint; item: TItem);
var packet: TSendCreateItemPacket;
begin
  ZeroMemory(@packet, sizeof(TSendCreateItemPacket));

  packet.Header.Size := sizeof(TSendCreateItemPacket);
  packet.Header.Code := $182;
  packet.Header.Index := ClientId;

  packet.invType := invType;
  packet.invSlot := invSlot;

  if(@item = NIL) then
      fillchar(packet.itemData, 0, sizeof(Item))
  else
      Move(item, packet.itemData, sizeof(item));

  SendPacket(@packet, packet.Header.Size);
end;

procedure TPlayer.SendItem(invType : smallint; invSlot : smallint);
var packet: TSendCreateItemPacket;
begin
  ZeroMemory(@packet, sizeof(TSendCreateItemPacket));

  packet.Header.Size := sizeof(TSendCreateItemPacket);
  packet.Header.Code := $182;
  packet.Header.Index := ClientId;

  packet.invType := invType;
  packet.invSlot := invSlot;

  case invType of
    EQUIP_TYPE:
      Move(self.Character.Equip[invSlot], packet.itemData, sizeof(TItem));
    INV_TYPE:
      Move(self.Character.Inventory[invSlot], packet.itemData, sizeof(TItem));
    STORAGE_TYPE:
      Move(self.Account.Header.StorageItens[invSlot], packet.itemData, sizeof(TItem));
    else
      exit;
  end;

  SendPacket(@packet, packet.Header.Size);
end;

procedure TPlayer.SendCreateDropItem(initId: WORD);
var packet: TSendCreateDropItem; initItem : TInitItem;
begin
  initItem := InitItems[initId];
  ZeroMemory(@packet, sizeof(TSendCreateDropItem));

  packet.Header.Size := sizeof(TSendCreateDropItem);
  packet.Header.Code := $26E;
  packet.Header.Index := $7530;

  packet.Pos := initItem.Pos;
  packet.initId := initId + 10000;

  Move(initItem.Item, packet.item, sizeof(TItem));

  packet.rotation := 0;
  packet.status   := 0;

  packet.Unknown := 0;

  self.SendToVisible(@packet, packet.Header.Size);
end;

procedure TPlayer.SendDeleteDropItem(initId: WORD; sendSelf: Boolean = False);
var packet: TDropDelete;
begin
  ZeroMemory(@packet, sizeof(TDropDelete));

  packet.Header.Size := sizeof(TDropDelete);
  packet.Header.Code := $16F;
  packet.Header.Index := $7530;

  packet.initId := initId;

  packet.Unknown1 := 0;

  if (sendSelf) then
    self.SendPacket(@packet, packet.Header.Size)
  else
    self.SendToVisible(@packet, packet.Header.Size);
end;

procedure TPlayer.SendDeleteItem(invType : smallint; invSlot : smallint);
var packet: TSendDeleteItemPacket;
begin
  ZeroMemory(@packet, sizeof(TSendDeleteItemPacket));

  packet.Header.Size := sizeof(TSendDeleteItemPacket);
  packet.Header.Code := $175;
  packet.Header.Index := ClientId;

  packet.invType := invType;
  packet.invSlot := invSlot;

  packet.Pos := (self as TBaseMob).Character.Last;

  SendPacket(@packet, packet.Header.Size);
end;

procedure TPlayer.SendAutoTrade(player : TPlayer);
var packet: TRequestOpenPlayerStorePacket;
begin
  packet.Header.Size  := sizeof(TRequestOpenPlayerStorePacket);
  packet.Header.Code  := $397;
  packet.Header.Index := player.clientId;

  Move(self.PlayerCharacter.TradeStore,packet.Trade,sizeof(TTradeStore));

  player.SendPacket(@packet, packet.Header.Size);
end;

procedure TPlayer.SendExitParty(exitid: WORD);
var packet: TExitPartyPacket;
begin
  packet.Header.Size  := sizeof(TExitPartyPacket);
  packet.Header.Code  := $37E;
  packet.Header.Index := $7530;
  packet.ExitId       := exitid;
  packet.unk          := 0;

  SendPacket(@packet,packet.Header.Size);
end;

(*void SendPKInfo(int conn, int target)
{
	if (conn <= 0 || conn >= MAX_USER)
		return;

	if (target <= 0 || target >= MAX_USER)
		return;

	MSG_STANDARDPARM sm;
	memset(&sm, 0, sizeof(MSG_STANDARDPARM));

	sm.Size = sizeof(MSG_STANDARDPARM);
	sm.Type = _MSG_PKInfo;
	sm.ID = target;

	if (NewbieEventServer == 0)
	{
		int guilty = GetGuilty(target);

		int state = 0;

		if (guilty || pUser[target].PKMode || RvRState || CastleState || GTorreState)
			state = 1;

		sm.Parm = state;
	}
	else
		sm.Parm = 1;

	pUser[conn].cSock.AddMessage(&sm, sizeof(MSG_STANDARDPARM));
}*)

end.

