unit GlobalDefs;

interface

uses
  Log, ServerSocket, MiscData;

var
  Logger : TLog;
  Server : TServerSocket;
  CurrentDir : String;
  ConfiguracoesDbServer : TConfiguracoes;

const
  MAX_CONNECTIONS = 10;

implementation

end.
