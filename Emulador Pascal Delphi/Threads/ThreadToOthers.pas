unit ThreadToOthers;

interface

uses Windows, SysUtils, Classes, DateUtils, Generics.Collections, System.TimeSpan,
    System.Diagnostics, System.SyncObjs, System.Threading, Generics.Nullable;

type TThreadToOthers = class(TThread)
  procedure Execute; override;  //Execute method. Must be overridden in a descendant thread.
  procedure Synchronize(); //Synchronizes the thread by executing the method in the main thread.
  procedure Queue(); //Queue a method for execution in the main thread
end;

implementation

Uses Log, GlobalDefs, Player, BackGroundThread;

{ TBackgroundThread }

procedure TThreadToOthers.Execute;
var timer : TStopwatch;
  updateTime: TTimeSpan;
  thread: TBackgroundThread;
begin
  try
    timer  := TStopwatch.StartNew;
    while (Server.IsActive) and not(self.Terminated) and (Self.Started) do
    begin
      if (TPlayer.InstantiatedPlayers <= 0) then
      begin
        TThread.Sleep(100);
        continue;
      end;

      for thread in TBackgroundThread.BackgroundThreads do
      begin

        if (thread.UpdateSpan.HasValue) AND (thread.UpdateSpan.Value > TTimeSpan.Zero) AND
           (thread.GetNexTimeUpdate > Now) then
          continue;

        //Logger.Write('[' + ThreadName + ']: DeltaTime -' + DeltaTime, TLogType.Warnings);
        timer.Reset;
        timer.Start;
        thread.Update();
        thread.LastUpdate := Now;
        thread.DeltaTime := timer.Elapsed;
      end;
      TThread.Sleep(10);
    end;
  except on e : Exception do
    Logger.Write('Erro na thread: ' + e.Message, TLogType.Warnings);
  end;
end;

procedure TThreadToOthers.Queue;
begin

end;

procedure TThreadToOthers.Synchronize;
begin

end;

end.
