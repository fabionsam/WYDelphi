unit PlayerDataClasses;

interface

uses Types, Generics.Collections, Position, REST.Json, REST.Json.Types;

type TPositionClass = class
  public
    [JSONMarshalled(True)] [JSonName('X')]
    X: SmallInt;
    [JSONMarshalled(True)] [JSonName('Y')]
    Y: SmallInt;

    constructor Create(); overload;
    constructor Create(X, Y : SmallInt); overload;
    procedure SetPosition(X, Y : SmallInt);
end;

type TStatusClass = Class
  public
    [JSONMarshalled(True)] [JSonName('level')]
    Level: Integer;
    [JSONMarshalled(True)] [JSonName('defense')]
    Defense: Integer;
    [JSONMarshalled(True)] [JSonName('attack')]
    Attack: Integer;
    [JSONMarshalled(True)] [JSonName('merch')]
    Merch: BYTE;
    [JSONMarshalled(True)] [JSonName('direction')]
    Direction: BYTE;
    [JSONMarshalled(True)] [JSonName('move')]
    Move: BYTE;
    [JSONMarshalled(True)] [JSonName('chaos')]
    Chaos : BYTE;

    [JSONMarshalled(True)] [JSonName('maxHP')]
    MaxHP: Integer;
    [JSONMarshalled(True)] [JSonName('maxMP')]
    MaxMP: Integer;
    [JSONMarshalled(True)] [JSonName('curHP')]
    CurHP: Integer;
    [JSONMarshalled(True)] [JSonName('curMP')]
    CurMP: Integer;

    [JSONMarshalled(True)] [JSonName('str')]
    Str: WORD;
    [JSONMarshalled(True)] [JSonName('int')]
    Int: WORD;
    [JSONMarshalled(True)] [JSonName('dex')]
    Dex: WORD;
    [JSONMarshalled(True)] [JSonName('con')]
    Con: WORD;

    [JSONMarshalled(True)] [JSonName('wMaster')]
    wMaster: WORD;
    [JSONMarshalled(True)] [JSonName('fMaster')]
    fMaster: WORD;
    [JSONMarshalled(True)] [JSonName('sMaster')]
    sMaster: WORD;
    [JSONMarshalled(True)] [JSonName('tMaster')]
    tMaster: WORD;
end;

type TAffectClass = Class
  public
    [JSONMarshalled(True)] [JSonName('index')]
    Index: BYTE;
    [JSONMarshalled(True)] [JSonName('master')]
    Master: BYTE;
    [JSONMarshalled(True)] [JSonName('value')]
    Value: smallint;
    [JSONMarshalled(True)] [JSonName('time')]
    Time: integer;
end;

type TAffectInfoClass = Class
  public
    [JSONMarshalled(True)] [JSonName('slowMov')]
    SlowMov: Byte;
    [JSONMarshalled(True)] [JSonName('drainHP')]
    DrainHP: Byte;
    [JSONMarshalled(True)] [JSonName('visionDrop')]
    VisionDrop: Byte;
    [JSONMarshalled(True)] [JSonName('evasion')]
    Evasion: Byte;
    [JSONMarshalled(True)] [JSonName('snoop')]
    Snoop: Byte;
    [JSONMarshalled(True)] [JSonName('speedMov')]
    SpeedMov: Byte;
    [JSONMarshalled(True)] [JSonName('skillDelay')]
    SkillDelay: Byte;
    [JSONMarshalled(True)] [JSonName('resist')]
    Resist: Byte;
end;

type TItemEffectClass = Class
  public
    [JSONMarshalled(True)] [JSonName('index')]
    Index: BYTE;
    [JSONMarshalled(True)] [JSonName('value')]
    Value : BYTE;
End;

type TItemClass = class
  public
    [JSONMarshalled(True)] [JSonName('index')]
    Index: Word;
    [JSONMarshalled(True)] [JSonName('effects')]
    Effects : TArray<TItemEffectClass>;
    constructor Create();
end;

type TCharacterClass = Class
  public
    [JSONMarshalled(True)] [JSonName('name')]
    Name: String;
    [JSONMarshalled(True)] [JSonName('capeInfo')]
    CapeInfo: BYTE; // Race
    [JSONMarshalled(True)] [JSonName('merch')]
    Merch: BYTE;
    [JSONMarshalled(True)] [JSonName('city')]
    City : BYTE;

    [JSONMarshalled(True)] [JSonName('guildIndex')]
    GuildIndex: WORD;
    [JSONMarshalled(True)] [JSonName('classInfo')]
    ClassInfo: BYTE;

    [JSONMarshalled(True)] [JSonName('affectInfo')]
    AffectInfo: TAffectInfoClass;
    [JSONMarshalled(True)] [JSonName('questInfo')]
    QuestInfo: WORD;

    [JSONMarshalled(True)] [JSonName('gold')]
    Gold: Integer;
    [JSONMarshalled(True)] [JSonName('exp')]
    Exp: Int64;

    [JSONMarshalled(True)] [JSonName('last')]
    Last: TPositionClass;
    [JSONMarshalled(True)] [JSonName('baseScore')]
    BaseScore: TStatusClass;

    [JSONMarshalled(True)] [JSonName('equip')]
    Equip: TArray<TItemClass>;
    [JSONMarshalled(True)] [JSonName('inventory')]
    Inventory: TArray<TItemClass>;

    [JSONMarshalled(True)] [JSonName('learn')]
    Learn: LongWord;
    [JSONMarshalled(True)] [JSonName('pStatus')]
    pStatus: WORD;
    [JSONMarshalled(True)] [JSonName('pMaster')]
    pMaster: WORD;
    [JSONMarshalled(True)] [JSonName('pSkill')]
    pSkill: WORD;
    [JSONMarshalled(True)] [JSonName('critical')]
    Critical: ShortInt;
    [JSONMarshalled(True)] [JSonName('saveMana')]
    SaveMana: ShortInt;

    [JSONMarshalled(True)] [JSonName('skillBar1')]
    SkillBar1: TArray<ShortInt>;
    [JSONMarshalled(True)] [JSonName('guildMemberType')]
    GuildMemberType: shortint;

    [JSONMarshalled(True)] [JSonName('magicIncrement')]
    MagicIncrement: BYTE;
    [JSONMarshalled(True)] [JSonName('regenHP')]
    RegenHP: BYTE;
    [JSONMarshalled(True)] [JSonName('regenMP')]
    RegenMP: BYTE;

    [JSONMarshalled(True)] [JSonName('effects')]
    Resist: TArray<ShortInt>;

    [JSONMarshalled(True)] [JSonName('skillBar2')]
    SkillBar2: TArray<int8>;
    [JSONMarshalled(True)] [JSonName('evasion')]
    Evasion: Int16;
    [JSONMarshalled(True)] [JSonName('hold')]
    Hold: integer;

    [JSONMarshalled(True)] [JSonName('affects')]
    Affects: TArray<TAffectClass>;
    [JSONMarshalled(True)] [JSonName('classeMaster')]
    ClasseMaster: integer;
    constructor Create();
end;

type TAccountHeaderClass = Class
  public
    [JSONMarshalled(True)] [JSonName('username')]
    Username: String;
    [JSONMarshalled(True)] [JSonName('password')]
    Password: String;
    [JSONMarshalled(True)] [JSonName('isActive')]
    IsActive: Boolean;
    [JSONMarshalled(True)] [JSonName('serverIdActive')]
    ServerIdActive: Byte;
    [JSONMarshalled(True)] [JSonName('storageGold')]
    StorageGold: Integer;
    [JSONMarshalled(True)] [JSonName('storageItens')]
    StorageItens: TArray<TItemClass>;
    [JSONMarshalled(True)] [JSonName('numericToken')]
    NumericToken: String;
    constructor Create();
end;

type TCharacterQuestsClass = Class
  public
    [JSONMarshalled(True)] [JSonName('molarDoGargula')]
    MolarDoGargula: Boolean;
    [JSONMarshalled(True)] [JSonName('pilulaMagica')]
    PilulaMagica: Boolean;
    [JSONMarshalled(True)] [JSonName('archDesbloq355')]
    ArchDesbloq355 : Boolean;
    [JSONMarshalled(True)] [JSonName('archDesbloq370')]
    ArchDesbloq370 : Boolean;
    [JSONMarshalled(True)] [JSonName('cristaisArch')]
    CristaisArch : TArray<boolean>;

    constructor Create();
    procedure SetQuests(AMolarDoGargula, APilulaMagica, AArchDesbloq355, AArchDesbloq370 : Boolean;
                       ACristais: Array of boolean);
End;

type TCharacterDBClass = class
  public
    [JSONMarshalled(True)] [JSonName('base')]
    Base : TCharacterClass;
    [JSONMarshalled(True)] [JSonName('lastAction')]
    LastAction: TTime;
    [JSONMarshalled(True)] [JSonName('playerKill')]
    PlayerKill: Boolean;
    [JSONMarshalled(True)] [JSonName('currentKill')]
    CurrentKill: BYTE;
    [JSONMarshalled(True)] [JSonName('totalKill')]
    TotalKill: WORD;
    [JSONMarshalled(True)] [JSonName('cp')]
    CP: integer;
    [JSONMarshalled(True)] [JSonName('fame')]
    Fame: WORD;
    [JSONMarshalled(True)] [JSonName('currentCity')]
    CurrentCity: BYTE;
    [JSONMarshalled(True)] [JSonName('gemaEstelar')]
    GemaEstelar : TPositionClass;
    [JSONMarshalled(True)] [JSonName('characterQuests')]
    CharacterQuests : TCharacterQuestsClass;
    [JSONMarshalled(True)] [JSonName('citizenship')]
    Citizenship: Integer;
    constructor Create();
end;

type TAccountFileClass = Class
  public
    [JSONMarshalled(True)] [JSonName('header')]
    Header: TAccountHeaderClass;
    [JSONMarshalled(True)] [JSonName('characters')]
    Characters: TArray<TCharacterDBClass>;
    constructor Create();
end;

implementation

uses
  ConstDefs;

{ TAccountFileClass }

constructor TAccountFileClass.Create;
var
  i : BYTE;
begin
//  AccountId := TId.Create();
  Header := TAccountHeaderClass.Create();
  SetLength(Characters, 4);
  for I := 0 to 3 do
    Characters[i] := TCharacterDBClass.Create();
end;

{ TAccountHeaderClass }

constructor TAccountHeaderClass.Create;
var
  i : Byte;
begin
  SetLength(StorageItens, MAX_CARGO);
  for i := 0 to MAX_CARGO - 1 do
    StorageItens[i] := TItemClass.Create();
end;

{ TItemClass }

constructor TItemClass.Create;
var
  i : BYTE;
begin
  SetLength(Effects, 3);
  for i := 0 to 2 do
    Effects[i] := TItemEffectClass.Create();
end;

{ TCharacterDBClass }

constructor TCharacterDBClass.Create;
begin
  CharacterQuests := TCharacterQuestsClass.Create;
  Base := TCharacterClass.Create();
  GemaEstelar := TPositionClass.Create();
end;

{ TCharacterQuestsClass }

constructor TCharacterQuestsClass.Create;
var
  i : BYTE;
begin
  SetLength(CristaisArch, 4);
  for i := 0 to 3 do
    CristaisArch[i] := false;
end;

procedure TCharacterQuestsClass.SetQuests(AMolarDoGargula, APilulaMagica,
  AArchDesbloq355, AArchDesbloq370: Boolean; ACristais: Array of boolean);
var
  i : Byte;
begin
  self.MolarDoGargula := AMolarDoGargula;
  self.PilulaMagica := APilulaMagica;
  self.ArchDesbloq355 := AArchDesbloq355;
  self.ArchDesbloq370 := AArchDesbloq370;
  for I := 0 to 3 do
    self.CristaisArch[i] := ACristais[i];
end;

{ TCharacterClass }

constructor TCharacterClass.Create;
var
  i : BYTE;
begin
  AffectInfo := TAffectInfoClass.Create();
  BaseScore := TStatusClass.Create();
  Last := TPositionClass.Create();

  SetLength(Equip, MAX_EQUIPS);
  for I := 0 to MAX_EQUIPS - 1 do
    Equip[i] := TItemClass.Create();

  SetLength(Inventory, MAX_INV);
  for I := 0 to MAX_INV - 1 do
    Inventory[i] := TItemClass.Create();

  SetLength(SkillBar1, 4);
  for I := 0 to 3 do
    SkillBar1[i] := -1;

  SetLength(Resist, 4);
  for I := 0 to 3 do
    Resist[i] := 0;

  SetLength(SkillBar2, 16);
  for I := 0 to 15 do
    SkillBar2[i] := -1;

  SetLength(Affects, 32);
  for I := 0 to MAXBUFFS - 1 do
    Affects[i] := TAffectClass.Create();
end;

{ TPositionClass }

constructor TPositionClass.Create;
begin

end;

constructor TPositionClass.Create(X, Y: SmallInt);
begin
  self.X := X;
  self.Y := Y;
end;

procedure TPositionClass.SetPosition(X, Y: SmallInt);
begin
  self.X := X;
  self.Y := Y;
end;

end.
