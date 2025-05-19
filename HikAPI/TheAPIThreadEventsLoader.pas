unit TheAPIThreadEventsLoader;

{
  ������ ������ �� API � ���������� ������ � ���� ������.

  ��� �������� ������ � �������� ��������� ���������� ����� ��������� �������.
  ������� �������������� ��� ������� ���������� � ������� ���� ��������
  � ������� ������ GetEventsPortion ������ TEventsLoader.

  ������������ ������� ��������� � ������ ������ ������ � �������
  �������� ����� ������ ������.
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
    // ��������� ������ ��� ���� ������� � ���� �����
    for I := 0 to Loader.DeviceCount - 1 do
      for J := 0 to Loader.MinorEventCount - 1 do begin
        // ��� ������ ��������� � ������� ����� ����� ���������� �������
        // ����� ���� ������, ������� ��� ���� ������
        StartTime := Loader.LastTimeInDB(I, J);
        StartTime := IncSecond(StartTime, 1);
        // �������� ������ ���� ������ ��������� ������ �� ������ ������
        // ������������� �������� ������� - ������ ��� ��������� ������
        Pos := 0;
        repeat
          if Self.Terminated then Break;
          Cnt := Loader.GetEventsPortion(I, Pos, Loader.MinorEvent[J],
            StartTime, FEndTime);
          FTotalCount := FTotalCount + Cnt;
          Pos := Pos + Cnt;
          // ������������� ����������
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
