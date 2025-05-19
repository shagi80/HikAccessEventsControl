unit TheAPIThreadEventsLoader;

{
  Запрос данных по API и сохранение данных в базе данных.

  При создании потока в качестве параметра передается время окончания выборки.
  Запросы осуществляются для каждого устройства и каждого кода порциями
  с помощью метода GetEventsPortion класса TEventsLoader.

  Генерируются событие получения и записи каждой порции и собятие
  принятия всего объема данных.
}

interface

uses
  Classes;

type
  TOnGetPortion = procedure (Pos: integer; Device, Code: string) of object;

  TOnGetAll = procedure (Count: integer) of object;

  TAPIThreadEventsLoader = class(TThread)
  private
    FEndTime: TDateTime;
    FOnGetPortion: TOnGetPortion;
    FOnGetAll: TOnGetAll;
    FTotalCount: integer;
    FCurrentDevice: string;
    FCurrentCode: string;
    procedure SyncGetPortion;
    procedure SyncGetAll;
  protected
    procedure Execute; override;
  public
    constructor Create(EndTime: TDateTime);
    property OnGetPortion: TOnGetPortion read FOnGetPortion
      write FOnGetPortion;
    property OnGetAll: TOnGetAll read FOnGetAll write FOnGetAll;
  end;

implementation

uses TheEventsLoader, DateUtils, SysUtils, TheSettings;

procedure TAPIThreadEventsLoader.SyncGetPortion;
begin
  if Assigned(FOnGetPortion) then FOnGetPortion(FTotalCount,
    FCurrentDevice, FCurrentCode);
end;

procedure TAPIThreadEventsLoader.SyncGetAll;
begin
  if Assigned(FOnGetAll) then FOnGetAll(FTotalCount);
end;

constructor TAPIThreadEventsLoader.Create(EndTime: TDateTime);
begin
  inherited Create(True);
  FEndTime := EndTime;
end;

procedure TAPIThreadEventsLoader.Execute;
var
  Loader: TEventsLoader;
  I, J, Pos, Cnt: integer;
  StartTime: TDateTime;
begin
  FreeOnTerminate := True;
  Loader := TEventsLoader.Create(Settings.GetInstance.DBFileName);
  FTotalCount := 0;
  Cnt := 0;
  try
    // Выполняем запрос для всех моделей и всех кодов
    for I := 0 to Loader.DeviceCount - 1 do
      for J := 0 to Loader.MinorEventCount - 1 do begin
        // Для разных устройств и разрных кодов время последнего события
        // может быть разное, поэтому его надо учнять
        StartTime := Loader.LastTimeInDB(I, J);
        StartTime := IncSecond(StartTime, 1);
        // Получаем порции пока размер очередной порции не станет меньше
        // максимального значения выборки - значит это последняя порция
        Pos := 0;
        repeat
          if Self.Terminated then Break;
          Cnt := Loader.GetEventsPortion(I, Pos, Loader.MinorEvent[J],
            StartTime, FEndTime);
          FTotalCount := FTotalCount + Cnt;
          Pos := Pos + Cnt;
          // Синхронизация интерфейса
          FCurrentDevice := UTF8Decode(Loader.Device[I].Name);
          FCurrentCode := IntToStr(LOader.MinorEvent[J]);
          Synchronize(SyncGetPortion);
        until (Cnt < Loader.PortionSize);
      end;
    Synchronize(SyncGetAll);
  finally
    Loader.Free
  end;
end;

end.
