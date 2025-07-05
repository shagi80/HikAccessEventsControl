unit TheTotalTimeCalculator;

interface

uses TheAnalysisByMinute, TheSchedule;

type
  TTotalTimeCalculator = class(TObject)
    FTotalTime: TEventsTotalTime;
    FWorkTime: integer;
    FOverTime: integer;
    FHookyTime: integer;
    FScheduleTime: integer;
    FUseOvertime: boolean;
    FCalcOvertime: boolean;
    procedure Calc;
  public
    constructor Create(TotalTime: TEventsTotalTime; Schedule: TSchedule;
      ScheduleTime: integer);
    property WorkTime: integer read FWorkTime;
    property OverTime: integer read FOverTime;
    property HookyTime: integer read FHookyTime;
  end;

implementation

constructor TTotalTimeCalculator.Create(TotalTime: TEventsTotalTime;
  Schedule: TSchedule; ScheduleTime: integer);
begin
  inherited Create;
  FTotalTime := TotalTime;
  FWorkTime := 0;
  FOverTime := 0;
  FHookyTime := 0;
  FScheduleTime := ScheduleTime;
  FUseOvertime := True;
  FCalcOvertime := True;
  Calc;
end;

procedure TTotalTimeCalculator.Calc;
var
  OvertimeBalance: integer;
begin
  OvertimeBalance := FTotalTime.Overtime;
  if FUseOvertime  then begin
    OvertimeBalance := OvertimeBalance - FHookyTime;
    if OvertimeBalance < 0 then OvertimeBalance := 0;
  end;
  FHookyTime := FTotalTime.EarlyFromShiftOrBreak
    + FTotalTime.LateToShift + FTotalTime.LateFromBreak + FTotalTime.Hooky;
  if FUseOvertime then FHookyTime := FHookyTime - FTotalTime.Overtime;
  if FHookyTime < 0 then FHookyTime := 0;

  FWorkTime := FScheduleTime - FHookyTime;
  if FCalcOvertime then FWorkTime := FWorkTime + FTotalTime.Overtime;
  
  FOvertime := OvertimeBalance;
  {  HookyTime := TotalTime.EarlyFromShiftOrBreak
    + TotalTime.LateToShift + TotalTime.LateFromBreak + TotalTime.Hooky;
  TotalToReport := TotalTime.TotalPresent;
  MinScheduleTime := ScheduleTime - HookyTime;
  if TotalToReport > MinScheduleTime then TotalToReport := MinScheduleTime;
  Overtime := TotalTime.Overtime - HookyTime
    - (ScheduleTime - TotalToReport);
  if (TotalToReport < ScheduleTime) and (TotalTime.Overtime > 0) then
    TotalToReport := TotalToReport + TotalTime.Overtime;
  if TotalToReport > ScheduleTime then begin
    Overtime := TotalToReport - ScheduleTime;
    TotalToReport := ScheduleTime;
  end;}
end;


end.
