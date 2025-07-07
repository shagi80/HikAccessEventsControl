unit ThePersons;

interface

uses
  SysUtils, DateUtils, Contnrs, Controls, SQLiteTable3, TheSchedule,
  TheDivisions;


type
  TPerson = class(TObject)
  private
    FGUID: TGUID;
    FPersonId: string;
    FName: string;
    FDivision: TDivision;
    FSchedule: TSchedule;
    function NormaizePersonId(PersonId: string): string;
    procedure SetPersonId(Value: string);
  public
    constructor Create;
    property GUID: TGUID read FGUID;
    property Name: string read FName write FName;
    property PersonId: string read FPersonId write SetPersonId;
    property Division: TDivision read FDivision write FDivision;
    property Schedule: TSchedule read FSchedule write FSchedule;
  end;

  TPersonList = class(TObjectList)
  protected
    function GetIndexByGUID(GUID: TGUID): integer;
    function GetIndexByPersonId(PersonId: string): integer;
    function GetItem(PersonId: string): TPerson; overload;
    procedure SetItem(PersonId: string; AObject: TPerson); overload;
    function GetItem(Ind: Integer): TPerson; overload;
    procedure SetItem(Ind: Integer; AObject: TPerson); overload;
    function GetItem(GUID: TGUID): TPerson; overload;
    procedure SetItem(GUID: TGUID; AObject: TPerson);  overload;
  public
    constructor Create(CanDestroyItem: boolean);
    destructor Destroy; override;
    property Items[PersonId: string]: TPerson read GetItem write SetItem; default;
    property Items[GUID: TGUID]: TPerson read GetItem write SetItem; default;
    property Items[Ind: Integer]: TPerson read GetItem write SetItem; default;
    function First: TPerson;
    function Last: TPerson;
    function Extract(Item: TObject): TPerson;
    function Add(Person: TPerson): Integer;
    procedure Insert(Index: Integer; Person: TPerson);
    function LoadFromBD(DBFileName: string; DivisionList: TDivisionList;
      ScheduleList: TScheduleList): boolean;
    procedure SortByTitle;
    function SaveToBD(DBFileName: string): boolean;
  end;


implementation

{ TPerson }

constructor TPerson.Create;
begin
  inherited Create;
  CreateGUID(FGUID);
end;

function TPerson.NormaizePersonId(PersonId: string): string;
var
  I: integer;
begin
  I := 1;
  while (I <= Length(PersonId)) and (PersonId[I] in ['0', ' ']) do Inc(I);
  if I = 0 then Result := PersonId
    else Result := Copy(PersonId, I, MaxInt);
end;

procedure TPerson.SetPersonId(Value: string);
begin
  Self.FPersonId := Self.NormaizePersonId(Value);
end;

{ TPersonList }

constructor TPersonList.Create(CanDestroyItem: boolean);
begin
  inherited Create(CanDestroyItem);
end;

destructor TPersonList.Destroy;
begin
  inherited Destroy;
end;

function TPersonList.GetIndexByPersonId(PersonId: string): integer;
var
  i: integer;
begin
  Result := -1;
  i := 0;
  while (i < self.Count) and
     (not CompareStr(TPerson(inherited Items[i]).FPersonId, PersonId) = 0) do inc(i);
  if (i < self.Count) and
    (CompareStr(TPerson(inherited Items[i]).FPersonId, PersonId) = 0) then
      Result := i;
end;

function TPersonList.GetItem(PersonId: string): TPerson;
var
  index: integer;
begin
  index := GetIndexByPersonId(PersonId);
  if index >= 0  then Result := TPerson(inherited GetItem(index))
    else Result := nil;
end;

procedure TPersonList.SetItem(PersonId: string; AObject: TPerson);
var
  index: integer;
begin
  index := GetIndexByPersonId(PersonId);
  if index >= 0  then inherited SetITem(index, AObject)
    else raise EAccessViolation.Create('Item PersonId out of list !');
end;

function TPersonList.GetIndexByGUID(GUID: TGUID): integer;
var
  i: integer;
begin
  Result := -1;
  i := 0;
  while (i < self.Count) and
     not IsEqualGUID(TPerson(inherited Items[i]).GUID, GUID) do inc(i);
  if (i < self.Count) and
    IsEqualGUID(TPerson(inherited Items[i]).GUID, GUID) then
      Result := i;
end;

function TPersonList.GetItem(Ind: Integer): TPerson;
begin
  Result := TPerson(inherited GetItem(Ind));
end;

procedure TPersonList.SetItem(Ind: Integer; AObject: TPerson);
begin
  inherited SetITem(Ind, AObject);
end;

function TPersonList.GetItem(GUID: TGUID): TPerson;
var
  index: integer;
begin
  index := GetIndexByGUID(GUID);
  if index >= 0  then Result := TPerson(inherited GetItem(index))
    else Result := nil;
end;

procedure TPersonList.SetItem(GUID: TGUID; AObject: TPerson);
var
  index: integer;
begin
  index := GetIndexByGUID(GUID);
  if index >= 0  then inherited SetITem(index, AObject)
    else raise EAccessViolation.Create('Item GUID out of list !');
end;

function TPersonList.First: TPerson;
begin
  Result := TPerson(inherited First);
end;

function TPersonList.Last: TPerson;
begin
  Result := TPerson(inherited Last);
end;

function TPersonList.Extract(Item: TObject): TPerson;
begin
  Result := TPerson(inherited Extract(Item));
end;

function TPersonList.Add(Person: TPerson): integer;
begin
  if GetIndexByGUID(Person.GUID) < 0 then Result := inherited Add(Person)
    else raise Exception.Create('Person GUID duplicate !');
end;

procedure TPersonList.Insert(Index: Integer; Person: TPerson);
begin
  if GetIndexByGUID(Person.GUID) < 0 then inherited Insert(Index, Person)
    else raise Exception.Create('Person GUID duplicate !');
end;

function TPersonList.LoadFromBD(DBFileName: string; DivisionList: TDivisionList;
  ScheduleList: TScheduleList): boolean;
var
  DB: TSQLiteDatabase;
  Table: TSQLiteUniTable;
  SQL, GUIDStr: string;
  Person: TPerson;
  DivisionGUID: TGUID;
begin
  Result := False;
  Self.Clear;
  if not FileExists(DBFileName) then Exit;
  DB := TSQLiteDatabase.Create(DBFileName);
  if not DB.TableExists('persons') then Exit;
  SQL := 'SELECT * FROM persons';
  Table := nil;
  try
    Table := DB.GetUniTable(SQL);
    while not Table.EOF do begin
      Person := TPerson.Create;
      Person.FGUID := StringToGUID(Table.FieldAsString(0));
      Person.FPersonId := UTF8Decode(Table.FieldAsString(1));
      Person.FName := UTF8Decode(Table.FieldAsString(2));
      DivisionGUID := StringToGUID(Table.FieldAsString(3));
      Person.FDivision := DivisionList.GetParentDivision(DivisionGUID);
      GUIDStr := Table.FieldAsString(4);
      if Length(GUIDStr) = 0 then Person.FSchedule := nil
        else Person.FSchedule := ScheduleList.Items[StringToGUID(GUIDStr)];
      Self.Add(Person);
      Table.Next;
    end;
    Result := (Self.Count > 0);
  finally
    Table.Free;
    DB.Free;
  end;
end;

procedure TPersonList.SortByTitle;

  function CompareTitle(Item1, Item2: Pointer): integer;
  begin
    Result := CompareStr(TPerson(Item1).FName, TPerson(Item2).FName);
  end;

begin
  Self.Sort(@CompareTitle);
end;

function TPersonList.SaveToBD(DBFileName: string): boolean;
var
  DB: TSQLiteDatabase;
  SQL: string;
  Person: TPerson;
  I: integer;
  DivisionGUID, ScheduleGUID: string;
begin
  Result := False;
  if not FileExists(DBFileName) then Exit;
  DB := TSQLiteDatabase.Create(DBFileName);
  if not DB.TableExists('persons') then Exit;
  try
    SQL := 'DELETE FROM persons';
    DB.ExecSQL(SQL);
    DB.BeginTransaction;
    for I := 0 to Self.Count - 1 do begin
      Person := Self.Items[i];
      DivisionGUID := '';
      ScheduleGUID := '';
      if Assigned(Person.FDivision) then
        DivisionGUID := GuidToString(Person.FDivision.GUID);
      if Assigned(Person.FSchedule) then
        ScheduleGUID := GuidToString(Person.FSchedule.GUID);
      SQL := 'INSERT INTO persons (GUID, person_id, title, divis_GUID, sched_GUID)'
        + ' VALUES (?, ?, ?, ?, ?)';
      DB.ExecSQL(SQL, [GuidToString(Person.FGUID), UTF8Encode(Person.NormaizePersonId(Person.FPersonId)),
        UTF8Encode(Person.FName), DivisionGUID, ScheduleGUID]);
    end;
    DB.Commit;
    Result := True;
  finally
    DB.Free
  end;
end;


end.
