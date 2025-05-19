unit TheSchedule;

interface

uses TheShift, SysUtils, DateUtils, Contnrs, Controls;

type
  TScheduleType = (stWeek, stPeriod);

  TSchedDay = class(TObject)
  private
    FShifts: TObjectList;
    function GetShiftCount: integer;
    function GetShift(Ind: Integer): TShift;
  public
    constructor Create;
    destructor Destroy; override;
    property ShiftCount: integer read GetShiftCount;
    property Shift[Ind: Integer]: TShift read GetShift;
    procedure AddShift(Shift: TShift);
    procedure DeleteShift(Ind: integer);
  end;

  TScheduleTemplate = class(TOBject)
  private
    FTitle: string;
    FType: TScheduleType;
    FDays: array of TSchedDay;
    function GetDayCount: integer;
    procedure SetDayCount(Cnt: integer);
    function GetDay(Ind: integer): TSchedDay;
  public
    constructor Create;
    destructor Destroy; override;
    property Title: string read FTitle write Ftitle;
    property DayCount: integer read GetDayCount write SetDayCount;
    property ShedType: TScheduleType read FType write FType;
    property Day[Ind: integer]: TSchedDay read GetDay;
  end;

implementation

{ TSchedDay }

constructor TSchedDay.Create;
begin
  inherited Create;
  FShifts := TObjectList.Create(False);
end;

destructor TSchedDay.Destroy;
begin
  FShifts.Free;
  inherited Destroy;
end;


function TSchedDay.GetShiftCount: integer;
begin
  Result := FShifts.Count;
end;

function TSchedDay.GetShift(Ind: Integer): TShift;
begin
  if (Ind >= 0) and (Ind < FShifts.Count) then Result := TShift(FShifts[Ind])
    else Result := nil;
end;

procedure TSchedDay.AddShift(Shift: TShift);
begin
  FShifts.Add(Shift);
end;

procedure TSchedDay.DeleteShift(Ind: integer);
begin
  FShifts.Delete(Ind);
end;



{ TScheduleTemplate }

constructor TScheduleTemplate.Create;
begin
  inherited Create;
  SetLength(FDays, 0);
end;

destructor TScheduleTemplate.Destroy;
begin
  SetDayCount(0);
  inherited Destroy;
end;

function TScheduleTemplate.GetDayCount: integer;
begin
  Result := High(FDays);
end;

procedure TScheduleTemplate.SetDayCount(Cnt: integer);
var
  I: integer;
begin
  if Cnt < (High(Self.FDays) + 1) then begin
    for I := Cnt to High(FDays) do FDays[I].Free;
    SetLength(FDays, 0);
  end;
  if Cnt > (High(Self.FDays) + 1) then begin
    SetLength(FDays, Cnt);
    for I := High(FDays) to Cnt - 1 do FDays[I] := TSchedDay.Create;
  end;
end;

function TScheduleTemplate.GetDay(Ind: integer): TSchedDay;
begin
  if (Ind >= 0) and (Ind <= High(FDays)) then Result := FDays[Ind]
    else Result := nil;
end;



end.
