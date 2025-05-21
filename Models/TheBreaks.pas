unit TheBreaks;

interface

uses
  SysUtils, DateUtils, Contnrs, Controls, SQLiteTable3;


type
  TBreak = class(TObject)
  private
    FGUID: TGUID;
    FTitle: string;
    FStartTime: TTime;
    FLength: TTime;
    FLateness: integer;
    function GetLengthOfMinutes: integer;
  public
    constructor Create;
    property GUID: TGUID read FGUID;
    property Title: string read FTitle write FTitle;
    property StartTime: TTime read FStartTime write FStartTime;
    property Length: TTime read FLength write FLength;
    property Lateness: integer read FLateness write FLateness;
    property LengthOfMinutes: integer read GetLengthOfMinutes;
  end;

  TBreakList = class(TObjectList)
  protected
    function GetIndexByGUID(GUID: TGUID): integer;
    function GetItem(Index: Integer): TBreak; overload;
    procedure SetItem(Index: Integer; AObject: TBreak); overload;
    function GetItem(GUID: TGUID): TBreak; overload;
    procedure SetItem(GUID: TGUID; AObject: TBreak);  overload;
    function CreateTable(DB: TSQLiteDatabase): boolean;
  public
    constructor Create(CanDestroyItem: boolean);
    destructor Destroy; override;
    property Items[GUID: TGUID]: TBreak read GetItem write SetItem; default;
    property Items[Index: Integer]: TBreak read GetItem write SetItem; default;
    function First: TBreak;
    function Last: TBreak;
    function Extract(Item: TObject): TBreak;
    function Add(Break: TBreak): Integer;
    procedure Insert(Index: Integer; Break: TBreak);
    function LoadFromBD(DBFileName: string): boolean;
    procedure SortByTitle;
    procedure SortByStartTime;
  end;

implementation


{ TBreak }

constructor TBreak.Create;
begin
  inherited Create;
  CreateGUID(FGUID);
end;

function TBreak.GetLengthOfMinutes: integer;
begin
  Result := HourOf(FLength) * 60 + MinuteOf(FLength);
end;

{ TBreakList }

constructor TBreakList.Create(CanDestroyItem: boolean);
begin
  inherited Create(CanDestroyItem);
end;

destructor TBreakList.Destroy;
begin
  inherited Destroy;
end;

function TBreakList.GetIndexByGUID(GUID: TGUID): integer;
var
  i: integer;
begin
  Result := -1;
  i := 0;
  while (i < self.Count) and
     not IsEqualGUID(TBreak(inherited Items[i]).GUID, GUID) do inc(i);
  if (i < self.Count) and
    IsEqualGUID(TBreak(inherited Items[i]).GUID, GUID) then
      Result := i;
end;

function TBreakList.GetItem(Index: Integer): TBreak;
begin
  Result := TBreak(inherited GetItem(Index));
end;

procedure TBreakList.SetItem(Index: Integer; AObject: TBreak);
begin
  inherited SetITem(Index, AObject);
end;

function TBreakList.GetItem(GUID: TGUID): TBreak;
var
  index: integer;
begin
  index := GetIndexByGUID(GUID);
  if index >= 0  then Result := TBreak(inherited GetItem(index))
    else Result := nil;
end;

procedure TBreakList.SetItem(GUID: TGUID; AObject: TBreak);
var
  index: integer;
begin
  index := GetIndexByGUID(GUID);
  if index >= 0  then inherited SetITem(index, AObject)
    else raise EAccessViolation.Create('Item GUID out of list !');
end;

function TBreakList.First: TBreak;
begin
  Result := TBreak(inherited First);
end;

function TBreakList.Last: TBreak;
begin
  Result := TBreak(inherited Last);
end;

function TBreakList.Extract(Item: TObject): TBreak;
begin
  Result := TBreak(inherited Extract(Item));
end;

function TBreakList.Add(Break: TBreak): integer;
begin
  if GetIndexByGUID(Break.GUID) < 0 then Result := inherited Add(Break)
    else raise Exception.Create('Break GUID duplicate !');
end;

procedure TBreakList.Insert(Index: Integer; Break: TBreak);
begin
  if GetIndexByGUID(Break.GUID) < 0 then inherited Insert(Index, Break)
    else raise Exception.Create('Break GUID duplicate !');
end;

function TBreakList.CreateTable(DB: TSQLiteDatabase): boolean;
begin
  Result := False;
  {DROP TABLE breaks;

CREATE TABLE breaks (
    GUID       TEXT    PRIMARY KEY
                       UNIQUE ON CONFLICT ROLLBACK,
    title      TEXT,
    start_time REAL,
    length     REAL,
    lateness   INTEGER
);

}
end;

function TBreakList.LoadFromBD(DBFileName: string): boolean;
var
  DB: TSQLiteDatabase;
  Table: TSQLiteUniTable;
  SQL: string;
  Break: TBreak;
begin
  Result := False;
  Self.Clear;
  if not FileExists(DBFileName) then Exit;
  DB := TSQLiteDatabase.Create(DBFileName);
  if not DB.TableExists('breaks') then Exit;
  SQL := 'SELECT * FROM breaks';
  Table := nil;
  try
    Table := DB.GetUniTable(SQL);
    while not Table.EOF do begin
      Break := TBreak.Create;
      Break.FGUID := StringToGUID(Table.FieldAsString(0));
      Break.FTitle := UTF8Decode(Table.FieldAsString(1));
      Break.FStartTime := Table.FieldAsDouble(2);
      Break.FLength := Table.FieldAsDouble(3);
      Break.FLateness := Table.FieldAsInteger(4);
      Self.Add(Break);
      Table.Next;
    end;
    Result := (Self.Count > 0);
  finally
    Table.Free;
    DB.Free;
  end;
end;

procedure TBreakList.SortByTitle;

  function CompareTitle(Item1, Item2: Pointer): integer;
  begin
    Result := CompareStr(TBreak(Item1).FTitle, TBreak(Item2).FTitle);
  end;

begin
  Self.Sort(@CompareTitle);
end;

procedure TBreakList.SortByStartTime;

  function CompareStartTime(Item1, Item2: Pointer): integer;
  begin
    Result := CompareTime(TBreak(Item1).FStartTime, TBreak(Item2).FStartTime);
  end;

begin
  Self.Sort(@CompareStartTime);
end;


end.
