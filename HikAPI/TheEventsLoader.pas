unit TheEventsLoader;

interface

uses
  Classes, SysUtils, DateUtils, APIClient, DigestHeader;

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
    Login: string[20];
    Password: string[20];
  end;

  TMinorEvents = array of Integer;

  TEventsLoader = class (TObject)
  private
    FDevices: TList;
    //FAPIClient: IAPIClient;
    FMinorEvents: TMinorEvents;
    FMajor: integer;
    FUTC: string;
    FUseThread: boolean;
    FStopFlag: boolean;
    FPortionSize: integer;
    { Геттеры и сеттеры }
    function GetDevice(Ind: integer): TDevice;
    function GetDeviceCount: integer;
    function GetMinorEventsCount: integer;
    function GetMinorEvent(Ind: integer): integer;
    { Работа с базой данных }
    procedure LoadDeviceFromDB;
    { Работа с HikAPI }
    procedure PrepareAPIClient(Client: THTTPClient; DeviceID: integer);
    function Request(DeviceId: integer; Method: TRequestMethod; Url, Body: string;
      var Response: TStringList): integer;
    function ISOTimeStrToDateTime(DateTimeStr: string): TDateTime;
    function GetEventsPortion(DeviceInd, Position, Minor: integer;
      StartTime, EndTime: TDateTime): integer;
  public
    constructor Create;
    destructor Destroy; override;
    { Свойства и настройки }
    procedure AddDevice(Device: TDevice);
    property DeviceCount: integer read GetDeviceCount;
    property Device[Ind: integer]: TDevice read GetDevice;
    procedure AddMinorEvent(Minor: integer);
    property MinorEventCount: integer read GetMinorEventsCount;
    property MinorEvent[Ind: integer]: integer read GetMinorEvent;
    { Работа с базой данных }
    function LastTimeInDB: TDateTime;
    { Работа с HikAPI }
    property UseThread: boolean read FUseThread write FUseThread;
    function GetDeviceTime(DeviceInd: integer): TDateTime;
    function CheckConnection(DeviceInd: integer): boolean;
    function GetEventsCount(DeviceInd, Minor: integer;
      StartTime, EndTime: TDateTime): integer;
    function GetEvents(Minor: TMinorEvents;
      StartTime, EndTime: TDateTime): integer;
  end;

implementation

uses
  JSON, Dialogs, Clipbrd, TheAPIExecutor, Windows, Forms, APIProcessWin;

constructor TEventsLoader.Create;
begin
  inherited Create;
  FDevices := TList.Create;
  FMajor := 5;
  FUTC := '+03:00';
  FUseThread := False;
  FStopFlag := false;
  FPortionSize := 30;
  LoadDeviceFromDB;
end;

destructor TEventsLoader.Destroy;
begin
  FDevices.Free;
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

{ Работа с базой данных. }

function TEventsLoader.LastTimeInDB: TDateTime;
begin
  Result := StartOfAYear(2025);;
end;

procedure TEventsLoader.LoadDeviceFromDB;
var
  PDevice: ^TDevice;
begin
  Self.FDevices.Clear;
  new(PDevice);
  PDevice^.Name := 'First';
  PDevice^.IP := '192.168.24.113';
  PDevice^.Port := 80;
  PDevice^.Direction := edIN;
  PDevice^.Login := 'admin';
  PDevice^.Password := 'shrtyjk8006';
  Fdevices.Add(PDevice);
end;

{ Работа с HikAPI. }

procedure TEventsLoader.PrepareAPIClient(Client: THTTPClient; DeviceID: integer);
var
  PDevice: ^TDevice;
begin
  PDevice := FDevices.Items[DeviceId];
  Client.SetHostPort(PDevice^.IP, PDevice^.Port);
  Client.SetLoginPassword(PDevice^.Login, PDevice^.Password);
end;

function TEventsLoader.Request(DeviceId: integer; Method: TRequestMethod;
  Url, Body: string; var Response: TStringList): integer;

  function IsThreadRunning(AThread: TThread): Boolean;
  begin
    if (AThread = nil) or (AThread.Handle = 0) then Result := False
      else Result := WaitForSingleObject(AThread.Handle, 0) = WAIT_TIMEOUT;
  end;

var
  APIExecutor: TAPIExecutor;
  HTTPClient: THTTPClient;
begin
  if Self.FUseThread then begin
    APIExecutor := TAPIExecutor.Create;
    PrepareAPIClient(APIExecutor.HTTPClient, DeviceId);
    APIExecutor.PrepareRequest(Method, Url, Body);
    APIExecutor.Resume;
    while IsThreadRunning(APIExecutor) do begin
      Application.ProcessMessages;
      if (FStopFlag) and (APIExecutor.HTTPClient.IdHTTP.Connected) then
            APIExecutor.HTTPClient.IdHTTP.Disconnect        
    end;
    Result := APIExecutor.Result;
    Response.Text := APIExecutor.Response;
    APIExecutor.Free;
  end else begin
    HTTPClient := THTTPClient.Create;;
    PrepareAPIClient(HTTPClient, DeviceId);
    Result := HTTPClient.Request(Method, Url, Body, Response);
    HTTPClient.Free;
  end;
end;

function TEventsLoader.ISOTimeStrToDateTime(DateTimeStr: string): TDateTime;
var
  CleanStr, UTCStr: string;
  UTCMinute: integer;
  DateTimeValue: TDateTime;
  FormatSettings: TFormatSettings;
begin
  // Выделям часвой пояс и преобразуем в минуты для смещения
  UTCStr := Copy(DateTimeStr, 20, MaxInt);
  UTCMinute := StrToIntDef(Copy(UTCStr, 2, 2), 0) * 60
    + StrToIntDef(Copy(UTCStr, 5, 2), 0);
  if UTCStr[1] = '-' then UTCMinute := -UTCMinute;

  // Выделяем дату и время, убираем символ 'T'
  CleanStr := StringReplace(DateTimeStr, 'T', ' ', [rfReplaceAll]); // Удаляем 'T'
  CleanStr := Copy(CleanStr, 1, 19);

  // Настраиваем формат даты и времени
  FormatSettings.DateSeparator := '-';
  FormatSettings.ShortDateFormat := 'yyyy-mm-dd'; // Формат даты
  FormatSettings.TimeSeparator := ':';
  FormatSettings.LongTimeFormat := 'hh:nn:ss';    // Формат времени

  // Преобразуем строку в TDateTime
  DateTimeValue := StrToDateTime(CleanStr, FormatSettings);

  //Добавялем часовой пояс
  IncMinute(DateTimeValue, UTCMinute);

  Result := DateTimeValue;
end;

function TEventsLoader.GetDeviceTime(DeviceInd: integer): TDateTime;
var
  Response: TStringList;
begin
  Response := TStringList.Create;
  Result := 0;
  try
    if (Request(DeviceInd, rmGET, apiTime, '', Response) = 200) then
      Result := ISOTimeStrToDateTime(Response.Text) ;  
  finally
    Response.Free;
  end;
end;

function TEventsLoader.CheckConnection(DeviceInd: integer): boolean;
var
  Response: TStringList;
begin
  Response := TStringList.Create;
  try
    Result := (Request(DeviceInd, rmGET, apiTime, '', Response) = 200);
  finally
    Response.Free;
  end;
end;

function TEventsLoader.GetEventsCount(DeviceInd, Minor: integer;
  StartTime, EndTime: TDateTime): integer;
var
  Res: integer;
  Response: TStringList;
  StartTimeStr, EndTimeStr: string;
  JsonRoot, JsonInfo: TJsonObject;
  JsonResp: TJsonArray;
begin
  Result := 0;

  // Определяем переменные для установки диапазона выборки
  StartTimeStr := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss' + FUTC, StartTime);
  EndTimeStr := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss' + FUTC, EndTime);

  // Подготавливаем тело запроса.
  JsonInfo := TJsonObject.Create(nil);
  JsonInfo.Add('major', FMajor);
  JsonInfo.Add('minor', Minor);
  JsonInfo.Add('startTime', StartTimeStr);
  JsonInfo.Add('endTime', EndTimeStr);
  JsonRoot := TJsonObject.Create(nil);
  JsonRoot.Add('AcsEventTotalNumCond', JsonInfo);
      
  // Выполняем запрос
  Response := TStringList.Create;
  try
    Res := Request(DeviceInd, rmPost, apiEventNum, JsonRoot.JsonText, Response);
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

function TEventsLoader.GetEventsPortion(DeviceInd, Position, Minor: integer;
  StartTime, EndTime: TDateTime): integer;
var
  Res: integer;
  Response: TStringList;
  StartTimeStr, EndTimeStr: string;
  JsonRoot, JsonInfo: TJsonObject;
  JsonResp: TJsonArray;
begin
  Result := 0;

  // Определяем переменные для установки диапазона выборки
  StartTimeStr := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss' + FUTC, StartTime);
  EndTimeStr := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss' + FUTC, EndTime);

  // Подготавливаем тело запроса.
  JsonInfo := TJsonObject.Create(nil);
  JsonInfo.Add('searchID', '1');
  JsonInfo.Add('searchResultPosition', Position);
  JsonInfo.Add('maxResults', FPortionSize);
  JsonInfo.Add('major', FMajor);
  JsonInfo.Add('minor', Minor);
  JsonInfo.Add('startTime', StartTimeStr);
  JsonInfo.Add('endTime', EndTimeStr);
  JsonRoot := TJsonObject.Create(nil);
  JsonRoot.Add('AcsEventTotalNumCond', JsonInfo);
      
  // Выполняем запрос
  Response := TStringList.Create;
  try
    Res := Request(DeviceInd, rmPost, apiEventNum, JsonRoot.JsonText, Response);
    if Res = 200 then begin

      {}

    end else
      raise Exception.Create(Response.Text);
  finally
    FreeAndNil(JsonRoot);
    FreeAndNil(JsonResp);
    Response.Free;
  end;
end;

function TEventsLoader.GetEvents(Minor: TMinorEvents;
  StartTime, EndTime: TDateTime): integer;
begin
  Result := 0;
end;





end.
