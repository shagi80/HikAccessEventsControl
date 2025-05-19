unit TheEventsLoader;

interface

{
  Инкапсуляция процедур и фнукций получения данных по API и сохранения
  результатов в базе данных SQLite.

  Данные об устройствах и кодах, для которых выполняются запросы,
  получаются из соответствующих таблиц базы данных.

  Для выполнения запросов с Digestв авторизацией используется класс
  THTTPClient.
}

uses
  Classes, SysUtils, DateUtils, APIClient, DigestHeader, JSON, ComCtrls;

const
  apiTime = '/ISAPI/System/time/localTime';
  apiEventNum = '/ISAPI/AccessControl/AcsEventTotalNum?format=json';
  apiEvents = '/ISAPI/AccessControl/AcsEvent?format=json';

type
  TEventDirection = (edIN, edOUT);

  TDevice = record
    id: integer;
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
    FMinorEvents: TMinorEvents;
    FMajor: integer;
    FUTC: string;
    FStopFlag: boolean;
    FPortionSize: integer;
    FDBFileName: string;
    { Геттеры и сеттеры }
    function GetDevice(Ind: integer): TDevice;
    function GetDeviceCount: integer;
    function GetMinorEventsCount: integer;
    function GetMinorEvent(Ind: integer): integer;
    { Работа с базой данных }
    procedure LoadDeviceFromDB;
    procedure SaveEventsToDB(JsonInfo: TJsonBase; DeviceId: integer);
    { Работа с HikAPI }
    function Request(DeviceId: integer; Method: TRequestMethod;
      Url, Body: string; var Response: TStringList): integer;
    function DeleteCyrillic(Text: string): string;
    function ISOTimeStrToDateTime(DateTimeStr: string): TDateTime;
  public
    constructor Create(DBFileName: string);
    destructor Destroy; override;
    { Свойства и настройки }
    procedure AddDevice(Device: TDevice);
    property DeviceCount: integer read GetDeviceCount;
    property Device[Ind: integer]: TDevice read GetDevice;
    procedure AddMinorEvent(Minor: integer);
    property MinorEventCount: integer read GetMinorEventsCount;
    property MinorEvent[Ind: integer]: integer read GetMinorEvent;
    { Работа с базой данных }
    function LastTimeInDB(DeviceId: integer; MinorId: integer = -1): TDateTime;
    { Работа с HikAPI }
    property PortionSize: integer read FPortionSize;
    function GetDeviceTime(DeviceInd: integer): TDateTime;
    function CheckConnection(DeviceInd: integer): boolean;
    function GetEventsCount(DeviceInd, Minor: integer;
      StartTime, EndTime: TDateTime): integer;
    function GetEventsPortion(DeviceInd, Position, Minor: integer;
      StartTime, EndTime: TDateTime): integer;
  end;

implementation

uses
  Dialogs, Clipbrd, Windows, Forms, APIProcessWin,
  SQLiteTable3;

constructor TEventsLoader.Create(DBFileName: string);
begin
  inherited Create;
  FDBFileName := DBFileName;
  FDevices := TList.Create;
  FMajor := 5;
  FUTC := '+03:00';
  FStopFlag := false;
  FPortionSize := 30;
  LoadDeviceFromDB;
  AddMinorEvent(1);
  AddMinorEvent(75);
end;

destructor TEventsLoader.Destroy;
begin
  FDevices.Free;
  inherited Destroy;
end;

{ Свойства и настройки }

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

function TEventsLoader.LastTimeInDB(DeviceId: integer;
  MinorId: integer = -1): TDateTime;
var
  DB: TSQLiteDatabase;
  Table: TSQLiteUniTable;
  SQL: string;
  PDevice: ^TDevice;
begin
  Result := StartOfAYear(2025);
  if not FileExists(FDBFileName) then Exit;
  DB := TSQLiteDatabase.Create(FDBFileName);
  Table := nil;
  try
    PDevice := FDevices.Items[DeviceId];
    if DB.TableExists('events') then begin
      SQL := 'SELECT id, time FROM events '
        + 'WHERE device_id=' + IntToStr(PDevice^.id);
      if MinorID >= 0 then
        SQL := SQL + ' AND minor=' + IntToStr(FMinorEvents[MinorId]);
      SQL := SQL + ' ORDER BY time DESC LIMIT 1';
      Table := db.GetUniTable(SQL);
      if not Table.EOF then begin
        Result := Table.FieldAsDouble(1);
      end;
    end;
  finally
    Table.Free;
    DB.Free;
  end;
end;

procedure TEventsLoader.LoadDeviceFromDB;
{ PDevice^.Name := 'First';
  PDevice^.IP := '192.168.24.113';
  PDevice^.Port := 80;
  PDevice^.Direction := edIN;
  PDevice^.Login := 'admin';
  PDevice^.Password := 'shrtyjk8006' } 
var
  PDevice: ^TDevice;
  DB: TSQLiteDatabase;
  Table: TSQLiteUniTable;
begin
  if not FileExists(FDBFileName) then Exit;
  DB := TSQLiteDatabase.Create(FDBFileName);
  Table := nil;
  try
    if DB.TableExists('devices') then begin
      Table := db.GetUniTable('SELECT * FROM devices');
      while not Table.EOF do begin
        new(PDevice);
        PDevice^.id := Table.FieldAsInteger(0);
        PDevice^.Name := Table.FieldAsString(1);
        PDevice^.IP := Table.FieldAsString(2);
        PDevice^.Port := Table.FieldAsInteger(3);
        PDevice^.Direction := TEventDirection(Table.FieldAsInteger(4));
        PDevice^.Login := Table.FieldAsString(5);
        PDevice^.Password := Table.FieldAsString(6);
        FDevices.Add(PDevice);
        Table.Next;
      end;
    end;
  finally
    Table.Free;
    DB.Free;
  end;
end;

procedure TEventsLoader.SaveEventsToDB(JsonInfo: TJsonBase; DeviceId: integer);
var
  DB: TSQLiteDatabase;
  SQL, TimeStr: string;
  I: integer;
  JsonChild: TJsonBase;
  PDevice: ^TDevice;
begin
  if JsonInfo.Count = 0 then Exit;
  DB := TSQLiteDatabase.Create(FDBFileName);
  if not DB.TableExists('events') then begin
    // Создание таблицы
    DB.ExecSQL('CREATE TABLE events ('
      + 'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      + 'major INTEGER, '
      + 'minor INTEGER, '
      + 'time REAL, '
      + 'employeeNoString TEXT (255), '
      + 'serialNo INTEGER, '
      + 'currentVerifyMode TEXT (255), '
      + 'device_id INTEGER, '
      + 'device_direction INTEGER);');
    // Создание индекса для поля startTime
    DB.ExecSQL('CREATE INDEX idx_time ON events(time);');
  end;
  try
    PDevice := FDevices.Items[DeviceId];
    if DB.TableExists('devices') then begin
      DB.BeginTransaction;
      for I := 0 to JsonInfo.Count - 1 do begin
        JsonChild := JsonInfo.Child[I];
        TimeStr := StringReplace(FloatToStr(ISOTimeStrToDateTime(
          JsonChild.Field['time'].Value)), ',', '.', [rfReplaceAll]);
        SQL := 'INSERT INTO events (major, minor, time, employeeNoString,'
          + 'serialNo, currentVerifyMode, device_id, device_direction) VALUES ('
          + IntToStr(JsonChild.Field['major'].Value) + ', '
          + IntToStr(JsonChild.Field['minor'].Value) + ', '
          + TimeStr + ', '
          + '"' + JsonChild.Field['employeeNoString'].Value + '", '
          + IntToStr(JsonChild.Field['serialNo'].Value) + ', '
          + '"' + JsonChild.Field['currentVerifyMode'].Value + '", '
          + IntToStr(PDevice^.id) + ', '
          + IntToStr(Ord(PDevice^.Direction))
          + ')';
        DB.ExecSQL(SQL);
      end;
      DB.Commit;
    end;
  finally
    DB.Free;
  end;
end;

{ Работа с HikAPI. }

function TEventsLoader.Request(DeviceId: integer; Method: TRequestMethod;
  Url, Body: string; var Response: TStringList): integer;

  procedure PrepareAPIClient(Client: THTTPClient; DeviceID: integer);
  var
    PDevice: ^TDevice;
  begin
    PDevice := FDevices.Items[DeviceId];
    Client.SetHostPort(PDevice^.IP, PDevice^.Port);
    Client.SetLoginPassword(PDevice^.Login, PDevice^.Password);
  end;

var
  HTTPClient: THTTPClient;
begin
  Result := 0;
  if FDevices.Count = 0 then Exit;
  HTTPClient := THTTPClient.Create;;
  PrepareAPIClient(HTTPClient, DeviceId);
  Result := HTTPClient.Request(Method, Url, Body, Response);
  HTTPClient.Free;
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

function TEventsLoader.DeleteCyrillic(Text: string): string;
var
  I: integer;
begin
  Result := '';
  for I := 1 to Length(Text) do
    if (Ord(Text[I]) >= 32) and (Ord(Text[I]) <= 126) then
      Result := Result + Text[I];
end;

function TEventsLoader.GetDeviceTime(DeviceInd: integer): TDateTime;
var
  Response: TStringList;
begin
  Response := TStringList.Create;
  Result := 0;
  try
    if (Request(DeviceInd, rmGET, apiTime, '', Response) = 200) then
      Result := ISOTimeStrToDateTime(Response.Text)
    else raise Exception.Create(Response.Text);
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
  JsonRoot, JsonInfo: TJsonObject;
  JsonResp: TJsonArray;
  StartTimeStr, EndTimeStr: string;
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
  JsonRoot.Add('AcsEventCond', JsonInfo);

  // Выполняем запрос
  Response := TStringList.Create;
  try
    Res := Request(DeviceInd, rmPost, apiEvents, JsonRoot.JsonText, Response);
    if Res = 200 then begin
      JsonResp := JSON.ParseJSON(PAnsiChar(DeleteCyrillic(Response.Text)));
      if integer(JsonResp.Field['AcsEvent'].Field['totalMatches'].Value) > 0 then begin
        SaveEventsToDB(JsonResp.Field['AcsEvent'].Field['InfoList'], DeviceInd);
        Result := JsonResp.Field['AcsEvent'].Field['InfoList'].Count;
      end;
    end else
      raise Exception.Create(Response.Text);
  finally
    FreeAndNil(JsonRoot);
    FreeAndNil(JsonResp);
    Response.Free;
  end;
end;


end.
