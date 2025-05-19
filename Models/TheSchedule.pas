unit TheSchedule;

interface

uses TheShift, SysUtils, DateUtils, Contnrs, Controls;

type
  TScheduleType = (stWeek, stPeriod);

  TScheduleTemplate = class(TOBject)
  private
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
    property Title: string read FTitle write Ftitle;
    property DayCount: integer read GetDayCount write SetDayCount;
    property ShedType: TScheduleType read FType write FType;
    property Day[Ind: integer]: TShiftList read GetDay;
  end;

implementation


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
    for I := High(FDays) to Cnt - 1 do FDays[I] := TShiftList.Create(False);
  end;
end;

function TScheduleTemplate.GetDay(Ind: integer): TShiftList;
begin
  if (Ind >= 0) and (Ind <= High(FDays)) then Result := FDays[Ind]
    else Result := nil;
end;



end.
