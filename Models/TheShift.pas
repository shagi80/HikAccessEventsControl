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
  end;

  TShiftList = class(TObjectList)
  protected
    function GetIndexByGUID(GUID: TGUID): integer;
    function GetItem(Index: Integer): TShift; overload;
    procedure SetItem(Index: Integer; AObject: TShift); overload;
    function GetItem(GUID: TGUID): TShift; overload;
    procedure SetItem(GUID: TGUID; AObject: TShift);  overload;
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
    function GetGUIDS(Text: string; GUIDSList: TStringList): boolean;
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

end.
