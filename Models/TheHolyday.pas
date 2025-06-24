unit TheHolyday;

interface

uses
  SysUtils, DateUtils, Contnrs, Controls, SQLiteTable3,
  Classes, TheSchedule;

type
  THolyday = class(TObject)
  private
    FGUID: TGUID;
    FTitle: string;
    FStartTime: TDateTime;
    FEndTime: TDateTime;
    FSchedule: TSchedule;
  public
    constructor Create;
    destructor Destroy; override;
    property GUID: TGUID read FGUID;
    property Title: string read FTitle write FTitle;
    property StartTime: TDateTime read FStartTime write FStartTime;
    property EndTime: TDateTime read FEndTime write FEndTime;
    property Schedule: TSchedule read FSchedule write FSchedule;
  end;

  THolydayList = class(TObjectList)
  protected
    function GetIndexByGUID(GUID: TGUID): integer;
    function GetIndexByDate(Date: TDate): integer;
    function GetItem(Index: Integer): THolyday; overload;
    procedure SetItem(Index: Integer; AObject: THolyday); overload;
    function GetItem(GUID: TGUID): THolyday; overload;
    procedure SetItem(GUID: TGUID; AObject: THolyday);  overload;
    function GetItem(Date: TDate): THolyday; overload;
    procedure SetItem(Date: TDate; AObject: THolyday);  overload;
  public
    constructor Create(CanDestroyItem: boolean);
    destructor Destroy; override;
    property Items[GUID: TGUID]: THolyday read GetItem write SetItem; default;
    property Items[Index: Integer]: THolyday read GetItem write SetItem; default;
    property Items[Date: TDate]: THolyday read GetItem write SetItem; default;
    function First: THolyday;
    function Last: THolyday;
    function Extract(Item: TObject): THolyday;
    function Add(Holyday: THolyday): Integer;
    procedure Insert(Index: Integer; Holyday: THolyday);
    function LoadFromBD(DBFileName: string; ScheduleList: TScheduleList): boolean;
    procedure SortByDateDesc;
    function SaveToBD(DBFileName: string): boolean;
  end;

implementation


{ THolyday }

constructor THolyday.Create;
begin
  inherited Create;
  CreateGUID(FGUID);
  FSchedule := nil;
  FStartTime := StartOfTheDay(now);
  FEndTime := EndOfTheDay(now);
end;

destructor THolyday.Destroy;
begin
  inherited Destroy;
end;

{ THolydayList }

constructor THolydayList.Create(CanDestroyItem: boolean);
begin
  inherited Create(CanDestroyItem);
end;

destructor THolydayList.Destroy;
begin
  inherited Destroy;
end;

function THolydayList.GetIndexByGUID(GUID: TGUID): integer;
var
  i: integer;
begin
  Result := -1;
  i := 0;
  while (i < self.Count) and
     not IsEqualGUID(THolyday(inherited Items[i]).GUID, GUID) do inc(i);
  if (i < self.Count) and
    IsEqualGUID(THolyday(inherited Items[i]).GUID, GUID) then
      Result := i;
end;

function THolydayList.GetItem(Index: Integer): THolyday;
begin
  Result := THolyday(inherited GetItem(Index));
end;

procedure THolydayList.SetItem(Index: Integer; AObject: THolyday);
begin
  inherited SetITem(Index, AObject);
end;

function THolydayList.GetItem(GUID: TGUID): THolyday;
var
  index: integer;
begin
  index := GetIndexByGUID(GUID);
  if index >= 0  then Result := THolyday(inherited GetItem(index))
    else Result := nil;
end;

procedure THolydayList.SetItem(GUID: TGUID; AObject: THolyday);
var
  index: integer;
begin
  index := GetIndexByGUID(GUID);
  if index >= 0  then inherited SetITem(index, AObject)
    else raise EAccessViolation.Create('Item GUID out of list !');
end;

function THolydayList.GetIndexByDate(Date: TDate): integer;
var
  i: integer;
begin
  Result := -1;
  i := 0;
  while (i < self.Count) and
     (DaysBetween(DateOf(THolyday(inherited Items[i]).FStartTime), Date) <> 0) do inc(i);
  if (i < self.Count) and
    (DaysBetween(DateOf(THolyday(inherited Items[i]).FStartTime), Date) = 0) then
      Result := i;
end;

function THolydayList.GetItem(Date: TDate): THolyday;
var
  index: integer;
begin
  index := GetIndexByDate(Date);
  if index >= 0  then Result := THolyday(inherited GetItem(index))
    else Result := nil;
end;

procedure THolydayList.SetItem(Date: TDate; AObject: THolyday);
var
  index: integer;
begin
  index := GetIndexByDate(Date);
  if index >= 0  then inherited SetITem(index, AObject)
    else raise EAccessViolation.Create('Item Date out of list !');
end;

function THolydayList.First: THolyday;
begin
  Result := THolyday(inherited First);
end;

function THolydayList.Last: THolyday;
begin
  Result := THolyday(inherited Last);
end;

function THolydayList.Extract(Item: TObject): THolyday;
begin
  Result := THolyday(inherited Extract(Item));
end;

function THolydayList.Add(Holyday: THolyday): integer;
begin
  if GetIndexByGUID(Holyday.GUID) < 0 then Result := inherited Add(Holyday)
    else raise Exception.Create('Holyday GUID duplicate !');
end;

procedure THolydayList.Insert(Index: Integer; Holyday: THolyday);
begin
  if GetIndexByGUID(Holyday.GUID) < 0 then inherited Insert(Index, Holyday)
    else raise Exception.Create('Holyday GUID duplicate !');
end;

function THolydayList.LoadFromBD(DBFileName: string; ScheduleList: TScheduleList): boolean;
var
  DB: TSQLiteDatabase;
  Table: TSQLiteUniTable;
  SQL, GUIDText: string;
  Holyday: THolyday;
begin
  Result := False;
  Self.Clear;
  if not FileExists(DBFileName) then Exit;
  DB := TSQLiteDatabase.Create(DBFileName);
  if not DB.TableExists('holydays') then Exit;
  SQL := 'SELECT * FROM holydays';
  Table := nil;
  try
    Table := DB.GetUniTable(SQL);
    while not Table.EOF do begin
      Holyday := THolyday.Create;
      Holyday.FGUID := StringToGUID(Table.FieldAsString(0));
      Holyday.FTitle := UTF8Decode(Table.FieldAsString(1));
      Holyday.FStartTime := Table.FieldAsDouble(2);
      Holyday.FEndTime := Table.FieldAsDouble(3);
      GUIDText := Table.FieldAsString(4);
      if Length(GUIDText) = 0 then Holyday.FSchedule := nil
        else Holyday.FSchedule := ScheduleList.Items[StringToGUID(GUIDText)];
      Self.Add(Holyday);
      Table.Next;
    end;
    Result := (Self.Count > 0);
  finally
    Table.Free;
    DB.Free;
  end;
end;

procedure THolydayList.SortByDateDesc;

  function CompareStartTime(Item1, Item2: Pointer): integer;
  begin
    Result := CompareTime(THolyday(Item1).FStartTime,
      THolyday(Item2).FStartTime);
  end;

begin
  Self.Sort(@CompareStartTime);
end;

function THolydayList.SaveToBD(DBFileName: string): boolean;
var
  DB: TSQLiteDatabase;
  SQL, ScheduleGUID: string;
  Holyday: THolyday;
  I: integer;
begin
  Result := False;
  if not FileExists(DBFileName) then Exit;
  DB := TSQLiteDatabase.Create(DBFileName);
  if not DB.TableExists('holydays') then Exit;
  try
    SQL := 'DELETE FROM holydays';
    DB.ExecSQL(SQL);
    DB.BeginTransaction;
    for I := 0 to Self.Count - 1 do begin
      Holyday := Self.Items[i];
      if not Assigned(Holyday.FSchedule) then ScheduleGUID := ''
        else ScheduleGUID := GUIDToString(Holyday.FSchedule.GUID);
      SQL := 'INSERT INTO Holydays (GUID, title, start_time, end_time, '
        +'Schedule_GUID) VALUES (?, ?, ?, ?, ?)';
      DB.ExecSQL(SQL, [GuidToString(Holyday.FGUID), UTF8Encode(Holyday.FTitle),
        Holyday.FStartTime, Holyday.FEndTime, ScheduleGUID]);
    end;
    DB.Commit;
    Result := True;
  finally
    DB.Free
  end;
end;

end.
