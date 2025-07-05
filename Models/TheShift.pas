unit TheShift;

interface

uses
  SysUtils, DateUtils, Contnrs, Controls, TheBreaks, SQLiteTable3,
  Classes;

type
  TShift = class(TObject)
  private
    FGUID: TGUID;
    FTitle: string;
    FStartTime: TTime;
    FLength: TTime;
    FInStart: TTime;
    FInFinish: TTime;
    FOutStart: TTime;
    FOutFinish: TTime;
    FLateness: integer;
    FBreaks: TBreakList;
    function GetLengthOfMinutes: integer;
    function GetEndTime: TDateTime;
    function CheckIncorrectIn: boolean;
    function CheckIncorrectOut: boolean;
    function ChekIncorrectLength: boolean;
    function CheckIncorrectBreaks: boolean;
    function CheckIncorrect: boolean;
    function GetScheduleState(MinNum: integer): TScheduleState;
  public
    constructor Create;
    destructor Destroy; override;
    property GUID: TGUID read FGUID;
    property Title: string read FTitle write FTitle;
    property StartTime: TTime read FStartTime write FStartTime;
    property Length: TTime read FLength write FLength;
    property LengthOfMinutes: integer read GetLengthOfMinutes;
    property InStart: TTime read FInStart write FInStart;
    property InFinish: TTime read FInFinish write FInFinish;
    property OutStart: TTime read FOutStart write FOutStart;
    property OutFinish: TTime read FOutFinish write FOutFinish;
    property Lateness: integer read FLateness write FLateness;
    property Breaks: TBreakList read FBreaks;
    procedure AddBreak(Break: TBreak);
    procedure Copy(Shift: TShift);
    property EndTime: TDateTime read GetEndTime;
    property IncorrectIn: boolean read CheckIncorrectIn;
    property IncorrectOut: boolean read CheckIncorrectOut;
    property IncorrectLength: boolean read ChekIncorrectLength;
    property IncorrectBreaks: boolean read CheckIncorrectBreaks;
    property Incorrect: boolean read CheckIncorrect;
    property ScheduleState[MinNum: integer]: TScheduleState read GetScheduleState;
  end;

  TShiftList = class(TObjectList)
  protected
    function GetIndexByGUID(GUID: TGUID): integer;
    function GetItem(Index: Integer): TShift; overload;
    procedure SetItem(Index: Integer; AObject: TShift); overload;
    function GetItem(GUID: TGUID): TShift; overload;
    procedure SetItem(GUID: TGUID; AObject: TShift);  overload;
    function GetGUIDS(Text: string; GUIDSList: TStringList): boolean;
  public
    constructor Create(CanDestroyItem: boolean);
    destructor Destroy; override;
    property Items[GUID: TGUID]: TShift read GetItem write SetItem; default;
    property Items[Index: Integer]: TShift read GetItem write SetItem; default;
    function First: TShift;
    function Last: TShift;
    function Extract(Item: TObject): TShift;
    function Add(Shift: TShift): Integer;
    procedure Insert(Index: Integer; Shift: TShift);
    function LoadFromBD(DBFileName: string; BreakList: TBreakList): boolean;
    procedure SortByTitle;
    procedure SortByStartTime;
    function SaveToBD(DBFileName: string): boolean;
  end;

implementation


{ TShift }

constructor TShift.Create;
begin
  inherited Create;
  CreateGUID(FGUID);
  FBreaks := TBreakList.Create(False);
end;

destructor TShift.Destroy;
begin
  FBreaks.Free;
  inherited Destroy;
end;

function TShift.GetLengthOfMinutes: integer;
begin
  Result := HourOf(FLength) * 60 + MinuteOf(FLength);
end;

procedure TShift.AddBreak(Break: TBreak);
begin
  FBreaks.Add(Break);
  if FBreaks.Count > 1 then FBreaks.SortByStartTime;
end;

procedure TShift.Copy(Shift: TShift);
var
  I: integer;
begin
  Self.FTitle := Shift.Title;
  Self.FStartTime := Shift.FStartTime;
  Self.FLength := Shift.FLength;
  Self.FInStart := Shift.FInStart;
  Self.FInFinish := Shift.FInFinish;
  Self.FOutStart := Shift.FOutStart;
  Self.FOutFinish := Shift.OutFinish;
  Self.FLateness := Shift.FLateness;
  Self.FBreaks.Clear;
  for I := 0 to Shift.FBreaks.Count - 1 do
    Self.FBreaks.Add(Shift.FBreaks.Items[i]);
end;

function TShift.GetEndTime: TDateTime;
begin
  Result := IncMinute(Self.StartTime, Self.LengthOfMinutes);
end;

function TShift.CheckIncorrectIn: boolean;
begin
  Result := not ((MinuteOfTheDay(Self.InStart) > 0)
    and (MinuteOfTheDay(Self.InFinish) > 0)
    and (Self.InFinish > Self.InStart)
    and (MinuteOfTheDay(Self.InFinish) >= MinuteOfTheDay(Self.StartTime))
    and (MinuteOfTheDay(Self.InStart) <= MinuteOfTheDay(Self.StartTime))
    and (MinutesBetween(Self.InStart, Self.InFinish) < Self.GetLengthOfMinutes));
end;

function TShift.CheckIncorrectOut: boolean;
begin
  Result := not ((MinuteOfTheDay(Self.OutStart) > 0)
    and (MinuteOfTheDay(Self.OutFinish) > 0)
    and (Self.OutFinish > Self.OutStart)
    and (MinuteOfTheDay(Self.OutFinish) >= MinuteOfTheDay(Self.GetEndTime))
    and (MinuteOfTheDay(Self.OutStart) <= MinuteOfTheDay(Self.GetEndTime))
    and (MinutesBetween(Self.OutStart, Self.OutFinish)
      < Self.GetLengthOfMinutes));
end;

function TShift.ChekIncorrectLength: boolean;
begin
  Result := not ((Self.GetLengthOfMinutes < 24 * 60)
    and (Self.GetLengthOfMinutes > 0));
end;

function TShift.CheckIncorrectBreaks: boolean;
var
  I: integer;
  Break: TBreak;
begin
  Result := False;
  for I := 0 to Self.FBreaks.Count - 1 do begin
    Break := Self.FBreaks.Items[I];
    Result := not ((Break.StartTime > Self.FStartTime)
      and (Break.EndTime < Self.EndTime));
    if Result then Exit;    
  end;
end;

function TShift.CheckIncorrect: boolean;
begin
  Result := (IncorrectIn or IncorrectOut or IncorrectBreaks
    or IncorrectLength);
end;

function TShift.GetScheduleState(MinNum: integer): TScheduleState;
var
  StartMin, EndMin: integer;
  StartIn, EndOut: integer;
  BreakState: TScheduleState;
  I: integer;
begin
  StartMin := MinuteOfTheDay(Self.FStartTime);
  EndMin := StartMin + Self.GetLengthOfMinutes - 1;
  StartIn := MinuteOfTheDay(Self.FInStart);
  EndOut := MinuteOfTheDay(Self.FOutFinish);
  Result := ssNone;
  // Если попадаем во время входа или выхода
  if (MinNum < StartMin) and (MinNum >= StartIn) then begin
    Result := ssInTime;
    Exit;
  end;
  if (MinNum > EndMin) and (MinNum <= EndOut) then begin
    Result := ssOutTime;
    Exit;
  end; 
  // Усли попадаем в периоды допустимых отклонений
  if Self.FLateness > 0 then begin
    if (MinNum > StartMin) and ((MinNum - StartMin) < Self.FLateness) then begin
      Result := ssLateToShift;
      Exit;
    end;
    if (MinNum < EndMin) and ((EndMin - MinNum) < Self.FLateness) then begin
      Result := ssEarlyFromShist;
      Exit;
    end;
    Inc(StartMin, Self.FLateness);
    Dec(EndMin, - Self.FLateness);
  end;
  // Если попадаем в смену
  if (MinNum >= StartMin) and (MinNum <= EndMin) then
    Result := ssWork;
  for I := 0 to Self.FBreaks.Count - 1 do begin
    BreakState := FBreaks.Items[I].ScheduleState[MinNum];
    if BreakState <> ssNone then begin
      Result := BreakState;
      Exit;
    end;
  end;
end;


{ TShiftList }

constructor TShiftList.Create(CanDestroyItem: boolean);
begin
  inherited Create(CanDestroyItem);
end;

destructor TShiftList.Destroy;
begin
  inherited Destroy;
end;

function TShiftList.GetIndexByGUID(GUID: TGUID): integer;
var
  i: integer;
begin
  Result := -1;
  i := 0;
  while (i < self.Count) and
     not IsEqualGUID(TShift(inherited Items[i]).GUID, GUID) do inc(i);
  if (i < self.Count) and
    IsEqualGUID(TShift(inherited Items[i]).GUID, GUID) then
      Result := i;
end;

function TShiftList.GetItem(Index: Integer): TShift;
begin
  Result := TShift(inherited GetItem(Index));
end;

procedure TShiftList.SetItem(Index: Integer; AObject: TShift);
begin
  inherited SetITem(Index, AObject);
end;

function TShiftList.GetItem(GUID: TGUID): TShift;
var
  index: integer;
begin
  index := GetIndexByGUID(GUID);
  if index >= 0  then Result := TShift(inherited GetItem(index))
    else Result := nil;
end;

procedure TShiftList.SetItem(GUID: TGUID; AObject: TShift);
var
  index: integer;
begin
  index := GetIndexByGUID(GUID);
  if index >= 0  then inherited SetITem(index, AObject)
    else raise EAccessViolation.Create('Item GUID out of list !');
end;

function TShiftList.First: TShift;
begin
  Result := TShift(inherited First);
end;

function TShiftList.Last: TShift;
begin
  Result := TShift(inherited Last);
end;

function TShiftList.Extract(Item: TObject): TShift;
begin
  Result := TShift(inherited Extract(Item));
end;

function TShiftList.Add(Shift: TShift): integer;
begin
  if GetIndexByGUID(Shift.GUID) < 0 then Result := inherited Add(Shift)
    else raise Exception.Create('Shift GUID duplicate !');
end;

procedure TShiftList.Insert(Index: Integer; Shift: TShift);
begin
  if GetIndexByGUID(Shift.GUID) < 0 then inherited Insert(Index, Shift)
    else raise Exception.Create('Shift GUID duplicate !');
end;

function TShiftList.LoadFromBD(DBFileName: string; BreakList: TBreakList): boolean;
var
  DB: TSQLiteDatabase;
  Table: TSQLiteUniTable;
  SQL, GUIDText: string;
  Shift: TShift;
  GUIDSList: TStringList;
  i: integer;
  Break: TBreak;
begin
  Result := False;
  Self.Clear;
  if not FileExists(DBFileName) then Exit;
  DB := TSQLiteDatabase.Create(DBFileName);
  if not DB.TableExists('shifts') then Exit;
  SQL := 'SELECT * FROM shifts';
  Table := nil;
  try
    Table := DB.GetUniTable(SQL);
    while not Table.EOF do begin
      Shift := TShift.Create;
      Shift.FGUID := StringToGUID(Table.FieldAsString(0));
      Shift.FTitle := UTF8Decode(Table.FieldAsString(1));
      Shift.FStartTime := Table.FieldAsDouble(2);
      Shift.FLength := Table.FieldAsDouble(3);
      Shift.FInStart := Table.FieldAsDouble(4);
      Shift.FInFinish := Table.FieldAsDouble(5);
      Shift.FOutStart := Table.FieldAsDouble(6);
      Shift.FOutFinish := Table.FieldAsDouble(7);
      Shift.FLateness := Table.FieldAsInteger(8);
      GUIDText := Table.FieldAsString(9);
      Shift.FBreaks.Clear;
      if Assigned(BreakList) and (Length(GUIDText) > 0) then begin
        GUIDSList := TStringList.Create;
        if Self.GetGUIDS(GUIDText, GUIDSList) then
          for i := 0 to GUIDSList.Count - 1 do begin
            Break := BreakList.Items[StringToGUID(GUIDSList[i])];
            if Break <> nil then Shift.FBreaks.Add(Break);
          end;
        GUIDSList.Free;
        if Shift.FBreaks.Count > 1 then Shift.FBreaks.SortByStartTime;
      end;
      Self.Add(Shift);
      Table.Next;
    end;
    Result := (Self.Count > 0);
  finally
    Table.Free;
    DB.Free;
  end;
end;

function TShiftList.GetGUIDS(Text: string; GUIDSList: TStringList): boolean;
var
  i: Integer;
  GuidStr: string;
begin
  Result := False;
  if not Assigned(GUIDSList) then Exit;
  GUIDSList.Clear;
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

procedure TShiftList.SortByTitle;

  function CompareTitle(Item1, Item2: Pointer): integer;
  begin
    Result := CompareStr(TShift(Item1).FTitle, TShift(Item2).FTitle);
  end;

begin
  Self.Sort(@CompareTitle);
end;

procedure TShiftList.SortByStartTime;

  function CompareStartTime(Item1, Item2: Pointer): integer;
  begin
    Result := CompareTime(TShift(Item1).FStartTime, TShift(Item2).FStartTime);
  end;

begin
  Self.Sort(@CompareStartTime);
end;

function TShiftList.SaveToBD(DBFileName: string): boolean;
var
  DB: TSQLiteDatabase;
  SQL, BreaksGUIDs: string;
  Shift: TShift;
  I, J: integer;
begin
  Result := False;
  if not FileExists(DBFileName) then Exit;
  DB := TSQLiteDatabase.Create(DBFileName);
  if not DB.TableExists('shifts') then Exit;
  try
    SQL := 'DELETE FROM shifts';
    DB.ExecSQL(SQL);
    DB.BeginTransaction;
    for I := 0 to Self.Count - 1 do begin
      Shift := Self.Items[i];
      BreaksGUIDs := '';
      for J := 0 to Shift.FBreaks.Count - 1 do begin
        BreaksGUIDs := BreaksGUIDs + GuidToString(Shift.FBreaks.Items[J].GUID);
        if not (J = Shift.FBreaks.Count - 1) then
          BreaksGUIDs := BreaksGUIDs + '|';
      end;
      SQL := 'INSERT INTO Shifts (GUID, title, start_time, length, '
        +'in_start, in_finish, out_start, out_finish, lateness, '
        +'breaks_GUIDs)'
        + ' VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';
      DB.ExecSQL(SQL, [GuidToString(Shift.FGUID), UTF8Encode(Shift.FTitle),
        Shift.FStartTime, Shift.FLength, Shift.InStart, Shift.InFinish,
        Shift.OutStart, Shift.OutFinish, Shift.FLateness, BreaksGUIDs]);
    end;
    DB.Commit;
    Result := True;
  finally
    DB.Free
  end;
end;

end.
