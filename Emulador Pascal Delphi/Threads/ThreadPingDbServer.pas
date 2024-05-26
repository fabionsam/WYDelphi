unit ThreadPingDbServer;

interface

uses
  System.Classes;

type TThreadPingDbServer = class(TThread)
  public
    procedure Execute; override;
end;

implementation

uses
  GlobalDefs;

{ TServerLoopThread }

procedure TThreadPingDbServer.Execute;
var
  i : BYTE;
begin
  Priority := tpNormal;
  FreeOnTerminate := True;
  while(DbClient.Started)do
  begin
    if not(Assigned(DbClient)) then
      continue;

    DbClient.SendSignal($50);
    Sleep(15000);
  end;
  inherited;
end;

end.
