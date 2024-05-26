unit LoginDisconnectBackgroundThread;

interface
uses BackgroundThread, System.TimeSpan;

type TLoginDisconnectBackgroundThread = class(TBackgroundThread)
  private
    function GetCurrTime: TDateTime;
  protected
    procedure Setup; override;
    procedure Update(); override;
end;

implementation
uses Classes, DateUtils, SysUtils, Player, PlayerData, GlobalDefs, Util;

function TLoginDisconnectBackgroundThread.GetCurrTime: TDateTime;
begin
  Result := Now;
end;

procedure TLoginDisconnectBackgroundThread.Setup;
begin
  Priority := tpLower;
  UpdateSpan := TTimeSpan.FromSeconds(5);
  SleepTime := TTimeSpan.FromSeconds(10);
end;

procedure TLoginDisconnectBackgroundThread.Update();
var lastId: WORD;
begin
  TPlayer.ForEach(procedure(player : TPlayer)
  begin
    if ((IncMinute(player.CountTime, 1) > GetCurrTime)
      and (player.Status = TPlayerStatus.WaitingLogin)) then
    begin
      player.Disconnect;
      exit;
    end;
    lastId := IFThen(player.ClientId > lastId, player.ClientId, lastId);
  end);
  TPlayer.InstantiatedPlayers := lastId;
end;

end.
