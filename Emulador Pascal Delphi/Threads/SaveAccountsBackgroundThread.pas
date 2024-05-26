unit SaveAccountsBackgroundThread;

interface
uses BackgroundThread, System.TimeSpan;

type TSaveAccountsBackgroundThread = class(TBackgroundThread)
  protected
    procedure Setup; override;
    procedure Update(); override;
end;

implementation
uses Classes, Player, PlayerData;

procedure TSaveAccountsBackgroundThread.Setup;
begin
  Priority := tpHigher;
  UpdateSpan := TTimeSpan.FromSeconds(5);
  SleepTime := TTimeSpan.FromSeconds(10);
end;

procedure TSaveAccountsBackgroundThread.Update();
var cnt: WORD;
begin
  TPlayer.ForEach(procedure(player : TPlayer)
  begin
    if not(player.Account.Header.IsActive) OR (player.Status < PLAYING) then
      exit;
    // A conta só será salva por essa thread caso o player esteja no mundo
    // Quando ele voltar a tela de personagens ela é salva automaticamente.
    // O mesmo vale para o Disconnect
    player.SaveAccount;
    Inc(cnt);
  end);
  //Logger.Write('[' + IntToStr(cnt) + '] contas foram salvas...', TLogType.ConnectionsTraffic);
end;


end.
