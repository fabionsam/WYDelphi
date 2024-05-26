unit ConstDefs;

interface


const
  MAXBUFFS = 32;
  MAX_CONNECTIONS = 750;
  MAX_SPAWN_ID = 30000;
  MAX_INITITEM_LIST = 10000;
  MAX_CARGO = 120;
  MAX_EQUIPS = 16;
  MAX_INV = 64;
  MAX_ROUTE = 24;

  AI_DELAY_MOVIMENTO = 2000;

  MAX_CARRY = 8;
  MAX_INVEN	= 48;
  Taxes = 5;
  CARRYGRIDX = 9;
  CARRYGRIDY = 7;
  MAX_GRIDX = 4096;
  MAX_GRIDY = 4096;

  VIEWGRIDX	= 33;
  VIEWGRIDY	=	33;
  MOB_EMPTY = 0;  // There's no mob on the slot

  HEIGHTWIDTH = 4096;
  HEIGHTHEIGHT = 4096;
  HEIGHTPOSX = 0;
  HEIGHTPOSY = 0;
  MH = 8;

  EQUIP_TYPE    = 0;
  INV_TYPE      = 1;
  STORAGE_TYPE  = 2;

  DISTANCE_TO_WATCH = 33;
  DISTANCE_TO_FORGET = 34;

  WORLD_MOB = 0;
  WORLD_ITEM = 1;


  MOVE_NORMAL = 0;
  MOVE_TELEPORT = 1;
  MOVE_GENERATESUMON = 8; // Segundo o Guican

  DELETE_NORMAL = 0;      // Somente desaparece
  DELETE_DEAD = 1;        // Animacao da morte do spawn
  DELETE_DISCONNECT = 2;  // Efeito de quando o personagem sai do jogo
  DELETE_UNSPAWN = 3;     // Efeito quando os monstros ancts somem


  SPAWN_NORMAL = 1;   // Somente aparece
  SPAWN_LOGIN = 2;    // Efeito usado quando o personagem nasce
  SPAWN_TELEPORT = 3; // Efeito usado quando o personagem é teleportado
  SPAWN_BABYGEN = 4;  // Efeito de quando uma cria nasce

  //BUFS INDEX
  LENTIDAO              = 1;
  FM_VELOCIDADE         = 2;
  RESISTENCIA_N         = 3;
  EVASAO_N              = 5;
  POCAO_ATK             = 6;
  VELOCIDADE_N          = 7;
  ADD                   = 8;
  FM_BUFFATK            = 9;
  ATKMENOS              = 10;
  FM_ESCUDO_MAGICO      = 11;
  DEFESA_N              = 12;
  TK_ASSALTO            = 13;
  TK_POSSUIDO           = 14;
  FM_SKILLS             = 15;
  BM_MUTACAO            = 16;
  TK_AURAVIDA           = 17;
  FM_CONTROLE_MANA      = 18;
  HT_IMUNIDADE          = 19;
  VENENO                = 20;
  HT_MEDITACAO          = 21;
  FM_TROVAO             = 22;
  BM_AURA_BESTIAL       = 23;
  TK_SAMARITANO         = 24;
  BM_PROTELEMENT        = 25;
  HT_EVASAO_APRIMORADA  = 26;
  HT_GELO               = 27;
  HT_INIVISIBILIDADE    = 28;
  LIMITE_DA_ALMA        = 29;
  PvM                   = 30;
  HT_ESCUDO_DOURADO     = 31;
  CANCELAMENTO          = 32;
  MUTACAO2              = 33;
  COMIDA                = 34;
  BONUS_HP_MP           = 35;
  HT_VENENO             = 36;
  HT_LIGACAO_ESPCTRAL   = 37;
  HT_TROCAESP           = 38;
  BAU_EXP               = 39;

  //MUTAÇÂO MASTER
  LOBISOMEM              = 1;
  URSO                   = 2;
  ASTAROTH               = 3;
  TITAN                  = 4;
  EDEN                   = 5;

  // Effect Defines
    EF_NONE            =    0;
  // Status
  EF_LEVEL                 =    1;
  EF_DAMAGE             =  2;
  EF_AC                     =    3;
  EF_HP                     =    4;
  EF_MP                     =    5;
  EF_EXP                     =    6;
  EF_STR                     =    7;
  EF_INT                     =    8;
  EF_DEX                     =    9;
  EF_CON                     =    10;
  EF_SPECIAL1         =    11;
  EF_SPECIAL2         =  12;
  EF_SPECIAL3         =  13;
  EF_SPECIAL4         =    14;
  EF_SCORE14             =    15;
  EF_SCORE15             =    16;

  // Requeriment
  EF_POS                     =    17;
  EF_CLASS                 =    18;
  EF_R1SIDC             =    19;
  EF_R2SIDC             =    20;
  EF_WTYPE                 =    21;
  EF_REQ_STR             =    22;
  EF_REQ_INT             =    23;
  EF_REQ_DEX             =    24;
  EF_REQ_CON             =    25;

  // Bonus
  EF_ATTSPEED         =            26;
  EF_RANGE                 =    27;
  EF_PRICE                 =    28;
  EF_RUNSPEED         =            29;
  EF_SPELL                 =    30;
  EF_DURATION         =            31;
  EF_PARM2                 =    32   ;
  EF_GRID                 =        33  ;
  EF_GROUND             =        34  ;
  EF_CLAN                 =        35;
  EF_HWORDCOIN         =        36;
  EF_LWORDCOIN         =        37;
  EF_VOLATILE         =            38;
  EF_KEYID                 =    39    ;
  EF_PARRY                 =    40     ;
  EF_HITRATE             =        41    ;
  EF_CRITICAL         =            42   ;
  EF_SANC                 =        43      ;
  EF_SAVEMANA         =            44     ;
  EF_HPADD                 =    45        ;
  EF_MPADD                 =    46       ;
  EF_REGENHP             =        47    ;
  EF_REGENMP             =        48    ;
  EF_RESIST1             =        49    ;
  EF_RESIST2             =        50    ;
  EF_RESIST3             =        51    ;
  EF_RESIST4             =        52    ;
  EF_ACADD                 =    53      ;
  EF_RESISTALL         =        54    ;
  EF_BONUS                 =    55      ;
  EF_HWORDGUILD     =            56  ;
  EF_LWORDGUILD     =            57  ;
  EF_QUEST                 =    58      ;
  EF_UNIQUE             =        59    ;
  EF_MAGIC                 =    60      ;
  EF_AMOUNT             =        61    ;
  EF_HWORDINDEX     =            62  ;
  EF_LWORDINDEX     =            63  ;
  EF_INIT1                 =    64      ;
  EF_INIT2                 =    65      ;
  EF_INIT3                 =    66      ;
  EF_DAMAGEADD         =        67    ;
  EF_MAGICADD         =            68  ;
  EF_HPADD2             =        69    ;
  EF_MPADD2             =        70    ;
  EF_CRITICAL2         =        71    ;
  EF_ACADD2             =        72    ;
  EF_DAMAGE2             =        73    ;
  EF_SPECIALALL     =            74  ;

  // Mount
  EF_CURKILL        =            75   ;
  EF_LTOTKILL        =            76   ;
  EF_HTOTKILL        =            77   ;
  EF_INCUBATE        =            78   ;
  EF_MOUNTLIFE        =        79     ;
  EF_MOUNTHP            =        80     ;
  EF_MOUNTSANC     =            81     ;
  EF_MOUNTFEED     =            82     ;
  EF_MOUNTKILL     =            83     ;
  EF_INCUDELAY     =            84     ;
  EF_SUBGUILD     =                85   ;

  //GRADE([A],[B],[C],[D],[E],[F]..[Z])
  EF_GRADE = 87;

  // Set Option
  EF_GRADE0            =        100     ;
  EF_GRADE1         =            101     ;
  EF_GRADE2        =            102     ;
  EF_GRADE3     =                103     ;
  EF_GRADE4    =                104     ;
  EF_GRADE5 =                    105     ;

 EF_CONTMES = 106;         // Mês (Taxa do Mês no Contador Amarelo)
 EF_CONTHOR = 107;         // Horas(s) (Taxa do Hora no Contador Amarelo)
 EF_CONTMIN = 108;         // Min(s) (Taxa do Minutos no Contador Amarelo)
 EF_CONTANO = 109;         // Ano (Taxa do Ano no Contador Amarelo)
 EF_CONTDIA = 110;         // Dia(s) (Taxa do Dia no Contador Amarelo)
 EF_NULL111 = 111;         // <O QUE É?> --
 EF_REQ_EVO = 112;         // <Evolução que pode usar o item [(0 = Todas as Evoluções) (1 = Archs ~ +) (2 = Apenas Mortais lvl 260 ~ +) (3 = Celestiais ~ +)]>
 EF_NULL113 = 113;         // <O QUE É?> --
 EF_NULL114 = 114;         // --
 EF_SANC2 = 115;           // <Refinação para itens>
 EF_BLUE = 116;            // <Tintura Azul para itens>
 EF_RED = 117;             // <Tintura Vermelho para itens>
 EF_GREEN = 118;           // <Tintura Verde para itens>
 EF_SILVER = 119;          // <Tintura Prata para itens>
 EF_BLACK = 120;           // <Tintura Preto para itens>
 EF_PURPLE = 121;          // <Tintura Roxo para itens>
 EF_BROWN = 122;           // <Tintura Marron para itens>
 EF_DARKRED = 123;         // <Tintura Vermelho Escuro para itens>
 EF_YELLOW = 124;          // <Tintura Amarelo para itens>
 EF_DARKBLUE = 125;        // <Tintura Azul Escuro para itens>
 EF_SANC3 = 126;           // <Refinação para itens>

  //Replations
  add_critical: array[0..5] of BYTE = ( 35, 40, 45, 50, 60, 70 );
  add_ac: array[0..4] of BYTE = ( 10, 15, 20, 25, 25 );
  add_damage: array[0..3] of BYTE = ( 9, 18, 24, 30 );
  add_magic: array[0..3] of BYTE = ( 4, 6, 8, 10 );
  add_attspeed: array[0..6] of BYTE = ( 3, 6, 9, 10, 12, 15, 18 );
  add_hp: array[0..2] of BYTE = ( 40, 50, 60 );
  add_skill: array[0..7] of BYTE  = ( 2, 4, 6, 8, 10, 12, 15, 18 );
  add_sanc: array[0..5] of BYTE = ( 1, 2, 3, 4, 5, 6 );

  effs_elmo: array[0..5] of BYTE = ( EF_NONE, EF_ATTSPEED, EF_MAGIC, EF_HP, EF_ACADD, EF_SANC );
  effs_armadura: array[0..5] of BYTE = ( EF_NONE, EF_DAMAGE, EF_CRITICAL, EF_MAGIC, EF_ACADD, EF_SANC );
  effs_calca: array[0..5] of BYTE = ( EF_NONE, EF_DAMAGE, EF_CRITICAL, EF_MAGIC, EF_ACADD, EF_SANC );
  effs_manopla: array[0..5] of BYTE = ( EF_NONE, EF_DAMAGE, EF_SPECIALALL, EF_MAGIC, EF_ACADD, EF_SANC );
  effs_bota: array[0..4] of BYTE = ( EF_NONE, EF_DAMAGE, EF_SPECIALALL, EF_MAGIC, EF_SANC );

implementation

end.
