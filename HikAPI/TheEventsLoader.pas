unit TheEventsLoader;

interface

uses
  Classes, SysUtils, DateUtils, APIClient;

const
  apiTime = '/ISAPI/System/time/localTime';
  apiEventNum = '/ISAPI/AccessControl/AcsEventTotalNum?format=json';

type
  TEventDirection = (edIN, edOUT);

  TDevice = record
    Name: string[250];
    IP: string[20];
    Port: integer;
    Direction: TEventDirection;
  end;

  TMinorEvents = array of Integer;

  TEventsLoader = class (TObject)
  private
    FDevices: TList;
    FAPIClient: IAPIClient;
    FMinorEvents: TMinorEvents;
    FMajor: integer;
    FUTC: string;
    function GetDevice(Ind: integer): TDevice;
    function GetDeviceCount: integer;
    function GetMinorEventsCount: integer;
    function GetMinorEvent(Ind: integer): integer;

    procedure SetLoginPasswordFromDB;

  public
    constructor Create(APIClientClass: TClass);
    destructor Destroy; override;
    procedure AddDevice(Name, IP: string; Port: integer;
      Direction: TEventDirection); overload;
    procedure AddDevice(Device: TDevice); overload;
    property DeviceCount: integer read GetDeviceCount;
    property Device[Ind: integer]: TDevice read GetDevice;
    procedure AddMinorEvent(Minor: integer);
    property MinorEventCount: integer read GetMinorEventsCount;
    property MinorEvent[Ind: integer]: integer read GetMinorEvent;
    function LastTimeInDB: TDateTime;
    function GetDeviceTime(DeviceInd: integer): TDateTime;
    function CheckConnection(DeviceInd: integer): boolean;
    function EventsCount(Minor: TMinorEvents;
      StartTime, EndTime: TDateTime): integer;
  end;

implementation

uses JSON, Dialogs, Clipbrd;

constructor TEventsLoader.Create(APIClientClass: TClass);
begin
  inherited Create;
  FDevices := TList.Create;
  FMajor := 5;
  FUTC := '+03:00';
  if (APIClientClass = THTTPClient) then FAPIClient := THTTPClient.Create;
  if (APIClientClass = TTCPClient) then FAPIClient := TTCPClient.Create;
  if Assigned(FAPIClient) then SetLoginPasswordFromDB;
end;

destructor TEventsLoader.Destroy;
begin
  FDevices.Free;
  FreeAndNil(FAPIClient);
  inherited Destroy;
end;

{}

function TEventsLoader.GetDeviceCount: integer;
begin
  Result := FDevices.Count;
end;

function TEventsLoader.GetDevice(Ind: Integer): TDevice;
var
  PDevice: ^TDevice;
begin
  PDevice := nil;
  if Ind < FDevices.Count then PDevice := FDevices.Items[Ind];
  Result := PDevice^;
end;

procedure TEventsLoader.AddDevice(Name, IP: string; Port: integer;
      Direction: TEventDirection);
var
  PDevice: ^TDevice;
begin
  new(PDevice);
  PDevice^.Name := Name;
  PDevice^.IP := IP;
  PDevice^.Port := Port;
  PDevice^.Direction := Direction;
  FDevices.Add(PDevice);
end;

procedure TEventsLoader.AddDevice(Device: TDevice);
var
  PDevice: ^TDevice;
begin
  new(PDevice);
  PDevice^ := Device;
  FDevices.Add(PDevice);
end;

function TEventsLoader.GetMinorEventsCount: integer;
begin
  Result := High(Self.FMinorEvents) + 1;
end;

procedure TEventsLoader.AddMinorEvent(Minor: integer);
begin
  SetLength(FMinorEvents, High(FMinorEvents) + 2);
  FMinorEvents[High(FMinorEvents)] := Minor;
end;

function TEventsLoader.GetMinorEvent(Ind: integer): integer;
begin
  if Ind > High(FMinorEvents) then Result := 0
    else Result := FMinorEvents[Ind];
end;

{}

function TEventsLoader.LastTimeInDB: TDateTime;
begin
  Result := StartOfAYear(2025);;
end;

procedure TEventsLoader.SetLoginPasswordFromDB;
begin
  FAPIClient.SetLoginPassword('admin', 'shrtyjk8006');
end;

{}

function TEventsLoader.GetDeviceTime(DeviceInd: integer): TDateTime;
var
  PDevice: ^TDevice;
  Response: TStringList;
begin
  PDevice := FDevices.Items[DeviceInd];
  FAPIClient.SetHostPort(PDevice^.IP, PDevice^.Port);
  Response := TStringList.Create;
  Result := 0;
  try
    if (FAPIClient.Get(apiTime, Response) = 200) then
      Result := ISO8601ToDate(Response.Text) ;
  finally
    Response.Free;
  end;
end;

function TEventsLoader.CheckConnection(DeviceInd: integer): boolean;
var
  PDevice: ^TDevice;
  Response: TStringList;
begin
  PDevice := FDevices.Items[DeviceInd];
  FAPIClient.SetHostPort(PDevice^.IP, PDevice^.Port);
  Response := TStringList.Create;
  try
    Result := (FAPIClient.Get(apiTime, Response) = 200);
  finally
    Response.Free;
  end;
end;

function TEventsLoader.EventsCount(Minor: TMinorEvents;
  StartTime, EndTime: TDateTime): integer;
var
  DevInd, MinorInd, Res: integer;
  PDevice: ^TDevice;
  Response: TStringList;
  StartTimeStr, EndTimeStr: string;
  JsonRoot, JsonInfo: TJsonObject;
  JsonResp: TJsonArray;
begin
  Result := 0;
  // Определяем переменные для установки диапазона выборки
  StartTimeStr := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss' + FUTC, StartTime);
  EndTimeStr := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss' + FUTC, EndTime);
  // Перебираем все устройства и все minor коды
  for DevInd := 0 to FDevices.Count - 1 do begin
    PDevice := FDevices.Items[DevInd];
    FAPIClient.SetHostPort(PDevice^.IP, PDevice^.Port);
    for MinorInd := 0 to High(Minor) do begin
      // Подготавливаем тело запроса.
      JsonInfo := TJsonObject.Create(nil);
      JsonInfo.Add('major', FMajor);
      JsonInfo.Add('minor', Minor[MinorInd]);
      JsonInfo.Add('startTime', StartTimeStr);
      JsonInfo.Add('endTime', EndTimeStr);
      JsonRoot := TJsonObject.Create(nil);
      JsonRoot.Add('AcsEventTotalNumCond', JsonInfo);
      // Выполняем запрос
      Response := TStringList.Create;
      try
        Res := FAPIClient.Post(apiEventNum, JsonRoot.JsonText, Response);
        if Res = 200 then begin
          JsonResp := JSON.ParseJSON(PAnsiChar(Response.Text));
          Result := Result
            + JsonResp.Field['AcsEventTotalNum'].Field['totalNum'].Value;
        end else
          raise Exception.Create(Response.Text);
      finally
        FreeAndNil(JsonRoot);
        FreeAndNil(JsonResp);
        Response.Free;
      end;
    end;
  end;
end;


end.
