unit QuestsBackgroundThread;

interface
uses BackgroundThread, System.TimeSpan;

type TQuestsBackgroundThread = class(TBackgroundThread)
  protected
    procedure Setup; override;
    procedure Update(); override;
end;

implementation
uses Classes, DateUtils, SysUtils, Player, MiscData, GlobalDefs, Functions, Position;

procedure TQuestsBackgroundThread.Setup;
begin
  Priority := tpNormal;
  UpdateSpan := TTimeSpan.FromMinutes(1);
  SleepTime := TTimeSpan.FromSeconds(25);
end;

procedure TQuestsBackgroundThread.Update();
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
        (player.PlayerCharacter.CurrentQuest <> quest.Index) then
      begin
        quest.Players.Remove(index);
        continue;
      end;

      if MinutesBetween(Now, player.PlayerCharacter.QuestEntraceTime) > quest.ResetTime then
      begin
        pos := TFunctions.GetStartXY(player);
        player.PlayerCharacter.CurrentQuest := -1;
        player.Teleport(pos);
      end;
    end;
  end;
end;

end.
