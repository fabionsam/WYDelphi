unit VisibleDropListBackgroundThread;

interface
uses BackgroundThread, System.TimeSpan;

type TVisibleDropListBackgroundThread = class(TBackgroundThread)
  protected
    procedure Setup; override;
    procedure Update(); override;
end;

implementation
uses Classes, ItemFunctions, GlobalDefs;

procedure TVisibleDropListBackgroundThread.Setup;
begin
  Priority := tpLower;
  UpdateSpan := TTimeSpan.FromSeconds(8);
  SleepTime := TTimeSpan.FromSeconds(10);
end;

procedure TVisibleDropListBackgroundThread.Update();
var i: Integer;
begin
  for i := 1 to Length(InitItems) do
  begin
    TItemFunctions.DeleteVisibleDropList(i);
    Sleep(1);
  end;
end;

end.
