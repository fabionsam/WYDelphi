unit Packets;

interface

Uses PlayerData, MiscData, Util, Position, ConstDefs;


type TPacketHeader = packed Record
  Size: Smallint;
  Key: Byte;
  ChkSum: Byte;
  Code: Smallint;
  Index: Smallint;
  Time: integer;
end;

type TSignalData = packed Record
  Header : TPacketHeader;
  Data : integer;
end;

type TSignalData2 = packed Record
  Header : TPacketHeader;
  Data : integer;
  Data2 : integer;
end;

type TNpcPacket = packed Record
  Header : TPacketHeader;
  NpcIndex: WORD;
  //Unknow: array[0..5] of BYTE;
  Unknow: WORD;
  Confirm: WORD;
end;

type TMestreGriffo = packed Record
	Header   : TPacketHeader;
	WarpID   : integer;
	WarpType : integer;
end;

// Request Emotion
type TRequestEmotion = packed Record
  Header  : TPacketHeader;
  effType : smallint;
  effValue: smallint;
  Unknown1: integer;
end;

type TDeleteItem = packed Record
  Header: TPacketHeader;
  slot,itemid: integer;
end;

type TGroupItem = packed Record
  Header: TPacketHeader;
  slot,itemid,quant: integer;
end;

type TRequestLoginPacket = packed Record
  Header: TPacketHeader;
  PassWord: array[0..9] of AnsiChar;
  unk: array[0..1] of BYTE;
  UserName: array[0..11] of AnsiChar;
  Zero: array[0..55] of BYTE;
  Version: integer;
  DBNeedSave: Boolean;
  AdapterName: array[0..3] of integer;
end;

type TRefreshMoneyPacket = packed Record
  Header: TPacketHeader;
  Gold: integer;
end;

type TRefreshEtcPacket = packed Record
  Header: TPacketHeader;
  Hold: Cardinal;
  Exp: Int64;
  Learn: Int64;
  StatusPoint: smallint;
  MasterPoint: smallint;
  SkillsPoint: smallint;
  MagicIncrement: smallint;
  Gold: Int64;
end;

type TClientMessagePacket = packed Record
  Header  : TPacketHeader;
  Message : Array[0..95] of AnsiChar;
end;

type TRefreshInventoryPacket = packed Record
  Header : TPacketHeader;
  Inventory : array[0..MAX_INV - 1] of TItem;
  Gold : Int64;
end;

type TSendCurrentHPMPPacket = packed Record
	Header: TPacketHeader;
	CurHP : Integer;
	CurMP : Integer;
  MaxHP : Integer;
	MaxMP : Integer;
end;


type TSendScorePacket = packed Record
  Header: TPacketHeader; //12
  Score : TStatus;       //40
  Critical: BYTE;
  SaveMana: BYTE;

  Affects: array[0..MAXBUFFS - 1] of TPacketAffect;

	GuildIndex, GuildMemberType : BYTE;

  Resist : array[0..3] of shortint;

  RegenHP, RegenMP : BYTE;

	CurHP, CurMP : Integer;

	MagicIncrement : Integer;
	Special: array[0..4] of BYTE;
end;

// Request Command
type TCommandPacket = packed Record
  Header: TPacketHeader;
  //Command: String[15];
  //Value: String[99];
  Command: array[0..15] of AnsiChar;
  Value: array[0..99] of AnsiChar;
end;

type TChatPacket = packed Record
  Header: TPacketHeader;
  Chat: array[0..94] of AnsiChar
end;


type TMessageAction = packed Record
  PosX, PosY: WORD;
  Speed : Integer;
  Effect: SmallInt;		// 0:앉기  1:서기  2:걷기  3:뛰기  4:날기  5:텔레포트,	6:밀리기(knock-back), 7:미끄러지기(이동애니없음)  8:도발, 9:인사, 10:돌격
  Direction: SmallInt;	//
  TargetX,TargetY: WORD;
end;

// Request Add Points
type TRequestAddPoints = packed Record
  Header: TPacketHeader;
  Mode,Info: smallint;
  Unk: integer;
end;

type TCharListCharactersData = packed Record
  Unknow_28: array[0..3] of Byte;

//  Position: array[0..3] of TPosition;
  PosX: array[0..3] of WORD;
  PosY: array[0..3] of WORD;
  Name: array[0..3] of array[0..15] of AnsiChar;

  Status: array[0..3] of tStatus;
  Equip: array[0..3] of array[0..MAX_EQUIPS-1] of tItem;

  GuildIndex: array[0..3] of Byte;

  Unknow_29: integer;

  Gold: array[0..3] of Int64;
  Exp: array[0..3] of uInt64;
end;

type TSendToCharListFromLoginPacket = packed Record
  Header : TPacketHeader;
  HashKeyTable : array[0..15] of Byte;

  CharactersData : TCharListCharactersData;
  Storage : array[0..MAX_CARGO - 1] of TItem;

  Unk: array[0..63] of Byte;

  Gold : Int64;
  Name : array[0..11] of Byte;
  Keys : array[0..15] of Byte;
end;

type TSendToCharListPacket = packed Record
  Header : TPacketHeader;
  CharactersData : TCharListCharactersData;
  Storage : array[0..MAX_CARGO - 1] of TItem;

  Gold : Int64;
  Name : String[11];
  Keys : String[15];

  unk1 : Integer;
  unk2 : Integer;
end;

type TNumericTokenPacket = packed Record
	Header: TPacketHeader;
	num: array[0..5] of AnsiChar;
  unk: array[0..9] of AnsiChar;
	RequestChange: integer;
end;

type TCreateCharacterRequestPacket = packed Record
  Header: TPacketHeader;
  SlotIndex: integer;
  Name: array[0..15] of AnsiChar;
  ClassIndex: integer;
end;

type TUpdateCharacterListPacket = packed Record
  Header: TPacketHeader;
  CharactersData : TCharListCharactersData;
end;

type TDeleteCharacterRequestPacket = packed Record
  Header: TPacketHeader;
  SlotIndex: Integer;
  Name: array[0..15] of AnsiChar;
  Password: array[0..11] of AnsiChar;
end;

type TSelectCharacterRequestPacket = packed Record
  Header : TPacketHeader;
  CharacterId : Byte;
End;

type TSendToWorldPacket = packed Record
  Header: TPacketHeader;
  Point: TPosition;
  Character: TCharacter;
  Zero: array[0..(1711 - (sizeof(TCharacter) + sizeof(TPosition) + 12))] of byte;
end;

type TAffectInPacket = packed Record
  Time: BYTE;
  Index: BYTE;
end;

type TSendNPCSellItensPacket = packed Record
  Header: TPacketHeader;
  Merch: integer;

  Itens: array[0..26] of TItem;

  Imposto: integer;
End;


type TSellItemsToNpcPacket = packed Record
  Header: TPacketHeader;
  mobID,invType: smallint;
  invSlot: integer;
end;

type TBuyNpcItensPacket = packed Record
  Header: TPacketHeader;
  mobID,sellSlot: smallint;
  invSlot,Unknown1: smallint;
  Unknown2: integer;
end;

type p2E4 = packed Record
  Header: TPacketHeader;
  slot, itemid: integer;
end;

//Send Party Request
type TPartyRequestPacket = packed Record
  Header: TPacketHeader;
  LeaderId: WORD;
  Level: WORD;
  MaxHp, CurHp: WORD;
  SenderId: WORD;
  Nick: array[0..15] of AnsiChar;//string[15];
  unk2: BYTE;
  TargetId: WORD;
end;

type TAcceptPartyPacket = packed Record
  Header: TPacketHeader;
  LeaderId: WORD;
  Nick: array[0..15] of AnsiChar;
end;

type TExitPartyPacket = packed Record
  Header: TPacketHeader;
  ExitId: WORD;
  unk: Word;//$CCCC
end;

type TSendPartyMember = packed Record
  Header: TPacketHeader;
  LiderID: WORD;
  Level: WORD;
  MaxHp, CurHp: WORD;
  ClientId: WORD;
  Nick: string[15];
  unk2: WORD;
end;

type TUseItemPacket = packed Record
  Header: TPacketHeader;
  SrcType, SrcSlot: integer;
  DstType, DstSlot: integer;

  Position : TPosition;
  unk: integer;
end;

// Request Drop Item
type TReqDropItem = packed Record
  Header: TPacketHeader;
  invType,
  InvSlot,
  Unknown1 : Integer;
  Position : TPosition;
  Unknown2 : Integer;
end;

type TMobNotInView = packed Record
  Header: TPacketHeader;
  MobId : Word;
End;

// Request Pick Item
type TReqPickItem = packed Record
  Header : TPacketHeader;
  invType,
  InvSlot : Integer;
  initId : WORD;
  Position : TPosition;
  Unknown1 : WORD;
end;

type TDropDelete = packed Record
  Header : TPacketHeader;
  initId : WORD;
  Unknown1 : WORD;
End;

// MOB DEAD
type
p_p338 = ^TSendMobDeadPacket;

TSendMobDeadPacket = packed Record
	Header: TPacketHeader;
	Hold: integer;
  killed, killer: smallint;
	Exp: Int64;
end;

type mob_kill = packed Record
  Hold : Integer;
  Exp: Int64;
  EnemyList, EnemyIndex: pInteger;
  Dead: boolean;
  inBattle: pBoolean;
end;


type TSendCreateMobPacket = packed Record
  private
    function GetBits(Index : BYTE; const aIndex: Integer): WORD;
    procedure SetBits(Index : BYTE; const aIndex: Integer; const aValue: WORD);
  public
    Header: TPacketHeader;

    Position : TPosition;

    ClientId: WORD;

    Values: array[0..15] of BYTE;

  //  Name: Array[0..11] of AnsiChar;
  //
  //  ChaosPoints : BYTE;
  //  CurrentKill : BYTE;
  //  TotalKill : WORD;

    ItemEff: array[0..15] of WORD;

    Affect: array[0..MAXBUFFS - 1] of TPacketAffect;

    GuildIndex: WORD;
    MemberType: BYTE;

    unk: array[0..2] of BYTE;

    Status: TStatus;

    SpawnType: WORD;

    AnctCode: array[0..15] of BYTE;

    Tab : array[0..25] of AnsiChar;

    unk2 : Integer;

    property Sanc[Index : BYTE] : WORD index $0C04 read GetBits write SetBits;
end;

type TSendCreateMobTradePacket = packed Record
  Header: TPacketHeader;

  Position : TPosition;

  Index: WORD;
  Name: array[0..11] of AnsiChar;

  ChaosPoint: BYTE;
  CurrentKill: BYTE;
  TotalKill: WORD;

  ItemEff: array[0..15] of WORD;

  Affect: array[0..15] of TPacketAffect;

  GuildIndex: WORD;

  Status: TStatus;

  spawnType: BYTE;
  MemberType: BYTE;

  unk: array[0..13] of BYTE;
  Clientid,unk2,y2,x2,clock : integer;

  unk3: array[0..7] of BYTE;

  StoreName: string[23];//Array[0..23]of AnsiChar;
  unk4: array[0..3] of BYTE;
  //tab: string[200];
end;


type TTradePacket = packed Record
	Header: TPacketHeader;

	TradeItem: array[0..14] of TItem;
	TradeItemSlot: array[0..14] of shortint;

	Unknow: BYTE;

	Gold: Int64;
	Confirm: boolean;
	OtherClientId: WORD;
end;

// Request Open Trade - 39A

//Open Trade
type TOpenTrade = packed Record
  Header: TPacketHeader;
  OtherClientId: integer;
end;

// Request Buy Item Trade
type TBuyStoreItemPacket = packed Record
  Header: TPacketHeader;
  Slot: integer;
  SellerId: integer;
  Gold: Int64;
  Unknown: integer;
  Item: TItem;
end;

type TSendItemBoughtPacket = packed Record
  Header: TPacketHeader;
  SellerId: Integer;
  Slot: Integer;
end;

// Request Create Item
type TSendCreateItemPacket = packed Record
  Header: TPacketHeader;
  invType: smallint;
  invSlot: smallint;
  itemData: TItem;
end;

// Send Delete Item
type TSendDeleteItemPacket = packed Record
  Header: TPacketHeader;
  invType: integer;
  invSlot: integer;
  Unknown: integer;
  Pos : TPosition;
end;

type TSendCreateDropItem = packed Record
  Header: TPacketHeader;
  Pos : TPosition;
  initId : WORD;
  item: TItem;
  rotation,
  status : BYTE;
  Unknown: integer;
End;
// Request Refresh Inventory



// Request Refresh Etc


// Request Move Item
type TMoveItemPacket = packed Record
  Header: TPacketHeader;
  DestType: BYTE;
  destSlot: BYTE;
  SrcType: BYTE;
  srcSlot: BYTE;
  Unknown: Int64;   //provavel gold banco
end;

// Request Refresh Itens
type TRefreshEquips = packed Record
  private
    function GetBits(Index : BYTE; const aIndex: Integer): WORD;
    procedure SetBits(Index : BYTE; const aIndex: Integer; const aValue: WORD);

  public
    Header: TPacketHeader;

    itemIDEF: array[0..15] of WORD;
    {
        unsigned short ItemID : 12;
        unsigned short Sanc : 4;
    } //ItemEff[16];

    pAnctCode: array[0..15] of shortint;

    property Sanc[Index : BYTE] : WORD index $0C04 read GetBits write SetBits;
end;

type TRequestOpenPlayerStorePacket = packed Record
  Header: TPacketHeader;
  Trade: TTradeStore;
end;


type TTarget = packed Record
  Index, Damage: Integer;
end;

//Attack Sigle Mob
type TProcessAttackOneMob = packed Record
	Header: TPacketHeader;

  unk: array[0..3] of BYTE;

  CurrentHp: Integer;

  unk2: array[0..3] of BYTE;

  CurrentExp: Int64;
  unk0: SmallInt;

  AttackerPos: TPosition;
  TargetPos: TPosition;

  AttackerID,
  AttackCount: WORD;

  Motion: ShortInt;
	SkillParm: ShortInt;
  DoubleCritical: ShortInt; // 0 para critico Simples, 1 para critico Duplo
	FlagLocal: ShortInt;

  rsv: WORD;

  CurrentMp: Integer;

  SkillIndex: SmallInt;
  ReqMp: SmallInt;

  Target: TTarget;

//	AttackerID, AttackCount: smallint; // Id de quem Realiza o ataque
//	AttackerPos: TPosition; // Posicao X e Y de quem Ataca
//	TargetPos: TPosition; // Posicao X e Y de quem Sofre o Ataque
//	SkillIndex: byte; // Id da skill usada
//	CurrentMp: smallint; // Mp atual de quem Ataca
//	Motion: shortint;   // (*)
//	SkillParm: shortint; // (*)
//	FlagLocal: shortint; // (*)
//	DoubleCritical: shortint; // 0 para critico Simples, 1 para critico Duplo
//	Hold : integer;
//  CurrentExp: Int64;
//	ReqMp: smallint; // Mp necessario para usar a Skill
//	Rsv: smallint;  // (*)
//  Target: TTarget;
end;


//Ataque em area
type TProcessAoEAttack = packed Record
	Header: TPacketHeader;

  unk: array[0..3] of BYTE;

  CurrentHp: Integer;

  unk2: array[0..3] of BYTE;

  CurrentExp: Int64;
  unk0: SmallInt;

  AttackerPos: TPosition;
  TargetPos: TPosition;

  AttackerID,
  AttackCount: WORD;

  Motion: BYTE;
	SkillParm: BYTE;
  DoubleCritical: BYTE; // 0 para critico Simples, 1 para critico Duplo
	FlagLocal: BYTE;

  rsv: WORD;

  CurrentMp: Integer;

  SkillIndex: SmallInt;
  ReqMp: SmallInt;

  Targets: array[0..12] of TTarget;

//	AttackerID,AttackCount: smallint; // Id de quem Realiza o ataque
//	AttackerPos: TPosition; // Posicao X e Y de quem Ataca
//	TargetPos: TPosition; // Posicao X e Y de quem Sofre o Ataque
//	SkillIndex: smallint; // Id da skill usada
//	CurrentMp: smallint; // Mp atual de quem Ataca
//	Motion: shortint;
//	SkillParm: shortint;
//	FlagLocal: shortint;
//	DoubleCritical: shortint; // 0 para critico Simples, 1 para critico Duplo
//	Hold : Integer;
//  CurrentExp: Int64;
//	ReqMp: smallint; // Mp necessario para usar a Skill
//	Rsv: smallint;
//	Targets: array[0..12] of TTarget;
end;


//atack reto
type
p_p39E = ^p39E;
p39E = packed Record
	Header: TPacketHeader;
	AttackerID,AttackCount: smallint; // Id de quem Realiza o ataque
	AttackerPos: TPosition; // Posicao X e Y de quem Ataca
	TargetPos: TPosition; // Posicao X e Y de quem Sofre o Ataque
	SkillIndex: smallint; // Id da skill usada
	CurrentMp: smallint; // Mp atual de quem Ataca
	Motion: shortint;
	SkillParm: shortint;
	FlagLocal: shortint;
	DoubleCritical: shortint; // 0 para critico Simples, 1 para critico Duplo
	Hold : Integer;
  CurrentExp: Int64;
	ReqMp: smallint; // Mp necessario para usar a Skill
	Rsv: smallint;

  Target: array[0..1] of TTarget;
end;

// Request Emotion
type TSendEmotionPacket = packed Record
  Header : TPacketHeader;
  effType, effValue: smallint;
  Unknown1: integer;
end;

type TSendWeatherPacket = packed Record
  Header: TPacketHeader;
  WeatherId: Integer;
End;

type TSkillBarChange = packed Record
  Header  : TPacketHeader;
  SkillBar: array[0..19] of BYTE;
End;

type TCompoundersPacket = packed Record
	  Header : TPacketHeader;
    Item: array[0..7] of TItem;
	  Slot: array[0..7] of BYTE;
end;

//GuildPackets
type TRecruitGuildMember = packed Record
  Header : TPacketHeader;
  otherClient, memberType : Integer;
End;

type TRemoveGuildMember = packed Record
  Header : TPacketHeader;
  otherClient : Integer;
End;

type TDeclareAlliance = packed Record
  Header : TPacketHeader;
  otherClient, memberType : Integer;
End;

//SendAffect
type TSendAffectsPacket = packed Record
	Header: TPacketHeader;
	Affects: array[0..MAXBUFFS] of TAffect;
end;

type TMovementPacket = packed Record
  Header : TPacketHeader;
  Source : TPosition;

  MoveType : integer;
  Speed : integer;

  Route : array [0..23] of AnsiChar;
  Destination : TPosition;
end; // p36c

type TMoveCommandPacket = packed Record // 52 -> 17
  Header: TPacketHeader;
  Destination: TPosition;
  Speed : Byte;
end;


implementation

uses System.Threading;

function TRefreshEquips.GetBits(Index : BYTE; const aIndex: Integer): WORD;
begin
  Result := GetBits(itemIDEF[Index], aIndex);
end;

procedure TRefreshEquips.SetBits(Index : BYTE; const aIndex: Integer; const aValue: WORD);
begin
  SetWordBits(itemIDEF[Index], aIndex, aValue);
end;

function TSendCreateMobPacket.GetBits(Index : BYTE; const aIndex: Integer): WORD;
begin
  Result := GetBits(itemEFF[Index], aIndex);
end;

procedure TSendCreateMobPacket.SetBits(Index : BYTE; const aIndex: Integer; const aValue: WORD);
begin
  SetWordBits(itemEFF[Index], aIndex, aValue);
end;

end.
