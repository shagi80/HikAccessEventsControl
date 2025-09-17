unit TheTablePoint;

interface

uses
  SysUtils, DateUtils, Contnrs, Controls;

type
  TTableState = (tsDay, tsNight);

  TTablePoint = class(TObject)
  private
    FState: TTableState;
    FTime: integer;
    function GetStateSumbol: string;
    function GetHours: real;
  public
    constructor Create(Owner: TObject);
    destructor Destroy; override;
    property State: TTableState read FState write FState;
    property Sumbol: string read GetStateSumbol;
    property Minutes: integer read FTime write FTime;
    property Hours: real read GetHours;
  end;

  TTablePointList = class(TObjectList)
  protected
    function GetItem(Index: Integer): TTablePoint;
    procedure SetItem(Index: Integer; AObject: TTablePoint);
  public
    constructor Create(CanDestroyItem: boolean);
    destructor Destroy; override;
    property Items[Index: Integer]: TTablePoint read GetItem write SetItem; default;
    function First: TTablePoint;
    function Last: TTablePoint;
    function Extract(Item: TObject): TTablePoint;
    procedure SortByState;
    procedure AddLastPoint(State: TTableState; Minutes: integer);
  end;

implementation

{ TTablePoint }

constructor TTablePoint.Create(Owner: TObject);
begin
  inherited Create;
end;

destructor TTablePoint.Destroy;
begin
  inherited Destroy;
end;

function TTablePoint.GetStateSumbol: string;
begin
  case Self.FState of
    tsDay: Result := 'ß';
    tsNight: Result := 'Í';
  end;
end;

function TTablePoint.GetHours: real;
begin
  Result := Self.FTime / 60;
end;


{ TTablePointList }

constructor TTablePointList.Create(CanDestroyItem: boolean);
begin
  inherited Create(CanDestroyItem);
end;

destructor TTablePointList.Destroy;
begin
  inherited Destroy;
end;

function TTablePointList.GetItem(Index: Integer): TTablePoint;
begin
  Result := TTablePoint(inherited GetItem(Index));
end;

procedure TTablePointList.SetItem(Index: Integer; AObject: TTablePoint);
begin
  inherited SetITem(Index, AObject);
end;

function TTablePointList.First: TTablePoint;
begin
  Result := TTablePoint(inherited First);
end;

function TTablePointList.Last: TTablePoint;
begin
  Result := TTablePoint(inherited Last);
end;

function TTablePointList.Extract(Item: TObject): TTablePoint;
begin
  Result := TTablePoint(inherited Extract(Item));
end;

procedure TTablePointList.SortByState;

  function GetStateInd(State: TTableState): integer;
  begin
    case State of
      tsDay: Result := 1;
      tsNight: Result := 3;
      else Result := 0;
    end;
  end;

  function CompareStartTime(Item1, Item2: Pointer): integer;
  begin
    if (GetStateInd(TTablePoint(Item2).FState) >
      GetStateInd(TTablePoint(Item1).FState)) then Result := 1
        else if (GetStateInd(TTablePoint(Item2).FState) >
          GetStateInd(TTablePoint(Item1).FState)) then Result := 0
            else Result := -1;
  end;

begin
  Self.Sort(@CompareStartTime);
end;

procedure TTablePointList.AddLastPoint(State: TTableState; Minutes: integer);
var
  LastPoint, NewPoint: TTablePoint;
begin
  LastPoint := Self.Last;
  if (Assigned(LastPoint)) and (LastPoint.State = State)then begin
    LastPoint.Minutes := LastPoint.Minutes + Minutes;
  end else begin
    NewPoint := TTablePoint.Create(Self);
    NewPoint.State := State;
    NewPoint.Minutes := Minutes;
    Self.Add(NewPoint);
  end;
end;

end.
