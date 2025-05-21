unit TheSchedule;

interface

uses TheShift, SysUtils, DateUtils, Contnrs, Controls, Classes, SQLiteTable3;

type
  TScheduleType = (stWeek, stPeriod);

  TSchedule = class(TOBject)
  private
    FGUID: TGUID;
    FTitle: string;
    FType: TScheduleType;
    FDays: array of TShiftList;
    FStartDate: TDate;
    function GetDayCount: integer;
    procedure SetDayCount(Cnt: integer);
    function GetDay(Ind: integer): TShiftList;
  public
    constructor Create;
    destructor Destroy; override;
    property GUID: TGUID read FGUID;
    property Title: string read FTitle write Ftitle;
    property DayCount: integer read GetDayCount write SetDayCount;
    property ShedType: TScheduleType read FType write FType;
    property Day[Ind: integer]: TShiftList read GetDay;
    property StartDate: TDate read FStartDate write FStartDate;
    property ScheduleType: TScheduleType read FType write FType;
  end;

  TScheduleList = class(TObjectList)
  private
    function LoadScheduleDay(DB: TSQLiteDatabase; Schedule: TSchedule;
      ShiftList: TShiftList): boolean;
  protected
    function GetIndexByGUID(GUID: TGUID): integer;
    function GetItem(Index: Integer): TSchedule; overload;
    procedure SetItem(Index: Integer; AObject: TSchedule); overload;
    function GetItem(GUID: TGUID): TSchedule; overload;
    procedure SetItem(GUID: TGUID; AObject: TSchedule);  overload;
  public
    constructor Create(CanDestroyItem: boolean);
    destructor Destroy; override;
    property Items[GUID: TGUID]: TSchedule read GetItem write SetItem; default;
    property Items[Index: Integer]: TSchedule read GetItem write SetItem; default;
    function First: TSchedule;
    function Last: TSchedule;
    function Extract(Item: TObject): TSchedule;
    function Add(Schedule: TSchedule): Integer;
    procedure Insert(Index: Integer; Schedule: TSchedule);
    function LoadFromBD(DBFileName: string; ShiftList: TShiftList): boolean;
    function GetGUIDS(Text: string; GUIDSList: TStringList): boolean;
    procedure SortByTitle;
  end;


implementation




{ TScheduleTemplate }

constructor TSchedule.Create;
begin
  inherited Create;
  SetLength(FDays, 0);
end;

destructor TSchedule.Destroy;
begin
  SetDayCount(0);
  inherited Destroy;
end;

function TSchedule.GetDayCount: integer;
begin
  Result := High(FDays) + 1;
end;

procedure TSchedule.SetDayCount(Cnt: integer);
var
  I, LastId: integer;
begin
  if Cnt < (High(Self.FDays) + 1) then begin
    for I := Cnt to High(FDays) do FDays[I].Free;
    SetLength(FDays, 0);
  end;
  if Cnt > (High(Self.FDays) + 1) then begin
    LastId := High(FDays) + 1;
    SetLength(FDays, Cnt);
    for I := LastId to Cnt - 1 do
      FDays[I] := TShiftList.Create(False);
  end;
end;

function TSchedule.GetDay(Ind: integer): TShiftList;
begin
  if (Ind >= 0) and (Ind <= High(FDays)) then Result := FDays[Ind]
    else Result := nil;
end;

{ TScheduleList }

constructor TScheduleList.Create(CanDestroyItem: boolean);
begin
  inherited Create(CanDestroyItem);
end;

destructor TScheduleList.Destroy;
begin
  inherited Destroy;
end;

function TScheduleList.GetIndexByGUID(GUID: TGUID): integer;
var
  i: integer;
begin
  Result := -1;
  i := 0;
  while (i < self.Count) and
     not IsEqualGUID(TSchedule(inherited Items[i]).GUID, GUID) do inc(i);
  if (i < self.Count) and
    IsEqualGUID(TSchedule(inherited Items[i]).GUID, GUID) then
      Result := i;
end;

function TScheduleList.GetItem(Index: Integer): TSchedule;
begin
  Result := TSchedule(inherited GetItem(Index));
end;

procedure TScheduleList.SetItem(Index: Integer; AObject: TSchedule);
begin
  inherited SetITem(Index, AObject);
end;

function TScheduleList.GetItem(GUID: TGUID): TSchedule;
var
  index: integer;
begin
  index := GetIndexByGUID(GUID);
  if index >= 0  then Result := TSchedule(inherited GetItem(index))
    else Result := nil;
end;

procedure TScheduleList.SetItem(GUID: TGUID; AObject: TSchedule);
var
  index: integer;
begin
  index := GetIndexByGUID(GUID);
  if index >= 0  then inherited SetITem(index, AObject)
    else raise EAccessViolation.Create('Item GUID out of list !');
end;

function TScheduleList.First: TSchedule;
begin
  Result := TSchedule(inherited First);
end;

function TScheduleList.Last: TSchedule;
begin
  Result := TSchedule(inherited Last);
end;

function TScheduleList.Extract(Item: TObject): TSchedule;
begin
  Result := TSchedule(inherited Extract(Item));
end;

function TScheduleList.Add(Schedule: TSchedule): integer;
begin
  if GetIndexByGUID(Schedule.GUID) < 0 then Result := inherited Add(Schedule)
    else raise Exception.Create('Schedule GUID duplicate !');
end;

procedure TScheduleList.Insert(Index: Integer; Schedule: TSchedule);
begin
  if GetIndexByGUID(Schedule.GUID) < 0 then inherited Insert(Index, Schedule)
    else raise Exception.Create('Schedule GUID duplicate !');
end;

function TScheduleList.LoadScheduleDay(DB: TSQLiteDatabase;
  Schedule: TSchedule; ShiftList: TShiftList): boolean;
var
  Table: TSQLiteUniTable;
  SQL, GUIDText: string;
  GUIDSList: TStringList;
  I, Num: integer;
  Shift: TShift;
begin
  Result := False;
  SQL := 'SELECT day_num, shift_GUIDs FROM schedule_days WHERE schedule_GUID="'
    + GUIDToString(Schedule.FGUID) + '" ORDER BY day_num';
  GUIDSList := TStringList.Create;
  Table := DB.GetUniTable(SQL);
  try
    while not Table.EOF do begin
      Num := Table.FieldAsInteger(0);
      GUIDText := Table.FieldAsString(1);
      if Self.GetGUIDS(GUIDText, GUIDSList) then
        for i := 0 to GUIDSList.Count - 1 do begin
          Shift := ShiftList.Items[StringToGUID(GUIDSList[i])];
          if Shift <> nil then Schedule.FDays[Num].Add(Shift);
        end;
      Schedule.FDays[Num].SortByStartTime;
      Table.Next;
    end;
    Result := True;
  finally
    Table.Free;
    GUIDSList.Free;
  end;
end;

function TScheduleList.LoadFromBD(DBFileName: string; ShiftList: TShiftList): boolean;
var
  DB: TSQLiteDatabase;
  Table: TSQLiteUniTable;
  SQL: string;
  Schedule: TSchedule;
  DayCount: integer;
begin
  Result := False;
  Self.Clear;
  if not FileExists(DBFileName) then Exit;
  DB := TSQLiteDatabase.Create(DBFileName);
  if not DB.TableExists('schedules') then Exit;
  SQL := 'SELECT * FROM Schedules';
  Table := DB.GetUniTable(SQL);
  try
    while not Table.EOF do begin
      Schedule := TSchedule.Create;
      Schedule.FGUID := StringToGUID(Table.FieldAsString(0));
      Schedule.FTitle := UTF8Decode(Table.FieldAsString(1));
      Schedule.FStartDate := Table.FieldAsDouble(2);
      case Table.FieldAsInteger(3) of
        1: Schedule.FType := stWeek;
        2: Schedule.FType := stPeriod
      end;
      DayCount := Table.FieldAsInteger(4);
      Schedule.SetDayCount(DayCount);
      if Assigned(ShiftList) and (DayCount > 0) then
        if not Self.LoadScheduleDay(DB, Schedule, ShiftList) then
          raise Exception.Create('Error load Schedule days for "'
            + Schedule.Title + '" !');
      Self.Add(Schedule);
      Table.Next;
    end;
    Result := (Self.Count > 0);
  finally
    Table.Free;
    DB.Free;
  end;
end;

function TScheduleList.GetGUIDS(Text: string; GUIDSList: TStringList): boolean;
var
  i: Integer;
  GuidStr: string;
begin
  Result := False;
  if not Assigned(GUIDSList) then Exit;
  GUIDSList.Clear;
  repeat
    i := Pos('|', Text);
    if i = 0 then GuidStr := Text
      else begin
        GuidStr := Copy(Text, 1, i - 1);
        Text := Copy(Text, i + 1, MaxInt);
      end;
    if Length(GuidStr) > 0 then GUIDSList.Add(GuidStr);
  until (i = 0) or (Length(Text) = 0);
  Result := (GUIDSList.Count > 0);
end;

procedure TScheduleList.SortByTitle;

  function CompareTitle(Item1, Item2: Pointer): integer;
  begin
    Result := CompareStr(TSchedule(Item1).FTitle, TSchedule(Item2).FTitle);
  end;

begin
  Self.Sort(@CompareTitle);
end;



end.
