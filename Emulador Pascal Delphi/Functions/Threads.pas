unit Threads;

interface

uses Windows, SysUtils, Classes, DateUtils, System.TimeSpan, System.Diagnostics,
      BaseMob, PlayerData, Player, NPC, ItemFunctions, System.SyncObjs;

type TBackgroundThread = class(TThread)
  public
    constructor Create(Suspend:Boolean);

  protected
    // Essas propriedades v�o ser definidas em 'Setup'
    CycleTime: Single; // Tempo entre um ciclo e o outro
    SleepTime: Single; // Tempo de sleep caso n�o tenha nenhum player
    Lock: TCriticalSection; // Vamos usar em threads que precisem ser Thread-Safe

    procedure Setup; virtual;
    procedure Execute; override;
    procedure OnTerminate(Sender: TObject);
    procedure Update(elapsed: TTimeSpan); virtual; abstract;
end;

type TVisibleListThread = class(TBackgroundThread)
  protected
    procedure Setup; override;
    procedure Update(elapsed: TTimeSpan); override;
end;

type TQuestsThread = class(TBackgroundThread)
  protected
    procedure Setup; override;
    procedure Update(elapsed: TTimeSpan); override;
end;

type TNpcAIThread = class(TBackgroundThread)
  protected
    procedure Setup; override;
    procedure Update(elapsed: TTimeSpan); override;
end;

type TVisibleDropListThread = class(TBackgroundThread)
  protected
    procedure Setup; override;
    procedure Update(elapsed: TTimeSpan); override;
end;

type TLoginDisconnectThread = class(TBackgroundThread)
  protected
    procedure Setup; override;
    procedure Update(elapsed: TTimeSpan); override;
end;

type TSaveAccountsThread = class(TBackgroundThread)
  protected
    procedure Setup; override;
    procedure Update(elapsed: TTimeSpan); override;
end;

type TUpdateHpMpThread = class(TBackgroundThread)
  protected
    procedure Setup; override;
    procedure Update(elapsed: TTimeSpan); override;
end;

type TWeatherChangeThread = class(TBackgroundThread)
  protected
    procedure Setup; override;
    procedure Update(elapsed: TTimeSpan); override;
end;

var LoginDisconnectThread : TLoginDisconnectThread;
    NpcAIThread : TNpcAIThread;
    SaveAccountsThread : TSaveAccountsThread;
    UpdateHpMpThread : TUpdateHpMpThread;
    WeatherChangeThread : TWeatherChangeThread;
    VisibleListThread : TVisibleListThread;
    VisibleDropListThread : TVisibleDropListThread;

implementation

uses GlobalDefs, Log, Packets, Util, MiscData, Functions;

{ TBackgroundThread }
constructor TBackgroundThread.Create(Suspend:Boolean);
begin
  inherited;
  self.Setup;
end;

procedure TBackgroundThread.Setup;
begin
  Priority := tpNormal;
  CycleTime := 2;
  SleepTime := 5;
end;

procedure TBackgroundThread.Execute;
var timer: TStopwatch;
  updateTime: TTimeSpan;
begin
  try
//    Logger.Write(self.ClassName + ': ' + IntToStr(self.ThreadID), TLogType.ServerStatus);
//    timer := TStopwatch.Create;
//    timer.Start;
    timer := TStopwatch.StartNew;
    while (Server.IsActive) do
    begin
      if (InstantiatedPlayers <= 0) AND (SleepTime > 0) then
      begin
        TThread.Sleep(Round(SleepTime * 1000));
        timer.Reset;
        timer.Start;
        continue;
      end;

      if (timer.ElapsedMilliseconds < CycleTime * 1000) then
      begin
        if ((CycleTime * 1000) - timer.ElapsedMilliSeconds > 0) THEN
        begin
          TThread.Sleep(Round((CycleTime * 1000) - timer.ElapsedMilliSeconds));
        end;
        continue;
      end;
      updateTime := timer.Elapsed;
      timer.Reset;
      timer.Start;
      Update(updateTime);
      inherited;
    end;
  except on e : Exception do
    Logger.Write(e.Message, TLogType.Warnings);
  end;
end;

procedure TBackgroundThread.OnTerminate(Sender: TObject);
begin
  Logger.Write('A BackgroundThread: ' + IntToStr(self.ThreadId) + ' foi finalizada', TLogType.Warnings);
  //inherited;
end;

{ TWeatherChangeThread }
procedure TWeatherChangeThread.Setup;
begin
  Priority := tpLower;
  CycleTime := 20;
  SleepTime := 50;
end;

procedure TWeatherChangeThread.Update(elapsed: TTimeSpan);
var cityId: BYTE; dirty: boolean; min: integer;
packet: TSendWeatherPacket;
begin
  dirty := false;
  for cityId := 0 to 3 do
  begin
    if(CityWeather[cityId].Time >= CityWeather[cityId].Next)then
    begin
      dirty := true;
      if(cityId = 3) then
      begin
        //somente gelo e nevasca
        CityWeather[cityId].Condition := TWeatherCondition(Random(2) + 2);
      end
      else
      begin
        CityWeather[cityId].Condition := TWeatherCondition(Random(3));
      end;
      CityWeather[cityId].Time := Now;
      min := (Random(30) + 30);
      CityWeather[cityId].Next := Now + StrToTime('00:' + InTtoStr(min) + ':00');
      //IncMinute(CityWeather[cityId].Next, min);
    end;
  end;

  if(dirty) then
  begin
    packet.Header.Size := 16;
    packet.Header.Code := $18B;

    TPlayer.ForEach(procedure(player: PPlayer)
    begin
      packet.Header.Index := player.Base.ClientId;
      packet.WeatherId := BYTE(CityWeather[BYTE(player.Character.CurrentCity)].Condition);
      player.SendPacket(@packet, packet.Header.Size);
    end);
  end;
end;


{ TLoginDisconnectThread }
procedure TLoginDisconnectThread.Setup;
begin
  Priority := tpNormal;
  CycleTime := 2;
  SleepTime := 10;
end;

procedure TLoginDisconnectThread.Update(elapsed: TTimeSpan);
var lastId: WORD;
begin
  TPlayer.ForEach(procedure(player : PPlayer)
  begin
    if not(player.Base.IsActive) then
      exit;

    if ((IncMinute(player.CountTime, 1) < Now)
      and (player.Status = TPlayerStatus.WaitingLogin)) then
    begin
      Server.Disconnect(player.Base.ClientId);
      exit;
    end;
    lastId := IFThen(player.Base.ClientId > lastId, player.Base.ClientId, lastId);
  end);
  InstantiatedPlayers := lastId;
end;


{ TSaveAccountsThread }
procedure TSaveAccountsThread.Setup;
begin
  Priority := tpHigher;
  CycleTime := 5;
  SleepTime := 10;
end;

procedure TSaveAccountsThread.Update(elapsed: TTimeSpan);
var cnt: WORD;
begin
  TPlayer.ForEach(procedure(player : PPlayer)
  begin
    if not(player.Account.Header.IsActive) OR (player.Status < PLAYING) then
      exit;
    // A conta s� ser� salva por essa thread caso o player esteja no mundo
    // Quando ele voltar a tela de personagens ela � salva automaticamente.
    // O mesmo vale para o Disconnect
    player.SaveAccount;
    Inc(cnt);
  end);
  //Logger.Write('[' + IntToStr(cnt) + '] contas foram salvas...', TLogType.ConnectionsTraffic);
end;

{ TVisibleListThread }
procedure TVisibleListThread.Setup;
begin
  Priority := tpHigher;
  CycleTime := 1;
  SleepTime := 6;
end;

procedure TVisibleListThread.Update(elapsed: TTimeSpan);
begin
  TPlayer.ForEach(procedure(player : PPlayer; state : TLoopState)
  begin
    if not(player.Base.IsDirty) OR (player.Status < Playing) then
      exit;

    player.Base.UpdateVisibleList;
    player.UpdateVisibleDropList;
    //state.Break;
  end);
end;


{ TNpcAIThread }
procedure TNpcAIThread.Setup;
begin
  Priority := tpHigher;
  CycleTime := 1;
  SleepTime := 10;
  Lock := TCriticalSection.Create;
end;

procedure TNpcAIThread.Update(elapsed: TTimeSpan);
begin
  TNpc.ForEach(false, procedure(npc: PNpc)
  begin
    npc.PerformAI;
  end);
end;


{ TVisibleDropListThread }
procedure TVisibleDropListThread.Setup;
begin
  Priority := tpLower;
  CycleTime := 8; // Essa � uma thread que pode ser realmente lenta
  SleepTime := 10;
end;

procedure TVisibleDropListThread.Update(elapsed: TTimeSpan);
var i: Integer;
begin
  for i := 1 to Length(InitItems) do
  begin
    TItemFunctions.DeleteVisibleDropList(i);
    sleep(1);
  end;
end;


{ TUpdateHpMpThread }
procedure TUpdateHpMpThread.Setup;
begin
  Priority := tpNormal;
  CycleTime := 8;
  SleepTime := 10;
end;

procedure TUpdateHpMpThread.Update(elapsed: TTimeSpan);
var hpMp: WORD;
    dirtyAffects: Boolean;
    dirtyHpMp: Boolean;
    aura: Boolean;
begin
  TPlayer.ForEach(procedure(player: PPlayer)
  var i: Byte;
  begin
    if (player.Status < TPlayerStatus.PLAYING) OR (player.Base.IsDead) then
      exit;

    if(player.Character.Base.CurrentScore.CurHP < player.Character.Base.CurrentScore.MaxHP) then
    begin
      dirtyHpMp := true;
      hpMp := player.Character.Base.CurrentScore.CurHP + player.Character.Base.RegenHP;
      hpMp := IFThen(hpMp > player.Character.Base.CurrentScore.MaxHP, player.Character.Base.CurrentScore.MaxHP, hpMp);
      player.Character.Base.CurrentScore.CurHP := hpMp;
    end;
    if(player.Character.Base.CurrentScore.CurMP < player.Character.Base.CurrentScore.MaxMP) then
    begin
      dirtyHpMp := true;
      hpMp := player.Character.Base.CurrentScore.CurMP + player.Character.Base.RegenMP;
      hpMp := IFThen(hpMp > player.Character.Base.CurrentScore.MaxMP, player.Character.Base.CurrentScore.MaxMP, hpMp);
      player.Character.Base.CurrentScore.CurMP := hpMp;
    end;

    if(dirtyHpMp) then
      player.Base.SendCurrentHPMP();

    for i := 0 to 15 do
    begin
      if(player.Character.Base.Affects[i].Time - 1 > 0) then
      begin
        Dec(player.Character.Base.Affects[i].Time, 1);

        if(player.Character.Base.ClassInfo = 0) OR (player.Character.Base.ClassInfo = 3) then
          continue;

        if (player.Character.Base.Affects[i].Index = FM_TROVAO)
          OR (player.Character.Base.Affects[i].Index = BM_AURA_BESTIAL) then
          aura := true;

        continue;
      end;

      if (player.Character.Base.Affects[i].Index <> 0) then
      begin
        dirtyAffects := true;
        if (player.Character.Base.Affects[i].Index = 16) then
        begin
          player.Character.Base.Equip[0].Index := player.Character.Base.Equip[0].Effects[2].Value;
          player.Character.Base.Equip[0].Effects[2].Value := 0;
          player.Base.SendEquipItems();
          ZeroMemory(@player.Character.Base.Affects[i], sizeof(TAffect));
        end
        else
          ZeroMemory(@player.Character.Base.Affects[i], sizeof(TAffect));
      end
    end;

    if(dirtyAffects) then
    begin
      player.Base.SendAffects;
      player.Base.SendScore;
    end;

    if not(aura) then exit;

    player.Base.ForEachInRange(4, procedure(pos: TPosition; self, mob: TBaseMob)
    begin

    end);
  end);
end;

{ TQuestsThread }
procedure TQuestsThread.Setup;
begin
  Priority := tpNormal;
  CycleTime := 60;
  SleepTime := 10;
end;

procedure TQuestsThread.Update(elapsed: TTimeSpan);
var quest: TQuest;
  index: WORD;
  player: TPlayer;
  pos: TPosition;
begin
  for quest in Quests do
  begin
    for index in quest.Players do
    begin
      if not (TPlayer.GetPlayer(index, player)) OR
        (player.Character.CurrentQuest <> quest.Index) then
      begin
        quest.Players.Remove(index);
        continue;
      end;

      if MinutesBetween(Now, player.Character.QuestEntraceTime) >= quest.ResetTime then
      begin
        pos := TFunctions.GetStartXY(player);
        player.Character.CurrentQuest := -1;
        player.Base.Teleport(pos);
      end;
    end;
  end;
end;

end.
