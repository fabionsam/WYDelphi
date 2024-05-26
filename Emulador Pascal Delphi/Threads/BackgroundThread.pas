unit BackgroundThread;

interface

uses Windows, SysUtils, Classes, DateUtils, Generics.Collections, System.TimeSpan,
    System.Diagnostics, System.SyncObjs, System.Threading, Generics.Nullable;

type TBackgroundThread = class(TThread)
  public
    ThreadName: string;
    class var BackgroundThreads: TList<TBackgroundThread>;
    class procedure AddThreads; static;
    class procedure StopThreads; static;

  private
    _deltaTime: TTimeSpan;
    _lastTime: Double;

  protected
    // Tipo FPS
    UpdateSpan: TNullable<TTimeSpan>;

    // Tempo de sleep caso n�o tenha nenhum player
    SleepTime: TNullable<TTimeSpan>;

    //Lock: TCriticalSection; // Vamos usar em threads que precisem ser Thread-Safe

    // Diferen�a de tempo entre um ciclo e o outro
    // Idealmente vai ser 1 / TimesPerSecond
    property DeltaTime: TTimeSpan read _deltaTime;

    procedure Setup; virtual;
    procedure Execute; override;
    procedure OnTerminate(Sender: TObject);
    procedure Update(); virtual; abstract;
end;

implementation
uses Log, GlobalDefs, Player,
    LoginDisconnectBackgroundThread, SaveAccountsBackgroundThread, VisibleListBackgroundThread,
    AIBackgroundThread, VisibleDropListBackgroundThread, WeatherChangeBackgroundThread, QuestsBackgroundThread,
    PositionUpdateBackgroundThread, ReviveNPCsBackgroundThread, UpdateHpMpBackgroundThread, Rtti;

procedure TBackgroundThread.Execute;
var timer: TStopwatch;
  updateTime: TTimeSpan;
begin
  try
    timer := TStopwatch.StartNew;
    while (Server.IsActive) and not(self.Terminated) and(Self.Started) do
    begin
      sleep(10);
      if (TPlayer.InstantiatedPlayers <= 0) AND (SleepTime.HasValue) AND (SleepTime <> TTimeSpan.Zero) then
      begin
        TThread.Sleep(SleepTime.Value.Milliseconds);
        timer.Reset;
        timer.Start;
        continue;
      end;

      if (UpdateSpan.HasValue) AND(UpdateSpan.Value > TTimeSpan.Zero) AND
        (timer.Elapsed < UpdateSpan.Value) then
      begin
        TThread.Sleep((UpdateSpan.Value - timer.Elapsed).Milliseconds);
        continue;
      end;
      _deltaTime := timer.Elapsed;
      //Logger.Write('[' + ThreadName + ']: DeltaTime -' + DeltaTime, TLogType.Warnings);
      timer.Reset;
      timer.Start;
      Update();
    end;
  except on e : Exception do
    Logger.Write('[' + Self.ThreadName + '] ' + e.Message, TLogType.Warnings);
  end;
end;

class procedure TBackgroundThread.AddThreads;
var thread: TBackgroundThread;
begin
  BackgroundThreads := TList<TBackgroundThread>.Create;
  BackgroundThreads.Add(TLoginDisconnectBackgroundThread.Create(true));
  BackgroundThreads.Add(TSaveAccountsBackgroundThread.Create(true));
  BackgroundThreads.Add(TVisibleListBackgroundThread.Create(true));
  BackgroundThreads.Add(TAIBackgroundThread.Create(true));
//  BackgroundThreads.Add(TVisibleDropListBackgroundThread.Create(true));
  BackgroundThreads.Add(TWeatherChangeBackgroundThread.Create(true));
  BackgroundThreads.Add(TQuestsBackgroundThread.Create(true));
  BackgroundThreads.Add(TPositionUpdateBackgroundThread.Create(true));
  BackgroundThreads.Add(TReviveNPCsBackgroundThread.Create(true));
  BackgroundThreads.Add(TUpdateHpMpBackgroundThread.Create(true));

  for thread in BackgroundThreads do
  begin
    thread.Setup;
    thread.FreeOnTerminate := true;
    thread.ThreadName := thread.ClassType.ClassName.Substring(1);
    TThread.NameThreadForDebugging(thread.ThreadName, thread.ThreadID);
  end;
end;

class procedure TBackgroundThread.StopThreads;
var thread: TBackgroundThread;
begin
  if(BackgroundThreads = nil) then
    exit;

  for thread in BackgroundThreads do
  begin
    if not(thread.Terminated) then
      thread.DoTerminate;
  end;
end;

procedure TBackgroundThread.Setup;
begin
  Priority := tpNormal;
  UpdateSpan := TTimeSpan.FromSeconds(2);
end;

procedure TBackgroundThread.OnTerminate(Sender: TObject);
begin
  Logger.Write('A BackgroundThread: ' + self.ThreadName + ' foi finalizada', TLogType.Warnings);
  //inherited;
end;

end.
