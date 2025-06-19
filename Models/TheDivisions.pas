unit TheDivisions;

interface

uses
  SysUtils, DateUtils, Contnrs, Controls, SQLiteTable3, TheSchedule;


type
  TDivision = class(TObject)
  private
    FGUID: TGUID;
    FDivisionId: string;
    FName: string;
    FParentGUIDStr: string;
    FParentDivision: TDivision;
    FSchedule: TSchedule;
  public
    constructor Create;
    property GUID: TGUID read FGUID;
    property Title: string read FName write FName;
    property DivisionId: string read FDivisionId write FDivisionId;
    property ParentDivision: TDivision read FParentDivision write FParentDivision;
    property Schedule: TSchedule read FSchedule write FSchedule;
  end;

  TDivisionList = class(TObjectList)
  protected
    function GetIndexByGUID(GUID: TGUID): integer;
    function GetIndexByDivisionId(DivisionId: string): integer;
    function GetItem(DivisionId: string): TDivision; overload;
    procedure SetItem(DivisionId: string; AObject: TDivision); overload;
    function GetItem(Ind: Integer): TDivision; overload;
    procedure SetItem(Ind: Integer; AObject: TDivision); overload;
    function GetItem(GUID: TGUID): TDivision; overload;
    procedure SetItem(GUID: TGUID; AObject: TDivision);  overload;
  public
    constructor Create(CanDestroyItem: boolean);
    destructor Destroy; override;
    property Items[DivisionId: string]: TDivision read GetItem write SetItem; default;
    property Items[GUID: TGUID]: TDivision read GetItem write SetItem; default;
    property Items[Ind: Integer]: TDivision read GetItem write SetItem; default;
    function First: TDivision;
    function Last: TDivision;
    function Extract(Item: TObject): TDivision;
    function Add(Division: TDivision): Integer;
    procedure Insert(Index: Integer; Division: TDivision);
    function LoadFromBD(DBFileName: string; ScheduleList: TScheduleList): boolean;
    procedure SortByTitle;
    function SaveToBD(DBFileName: string): boolean;
    function GetParentDivision(GUID: TGUID): TDivision;
  end;


implementation

uses Dialogs;

{ TDivision }

constructor TDivision.Create;
begin
  inherited Create;
  CreateGUID(FGUID);
end;

{ TDivisionList }

constructor TDivisionList.Create(CanDestroyItem: boolean);
begin
  inherited Create(CanDestroyItem);
end;

destructor TDivisionList.Destroy;
begin
  inherited Destroy;
end;

function TDivisionList.GetIndexByDivisionId(DivisionId: string): integer;
var
  i: integer;
begin
  Result := -1;
  i := 0;
  while (i < self.Count) and
     (TDivision(inherited Items[i]).FDivisionId <> DivisionId)do begin
      inc(i);
     end;
  if (i < self.Count) and
    (TDivision(inherited Items[i]).FDivisionId = DivisionId) then
      Result := i;
end;

function TDivisionList.GetItem(DivisionId: string): TDivision;
var
  index: integer;
begin
  index := GetIndexByDivisionId(DivisionId);
  if index >= 0  then Result := TDivision(inherited GetItem(index))
    else Result := nil;
end;

procedure TDivisionList.SetItem(DivisionId: string; AObject: TDivision);
var
  index: integer;
begin
  index := GetIndexByDivisionId(DivisionId);
  if index >= 0  then inherited SetITem(index, AObject)
    else raise EAccessViolation.Create('Item DivisionId out of list !');
end;

function TDivisionList.GetIndexByGUID(GUID: TGUID): integer;
var
  i: integer;
begin
  Result := -1;
  i := 0;
  while (i < self.Count) and
     not IsEqualGUID(TDivision(inherited Items[i]).GUID, GUID) do inc(i);
  if (i < self.Count) and
    IsEqualGUID(TDivision(inherited Items[i]).GUID, GUID) then
      Result := i;
end;

function TDivisionList.GetItem(Ind: Integer): TDivision;
begin
  Result := TDivision(inherited GetItem(Ind));
end;

procedure TDivisionList.SetItem(Ind: Integer; AObject: TDivision);
begin
  inherited SetITem(Ind, AObject);
end;

function TDivisionList.GetItem(GUID: TGUID): TDivision;
var
  index: integer;
begin
  index := GetIndexByGUID(GUID);
  if index >= 0  then Result := TDivision(inherited GetItem(index))
    else Result := nil;
end;

procedure TDivisionList.SetItem(GUID: TGUID; AObject: TDivision);
var
  index: integer;
begin
  index := GetIndexByGUID(GUID);
  if index >= 0  then inherited SetITem(index, AObject)
    else raise EAccessViolation.Create('Item GUID out of list !');
end;

function TDivisionList.First: TDivision;
begin
  Result := TDivision(inherited First);
end;

function TDivisionList.Last: TDivision;
begin
  Result := TDivision(inherited Last);
end;

function TDivisionList.Extract(Item: TObject): TDivision;
begin
  Result := TDivision(inherited Extract(Item));
end;

function TDivisionList.Add(Division: TDivision): integer;
begin
  if GetIndexByGUID(Division.GUID) < 0 then Result := inherited Add(Division)
    else raise Exception.Create('Division GUID duplicate !');
end;

procedure TDivisionList.Insert(Index: Integer; Division: TDivision);
begin
  if GetIndexByGUID(Division.GUID) < 0 then inherited Insert(Index, Division)
    else raise Exception.Create('Division GUID duplicate !');
end;

function TDivisionList.GetParentDivision(GUID: TGUID): TDivision;
begin
  Result := Self.GetItem(GUID);
  if Result = nil then Result := Self.GetItem('parent');  
end;

function TDivisionList.LoadFromBD(DBFileName: string; ScheduleList: TScheduleList): boolean;
var
  DB: TSQLiteDatabase;
  Table: TSQLiteUniTable;
  SQL, GUIDStr: string;
  Division: TDivision;
  GUID: TGUID;
  I: integer;
begin
  Result := False;
  Self.Clear;
  if not FileExists(DBFileName) then Exit;
  DB := TSQLiteDatabase.Create(DBFileName);
  if not DB.TableExists('divisions') then Exit;
  SQL := 'SELECT * FROM divisions';
  Table := nil;
  try
    Table := DB.GetUniTable(SQL);
    while not Table.EOF do begin
      Division := TDivision.Create;
      Division.FGUID := StringToGUID(Table.FieldAsString(0));
      Division.FDivisionId := UTF8Decode(Table.FieldAsString(1));
      Division.FName := UTF8Decode(Table.FieldAsString(2));
      Division.FParentGUIDStr := Table.FieldAsString(3);
      GUIDStr := Table.FieldAsString(4);
      if Length(GUIDStr) > 0 then begin
        GUID := StringToGUID(GUIDStr);
        Division.FSchedule := ScheduleList.Items[GUID];
      end else
        Division.FSchedule := nil;
      Self.Add(Division);
      Table.Next;
    end;
    //
    for I := 0 to Self.Count - 1 do begin
      Division := Self.Items[I];
        if Length(Division.FParentGUIDStr) > 0 then begin
          GUID := StringToGUID(Division.FParentGUIDStr);
          Division.FParentDivision := Self.GetParentDivision(GUID);
        end else Division.FParentDivision := nil;
      end;
    Result := (Self.Count > 0);
  finally
    Table.Free;
    DB.Free;
    if Self.Count = 0 then begin
      Division := TDivision.Create;
      CreateGUID(Division.FGUID);
      Division.FDivisionId := 'parent';
      Division.FName := 'All division';
      Division.FParentDivision := nil;
      Division.FSchedule := nil;
      Self.Add(Division);
    end;
  end;
end;

procedure TDivisionList.SortByTitle;

  function CompareTitle(Item1, Item2: Pointer): integer;
  begin
    Result := CompareStr(TDivision(Item1).FName, TDivision(Item2).FName);
  end;

begin
  Self.Sort(@CompareTitle);
end;

function TDivisionList.SaveToBD(DBFileName: string): boolean;
var
  DB: TSQLiteDatabase;
  SQL: string;
  Division: TDivision;
  I: integer;
  ParentGUID, ScheduleGUID: string;
begin
  Result := False;
  if not FileExists(DBFileName) then Exit;
  DB := TSQLiteDatabase.Create(DBFileName);
  if not DB.TableExists('divisions') then Exit;
  try
    SQL := 'DELETE FROM divisions';
    DB.ExecSQL(SQL);
    DB.BeginTransaction;
    for I := 0 to Self.Count - 1 do begin
      Division := Self.Items[i];
      ParentGUID := '';
      ScheduleGUID := '';
      if Assigned(Division.FParentDivision) then
        ParentGUID := GuidToString(Division.FParentDivision.FGUID);
      if Assigned(Division.FSchedule) then
        ScheduleGUID := GuidToString(Division.FSchedule.GUID);
      SQL := 'INSERT INTO divisions (GUID, division_id, title, parent_divis_GUID, sched_GUID)'
        + ' VALUES (?, ?, ?, ?, ?)';
      DB.ExecSQL(SQL, [GuidToString(Division.FGUID), UTF8Encode(Division.FDivisionId),
        UTF8Encode(Division.FName), ParentGUID, ScheduleGUID]);
    end;
    DB.Commit;
    Result := True;
  finally
    DB.Free
  end;
end;


end.

