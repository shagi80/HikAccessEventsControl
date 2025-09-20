unit TheAnalysisByMinute;

interface

uses SysUtils, Contnrs, Controls, Classes, SQLiteTable3, StdCtrls, TheSchedule,
  TheShift, TheBreaks, TheEventPairs, TheHolyday;

type
  TEventState = (esNone, esRest, esOvertime, esWork, esEarlyBreak,
    esEarlyFromShiftOrBreak, esLateFromBreak, esLateToShift, esBreak, esHooky,
    esWorkOnBreak);

  TDayResultState = (dsNormal, dsHooky, dsOvertime, dsSmallTime, dsFullHooky,
    dsRest);

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
    NightMinutes: integer;
    IsCame: boolean;
  end;

  TPersonResult = record
    Schedule: integer;
    TotalWork: integer;
    Overtime: integer;
    Hooky: integer;
    LateCount: integer;
    DayCount: integer;
  end;

  TPersonMinuteState = record
    PersinId: string;
    PersonName: string;
    StateArray: TMinuteStateArray;
    Pairs: TEmplPairs;
    DayResult: array of TDayResult;
    TotalDayResult: TPersonResult;
  end;

  THolydayStateArray = array of boolean;

  TAnalysisByMinute = class(TObject)
  private
    FStartDate: TDateTime;
    FEndDate: TDateTime;
    FScheduleTemplate: TSchedule;
    FMaxShiftLen: integer;
    FMinWorkLen: integer;
    FScheduleStateArray: TScheduleStateArray;
    FPersonState: array of TPersonMinuteState;
    FPersonCount: integer;
    FHolydayList: THolydayList;
    FPersonList: TStringList;
    FNightBegin: integer;
    FNightEnd: integer;
    function LoadPersonPairs(PersonId: string; PersonInd: integer): boolean;
    function GetDayCount: integer;
    function GetMinCount: integer;
    procedure AnalysisEvent;
    function GetMinuteState(Ind: integer): TPersonMinuteState;
    function GetScheduleState(Ind: integer): TScheduleState;
    procedure Clear;
    procedure ClearPersonDayResult(PersonInd: integer);
    procedure ClearPersonTotalResult(PersonInd: integer);
    function GetScheduleTotalTime: integer;
    procedure PrepareHolydaysStateArray(var HolydayStates: THolydayStateArray);
    procedure PrepareScheduleStateArrayNew;
    procedure CalckDayResult(State: TEventState; IsNight: boolean;
      var PersonState: TPersonMinuteState; DayNum: integer; CalckTotal,
      IsCame: boolean);
  public
    constructor Create;
    destructor Destroy; override;
    function GetDayShifts(Date: TDate): TShiftList;
    procedure SetParametrs(PersonIdList: TStringList; ScheduleTemplate: TSchedule;
      StartDate, EndDate: TDate; Holydays: THolydayList);
    function Analysis: boolean;
    property DayCnt: integer read GetDayCount;
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
  FMaxShiftLen := Settings.GetInstance.MaxShiftHours;
  FMinWorkLen := Settings.GetInstance.MinWorkMinutes;
  FNightBegin := 20 * 60;
  FNightEnd := 8 * 60;
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
  Result := DaysBetween(FStartDate, FEndDate) + 1;
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

procedure TAnalysisByMinute.PrepareHolydaysStateArray
  (var HolydayStates: THolydayStateArray);
var
  DayNum: integer;
  Date: TDate;
  MinNum, StartMin, EndMin: integer;
  Holyday: THolyday;
begin
  for DayNum := 0 to Self.DayCnt - 1 do begin
    Date := DateOf(IncDay(FStartDate, DayNum));
    Holyday := Self.FHolydayList.HolydayFor(Date, Self.FScheduleTemplate);
    if (not Assigned(Holyday)) or ((Holyday.Schedule <> nil)
      and (Holyday.Schedule <> Self.FScheduleTemplate)) then Continue;
    if DateOf(Holyday.StartTime) < DateOf(Date) then begin
      StartMin := DayNum * 60 * 24;
      EndMin := MinutesBetween(StartOfTheDay(Date), Holyday.EndTime);
    end else begin
        StartMin := MinuteOfTheDay(Holyday.StartTime) + DayNum * 60 * 24;
        EndMin := MinutesBetween(Holyday.StartTime, Holyday.EndTime)
          + StartMin + 1;
    end;
    if EndMin > High(HolydayStates) then EndMin := High(HolydayStates);
    for MinNum := StartMin to EndMin do HolydayStates[MinNum] := True;
  end;
end;

procedure TAnalysisByMinute.PrepareScheduleStateArrayNew;
var
  HolydayStates: THolydayStateArray;
  DayNum, ShiftScheduleTime: integer;
  ShiftNum, MinNum, RealMinNum, PersonInd: integer;
  StartMin, EndMin: integer;
  Date: TDate;
  ShiftList: TShiftList;
  State: TScheduleState;
begin
  // Подготовливаем массив с отметкой о праздниках
  SetLength(HolydayStates, High(Self.FScheduleStateArray) + 1);
  PrepareHolydaysStateArray(HolydayStates);
  for DayNum := 0 to Self.DayCnt - 1 do begin
    Date := DateOf(IncDay(FStartDate, DayNum));
    ShiftList := GetDayShifts(Date);
    // Проходим по списку смен и записываем статус в массив графика
    for ShiftNum := 0 to ShiftList.Count - 1 do begin
      StartMin := MinuteOfTheDay(ShiftList.Items[ShiftNum].InStart);
      EndMin := MinuteOfTheDay(ShiftList.Items[ShiftNum].OutFinish);
      if EndMin < StartMin then EndMin := EndMin + 60 * 24;
      // Получаем и записываем статус каждой смены поминутно
      for MinNum := StartMin to EndMin do begin
        RealMinNum := MinNum + DayNum * 60 * 24;
        if (RealMinNum <= High(FScheduleStateArray))
          and (not HolydayStates[RealMinNum]) then begin
            State := ShiftList.Items[ShiftNum].ScheduleState[MinNum];
            FScheduleStateArray[RealMinNum] := State;
          end;
      end;
    end;
  end;
  // Прходим получившийся массив для поденного подсчета кол-ва часов.
  // В конце дня записываем данные о графике для каждого сотрудника
  // начинаем с 1 дня тк один день добавлен в начало для учета
  // возможных окончаний предыдущих смен
  ShiftScheduleTime := 0;
  for MinNum := 0 to High(FScheduleStateArray) do begin
    State := FScheduleStateArray[MinNum];
    if not(State in [ssNone, ssBreak, ssInTime, ssOutTime])
      then Inc(ShiftScheduleTime);
    if (MinNum > 0) and ((MinNum + 1) mod (60 * 24) = 0) then begin
      DayNum := (MinNum + 1) div (60 * 24) - 1;
      if (DayNum > 0) then
        for PersonInd := 0 to High(Self.FPersonState) do begin
          FPersonState[PersonInd].DayResult[DayNum - 1].Schedule :=
            ShiftScheduleTime;
          FPersonState[PersonInd].TotalDayResult.Schedule :=
            FPersonState[PersonInd].TotalDayResult.Schedule
              + ShiftScheduleTime;
        end;
      ShiftScheduleTime := 0;
    end;
  end;
end;

{ Сопоставление графика и явки. }

procedure TAnalysisByMinute.CalckDayResult(State: TEventState; IsNight: boolean;
  var PersonState: TPersonMinuteState; DayNum: integer; CalckTotal,
  IsCame: boolean);
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
  // Ночные минуты
  if IsNight then Inc(PersonState.DayResult[DayNum].NightMinutes);
  
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
    // Если все прогул компенсированы надо обнулить все состоавляюшие
    if DayHookyTotal = 0 then begin
      PersonState.DayResult[DayNum].EarlyFromShiftOrBreak := 0;
      PersonState.DayResult[DayNum].LateFromBreak := 0;
      PersonState.DayResult[DayNum].LateToShift := 0;
      PersonState.DayResult[DayNum].Hooky := 0;
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

    // Определяем статус дня
    if (IsCame) and ((DayWork + DayOvertime) < Self.FMinWorkLen) then begin
      PersonState.DayResult[DayNum].State := dsSmallTime;
      IsCame := False;
    end else
      if (DayHookyTotal > 0) then begin
        if (DayWork + DayOvertime) = 0 then
          PersonState.DayResult[DayNum].State := dsFullHooky
        else
          PersonState.DayResult[DayNum].State := dsHooky;
      end else
        if DayOvertime > 0 then
          PersonState.DayResult[DayNum].State := dsOvertime
        else
          if DayWork > 0 then
          
          PersonState.DayResult[DayNum].State := dsNormal;


    // Сумируем общий итог по сотруднику
    if (PersonState.DayResult[DayNum].State in [dsHooky, dsOvertime, dsNormal]) then begin
      PersonState.TotalDayResult.Overtime := PersonState.TotalDayResult.Overtime
        + PersonState.DayResult[DayNum].Overtime;
      PersonState.TotalDayResult.Hooky := PersonState.TotalDayResult.Hooky
        + PersonState.DayResult[DayNum].Hooky;
      PersonState.TotalDayResult.TotalWork := PersonState.TotalDayResult.TotalWork
        + PersonState.DayResult[DayNum].TotalWork;
      // Подсчет количества опозданий
      if (PersonState.DayResult[DayNum].LateToShift > 0)
        and (PersonState.DayResult[DayNum].WorkToSchedule > 0) then
          Inc(PersonState.TotalDayResult.LateCount);
      // Подсчет кол-ва дней
      if IsCame then Inc(PersonState.TotalDayResult.DayCount);
    end;
  end;
end;

procedure TAnalysisByMinute.AnalysisEvent;
var
  PersonInd, MinuteInd, DayNum: integer;
  EventState, PrevEventState: TEventState;
  ScheduleState: TScheduleState;
  Presence, WorkFlag: boolean;
  IsNight, IsCame, CalckDay: boolean;
begin
  PrevEventState := esNone;
  EventState := esNone;
  IsCame := False;
  for PersonInd := 0 to FPersonCount - 1 do
    for MinuteInd := 60 * 24 to High(FPersonState[PersonInd].StateArray) do begin
      DayNum := MinuteInd div (60 * 24);
      WorkFlag := (FPersonState[PersonInd].DayResult[DayNum - 1].Schedule > 0);
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
      // Флаг работы в ночь
      IsNight := (((MinuteInd - DayNum * 24 * 60 >= Self.FNightBegin) or
          (MinuteInd  - DayNum * 24 * 60 <= Self.FNightEnd))
           and Presence);
      //Подсчет итогов за день
      if DayNum > 0 then begin
        if Presence then Inc(FPersonState[PersonInd].DayResult[DayNum - 1].Present);
        if not IsCame then
          IsCame := ((Presence) and (PrevEventState in [esNone, esRest, esLateToShift]));
        CalckDay := ((MinuteInd + 1) mod (60 * 24) = 0);
        CalckDayResult(EventState, IsNight, FPersonState[PersonInd], DayNum - 1,
          CalckDay, IsCame);
        if CalckDay then IsCame := False;
      end;
      // Запоминаем последнее событие
      PrevEventState := EventState;
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
    FPersonState[PersonInd].DayResult[J].NightMinutes := 0;
    FPersonState[PersonInd].DayResult[J].HookyComps := False;
    FPersonState[PersonInd].DayResult[J].State := dsRest;
    FPersonState[PersonInd].DayResult[J].IsCame := False;
  end;
end;

procedure TAnalysisByMinute.ClearPersonTotalResult(PersonInd: Integer);
begin
  FPersonState[PersonInd].TotalDayResult.Schedule := 0;
  FPersonState[PersonInd].TotalDayResult.TotalWork := 0;
  FPersonState[PersonInd].TotalDayResult.Overtime := 0;
  FPersonState[PersonInd].TotalDayResult.Hooky := 0;
  FPersonState[PersonInd].TotalDayResult.LateCount := 0;
  FPersonState[PersonInd].TotalDayResult.DayCount := 0;
end;

function TAnalysisByMinute.Analysis: boolean;
var
  PersonId: string;
  I: integer;
begin
  Result := False;
  if (not Assigned(FPersonList)) or (not Assigned(FScheduleTemplate))
    or (FPersonCount = 0) then Exit;
  // Подготавливаем массив сотрудников
  SetLength(FPersonState, FPersonCount);
  for I := 0 to FPersonCount - 1 do begin
    PersonId := FPersonList.Names[I];
    FPersonState[I].PersinId := PersonId;
    FPersonState[I].PersonName := FPersonList.Values[PersonId];
    // Для каждого одготавливаем массив, в котором будем суммировать
    // разные виды времени.
    SetLength(FPersonState[I].DayResult, Self.DayCnt - 1);
    ClearPersonDayResult(I);
    ClearPersonTotalResult(I);
    SetLength(FPersonState[I].StateArray,
      MinutesBetween(FStartDate, FEndDate) + 1);
    // Загружаем явку
    LoadPersonPairs(PersonId, I);
  end;
  // Инициализация массива минут графика
  SetLength(FScheduleStateArray, MinutesBetween(FStartDate, FEndDate) + 1);
  PrepareScheduleStateArrayNew;
  // Сравнение графика и явки
  AnalysisEvent;
  Result := True;
  FPersonList.Free;
end;


end.
