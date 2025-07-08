unit TheAnalysisByMinute;

interface

uses SysUtils, Contnrs, Controls, Classes, SQLiteTable3, StdCtrls, TheSchedule,
  TheShift, TheBreaks, TheEventPairs, TheHolyday;

type
  TEventState = (esNone, esRest, esOvertime, esWork, esEarlyBreak,
    esEarlyFromShiftOrBreak, esLateFromBreak, esLateToShift, esBreak, esHooky,
    esWorkOnBreak);

  TDayResultState = (dsNormal, dsHooky, dsOvertime);

  TMinuteState = record
    Presence: boolean;
    EventState: TEventState;
  end;

  TMinuteStateArray = array of TMinuteState;

  TDayResult = record
    Schedule: integer;
    Present: integer;
    WorkToSchedule: integer;
    TotalWork: integer;
    Overtime: integer;
    WorkOnBreak: integer;
    EarlyFromShiftOrBreak: integer;
    LateFromBreak: integer;
    LateToShift: integer;
    Hooky: integer;
    HookyComps: boolean;
    State: TDayResultState;
  end;

  TPersonResult = record
    Schedule: integer;
    TotalWork: integer;
    Overtime: integer;
    Hooky: integer;
    LateCount: integer;
  end;

  TPersonMinuteState = record
    PersinId: string;
    PersonName: string;
    StateArray: TMinuteStateArray;
    Pairs: TEmplPairs;
    DayResult: array of TDayResult;
    TotalDayResult: TPersonResult;
  end;

  TAnalysisByMinute = class(TObject)
  private
    FStartDate: TDateTime;
    FEndDate: TDateTime;
    FScheduleTemplate: TSchedule;
    FMaxShiftLen: integer;
    FScheduleStateArray: TScheduleStateArray;
    FPersonState: array of TPersonMinuteState;
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
    procedure ClearPersonDayResult(PersonInd: integer);
    procedure ClearPersonTotalResult(PersonInd: integer);
    function GetScheduleTotalTime: integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetParametrs(PersonIdList: TStringList; ScheduleTemplate: TSchedule;
      StartDate, EndDate: TDate; Holydays: THolydayList);
    function Analysis: boolean;
    procedure CalckDayResult(State: TEventState; var PersonState: TPersonMinuteState;
      DayNum: integer; CalckTotal: boolean);
    property DayCount: integer read GetDayCount;
    property PersonCount: integer read FPersonCount;
    property MinuteCount: integer read GetMinCount;
    property ScheduleState[Ind: integer]: TScheduleState read GetScheduleState;
    property PersonState[Ind: integer]: TPersonMinuteState read GetMinuteState;
    property StartDate: TDateTime read FStartDate;
    property EndDate: TDateTime read FEndDate;
    property ScheduleTotalTime: integer read GetScheduleTotalTime;
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
  SetLength(FPersonState, 0);
  SetLength(FScheduleStateArray, 0);
end;

destructor TAnalysisByMinute.Destroy;
var
  i: integer;
begin
  for I := 0 to High(FPersonState) do SetLength(FPersonState[I].StateArray, 0);
  SetLength(FPersonState, 0);
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
  if High(FPersonState) < 0 then Result := 0
    else Result := High(FPersonState[0].StateArray) + 1;
end;

function TAnalysisByMinute.GetMinuteState(Ind: integer): TPersonMinuteState;
begin
  Result := Self.FPersonState[Ind];
end;

function TAnalysisByMinute.GetScheduleState(Ind: integer): TScheduleState;
begin
  Result := Self.FScheduleStateArray[Ind];
end;

function TAnalysisByMinute.GetScheduleTotalTime: integer;
var
  I: integer;
begin
  Result := 0;
  if High(FPersonState) < 0 then Exit;
  for I := 0 to High(Self.FPersonState[0].DayResult) do
    Result := Result + FPersonState[0].DayResult[I].Schedule;
end;

{ Заполнение массива минут данными о фактичкской явке. }

function TAnalysisByMinute.LoadPersonPairs(PersonId: string;
  PersonInd: integer): boolean;
var
  I, Min, StartMin, EndMin: integer;
begin
  Result := False;
  FPersonState[PersonInd].Pairs := TEmplPairs.Create(PersonId, FMaxShiftLen);
  FPersonState[PersonInd].Pairs.CreatePairsFromBD(Settings.GetInstance.DBFileName,FStartDate,
    IncDay(FEndDate, 1));
  for I := 0 to FPersonState[PersonInd].Pairs.Count - 1 do begin
    if FPersonState[PersonInd].Pairs.Pair[I].State = psNormal then begin
      StartMin := MinutesBetween(FStartDate,
        FPersonState[PersonInd].Pairs.Pair[I].InTime);
      EndMin := MinutesBetween(FStartDate,
        FPersonState[PersonInd].Pairs.Pair[I].OutTime);
      if EndMin > High(Self.FPersonState[PersonInd].StateArray) then
        EndMin := High(FPersonState[PersonInd].StateArray);
      for Min := StartMin to EndMin do
        if Min <= High(FPersonState[PersonInd].StateArray) then
          Self.FPersonState[PersonInd].StateArray[Min].Presence := True;
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
  PersonInd, TimeSum: integer;
begin
  if Self.FScheduleTemplate = nil then Exit;
  for DayNum := 0 to Self.DayCount do begin
    Date := DateOf(IncDay(FStartDate, DayNum));
    ShiftList := GetDayShifts(Date);
    // Обнуляем время по графику за день
    TimeSum := 0;
    for ShiftNum := 0 to ShiftList.Count - 1 do begin
      StartMin := MinuteOfTheDay(ShiftList.Items[ShiftNum].InStart);
      EndMin := MinuteOfTheDay(ShiftList.Items[ShiftNum].OutFinish);
      if EndMin < StartMin then EndMin := EndMin + 60 * 24; 
      // Получаем и записываем статус каждой смены поминутно
      for MinNum := StartMin to EndMin do begin
        I := MinNum + DayNum * 60 *24;
        if I <= High(FScheduleStateArray) then begin
          FScheduleStateArray[I] := ShiftList.Items[ShiftNum].ScheduleState[MinNum];
          if not(ShiftList.Items[ShiftNum].ScheduleState[MinNum] in [ssNone, ssBreak,
            ssInTime, ssOutTime]) then Inc(TimeSum);
        end;
      end;
    end;
    // Записываем время по графику для каждого сотрудника
    if (DayNum > 0) then
      for PersonInd := 0 to High(Self.FPersonState) do begin
        FPersonState[PersonInd].DayResult[DayNum - 1].Schedule := TimeSum;
        FPersonState[PersonInd].TotalDayResult.Schedule :=
          FPersonState[PersonInd].TotalDayResult.Schedule + TimeSum;
      end;
  end;
end;

procedure TAnalysisByMinute.SetHolydays;
var
  Date: TDate;
  DayNum, MinNum, I, DayNum_2: integer;
  StartMin, MinCount: integer;
  Holyday: THolyday;
  PersonInd, TimeSum: integer;
begin
  for DayNum := 1 to Self.DayCount do begin
    Date := DateOf(IncDay(FStartDate, DayNum));
    Holyday := Self.FHolydayList.HolydayFor(Date, Self.FScheduleTemplate);
    if (not Assigned(Holyday)) or ((Holyday.Schedule <> nil)
      and (Holyday.Schedule <> Self.FScheduleTemplate)) then Continue;
    MinCount := MinutesBetween(Holyday.StartTime, Holyday.EndTime);
    StartMin := MinuteOfTheDay(Holyday.StartTime);
    // Обнуляем время по графику за день
    TimeSum := 0;
    for MinNum := StartMin to (StartMin + MinCount + 1) do begin
      I := DayNum * 60 * 24 + MinNum;
      if I <= High(FScheduleStateArray) then begin
        { Если в графике эта минута отмечена как рабочая отмечаем как отдых
          и уменьшаем время по гарфику для каждого сотрудника за этот день}
        if (FScheduleStateArray[I] in [ssWork, ssEarlyToBreak, ssEarlyFromShist,
          ssLateFromBreak, ssLateToShift]) then begin
            // Считаем общее время что бы потом уменьшить общий итог
            Inc(TimeSum);
            if (DayNum > 0)  then begin
              // Вычисляем номе дня и уменьшаем время по графику за день
              DayNum_2 := (I div (60 * 24)) - 1;
              for PersonInd := 0 to High(Self.FPersonState) do begin
                FPersonState[PersonInd].DayResult[DayNum_2].Schedule :=
                  FPersonState[PersonInd].DayResult[DayNum_2].Schedule - 1;
                if FPersonState[PersonInd].DayResult[DayNum_2].Schedule < 0 then
                  FPersonState[PersonInd].DayResult[DayNum_2].Schedule := 0;
              end;
            end;
          end;
        FScheduleStateArray[I] := ssNone;
      end;
    end;
    // Уменьшаем ОБЩЕЕ время по графику для каждого сотрудника
    if DayNum > 0 then
      for PersonInd := 0 to High(Self.FPersonState) do begin
        FPersonState[PersonInd].TotalDayResult.Schedule :=
          FPersonState[PersonInd].TotalDayResult.Schedule - TimeSum;
        if FPersonState[PersonInd].TotalDayResult.Schedule < 0 then
          FPersonState[PersonInd].TotalDayResult.Schedule := 0;
      end;
  end;
end;

{ Сопоставление графика и явки. }

procedure TAnalysisByMinute.CalckDayResult(State: TEventState;
  var PersonState: TPersonMinuteState; DayNum: integer; CalckTotal: boolean);
var
  DayHookyTotal: integer;
  HookyCompinsation: integer;
  DayOvertime: integer;
  DayWork: integer;
begin
  // Суммируем статусы по видам в течении дня
  case State of
    esWork: Inc(PersonState.DayResult[DayNum].WorkToSchedule) ;
    esOvertime: Inc(PersonState.DayResult[DayNum].Overtime);
    esWorkOnBreak: Inc(PersonState.DayResult[DayNum].WorkOnBreak);
    esEarlyFromShiftOrBreak: Inc(PersonState.DayResult[DayNum].EarlyFromShiftOrBreak);
    esLateFromBreak: Inc(PersonState.DayResult[DayNum].LateFromBreak);
    esLateToShift: Inc(PersonState.DayResult[DayNum].LateToShift);
    esHooky: Inc(PersonState.DayResult[DayNum].Hooky);
  end;
  // Расчет дневных итогов
  if CalckTotal then begin
    // Суммируем все виды прогулов, запоминаем переработку
    HookyCompinsation := 0;
    DayOvertime := PersonState.DayResult[DayNum].Overtime;
    DayHookyTotal := PersonState.DayResult[DayNum].EarlyFromShiftOrBreak
      + PersonState.DayResult[DayNum].LateFromBreak
      + PersonState.DayResult[DayNum].LateToShift
      + PersonState.DayResult[DayNum].Hooky;
    // Расчет компенасации прогулов переработкой
    if (DayHookyTotal > 0) and (DayOvertime > 0)
      and (FScheduleTemplate.CanOvertime)
      and (FScheduleTemplate.UseOvertimeForHooky) then
        if DayOvertime  >= DayHookyTotal then begin
            HookyCompinsation := DayHookyTotal;
            DayOvertime := DayOvertime - HookyCompinsation;
            DayHookyTotal := 0;
          end else begin
            HookyCompinsation := DayOvertime;
            DayHookyTotal := DayHookyTotal - HookyCompinsation;
            DayOvertime := 0;
          end;
    // Отбрасываем переработку меньши лимита
    if DayOvertime < FScheduleTemplate.OvertimeMin  then DayOvertime := 0;
    // Считаем все рабочее время за день (включая скомпенсированные прогулы)
    DayWork := PersonState.DayResult[DayNum].WorkToSchedule
      + HookyCompinsation;
    if FScheduleTemplate.CanWorkToBreak then DayWork := DayWork
      + PersonState.DayResult[DayNum].WorkOnBreak;
    // Фиксируем дневные итоги
    PersonState.DayResult[DayNum].TotalWork := DayWork;
    PersonState.DayResult[DayNum].Overtime := DayOvertime;
    PersonState.DayResult[DayNum].Hooky := DayHookyTotal;
    PersonState.DayResult[DayNum].HookyComps :=(HookyCompinsation > 0);
    if DayOvertime > 0 then PersonState.DayResult[DayNum].State := dsOvertime
      else if DayHookyTotal > 0 then
          PersonState.DayResult[DayNum].State := dsHooky;
    // Сумируем общий итог по сотруднику
    PersonState.TotalDayResult.Overtime := PersonState.TotalDayResult.Overtime
      + PersonState.DayResult[DayNum].Overtime;
    PersonState.TotalDayResult.Hooky := PersonState.TotalDayResult.Hooky
      + PersonState.DayResult[DayNum].Hooky;
    PersonState.TotalDayResult.TotalWork := PersonState.TotalDayResult.TotalWork
      + PersonState.DayResult[DayNum].TotalWork;
    // Подсчет количества опозданий
    if (not PersonState.DayResult[DayNum].HookyComps)
      and (PersonState.DayResult[DayNum].LateToShift > 0)
      and (PersonState.DayResult[DayNum].WorkToSchedule > 0) then
        Inc(PersonState.TotalDayResult.LateCount);
  end;
end;

procedure TAnalysisByMinute.AnalysisEvent;
var
  PersonInd, MinuteInd, DayNum: integer;
  EventState, PrevEventState: TEventState;
  ScheduleState: TScheduleState;
  Presence, WorkFlag: boolean;
begin
  PrevEventState := esNone;
  EventState := esNone;
  for PersonInd := 0 to FPersonCount - 1 do
    for MinuteInd := 0 to High(FPersonState[PersonInd].StateArray) do begin
      DayNum := MinuteInd div (60 * 24);
      WorkFlag := (FPersonState[PersonInd].DayResult[DayNum].Schedule > 0);
      ScheduleState := FScheduleStateArray[MinuteInd];
      Presence := FPersonState[PersonInd].StateArray[MinuteInd].Presence;
      case ScheduleState of
        // Если в графике пусто, а по факту работа - значит переработка
        // иначе - отдых
        ssInTime, ssOutTime, ssNone: if Presence and FScheduleTemplate.CanOvertime
          then EventState := esOvertime else EventState := esRest;
        // Работа в рабочее время это работа
        ssWork: if Presence then EventState := esWork
          else begin
            // Отсутствие в рабочее время по умолчанию прогул, но для
            // детализации смотрим предыдущие события
            EventState := esHooky;
            if (MinuteInd > 0) then begin
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
        // В период разрешенного опоздания на смену отсутсвие это отдых
        ssLateToShift: if Presence then EventState := esWork
          else EventState := esRest;
        // Если ушел раньше в разрешенный период - отдых, но если вообще
        // не работал - прогул
        ssEarlyFromShist: if Presence then EventState := esWork
          else
            if not WorkFlag then EventState := esHooky
              else EventState := esRest;
        // Если раблтал в перерыв - отмечаем отдельно
        ssBreak: if Presence then EventState := esWorkOnBreak
          else EventState := esBreak;
        // Ранний уход на перерыв или опоздание (если это разрешено)
        // это перерыв, но если в тот день совсем не равботал - прогул
        ssEarlyToBreak, ssLateFromBreak: if Presence then EventState := esWork
          else
            if not WorkFlag then EventState := esHooky
              else EventState := esBreak; 
      end;
      FPersonState[PersonInd].StateArray[MinuteInd].EventState := EventState;
      PrevEventState := EventState;
      if DayNum > 0 then begin
        if Presence then Inc(FPersonState[PersonInd].DayResult[DayNum - 1].Present);
        CalckDayResult(EventState, FPersonState[PersonInd], DayNum - 1,
          ((MinuteInd + 1) mod (60 * 24) = 0));
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
  for I := 0 to High(FPersonState) do begin
    SetLength(FPersonState[I].StateArray, 0);
    FPersonState[I].Pairs.Free;
    SetLength(FPersonState[I].DayResult, 0);
  end;
  SetLength(FPersonState, 0);
  SetLength(FScheduleStateArray, 0);
  FPersonList := nil;
  FScheduleTemplate := nil;
  FStartDate := 0;
  FEndDate := 0;
  FPersonCount := 0;
end;

procedure TAnalysisByMinute.ClearPersonDayResult(PersonInd: Integer);
var
  J: integer;
begin
  for J := 0 to High(FPersonState[PersonInd].DayResult) do begin
    FPersonState[PersonInd].DayResult[J].Schedule := 0;
    FPersonState[PersonInd].DayResult[J].Present := 0;
    FPersonState[PersonInd].DayResult[J].WorkToSchedule := 0;
    FPersonState[PersonInd].DayResult[J].TotalWork := 0;
    FPersonState[PersonInd].DayResult[J].Overtime := 0;
    FPersonState[PersonInd].DayResult[J].WorkOnBreak := 0;
    FPersonState[PersonInd].DayResult[J].EarlyFromShiftOrBreak := 0;
    FPersonState[PersonInd].DayResult[J].LateFromBreak := 0;
    FPersonState[PersonInd].DayResult[J].LateToShift := 0;
    FPersonState[PersonInd].DayResult[J].Hooky := 0;
    FPersonState[PersonInd].DayResult[J].HookyComps := False;
    FPersonState[PersonInd].DayResult[J].State := dsNormal;
  end;
end;

procedure TAnalysisByMinute.ClearPersonTotalResult(PersonInd: Integer);
begin
  FPersonState[PersonInd].TotalDayResult.Schedule := 0;
  FPersonState[PersonInd].TotalDayResult.TotalWork := 0;
  FPersonState[PersonInd].TotalDayResult.Overtime := 0;
  FPersonState[PersonInd].TotalDayResult.Hooky := 0;
  FPersonState[PersonInd].TotalDayResult.LateCount := 0;
end;

function TAnalysisByMinute.Analysis: boolean;
var
  PersonId: string;
  I: integer;
begin
  Result := False;
  if (not Assigned(FPersonList)) or (not Assigned(FScheduleTemplate))
    or (FPersonCount = 0) then Exit;
  SetLength(FPersonState, FPersonCount);
  // Подготавливаем массив, в котором будем суммировать разные виды времени.
  for I := 0 to High(FPersonState) do begin
    SetLength(FPersonState[I].DayResult, Self.DayCount);
    ClearPersonDayResult(I);
    ClearPersonTotalResult(I);
    SetLength(FPersonState[I].StateArray,
      MinutesBetween(FStartDate, FEndDate) + 2);
  end;
  try
    SetLength(FScheduleStateArray, MinutesBetween(FStartDate, FEndDate) + 1);
    PrepareScheduleStateArray;
    SetHolydays;
    for I := 0 to FPersonCount - 1 do begin
      PersonId := FPersonList.Names[I];
      FPersonState[I].PersinId := PersonId;
      FPersonState[I].PersonName := FPersonList.Values[PersonId];
      LoadPersonPairs(PersonId, I);
    end;
    AnalysisEvent;
    Result := True;
  finally
    FPersonList.Free;
  end;
end;


end.
