unit VisibleListBackgroundThread;

interface
uses Windows, SysUtils, Classes, DateUtils, Generics.Collections, System.TimeSpan,
    System.Diagnostics, System.SyncObjs, System.Threading, Generics.Nullable,
    BackgroundThread;

type TVisibleListBackgroundThread = class(TBackgroundThread)
    procedure Execute; override;
    procedure Update();
end;

implementation

uses Player, Util, PlayerData, Log, GlobalDefs, ConstDefs, BaseMob;

procedure TVisibleListBackgroundThread.Execute;
begin
  Self.Priority := tpTimeCritical;
  while (Server.IsActive) and not(self.Terminated) and (Self.Started) do
  begin
    try
      if (TPlayer.InstantiatedPlayers <= 0) then
      begin
        TThread.Sleep(100);
        continue;
      end;

      Update;
      TThread.Sleep(10);
    except
      on E : Exception do
      begin
        Logger.Write('Erro na TVisibleListBackgroundThread : ' + e.Message, TLogType.Warnings);
      end;
    end;
  end;
end;

procedure TVisibleListBackgroundThread.Update();
begin
  TPlayer.ForEach(procedure(player : TPlayer; state : TLoopState)
  var
    i : Word;
    mob : TBaseMob;
  begin
    if not(player.IsDirty) OR (player.Status < Playing) or (player.ClientId > MAX_CONNECTIONS) or (player.isFirstAppear) then
      exit;

    player.SendGridMob(SPAWN_NORMAL);

    if(player.VisibleMobs.Count > 0) then
    begin
      for i in player.VisibleMobs do
      begin
        if (player.GetMob(i, mob) = false) then
        begin
          player.VisibleMobs.Remove(i);
          continue;
        end;

        if not(player.CurrentPosition.InRange(mob.CurrentPosition, DISTANCE_TO_FORGET)) then
          player.RemoveFromVisible(mob);
      end;
    end;

    player.IsDirty := False;
    //state.Break;
  end);
end;

end.
