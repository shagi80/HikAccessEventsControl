unit TheAPIThreadStateLoader;

{
  ������ ��������� ��������� � ���������� ����� ������� �� API.

  ��� �������� ������ � �������� ��������� ���������� ����� ��������� �������.
  ������� �������������� ��� ������� ����������, ����������� ��� �����������
  � ����� ���������� ���������� � ���������� ����� �������.
  ���������� ������������� ����� ��������� �������, ����������� ���������
  � ���������������� �������.
}

interface

uses
  Classes;

type
  TDeviceStatus = record
    id: integer;
    Name: string;
    Enabled: boolean;
    LastTimeInBD: TDateTime;
    EventsCount: integer;
  end;

  TDeviceStatuses = array of TDeviceStatus;

  TOnGetData = procedure(Statuses: TDeviceStatuses)of object;

  TAPIStateLoader = class(TThread)
  private
    { Private declarations }
    FOnGetdata: TOnGetData;
    FStatuses: TDeviceStatuses;
    FEndTime: TDateTime;
    procedure SyncGetData;
  protected
    procedure Execute; override;
  public
    constructor Create(EndTime: TDateTime);
    property OnGetdata: TOnGetData read FOnGetData write FOnGetData;
  end;

implementation

uses
  TheEventsLoader, DateUtils, SysUtils, TheSettings;

constructor TAPIStateLoader.Create(EndTime: TDateTime);
begin
  inherited Create(True);
  FEndTime := EndTime;
end;

procedure TAPIStateLoader.SyncGetData;
begin
  if Assigned(FOnGetData) then FOnGetData(FStatuses);
end;

procedure TAPIStateLoader.Execute;
var
  Loader: TEventsLoader;
  Device: TDevice;
  I, J, Cnt: integer;
  StartTime: TDateTime;
begin
  FreeOnTerminate := True;
  Loader := TEventsLoader.Create(Settings.GetInstance.DBFileName);
  SetLength(FStatuses, Loader.DeviceCount);
  try
    // ����������� ��������� ������� ����������
    for I := 0 to High(FStatuses) do begin
      Device := Loader.Device[I];
      FStatuses[I].id := Device.id;
      FStatuses[I].Name := UTF8Decode(Device.Name) + '(' + Device.IP + ':'
        + IntToStr(Device.Port) + ')';
      // �������� ����������
      FStatuses[I].Enabled := Loader.CheckConnection(I);
      // ����� ������� ����� ���������� ���������� � ���-�� ����� �������
      FStatuses[I].LastTimeInBD := FEndTime;
      if FStatuses[I].Enabled then begin
        Cnt := 0;
        for j := 0 to Loader.MinorEventCount - 1 do begin
          // ����������� ����� ���������� ���������� ��� ������� ���� �������.
          StartTime := Loader.LastTimeInDB(I, J);
          if StartTime < FStatuses[I].LastTimeInBD then
            FStatuses[I].LastTimeInBD := StartTime;
          StartTime := IncSecond(StartTime, 1);
          // ����������� ���������� ����� ��������
          Cnt := Cnt + Loader.GetEventsCount(I, Loader.MinorEvent[J],
            StartTime, FEndTime);
        end;
        FStatuses[I].EventsCount := Cnt;
      end;
    end;
    Synchronize(Self.SyncGetData);
    SetLength(FStatuses, 0);
  finally
    Loader.Free;
  end;

end;

end.
