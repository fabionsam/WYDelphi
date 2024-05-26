unit WeatherChangeBackgroundThread;

interface
uses BackgroundThread, System.TimeSpan;

type TWeatherChangeBackgroundThread = class(TBackgroundThread)
  protected
    procedure Setup; override;
    procedure Update(); override;
end;

implementation
uses Classes, Packets, GlobalDefs, MiscData, SysUtils, Player;

procedure TWeatherChangeBackgroundThread.Setup;
begin
  UpdateSpan := TTimeSpan.FromSeconds(20);
end;

procedure TWeatherChangeBackgroundThread.Update();
var cityId: BYTE; dirty: boolean; min: integer;
packet: TSendWeatherPacket;
begin
  dirty := false;
  for cityId := 0 to 3 do
  begin
    if(Now >= CityWeather[cityId].Next)then
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

    TPlayer.ForEach(procedure(player: TPlayer)
    begin
      packet.Header.Index := player.ClientId;
      packet.WeatherId := BYTE(CityWeather[BYTE(player.PlayerCharacter.CurrentCity)].Condition);
      player.SendPacket(@packet, packet.Header.Size);
    end);
  end;
end;

end.
