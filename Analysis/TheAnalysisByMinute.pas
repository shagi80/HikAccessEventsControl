unit TheAnalysisByMinute;

interface

uses SysUtils, Contnrs, Controls, Classes, SQLiteTable3, StdCtrls, TheSchedule,
  TheShift, TheBreaks, TheEventPairs, TheHolyday;

type
  TEventState = (esNone, esRest, esOvertime, esWork, esEarlyBreak,
    esEarlyFromShiftOrBreak, esLateFromBreak, esLateToShift, esBreak, esHooky);

  TMinuteState = record
    Presence: boolean;
    EventState: TEventState;
  end;

  TMinuteStateArray = array of TMinuteState;

  TEventsTotalTime = record
    TotalWork: integer;
    EarlyFromShiftOrBreak: integer;
    LateFromBreak: integer;
    LateToShift: integer;
    Hooky: integer;
  end;

  TPersonMinuteState = record
    PersinId: string;
    PersonName: string;
    TotalTime: TEventsTotalTime;
    StateArray: TMinuteStateArray;
    Pairs: TEmplPairs;
  end;

  TAnalysisByMinute = class(TObject)
  private
    FStartDate: TDateTime;
    FEndDate: TDateTime;
    FScheduleTemplate: TSchedule;
    FMaxShiftLen: integer;
    FScheduleStateArray: TScheduleStateArray;
    FMinuteState: array of TPersonMinuteState;
    FScheduleTotalTime: integer;
    FPersonCount: integer;
    FHolydayList: THolydayList;
    FPersonList: TStringList;
    function LoadPersonPairs(PersonId: string; PersonInd: integer): boolean;
    function GetDayCount: integer;
    function GetMinCount: integer;
    procedure AnalysisEvent;
    function GetMinuteState(Ind: integer): TPersonMinuteState;
    function GetScheduleState(Ind: integer): TScheduleState;
    function GetDayShifts(Date: TDate): TShiftList;
    procedure PrepareScheduleStateArray;
    procedure SetHolydays;
    procedure Clear;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetParametrs(PersonIdList: TStringList; ScheduleTemplate: TSchedule;
      StartDate, EndDate: TDate; Holydays: THolydayList);
    function Analysis: boolean;
    procedure IncEventsTotalTime(State: TEventState; var TotalTime: TEventsTotalTime);
    property DayCount: integer read GetDayCount;
    property PersonCount: integer read FPersonCount;
    property MinuteCount: integer read GetMinCount;
    property ScheduleState[Ind: integer]: TScheduleState read GetScheduleState;
    property PersonState[Ind: integer]: TPersonMinuteState read GetMinuteState;
    property StartDate: TDateTime read FStartDate;
    property EndDate: TDateTime read FEndDate;
    property ScheduleTotalTime: integer read FScheduleTotalTime;
    property ScheduleTemplate: TSchedule read FScheduleTemplate;
  end;

implementation

uses TheSettings, DateUtils, Dialogs;

constructor TAnalysisByMinute.Create;
begin
  inherited Create;
  FMaxShiftLen := 14;
  FPersonCount := 0;
  FHolydayList := nil;
  FPersonList := nil;
  SetLength(FMinuteState, 0);
  SetLength(FScheduleStateArray, 0);
end;

destructor TAnalysisByMinute.Destroy;
var
  i: integer;
begin
  for I := 0 to High(FMinuteState) do SetLength(FMinuteState[I].StateArray, 0);
  SetLength(FMinuteState, 0);
  SetLength(FScheduleStateArray, 0);
  FPersonList := nil;;
  inherited Destroy;
end;

function TAnalysisByMinute.GetDayCount: integer;
begin
  Result := DaysBetween(FStartDate, FEndDate);
end;

function TAnalysisByMinute.GetMinCount: integer;
begin
  if High(FMinuteState) < 0 then Result := 0
    else Result := High(FMinuteState[0].StateArray) + 1;
end;

function TAnalysisByMinute.GetMinuteState(Ind: integer): TPersonMinuteState;
begin
  Result := Self.FMinuteState[Ind];
end;

function TAnalysisByMinute.GetScheduleState(Ind: integer): TScheduleState;
begin
  Result := Self.FScheduleStateArray[Ind];
end;

{ Заполнение массива минут данными о фактичкской явке. }

function TAnalysisByMinute.LoadPersonPairs(PersonId: string;
  PersonInd: integer): boolean;
var
  I, Min, StartMin, EndMin: integer;
begin
  Result := False;
  SetLength(FMinuteState[PersonInd].StateArray, MinutesBetween(FStartDate, FEndDate));
  FMinuteState[PersonInd].Pairs := TEmplPairs.Create(PersonId, FMaxShiftLen);
  FMinuteState[PersonInd].Pairs.CreatePairsFromBD(Settings.GetInstance.DBFileName,FStartDate,
    FEndDate);
  for I := 0 to FMinuteState[PersonInd].Pairs.Count - 1 do begin
    if FMinuteState[PersonInd].Pairs.Pair[I].State = psNormal then begin
      StartMin := MinutesBetween(FStartDate,
        FMinuteState[PersonInd].Pairs.Pair[I].InTime);
      EndMin := MinutesBetween(FStartDate,
        FMinuteState[PersonInd].Pairs.Pair[I].OutTime);
      if EndMin > High(Self.FMinuteState[PersonInd].StateArray) then
        EndMin := High(FMinuteState[PersonInd].StateArray);
      for Min := StartMin to EndMin do
        Self.FMinuteState[PersonInd].StateArray[Min].Presence := True;
      Result := True;
    end;
  end;
end;

{ Заполнение массива минут данными о графике. }

function TAnalysisByMinute.GetDayShifts(Date: TDate): TShiftList;
var
  SchedDayNum: integer;
begin
  SchedDayNum := FScheduleTemplate.GetDayNumber(Date);
  Result := FScheduleTemplate.Day[SchedDayNum];
end;

procedure TAnalysisByMinute.PrepareScheduleStateArray;
var
  Date: TDate;
  DayNum, ShiftNum, MinNum, I: integer;
  StartMin, EndMin: integer;
  ShiftList: TShiftList;
begin
  SetLength(FScheduleStateArray, MinutesBetween(FStartDate, FEndDate));
  if Self.FScheduleTemplate = nil then Exit;
  for DayNum := 0 to Self.DayCount do begin
    Date := DateOf(IncDay(FStartDate, DayNum));
    ShiftList := GetDayShifts(Date);
    for ShiftNum := 0 to ShiftList.Count - 1 do begin
      StartMin := MinuteOfTheDay(ShiftList.Items[ShiftNum].StartTime);
      EndMin := StartMin + ShiftList.Items[ShiftNum].LengthOfMinutes;
      for MinNum := StartMin to EndMin do begin
        I := MinNum + DayNum * 60 *24;
        if I <= High(FScheduleStateArray) then begin
          FScheduleStateArray[I] := ShiftList.Items[ShiftNum].ScheduleState[MinNum];
          if not(ShiftList.Items[ShiftNum].ScheduleState[MinNum] in [ssNone, ssBreak])
            and (DayNum > 0) then Inc(Self.FScheduleTotalTime);
        end;
      end;
    end;
  end;
end;

procedure TAnalysisByMinute.SetHolydays;
var
  Date: TDate;
  DayNum, MinNum, I: integer;
  StartMin, MinCount: integer;
  Holyday: THolyday;
begin
  for DayNum := 1 to Self.DayCount do begin
    Date := DateOf(IncDay(FStartDate, DayNum));
    Holyday := Self.FHolydayList.HolydayFor(Date, Self.FScheduleTemplate);
    if (not Assigned(Holyday)) or ((Holyday.Schedule <> nil)
      and (Holyday.Schedule <> Self.FScheduleTemplate)) then Continue;
    MinCount := MinutesBetween(Holyday.StartTime, Holyday.EndTime);
    StartMin := MinuteOfTheDay(Holyday.StartTime);
    for MinNum := StartMin to (StartMin + MinCount + 1) do begin
      I := MinNum + DayNum * 60 * 24;
      if I <= High(FScheduleStateArray) then begin
        if not (FScheduleStateArray[I]
          in [ssNone, ssBreak]) then Dec(Self.FScheduleTotalTime);
        FScheduleStateArray[MinNum + DayNum * 60 * 24] := ssNone;
      end;
    end;
  end;
end;

{ Сопоставление графика и явки. }

procedure TAnalysisByMinute.IncEventsTotalTime(State: TEventState;
  var TotalTime: TEventsTotalTime);
begin
  case State of
    esOvertime,esWork: Inc(TotalTime.TotalWork) ;
    esEarlyFromShiftOrBreak: Inc(TotalTime.EarlyFromShiftOrBreak);
    esLateFromBreak: Inc(TotalTime.LateFromBreak);
    esLateToShift: Inc(TotalTime.LateToShift);
    esHooky: Inc(TotalTime.Hooky);
  end;
end;

procedure TAnalysisByMinute.AnalysisEvent;
var
  PersonInd, MinuteInd: integer;
  EventState, PrevEventState: TEventState;
  ScheduleState: TScheduleState;
  Presence: boolean;
begin
  for PersonInd := 0 to FPersonCount - 1 do begin
    for MinuteInd := 0 to High(FMinuteState[PersonInd].StateArray) do begin
      ScheduleState := FScheduleStateArray[MinuteInd];
      Presence := FMinuteState[PersonInd].StateArray[MinuteInd].Presence;
      EventState := esRest;
      case ScheduleState of
        // Если в графике пусто, а по факту работа - значит переработка
        ssNone: if Presence then EventState := esOvertime
          else EventState := esRest;
        // Работа в рабочее время это работа
        ssWork: if Presence then EventState := esWork
          else begin
            // Отсутствие в рабочее время по умолчанию прогул, но для
            // детализации смотрим предыдущие события
            EventState := esHooky;
            if (MinuteInd > 0) then begin
              PrevEventState := FMinuteState[PersonInd].StateArray[MinuteInd - 1].EventState;
              case PrevEventState of
                // Если перед эти работал или ушел раньше - значит ушел раньше
                esWork, esEarlyFromShiftOrBreak: EventState := esEarlyFromShiftOrBreak;
                // Если пере этим отдыхалб илибыл на перерывае или опаздывал
                // значит опаздывает на смену или опаздывает с перерыва
                esRest, esLateToShift:  EventState := esLateToShift;
                esBreak, esLateFromBreak:  EventState := esLateFromBreak;
              end;
            end;
          end;
        // Перерыв - всегда перерыв
        ssBreak: EventState := esBreak;
        // В допустимые периоды опозданий отсутсвие засчитывается как отдых
        // или перерыв
        ssEarlyFromShist, ssLateToShift: if Presence then EventState := esWork
          else EventState := esRest;
        ssEarlyToBreak, ssLateFromBreak: if Presence then EventState := esWork
          else EventState := esBreak;
      end;
      FMinuteState[PersonInd].StateArray[MinuteInd].EventState := EventState;
      if MinuteInd >= 60 * 24 then IncEventsTotalTime(EventState,
        FMinuteState[PersonInd].TotalTime);
    end;
  end;
end;

{ Основная процедура. }

procedure TAnalysisByMinute.SetParametrs(PersonIdList: TStringList;
  ScheduleTemplate: TSchedule; StartDate, EndDate: TDate;
  Holydays: THolydayList);
begin
  Self.Clear;
  FPersonList := PersonIdList;
  FHolydayList := Holydays;
  FScheduleTemplate := ScheduleTemplate;
  FStartDate := StartOfTheDay(IncDay(StartDate, -1));
  FEndDate := EndOfTheDay(EndDate);
  FPersonCount := FPersonList.Count;
end;

procedure TAnalysisByMinute.Clear;
var
  I: integer;
begin
  for I := 0 to High(FMinuteState) do begin
    SetLength(FMinuteState[I].StateArray, 0);
    FMinuteState[I].Pairs.Free;
  end;
  SetLength(FMinuteState, 0);
  SetLength(FScheduleStateArray, 0);
  FPersonList := nil;
  FScheduleTotalTime := 0;
  FScheduleTemplate := nil;
  FStartDate := 0;
  FEndDate := 0;
  FPersonCount := 0;
end;

function TAnalysisByMinute.Analysis: boolean;
var
  PersonId: string;
  I: integer;
begin
  Result := False;
  if (not Assigned(FPersonList)) or (not Assigned(FScheduleTemplate))
    or (FPersonCount = 0) then Exit;
  SetLength(FMinuteState, FPersonCount);
  for I := 0 to High(FMinuteState) do begin
    FMinuteState[I].TotalTime.TotalWork := 0;
    FMinuteState[I].TotalTime.EarlyFromShiftOrBreak := 0;
    FMinuteState[I].TotalTime.LateFromBreak := 0;
    FMinuteState[I].TotalTime.LateToShift := 0;
  end;
  try
    PrepareScheduleStateArray;
    SetHolydays;
    for I := 0 to FPersonCount - 1 do begin
      PersonId := FPersonList.Names[I];
      FMinuteState[I].PersinId := PersonId;
      FMinuteState[I].PersonName := FPersonList.Values[PersonId];
      LoadPersonPairs(PersonId, I);
    end;
    AnalysisEvent;
    Result := True;
  finally
    FPersonList.Free;
  end;
end;


end.
