unit MiscData;

interface

uses SysUtils, Generics.Collections, Types, Position, PlayerDataClasses;


type TWeatherCondition = (Normal, Rain, Snow, HeavySnow);

type TEquipSlot =
(
  Face=0,
  Helmet=1,
  Chest=2,
  Pants=3,
  Gloves=4,
  Boots=5,
  LWeapon=6,
  RWeapon=7,
  Earring=8,
  SilverAmulet=9,
  Orb=10,
  Amulet=11,
  Guild=12,
  Fairy=13,
  Mount=14,
  Cape=15,
  Colar=16,
  Anel=17
);

type TMountAdd =
(
  AddHp = 0,
  CurHp = 1,
  Level = 2,
  Vitalidade = 3,
  Racao = 4,
  Exp = 5
);

type TWeaponUnique =
(
  One_Handed_Axe = 41,
  Bow = 42,
  Claw = 43,
  Two_Handed_Lance = 44,
  One_Handed_Sword = 45,
  Dart = 46,
  Two_Handed_Staff = 47,
  Two_Handed_Sword = 48,
  Two_Handed_Axe = 49,
  Shield = 51
);

type TDirection = (Forward, Backward, Rigth, Left);

type TItemAmount = Record
  ItemId: Integer;
  Slots: array[0..127] of BYTE;
  Amount: WORD;
  SlotsCount: BYTE;
End;

type TRect = record
  BottomLeft, TopRigth: TPosition;
end;

type TQuest = class
  Index: Integer;
  Name: string;
  ItemId: Integer;
  ResetTime: Int8;
  QuestPosition: TPosition;
  QuestArea: TRect;
  LevelMin,
  LevelMax : WORD;

  Players: TList<WORD>;

  procedure ClearQuest;
end;

type TTeleport = Record
  Scr1, Scr2, Dest1, Dest2 : TPosition;
  Price, Time: Integer;
End;

type TConfiguracoes = Record
  Porta : Integer;
  Ip : String;
End;

type TItemEffect = Record
  Index, Value : BYTE;
End;

type PItem = ^TItem;
TItem = packed record
  Index: Word;
  Effects : array[0..2] of TItemEffect;

  class operator Implicit(item: TItemClass): TItem;
end;

type THeightMap = Record
  p: array[0..4095] of array[0..4095] of BYTE;
End;

type TTradeStore = Record
  Name: array[0..23] of AnsiChar;
  Item: array[0..11] of TItem;

  Slot: array[0..11] of BYTE;

  Gold: array[0..11] of integer;

  Tax,
  index: smallint;
end;

type TPacketAffect = Record
  Time, Index : Byte;
End;

type TGemaEstelar = Record
  Local : array[0..1] of TPosition;
End;

type TSkillData = Record
  Index : smallint;
  SkillPoint, TargetType, AffectTime : integer;
  ManaSpent : WORD;
  Delay: WORD;
  Range : string;
  InstanceType : Word;
  InstanceValue, TickType, TickValue,
  AffectType, AffectValue, Act123, Act123_2,
  InstanceAttribute, TickAttribute, Aggressive,
  Maxtarget, PartyCheck, AffectResist, PassiveCheck, Name : String;
End;

type TAISegment = Record
  Position: TPosition;
  Say: string[80];
  WaitTime: WORD; // Em segundos
  Range : BYTE;
End;
{
type PMOBGener = ^TMOBGener;
TMOBGener = Record
  Id,
	Mode, // 0 - 3
	MinuteGenerate,// 4 - 7

	MaxNumMob, // 8 - 11

	MobCount, // 12 - 15

	MinGroup, // 16 - 19
	MaxGroup: integer;// 20 - 23

  SpawnSegment: TAISegment;     // Só vai ser usado pra definir o Spawn
  Segments : TList<TAISegment>;
//  Destination: TAISegment;

	FightAction, // 504 - 823
	FleeAction, // 824 - 1143
	DieAction: array[0..3] of string[79]; // 1144 - 1463

  Follower,
  Leader: string;

	Formation, // 1464 - 1467
	RouteType: integer; // 1468 - 1471

  procedure AddSegmentData(segmentId: Byte); overload;
  procedure AddSegmentData(segmentId : Byte; x, y: Integer); overload;
  procedure AddSegmentData(segmentId : Byte; waitTime: Integer); overload;
  procedure AddSegmentData(segmentId : Byte; say: string); overload;
end;
}
type TItemListOld = Record
  Index : smallint;
  Name: String[63];

  Mesh: Smallint;
  Submesh: Smallint;

  unknow: Smallint;

  Level: Smallint;
  STR: Smallint;
  INT: Smallint;
  DEX: Smallint;
  CON: Smallint;

  Effects: array[0..11] of TItemEffect;

  Price: Integer;
  Unique: Smallint;
  Pos: Word;

  Extreme: Smallint;
  Grade: Smallint;
end;

type TEffectsBinary = Record
    index: Smallint;
    value: Smallint;
end;

type TItemList = Record
    Name: array[0..63] of AnsiChar;

    Mesh: Smallint;
	  Submesh: Smallint;

	  unknow: Smallint;

    Level: Smallint;
    STR: Smallint;
    INT: Smallint;
    DEX: Smallint;
    CON: Smallint;

    Effects: array[0..11] of TEffectsBinary;

    Price: Integer;
    Unique: Smallint;
    Pos: Word;

    Extreme: Smallint;
    Grade: Smallint;
end;

type TGuildData = class
  ID : WORD;
  Alianca : WORD;
  Nome: string;
end;

implementation

{ TQuest }
procedure TQuest.ClearQuest;
begin
//  TFunctions.ClearArea(QuestArea.BottomLeft, QuestArea.TopRigth);
  self.Players.Clear;
end;

{ TMOBGener }
{
procedure TMOBGener.AddSegmentData(segmentId: Byte; x, y: Integer);
var segment: TAISegment;
begin
  AddSegmentData(segmentId);
  Dec(segmentId);

  segment := Segments[segmentId];
  if x <> -1 then
    segment.Position.X := x;
  if y <> -1 then
    segment.Position.Y := y;

  Segments[segmentId] := segment;
end;

procedure TMOBGener.AddSegmentData(segmentId: Byte; waitTime: Integer);
var segment: TAISegment;
begin
  AddSegmentData(segmentId);
  Dec(segmentId);

  segment := Segments[segmentId];
  segment.WaitTime := waitTime;
  Segments[segmentId] := segment;
end;

procedure TMOBGener.AddSegmentData(segmentId: Byte; say: string);
var segment: TAISegment;
begin
  AddSegmentData(segmentId);
  Dec(segmentId);

  segment := Segments[segmentId];
  segment.Say := say;
  Segments[segmentId] := segment;
end;

procedure TMOBGener.AddSegmentData(segmentId: Byte);
var segment: TAISegment;
begin
  if Segments = NIL then
    Segments := TList<TAISegment>.Create;

  while segmentId > Segments.Count do
  begin
    Segments.Add(segment);
  end;
end;
}
{ TItem }

class operator TItem.Implicit(item: TItemClass): TItem;
var
  i : Byte;
begin
  result.Index := item.Index;
  for i := 0 to 2 do
  begin
    result.Effects[i].Index := item.Effects[i].Index;
    result.Effects[i].Value := item.Effects[i].Value;
  end;
end;

end.
