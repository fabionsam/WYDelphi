unit PacketsDbServer;

interface

uses
  PlayerData;

type TDbPacketHeader = packed Record
  Size: Smallint;
  Key: Byte;
  ChkSum: Byte;
  Code: Smallint;
  Index: Smallint;
  Time: LongWord;
end;

type TCreateCharacterDb = packed Record
  Header : TDbPacketHeader;
  ClientId : Word;
  SlotIndex: integer;
  CharacterName: array[0..15] of AnsiChar;
  ClassIndex: integer;
End;

type TRespCreateCharacterDb = packed Record
  Header : TDbPacketHeader;
  Exists: Boolean;
  ClientId : Word;
  SlotIndex: integer;
  CharacterName: array[0..15] of AnsiChar;
  ClassIndex: integer;
End;

type TSaveAccount = packed Record
  Header : TDbPacketHeader;
  Acc : TAccountFile;
End;

type TSendRecServerId = packed Record
  Header : TDbPacketHeader;
  ServerId: BYTE;
End;

type TResquestAccount = packed Record
  Header : TDbPacketHeader;
  Login : array[0..15] of AnsiChar;
  PassWord : array[0..11] of AnsiChar;
  ClientId : Word;
End;

type TReceiveAccount = packed Record
  Header : TDbPacketHeader;
  ClientId : Word;
  Found : Boolean;
  WrongPassWord : Boolean;
  IsActive : Boolean;
  Account: TAccountFile;
End;

type TAccountDisconnect = packed Record
  Header : TDbPacketHeader;
  AccountId: String[50];
End;

implementation

end.
