unit TheAnalysisByMinute;

interface

uses SysUtils, Contnrs, Controls, Classes, SQLiteTable3, StdCtrls, TheSchedule,
  TheShift, TheBreaks, TheEventPairs;

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
    function LoadPersonPairs(PersonId: string; PersonInd: integer): boolean;
    function GetDayCount: integer;
    function GetMinCount: integer;
    procedure AnalysisEvent;
    function GetMinuteState(Ind: integer): TPersonMinuteState;
    function GetScheduleState(Ind: integer): TScheduleState;
    function GetDayShifts(Date: TDate): TShiftList;
    procedure PrepareScheduleStateArray;
    procedure Clear;
  public
    constructor Create;
    destructor Destroy; override;
    function Analysis(PersonIdList: TStringList; ScheduleTemplate: TSchedule;
      StartDate, EndDate: TDate): boolean;
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

{ ���������� ������� ����� ������� � ����������� ����. }

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
  for I := 0 to FMinuteState[PersonInd].Pairs.Count - 1 do
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

{ ���������� ������� ����� ������� � �������. }

function TAnalysisByMinute.GetDayShifts(Date: TDate): TShiftList;
var
  SchedDayNum: integer;
begin
  SchedDayNum := -1;
  if Self.FScheduleTemplate.ScheduleType = stWeek then begin
    SchedDayNum := DayOfTheWeek(Date) - 1;
  end;
  Result := FScheduleTemplate.Day[SchedDayNum];
end;

procedure TAnalysisByMinute.PrepareScheduleStateArray;
var
  DayNum, ShiftNum, MinNum: integer;
  StartMin, EndMin: integer;
  ShiftList: TShiftList;
begin
  SetLength(FScheduleStateArray, MinutesBetween(FStartDate, FEndDate));
  if Self.FScheduleTemplate = nil then Exit;  
  for DayNum := 0 to Self.DayCount do begin
    ShiftList := GetDayShifts(DateOf(IncDay(FStartDate, DayNum)));
    for ShiftNum := 0 to ShiftList.Count - 1 do begin
      StartMin := MinuteOfTheDay(ShiftList.Items[ShiftNum].StartTime);
      EndMin := StartMin + ShiftList.Items[ShiftNum].LengthOfMinutes;
      for MinNum := StartMin to EndMin do begin
        FScheduleStateArray[MinNum + DayNum * 60 *24] :=
          ShiftList.Items[ShiftNum].ScheduleState[MinNum];
        if not(ShiftList.Items[ShiftNum].ScheduleState[MinNum] in [ssNone, ssBreak])
         and (DayNum > 0) then Inc(Self.FScheduleTotalTime);
      end;
    end;
  end;
end;

{ ������������� ������� � ����. }

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
        // ���� � ������� �����, � �� ����� ������ - ������ �����������
        ssNone: if Presence then EventState := esOvertime
          else EventState := esRest;
        // ������ � ������� ����� ��� ������
        ssWork: if Presence then EventState := esWork
          else begin
            // ���������� � ������� ����� �� ��������� ������, �� ���
            // ����������� ������� ���������� �������
            EventState := esHooky;
            if (MinuteInd > 0) then begin
              PrevEventState := FMinuteState[PersonInd].StateArray[MinuteInd - 1].EventState;
              case PrevEventState of
                // ���� ����� ��� ������� ��� ���� ������ - ������ ���� ������
                esWork, esEarlyFromShiftOrBreak: EventState := esEarlyFromShiftOrBreak;
                // ���� ���� ���� �������� ������ �� ��������� ��� ���������
                // ������ ���������� �� ����� ��� ���������� � ��������
                esRest, esLateToShift:  EventState := esLateToShift;
                esBreak, esLateFromBreak:  EventState := esLateFromBreak;
              end;
            end;
          end;
        // ������� - ������ �������
        ssBreak: EventState := esBreak;
        // � ���������� ������� ��������� ��������� ������������� ��� �����
        // ��� �������
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

{ �������� ���������. }

procedure TAnalysisByMinute.Clear;
var
  I: integer;
begin
  for I := 0 to High(FMinuteState) do begin
    SetLength(FMinuteState[I].StateArray, 0);
    FMinuteState[I].Pairs.Free;
  end;
  SetLength(FMinuteState, 0);
  FScheduleTotalTime := 0;
  FScheduleTemplate := nil;
  FStartDate := 0;
  FEndDate := 0;
  FPersonCount := 0;
end;

function TAnalysisByMinute.Analysis(PersonIdList: TStringList;
  ScheduleTemplate: TSchedule; StartDate, EndDate: TDate): boolean;
var
  PersonId: string;
  I: integer;
begin
  Result := False;
  Clear;
  //
  FScheduleTemplate := ScheduleTemplate;
  FStartDate := StartOfTheDay(IncDay(StartDate, -1));
  FEndDate := EndOfTheDay(EndDate);
  FPersonCount := PersonIdList.Count;
  SetLength(FMinuteState, FPersonCount);
  for I := 0 to High(FMinuteState) do begin
    FMinuteState[I].TotalTime.TotalWork := 0;
    FMinuteState[I].TotalTime.EarlyFromShiftOrBreak := 0;
    FMinuteState[I].TotalTime.LateFromBreak := 0;
    FMinuteState[I].TotalTime.LateToShift := 0;
  end;
  try
    PrepareScheduleStateArray;
    for I := 0 to FPersonCount - 1 do begin
      PersonId := PersonIdList.Names[I];
      FMinuteState[I].PersinId := PersonId;
      FMinuteState[I].PersonName := PersonIdList.Values[PersonId];
      LoadPersonPairs(PersonId, I);
    end;
    AnalysisEvent;
    Result := True;
  finally
    //
  end;
end;


end.
