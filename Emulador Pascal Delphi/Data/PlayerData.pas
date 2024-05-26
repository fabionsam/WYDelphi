unit PlayerData;

interface

uses MiscData, Types, Generics.Collections, Position, PlayerDataClasses,
  ConstDefs;

type TCity = (Armia, Azram, Erion, Karden);
type TCitizenship = (None = -1, Server1, Server2, Server3);
type TClassLevel = (Mortal, Arch, Celestial, SubCelestial, Hardcore);
type TPlayerStatus = (WaitingLogin, WaitingAccount, AccNotFound, CharList, Senha2, Waiting, Playing);

type TInitItem = Record
  Item : TItem;
  ClientId : WORD;
  TimeDrop : TDateTime;
  Pos : TPosition;
End;

type TStatus = Record
//  private
//    function GetMerchDir(const Index: Integer): Byte;
//    procedure SetMerchDir(const Index: Integer; const Value: Byte);
//    function GetMoveChaos(const Index: Integer): Byte;
//    procedure SetMoveChaos(const Index: Integer; const Value: Byte);

  public
    Level: Integer;
    Defense: Integer;
    Attack: Integer;
    (*
    struct
    {
      BYTE Merchant : 4;
      BYTE Direction : 4;
    } Merchant;
    *)
//    _MerchDir: BYTE;
    Merchant : Byte;
    MoveSpeed : Byte;
    Direction : Byte;
    (*
    struct
    {
      BYTE Speed : 4;
      BYTE ChaosRate : 4;
    } Move;
    *)
//    _MoveChaos: BYTE;

    ChaosRate : Byte;

    MaxHP, MaxMP: Integer;
    CurHP, CurMP: Integer;

    Str,Int: WORD;
    Dex,Con: WORD;

    wMaster: Word;
    fMaster: Word;
    sMaster: Word;
    tMaster: Word;

//    property Merchant : Byte index $0004 read GetMerchDir write SetMerchDir;
//    property Direction : Byte index $0404 read GetMerchDir write SetMerchDir;
//
//    property MoveSpeed : Byte index $0004 read GetMoveChaos write SetMoveChaos;
//    property ChaosRate : Byte index $0404 read GetMoveChaos write SetMoveChaos;

    class operator Implicit(status: TStatusClass): TStatus;
end;

type TCharacterListData = Record
  PosX: Smallint;
  PosY: Smallint;
  Name:Array[0..15]of AnsiChar;

  Status: TStatus;
  Equip: array[0..MAX_EQUIPS-1] of TItem;

  GuildIndex: Word;

  Gold: Integer;
  Exp: Integer;
end;

type TAffect = Record
	Index: BYTE;
	Master: BYTE;
	Value: WORD;
	Time: Cardinal;

  class operator Implicit(affect: TAffectClass): TAffect;
end;

type TAffectInfo = record
  private
    function GetBits(const Index: Integer): Byte;
    procedure SetBits(const Index: Integer; const Value: Byte);
  (*
  struct
  {
      BYTE SlowMov : 1;
      BYTE DrainHP : 1;
      BYTE VisionDrop : 1;
      BYTE Evasion : 1;
      BYTE Snoop : 1;
      BYTE SpeedMov : 1;
      BYTE SkillDelay : 1;
      BYTE Resist : 1;
  } AffectInfo;
  *)
  public
    _Info: Byte;

    property SlowMov : Byte index $0001 read GetBits write SetBits;
    property DrainHP : Byte index $0101 read GetBits write SetBits;
    property VisionDrop : Byte index $0201 read GetBits write SetBits;
    property Evasion : Byte index $0301 read GetBits write SetBits;
    property Snoop : Byte index $0401 read GetBits write SetBits;
    property SpeedMov : Byte index $0501 read GetBits write SetBits;
    property SkillDelay : Byte index $0601 read GetBits write SetBits;
    property Resist : Byte index $0701 read GetBits write SetBits;

    class operator Implicit(affect: TAffectInfoClass): TAffectInfo;
end;

type PCharacter = ^TCharacter;
TCharacter = packed Record
  public
    Name: array[0..15] of AnsiChar;
    CapeInfo: BYTE; // Race
    Merchant: BYTE;

    GuildIndex: WORD;
    ClassInfo: BYTE;

    AffectInfo: TAffectInfo;
    QuestInfo: WORD;

    Gold: Int64;
    Exp: Int64;

    Last: TPosition;
    BaseScore: TStatus;
    CurrentScore: TStatus;

    Equip: array[0..MAX_EQUIPS-1] of TItem;
    Inventory: array[0..MAX_INV-1] of TItem;

    Learn: uInt64; //verified
    pStatus: WORD; //verified    pMaster: WORD; //verified    pSkill: WORD; //verified    Critical: Byte;    SaveMana: Byte;    SkillBar1: array[0..3] of Byte; //verified    unkk: array[0..3] of Byte;    Resist: array[0..3] of Byte; //verified//    ResistFire: ShortInt; //verified//    ResistIce: ShortInt; //verified//    ResistHoly: ShortInt; //verified//    ResistThunder: ShortInt; //verified
    unk3: array[0..209] of Byte;

    MagicIncrement: WORD;

    unk5: array[0..3] of Byte;

    SlotIndex: WORD;
    ClientId: WORD; //verified
    CityId: Smallint;

    SkillBar2: array[0..15] of Byte; //verified

    unk: WORD;

    ChaosPoint: Integer; //verified

    //all the props below are not working
    Tab: array [0..25] of AnsiChar;

    unk6: array[0..1] of Byte;

    Affects: array[0..MAXBUFFS - 1] of TAffect;

    ClassMaster: integer;
    RegenHp: WORD;
    RegenMp: WORD;
    GuildMemberType: WORD;
    Evasion        : WORD;

    function ClassLevel: TClassLevel;
    function HaveSkill(SkillId: Byte): Boolean;
    class operator Implicit(character: TCharacterClass): TCharacter;
end;

type TAccountHeader = Record
  AccountId: String[50];
  Username: String[15];
  Password: String[11];
  IsActive: Boolean;
  StorageGold: Integer;
  StorageItens: array[0..MAX_CARGO-1] of TItem;
  NumericToken: String[5];
  //CharacterIndexes: array[0..3] of Integer;

  class operator Implicit(header: TAccountHeaderClass): TAccountHeader;
end;

type PParty = ^TParty;
TParty = Record
  Leader: WORD;
  Members: TList<WORD>;
  RequestId: WORD;

  function AddMember(memberClientId: WORD): Boolean;
End;

type TTradeStore = Record
  Name: string[23];
  Item: array[0..11] of TItem;
  Slot: array[0..11] of BYTE;
  Gold: array[0..11] of integer;
  Unknown, Index: smallint;
end;

type TTrade = Record
	IsTrading: boolean;
  Confirm: boolean;
	Waiting: boolean;

	Gold: integer;

	Timer: TDateTime;

	OtherClientid: WORD;

	Itens: array[0..14] of TItem;
	TradeItemSlot: array[0..14] of shortint;
end;

type TCharacterQuests = Record
  MolarDoGargula,
  PilulaMagica,
  ArchDesbloq355,
  ArchDesbloq370 : Boolean;
  CristaisArch : array[0..3] of boolean;

  class operator Implicit(quest: TCharacterQuestsClass): TCharacterQuests;
End;

type TCharacterDB = record
  Index : Integer;  // Id único do personagem
  Base : TCharacter;
  LastAction: TTime;
  PlayerKill: Boolean;
  CurrentKill: BYTE;
  TotalKill: WORD;
  CP: integer;
  Fame: WORD;
  CurrentCity: TCity;
  GemaEstelar : TPosition;
  CharacterQuests : TCharacterQuests;
  Citizenship: TCitizenship;
end;

type TPlayerCharacter = record
  Index : Integer;  // Id único do personagem
  //////////////////////////////

  Base : TCharacter;

  //////////////////////////////
  LastAction: TTime;
  PlayerKill: Boolean;
  CurrentKill: BYTE;
  TotalKill: WORD;
  CP: integer;
  Fame: WORD;
  CurrentCity: TCity;
  GemaEstelar : TPosition;
  CharacterQuests : TCharacterQuests;
  Citizenship: TCitizenship;
  //TCharacterDB

  CurrentQuest: Int8;
  QuestEntraceTime: TDateTime;
  TradeStore: TTradeStore;
  IsStoreOpened : Boolean;
  Trade: TTrade;
  Absorcao: Integer;
  AttackSpeed: WORD;
  Mobbaby: WORD;
  Evasion : BYTE;
end;

type TWeather = Record
  Condition : TWeatherCondition;
  Time : TDateTime;
  Next : TDateTime;
End;


type TAccountFile = Record
  Header: TAccountHeader;
  Characters: array[0..3] of TCharacterDB;

  class operator Implicit(acc: TAccountFileClass): TAccountFile;
end;

type TCharacterFile = Record
  Name: String[15];
end;

type TItemEffect = Record
  Index: Smallint;
  Value: Smallint;
end;

type PNpcGenerator = ^TNpcGenerator;
TNpcGenerator = record
  MinuteGenerate : smallint;
  LeaderName : string[15];
  FollowerName : string[15];
  LeaderCount : BYTE;
  FollowerCount : BYTE;
  RouteType : BYTE;
  SpawnPosition : TPosition;
  SpawnWait : shortint;
  SpawnSay : string[95];
  Destination : TPosition;
  DestSay: string[95];
  DestWait : shortint;
  ReviveTime: Cardinal;
  AttackDelay: Cardinal;
End;

const MAX_MOB_BABY = 38;

const MobBabyNames: array[0..MAX_MOB_BABY - 1] of string =
('Condor', 'Javali', 'Lobo', 'Urso', 'Tigre',
'Gorila', 'Dragao_Negro', 'Succubus', 'Porco',
'Javali_', 'Lobo_', 'Dragao_Menor', 'Urso_',
'Dente_de_Sabre', 'Sem_Sela', 'Fantasma', 'Leve',
'Equipado', 'Andaluz', 'Sem_Sela_', 'Fantasma_',
'Leve_', 'Equipado_', 'Andaluz_', 'Fenrir', 'Dragao',
'Grande_Fenrir', 'Tigre_de_Fogo', 'Dragao_Vermelho',
'Unicornio', 'Pegasus', 'Unisus', 'Grifo', 'Hippo_Grifo',
'Grifo_Sangrento', 'Svadilfari', 'Sleipnir', '');

const exp_Mortal_Arch: array[0..399] of Cardinal = (
500,
1124,
1826,
2610,
3480,
4440,
5494,
6646,
7900,
9260,
10893,
12817,
15050,
17610,
20515,
23783,
27432,
31480,
35945,
40845,
46251,
52187,
58677,
65745,
73415,
81711,
90657,
100277,
110595,
121635,
133647,
146671,
160747,
175915,
192215,
209687,
228371,
248307,
269535,
292095,
316151,
341751,
368943,
397775,
428295,
460551,
494591,
530463,
568215,
607895,
649715,
693731,
739999,
788575,
839515,
892875,
948711,
1007079,
1068035,
1131635,
1198670,
1269230,
1343405,
1421285,
1502960,
1588520,
1678055,
1771655,
1869410,
1971410,
2078255,
2190055,
2306920,
2428960,
2556285,
2689005,
2827230,
2971070,
3120635,
3276035,
3438521,
3608249,
3785375,
3970055,
4162445,
4362701,
4570979,
4787435,
5012225,
5245505,
5488163,
5740379,
6002333,
6274205,
6556175,
6848423,
7151129,
7464473,
7788635,
8123795,
8460174,
8797774,
9136597,
9476645,
9817920,
10160424,
10504159,
10849127,
11195330,
11542770,
11892311,
12243959,
12597720,
12953600,
13311605,
13671741,
14034014,
14398430,
14764995,
15133715,
15508850,
15890450,
16278565,
16673245,
17074540,
17482500,
17897175,
18318615,
18746870,
19181990,
19625811,
20078403,
20539836,
21010180,
21489505,
21977881,
22475378,
22982066,
23498015,
24023295,
24559110,
25105558,
25662737,
26230745,
26809680,
27399640,
28000723,
28613027,
29236650,
29871690,
30517485,
31174125,
31841700,
32520300,
33210015,
33910935,
34623150,
35346750,
36081825,
36828465,
37587867,
38360139,
39145389,
39943725,
40755255,
41580087,
42418329,
43270089,
44135475,
45014595,
45904870,
46806370,
47719165,
48643325,
49578920,
50526020,
51484695,
52455015,
53437050,
54430870,
55439542,
56463162,
57501826,
58555630,
59624670,
60709042,
61808842,
62924166,
64055110,
65201770,
66366010,
67547930,
68747630,
69965210,
71200770,
72454410,
73726230,
75016330,
76324810,
77651770,
78985354,
80325578,
81672458,
83026010,
84386250,
85753194,
87126858,
88507258,
89894410,
91288330,
92693002,
94108458,
95534730,
96971850,
98419850,
99878762,
101348618,
102829450,
104321290,
105824170,
107352234,
108905674,
110484682,
112089450,
113720170,
115377034,
117060234,
118769962,
120506410,
122269770,
124065890,
125895058,
127757562,
129653690,
131583730,
133547970,
135546698,
137580202,
139648770,
141752690,
143928178,
146176386,
148498466,
150895570,
153368850,
155919458,
158548546,
161257266,
164046770,
166918210,
169956978,
173167682,
176554930,
180123330,
205345890,
209100050,
212902550,
216753470,
220652890,
224600890,
228597550,
232642950,
236737170,
240880290,
245072390,
249313550,
253603850,
257943370,
262332190,
266770390,
271258050,
275795250,
280382070,
285018590,
289904810,
295042730,
300434350,
306081670,
311986690,
318151410,
324577830,
331267950,
338223770,
345447290,
354039310,
364049830,
375528850,
388526370,
403092390,
419276910,
437129930,
456701450,
476272970,
495844490,
515416010,
534987530,
554559050,
574130570,
593702090,
613273610,
632845130,
652416650,
671988170,
691559690,
711131210,
730702730,
750274250,
769845770,
789417290,
808988810,
828560330,
848131850,
867703370,
887274890,
906846410,
926417930,
945989450,
965560970,
985132490,
1004704010,
1024275530,
1043847050,
1063418570,
1082990090,
1102561610,
1122133130,
1141704650,
1161276170,
1180847690,
1200419210,
1222705731,
1244995262,
1267288477,
1289622601,
1311966887,
1334333102,
1356724650,
1379151914,
1401651370,
1424151231,
1448674779,
1473220997,
1497782544,
1522364697,
1546957043,
1571581919,
1596243411,
1620925875,
1645647464,
1670373305,
1754612555,
1864552110,
1985221455,
2000000000,
2039000000,
2078000000,
2117000000,
2156000000,
2195000000,
2234000000,
2273000000,
2312000000,
2351000000,
2390000000,
2429000000,
2468000000,
2507000000,
2546000000,
2585000000,
2624000000,
2663000000,
2702000000,
2741000000,
2780000000,
2819000000,
2858000000,
2897000000,
2936000000,
3000000000,
3043000000,
3086000000,
3129000000,
3172000000,
3215000000,
3250000000,
3301000000,
3344000000,
3387000000,
3430000000,
3473000000,
3516000000,
3559000000,
3602000000,
3645000000,
3688000000,
3731000000,
3774000000,
3817000000,
4000000000,
4100000000);

const exp_list_celestial: array[0..198] of Cardinal = (
20000000,
40000000,
60000000,
80000000,
100000000,
120000000,
140000000,
160000000,
180000000,
200000000,
220000000,
240000000,
260000000,
280000000,
300000000,
320000000,
340000000,
360000000,
380000000,
400000000,
420000000,
440000000,
460000000,
480000000,
500000000,
520000000,
540000000,
560000000,
580000000,
600000000,
620000000,
640000000,
660000000,
680000000,
700000000,
720000000,
740000000,
760000000,
780000000,
800000000,
820000000,
840000000,
860000000,
880000000,
900000000,
920000000,
940000000,
960000000,
980000000,
1000000000,
1020000000,
1040000000,
1060000000,
1080000000,
1100000000,
1120000000,
1140000000,
1160000000,
1180000000,
1200000000,
1220000000,
1240000000,
1260000000,
1280000000,
1300000000,
1320000000,
1340000000,
1360000000,
1380000000,
1400000000,
1420000000,
1440000000,
1460000000,
1480000000,
1500000000,
1520000000,
1540000000,
1560000000,
1580000000,
1600000000,
1620000000,
1640000000,
1660000000,
1680000000,
1700000000,
1720000000,
1740000000,
1760000000,
1780000000,
1800000000,
1820000000,
1840000000,
1860000000,
1880000000,
1900000000,
1920000000,
1940000000,
1960000000,
1980000000,
2000000000,
2020000000,
2040000000,
2060000000,
2080000000,
2100000000,
2120000000,
2140000000,
2160000000,
2180000000,
2200000000,
2220000000,
2240000000,
2260000000,
2280000000,
2300000000,
2320000000,
2340000000,
2360000000,
2380000000,
2400000000,
2420000000,
2440000000,
2460000000,
2480000000,
2500000000,
2520000000,
2540000000,
2560000000,
2580000000,
2600000000,
2620000000,
2640000000,
2660000000,
2680000000,
2700000000,
2720000000,
2740000000,
2760000000,
2780000000,
2800000000,
2820000000,
2840000000,
2860000000,
2880000000,
2900000000,
2920000000,
2940000000,
2960000000,
2980000000,
3000000000,
3020000000,
3040000000,
3060000000,
3080000000,
3100000000,
3120000000,
3140000000,
3160000000,
3180000000,
3200000000,
3220000000,
3240000000,
3260000000,
3280000000,
3300000000,
3320000000,
3340000000,
3360000000,
3380000000,
3400000000,
3420000000,
3440000000,
3460000000,
3480000000,
3500000000,
3520000000,
3540000000,
3560000000,
3580000000,
3600000000,
3620000000,
3640000000,
3660000000,
3680000000,
3700000000,
3720000000,
3740000000,
3760000000,
3780000000,
3800000000,
3820000000,
3840000000,
3860000000,
3880000000,
3900000000,
3920000000,
3940000000,
3960000000,
4100000000);

implementation

uses Util, System.SysUtils, Winapi.Windows;

{ TCharacter }
function TCharacter.ClassLevel: TClassLevel;
begin
  if(Equip[0].Index = 1) OR (Equip[0].Index = 11) OR (Equip[0].Index = 21) OR (Equip[0].Index = 31) then
  begin
    Result := TClassLevel.Mortal;
    exit;
  end;
  Result := TClassLevel(Equip[0].Effects[1].Value);
end;

//function TCharacter.GetBits(const Index: Integer): Byte;
//begin
//  Result := Util.GetBits(_MerchCity, Index);
//end;

function TCharacter.HaveSkill(SkillId: Byte): Boolean;
var skillID2, aux: integer;
begin
  skillID2 := SkillId mod 24;
  aux := (Learn and (1 shl skillID2));
  Result := aux <> 0;
end;

class operator TCharacter.Implicit(character: TCharacterClass): TCharacter;
var
  i : BYTE;
begin
  ZeroMemory(@Result, Sizeof(TCharacter));
  StrPLCopy(Result.Name, character.Name, 16);
  Result.CapeInfo := character.CapeInfo;
  Result.Merchant := character.Merch;
  Result.CityId := character.City;
  Result.GuildIndex := character.GuildIndex;
  Result.ClassInfo := character.ClassInfo;
  Result.QuestInfo := character.QuestInfo;
  Result.Gold := character.Gold;
  Result.Exp := character.Exp;
  Result.Last := TPosition.Create(character.Last.X, character.Last.Y);
  Result.AffectInfo := character.AffectInfo;
  Result.BaseScore := character.BaseScore;

  for I := 0 to MAX_EQUIPS-1 do
    Result.Equip[i] := character.Equip[i];
  for I := 0 to MAX_INV-1 do
    Result.Inventory[i] := character.Inventory[i];

  Result.Learn := character.Learn;
  Result.pStatus := character.pStatus;
  Result.pMaster := character.pMaster;
  Result.pSkill := character.pSkill;
  Result.Critical := character.Critical;
  Result.SaveMana := character.SaveMana;

  for I := 0 to 3 do
    Result.SkillBar1[i] := character.SkillBar1[i];

  for I := 0 to 3 do
    Result.Resist[i] := character.Resist[i];

  Result.GuildMemberType := character.GuildMemberType;
  Result.MagicIncrement := character.MagicIncrement;
  Result.RegenHP := character.RegenHP;
  Result.RegenMP := character.RegenMP;

  for I := 0 to 15 do
    Result.SkillBar2[i] := character.SkillBar2[i];

  Result.Evasion := character.Evasion;
  Result.ChaosPoint := character.Hold;
  Result.ClassMaster := character.ClasseMaster;

  for I := 0 to MAXBUFFS - 1 do
    Result.Affects[i] := character.Affects[i];
end;

//procedure TCharacter.SetBits(const Index: Integer; const Value: Byte);
//begin
//  SetByteBits(_MerchCity, Index, Value);
//end;

{ TStatus }
//function TStatus.GetMerchDir(const Index: Integer): Byte;
//begin
//  Result := GetBits(_MerchDir, Index);
//end;
//
//procedure TStatus.SetMerchDir(const Index: Integer; const Value: Byte);
//begin
//  SetByteBits(_MerchDir, Index, Value);
//end;
//
//function TStatus.GetMoveChaos(const Index: Integer): Byte;
//begin
//  Result := Util.GetBits(_MoveChaos, Index);
//end;

class operator TStatus.Implicit(status: TStatusClass): TStatus;
begin
  ZeroMemory(@Result, Sizeof(TStatus));
  Result.Level := status.Level;
  Result.Defense := status.Defense;
  Result.Attack := status.Attack;
  Result.Merchant := status.Merch;
  Result.Direction := status.Direction;
  Result.MoveSpeed := status.Move;
  Result.ChaosRate := status.Chaos;
  Result.MaxHP := status.MaxHP;
  Result.MaxMP := status.MaxMP;
  Result.CurHP := status.CurHP;
  Result.CurMP := status.CurMP;
  Result.Str := status.Str;
  Result.Int := status.Int;
  Result.Dex := status.Dex;
  Result.Con := status.Con;
  Result.wMaster := status.wMaster;
  Result.fMaster := status.fMaster;
  Result.sMaster := status.sMaster;
  Result.tMaster := status.tMaster;
end;

//procedure TStatus.SetMoveChaos(const Index: Integer; const Value: Byte);
//begin
//  SetByteBits(_MoveChaos, Index, Value);
//end;

{ TAffectInfo }
function TAffectInfo.GetBits(const Index: Integer): Byte;
begin
  Result := Util.GetBits(_Info, Index);
end;

class operator TAffectInfo.Implicit(affect: TAffectInfoClass): TAffectInfo;
begin
  ZeroMemory(@Result, Sizeof(TAffectInfo));
  affect.SlowMov := affect.SlowMov;
  affect.DrainHP := affect.DrainHP;
  affect.VisionDrop := affect.VisionDrop;
  affect.Evasion := affect.Evasion;
  affect.Snoop := affect.Snoop;
  affect.SpeedMov := affect.SpeedMov;
  affect.SkillDelay := affect.SkillDelay;
  affect.Resist := affect.Resist;
end;

procedure TAffectInfo.SetBits(const Index: Integer; const Value: Byte);
begin
  SetByteBits(_Info, Index, Value);
end;

{ TParty }

function TParty.AddMember(memberClientId: WORD): Boolean;
begin
  if not Assigned(Members) then
    self.Members := TList<WORD>.Create;

  if (Members.Count = 15) then
  begin
    result := false;
    exit;
  end;

  Members.Add(memberClientId);
  result := true;
end;

{ TCharacterQuests }

class operator TCharacterQuests.Implicit(quest: TCharacterQuestsClass): TCharacterQuests;
var
  i : BYTE;
begin
  ZeroMemory(@Result, Sizeof(TCharacterQuests));
  Result.MolarDoGargula := quest.MolarDoGargula;
  Result.PilulaMagica := quest.PilulaMagica;
  Result.ArchDesbloq355 := quest.ArchDesbloq355;
  Result.ArchDesbloq370 := quest.ArchDesbloq370;

  for I := 0 to 3 do
    Result.CristaisArch[i] := quest.CristaisArch[i];
end;

{ TAffect }

class operator TAffect.Implicit(affect: TAffectClass): TAffect;
begin
  ZeroMemory(@Result, Sizeof(TAffect));
  Result.Index := affect.Index;
  Result.Master := affect.Master;
  Result.Value := affect.Value;
  Result.Time := affect.Time;
end;

{ TAccountFile }

class operator TAccountFile.Implicit(acc: TAccountFileClass): TAccountFile;
var
  i : BYTE;
begin
  ZeroMemory(@Result, Sizeof(TAccountFile));
  Result.Header := acc.Header;

  for i := 0 to 3 do
  begin
    Result.Characters[i].Index := i;
    Result.Characters[i].Base := acc.Characters[i].Base;
    Result.Characters[i].Base.SlotIndex := i;
    Result.Characters[i].LastAction := acc.Characters[i].LastAction;
    Result.Characters[i].PlayerKill := acc.Characters[i].PlayerKill;
    Result.Characters[i].CurrentKill := acc.Characters[i].CurrentKill;
    Result.Characters[i].TotalKill := acc.Characters[i].TotalKill;
    Result.Characters[i].CP := acc.Characters[i].CP;
    Result.Characters[i].Fame := acc.Characters[i].Fame;
    Result.Characters[i].CurrentCity := TCity(acc.Characters[i].CurrentCity);
    Result.Characters[i].GemaEstelar := TPosition.Create(acc.Characters[i].GemaEstelar.X, acc.Characters[i].GemaEstelar.Y);
    Result.Characters[i].CharacterQuests := acc.Characters[i].CharacterQuests;
    Result.Characters[i].Citizenship := TCitizenship(acc.Characters[i].Citizenship);
  end;
end;

{ TAccountHeader }

class operator TAccountHeader.Implicit(header: TAccountHeaderClass): TAccountHeader;
var
  i : BYTE;
begin
  ZeroMemory(@Result, Sizeof(TAccountHeader));
  Result.Username := Header.Username;
  Result.Password := Header.Password;
  Result.IsActive := True;
  Result.StorageGold := Header.StorageGold;
  for i := 0 to MAX_CARGO-1 do
    Result.StorageItens[i] := Header.StorageItens[i];
  Result.NumericToken := Header.NumericToken;
end;

end.
