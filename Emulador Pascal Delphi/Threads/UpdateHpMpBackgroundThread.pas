unit UpdateHpMpBackgroundThread;

interface
uses BackgroundThread, System.TimeSpan;

type TUpdateHpMpBackgroundThread = class(TBackgroundThread)
  protected
    procedure Setup; override;
    procedure Update(); override;
end;

implementation
uses Windows, Classes, Player, PlayerData, Util, MiscData, SysUtils, GlobalDefs, ConstDefs, BaseMob, Position;

procedure TUpdateHpMpBackgroundThread.Setup;
begin
  Priority := tpNormal;
  UpdateSpan := TTimeSpan.FromSeconds(8);
  SleepTime := TTimeSpan.FromSeconds(10);
end;

procedure TUpdateHpMpBackgroundThread.Update();
var hpMp: WORD;
    dirtyAffects: Boolean;
    dirtyHpMp: Boolean;
    aura: Boolean;
begin
  TPlayer.ForEach(procedure(player: TPlayer)
  var i: Byte;
  begin
    if (player.Status < TPlayerStatus.PLAYING) OR (player.IsDead) then
      exit;

    if(player.Character.CurrentScore.CurHP < player.Character.CurrentScore.MaxHP) then
    begin
      dirtyHpMp := true;
      hpMp := player.Character.CurrentScore.CurHP + player.Character.RegenHP;
      hpMp := IFThen(hpMp > player.Character.CurrentScore.MaxHP, player.Character.CurrentScore.MaxHP, hpMp);
      player.Character.CurrentScore.CurHP := hpMp;
    end;
    if(player.Character.CurrentScore.CurMP < player.Character.CurrentScore.MaxMP) then
    begin
      dirtyHpMp := true;
      hpMp := player.Character.CurrentScore.CurMP + player.Character.RegenMP;
      hpMp := IFThen(hpMp > player.Character.CurrentScore.MaxMP, player.Character.CurrentScore.MaxMP, hpMp);
      player.Character.CurrentScore.CurMP := hpMp;
    end;

    if(dirtyHpMp) then
      player.SendCurrentHPMP();

    for i := 0 to MAXBUFFS - 1 do
    begin
      if(player.Character.Affects[i].Time - 1 > 0) then
      begin
        Dec(player.Character.Affects[i].Time, 1);

        if(player.Character.ClassInfo = 0) OR (player.Character.ClassInfo = 3) then
          continue;

        if (player.Character.Affects[i].Index = FM_TROVAO)
          OR (player.Character.Affects[i].Index = BM_AURA_BESTIAL) then
          aura := true;

        continue;
      end;

      if (player.Character.Affects[i].Index <> 0) then
      begin
        dirtyAffects := true;
        if (player.Character.Affects[i].Index = 16) then
        begin
          player.Character.Equip[0].Index := player.Character.Equip[0].Effects[2].Value;
          player.Character.Equip[0].Effects[2].Value := 0;
          player.SendEquipItems();
          ZeroMemory(@player.Character.Affects[i], sizeof(TAffect));
        end
        else
          ZeroMemory(@player.Character.Affects[i], sizeof(TAffect));
      end
    end;

    if(dirtyAffects) then
    begin
      player.SendAffects;
      player.SendScore;
    end;

    if not(aura) then exit;

    player.ForEachInRange(4, procedure(pos: TPosition; self, mob: TBaseMob)
    begin

    end);
  end);
end;

end.
