unit Events;

interface
uses Windows, SysUtils, ServerSocket;

type TApplicationEvents = class(TObject)
  private
    _server: TServerSocket;

  public
    constructor Create(server: TServerSocket);
    function HandleEvents(CtrlType: integer): BOOL; stdcall;
end;

implementation

{ TApplicationEvents }

constructor TApplicationEvents.Create(server: TServerSocket);
begin
  Windows.SetConsoleCtrlHandler(Addr(TApplicationEvents.HandleEvents), True);
  _server := server;
end;

function TApplicationEvents.HandleEvents(CtrlType: integer): BOOL;
const
  ExitCodes = [CTRL_LOGOFF_EVENT, CTRL_SHUTDOWN_EVENT, CTRL_CLOSE_EVENT,
               CTRL_BREAK_EVENT, CTRL_C_EVENT];
begin
  if (CtrlType in ExitCodes) Then
  begin
    _server.CloseServer;
  end;
  result := true;
end;

end.
