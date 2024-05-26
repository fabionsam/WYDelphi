unit GlobalDefs;

interface

uses System.Threading, Generics.Collections, Position,
    PlayerData, MiscData, Load, Functions, NPC, NpcFunctions, ItemFunctions,
    ServerSocket, Player, Packets, Log, Util, MobGenerData, BaseMob,
  DbServerConnection, ConstDefs;

var
  CurrentServer: TCitizenship = TCitizenship.Server1;

  Neighbors: array[0..7] of TPosition;

  CurrentDir: string;
  MobGrid, ItemGrid: array[0..4096] of array[0..4096] of WORD;
  g_pItemGrid : array[0..7] of array[0..7] of BYTE = (
    ( 01, 00, 00, 00, 00, 00, 00, 00 ), ( 01, 00, 01, 00, 00, 00, 00, 00 ),
    ( 01, 00, 01, 00, 01, 00, 00, 00 ), ( 01, 00, 01, 00, 01, 00, 01, 00 ),
    ( 01, 01, 00, 00, 00, 00, 00, 00 ), ( 01, 01, 01, 01, 00, 00, 00, 00 ),
    ( 01, 01, 01, 01, 01, 01, 00, 00 ), ( 01, 01, 01, 01, 01, 01, 01, 01 )
    );
  TimeTick: Cardinal;
  CityWeather: array[0..3] of TWeather;
  NpcFuncs: TNpcFunctions;
  ItemFuncs: TItemFunctions;
  ConfiguracoesGameServer : TConfiguracoes;
  ConfiguracoesDbServer : TConfiguracoes;

  Logger : TLog;
  Server : TServerSocket;
  DbClient : TDbServerConnection;
  HeightGrid : THeightMap;
  ItemList : TDictionary<integer, TItemList>;
  MobGener : TDictionary<integer, TMobGenerData>;
  TeleportsList : TList<TTeleport>;
  SkillsData : TList<TSkillData>;
  MobBabyList : TList<TCharacter>;
  GemaEstelar : TList<TGemaEstelar>;
  Replations : TDictionary<BYTE, TList<WORD>>;

  //InstantiatedPlayers : Integer;
  //Players : array[1..750] of TPlayer;

  //NPCs : array[1001..30000] of TNpc;
  //InstantiatedNPCs: WORD;

  InitialCharacters: array[0..3] of TCharacter;
  Parties : array[1..750] of TParty;
  Quests: TList<TQuest>;
  Guilds: TDictionary<integer, TGuildData>;
  PlayersNick: TDictionary<string, word>;
  LastGuildId: WORD;
  InitItems : array[1..MAX_INITITEM_LIST] of TInitItem;

implementation

end.
