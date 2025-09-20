unit TheSettings;

interface

uses SysUtils, Classes;

type
  TSettingsSingleton = class(TObject)
  private
    FDBFileName: string;
    FCurrentPassword: string;
    FAccessLevel: integer;
    FMaxShiftHours: integer;
    FMinWorkMinutes: integer;
    procedure WriteString(Stream: TStream; const Value: string);
    function ReadString(Stream: TStream): string;
    procedure WriteInteger(Stream: TStream; const Value: Integer);
    function ReadInteger(Stream: TStream): Integer;
    procedure SetAccessLevel;
    procedure SetCurrentPassword(Value: string);
    class var FInstance: TSettingsSingleton;
    const SETTINGS_FILE = 'settings.dat';
  public
    class function GetInstance(): TSettingsSingleton;
    class procedure DestroyInstance;
    procedure SaveSettings;
    function LoadSettings: boolean;
    property DBFileName: string read FDBFileName write FDBFileName;
    property CurrentPassword: string read FCurrentPassword
      write SetCurrentPassword;
    property AccessLevel: integer read FAccessLevel;
    property MaxShiftHours: integer read FMaxShiftHours;
    property MinWorkMinutes: integer read FMinWorkMinutes;
  end;

  TSettings = class of TSettingsSingleton;

var
  Settings: TSettings;

implementation

uses SQLiteTable3, Dialogs;

class function TSettingsSingleton.GetInstance: TSettingsSingleton;
begin
  if not Assigned(FInstance) then begin
    FInstance := TSettingsSingleton.Create;
    if not FInstance.LoadSettings then
      FInstance.FDBFileName := 'hik_events.db';
    FInstance.SetAccessLevel;
    FInstance.FMaxShiftHours := 16;
    FInstance.FMinWorkMinutes := Trunc(60 * 3.5);
  end;
  Result := FInstance;
end;

class procedure TSettingsSingleton.DestroyInstance;
begin
  if Assigned(FInstance) then
  begin
    FInstance.SaveSettings;
    FInstance.Free;
    FInstance := nil;
  end;
end;

procedure TSettingsSingleton.SetCurrentPassword(Value: string);
begin
  Self.FCurrentPassword := Value;
  Self.SetAccessLevel;
end;

procedure TSettingsSingleton.SetAccessLevel;
var
  DB: TSQLiteDatabase;
  Table: TSQLiteUniTable;
begin
  FAccessLevel := 0;
  if (Length(FCurrentPassword) = 0) or (not FileExists(FDBFileName)) then Exit;
  DB := TSQLiteDatabase.Create(FDBFileName);
  if not DB.TableExists('access') then Exit;
  Table := DB.GetUniTable('SELECT level FROM access WHERE password="'
    + Self.FCurrentPassword + '"');
  try
    while not Table.EOF do begin
      Self.FAccessLevel := Table.FieldAsInteger(0);
      Table.Next;
    end;
  finally
    Table.Free;
    DB.Free;
  end;
end;

procedure TSettingsSingleton.WriteString(Stream: TStream; const Value: string);
var
  Len: Integer;
begin
  Len := Length(Value);
  Stream.WriteBuffer(Len, SizeOf(Len));
  if Len > 0 then
    Stream.WriteBuffer(Value[1], Len * SizeOf(Char));
end;

function TSettingsSingleton.ReadString(Stream: TStream): string;
var
  Len: Integer;
begin
  Stream.ReadBuffer(Len, SizeOf(Len));
  SetLength(Result, Len);
  if Len > 0 then
    Stream.ReadBuffer(Result[1], Len * SizeOf(Char));
end;

procedure TSettingsSingleton.WriteInteger(Stream: TStream; const Value: Integer);
begin
  Stream.WriteBuffer(Value, SizeOf(Integer));
end;

function TSettingsSingleton.ReadInteger(Stream: TStream): Integer;
var
  BytesRead: Integer;
begin
  BytesRead := Stream.Read(Result, SizeOf(Integer));
  if BytesRead <> SizeOf(Integer) then
    raise EReadError.Create('Не удалось прочитать целое число');
end;

procedure TSettingsSingleton.SaveSettings;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(SETTINGS_FILE, fmCreate);
  try
    WriteString(Stream, FDBFileName);
    WriteString(Stream, FCurrentPassword);
    WriteInteger(Stream, FMaxShiftHours);
    WriteInteger(Stream, FMinWorkMinutes);
  finally
    Stream.Free;
  end;
end;

function TSettingsSingleton.LoadSettings: boolean;
var
  Stream: TFileStream;
begin
  Result := False;
  if not FileExists(SETTINGS_FILE) then Exit;
  Stream := TFileStream.Create(SETTINGS_FILE, fmOpenRead);
  try
    FDBFileName := ReadString(Stream);
    FCurrentPassword := ReadString(Stream);
    FMaxShiftHours := ReadInteger(Stream);
    FMinWorkMinutes := ReadInteger(Stream);
    Result := FileExists(Self.FDBFileName);
  finally
    Stream.Free;
  end;
end;

end.
