unit TheTableAnalysis;

interface

uses
  SysUtils, DateUtils, Contnrs, Controls,  Classes, TheEventPairs;

type

  TOneDay = record
    NightBefore: integer;
    Day: integer;
    NightAfter: integer;
  end;

  TDays = array of TOneDay;

  TPersonTable = record
    PersonName: string;
    PersonId: string;
    Days: TDays;
  end;

  TTable = array of TPersonTable;

  TTableAnalysis = class(TObject)
  private
    FMaxShiftLen: integer;
    FStartDate: TDateTime;
    FEndDate: TDateTime;
    FDayCount: integer;
    FNightStart: integer;
    FDayStart: integer;
    FNightLength: integer;
    FTable: TTable;
    procedure CreatePointsFromPairs(PersonTable: TPersonTable;
      Pairs: TEmplPairs);
    procedure NormalizeNight(PersonTable: TPersonTable);
    procedure NormalizeNightAfter(PersonTable: TPersonTable);
    function GetRowCount: integer;
    function GetShowDayCount: integer;
    function GetTableRow(Ind: integer):TPersonTable;
  public
    constructor Create;
    destructor Destroy; override;
    property RowCount: integer read GetRowCount;
    property ShowDayCount: integer read GetShowDayCount;
    property Row[Ind: integer]: TPersonTable read GetTableRow;
    procedure SetParametrs(PersonList: TStringList; StartDate, EndDate: TDate);
    function Analysis: boolean;
  end;

implementation

uses Dialogs, TheSettings;


constructor TTableAnalysis.Create;
begin
  inherited Create;
  FMaxShiftLen := 16;
  FDayCount := 0;
  FNightStart := 20 * 60;
  FDayStart := 8 * 60;
  FNightLength := 12 * 60;
end;

destructor TTableAnalysis.Destroy;
begin
  inherited Destroy;
end;

function TTableAnalysis.GetRowCount: integer;
begin
  Result := High(FTable) + 1;
end;

function TTableAnalysis.GetShowDayCount: integer;
begin
  Result := Self.FDayCount - 1;
end;

function TTableAnalysis.GetTableRow(Ind: integer):TPersonTable;
begin
  Result := Self.FTable[Ind];
end;

//

procedure TTableAnalysis.CreatePointsFromPairs(PersonTable: TPersonTable;
  Pairs: TEmplPairs);
var
  DayNum, I, Night, Day: integer;
  PairLength, PairStart: integer;
  Pair: TOnePair;
begin
  for I := 0 to Pairs.Count - 1 do begin
    Pair := Pairs.Pair[I];
    if not(Pair.State = psNormal) then Continue;
    // Определяем номер дня в табеле и получаем список точек.
    DayNum := DaysBetween(FStartDate, Pair.InTime);
    // Определяем продолжительность присутствия в день и в ночь.
    PairStart := MinuteOfTheDay(Pair.InTime);
    PairLength := MinutesBetween(Pair.InTime, Pair.OutTime) + 1;
    Day := 0;
    Night := 0;
    // Если вход до начала дня.
    if PairStart < FDayStart then
      if (PairStart + PairLength) < FDayStart then
            PersonTable.Days[DayNum].NightBefore :=
              PersonTable.Days[DayNum].NightBefore + PairLength
          else begin
            Night := FDayStart - PairStart;
            Day := PairStart + PairLength - FDayStart;
            if Night > Day then PersonTable.Days[DayNum].NightBefore :=
              PersonTable.Days[DayNum].NightBefore + PairLength
                else PersonTable.Days[DayNum].Day :=
                  PersonTable.Days[DayNum].Day + PairLength;
          end;
    // Если вход в дневное время.
    if (PairStart > FDayStart) and (PairStart < FNightStart) then
      if (PairStart + PairLength) < FNightStart then
          PersonTable.Days[DayNum].Day :=
            PersonTable.Days[DayNum].Day + PairLength
        else begin
          Day := FNightStart - PairStart;
          Night := PairStart + PairLength - FNightStart;
          if Night > Day then PersonTable.Days[DayNum].NightAfter :=
            PersonTable.Days[DayNum].NightAfter + PairLength
              else PersonTable.Days[DayNum].Day :=
                PersonTable.Days[DayNum].Day + PairLength;
        end;
    // Если вход в ночное время
    if PairStart > FNightStart then
      PersonTable.Days[DayNum].NightAfter :=
        PersonTable.Days[DayNum].NightAfter + PairLength;
    // Переносим кусочек ночи 0-го дя в утренние часы 1-го дня;
    if (DayNum = 0) and ((PairStart + PairLength) > 24 * 60) then
      PersonTable.Days[1].NightBefore := (PairStart + PairLength) - 24 * 60;
  end;
end;

procedure TTableAnalysis.NormalizeNight(PersonTable: TPersonTable);
var
  DayNum: Integer;
begin
  for DayNum := 1 to High(PersonTable.Days) do begin
    if PersonTable.Days[DayNum].Day = 0 then Continue;    
    if PersonTable.Days[DayNum].NightBefore < PersonTable.Days[DayNum].Day then
      begin
        PersonTable.Days[DayNum].Day := PersonTable.Days[DayNum].Day
          + PersonTable.Days[DayNum].NightBefore;
        PersonTable.Days[DayNum].NightBefore := 0;
      end else begin
        PersonTable.Days[DayNum].NightBefore :=
          PersonTable.Days[DayNum].NightBefore + PersonTable.Days[DayNum].Day;
        PersonTable.Days[DayNum].Day := 0;
      end;
    if PersonTable.Days[DayNum].NightAfter < PersonTable.Days[DayNum].Day then
      begin
        PersonTable.Days[DayNum].Day := PersonTable.Days[DayNum].Day
          + PersonTable.Days[DayNum].NightAfter;
        PersonTable.Days[DayNum].NightAfter := 0;
      end else begin
        PersonTable.Days[DayNum].NightAfter :=
          PersonTable.Days[DayNum].NightAfter + PersonTable.Days[DayNum].Day;
        PersonTable.Days[DayNum].Day := 0;
      end;
  end;
end;

procedure TTableAnalysis.NormalizeNightAfter(PersonTable: TPersonTable);
var
  DayNum: integer;
begin
  for DayNum := 1 to High(PersonTable.Days) - 1 do
    if (PersonTable.Days[DayNum].NightAfter > 0)
      and (PersonTable.Days[DayNum + 1].NightBefore > 0) then begin
        PersonTable.Days[DayNum].NightAfter :=
          PersonTable.Days[DayNum].NightAfter
            + PersonTable.Days[DayNum + 1].NightBefore;
        PersonTable.Days[DayNum + 1].NightBefore := 0;
      end;
end;

//

procedure TTableAnalysis.SetParametrs(PersonList: TStringList;
  StartDate, EndDate: TDate);
var
  I, J : integer;
begin
  //
  for I := 0 to High(FTable) do SetLength(FTable[I].Days, 0);
  SetLength(FTable, 0);
  //
  FStartDate := StartOfTheDay(IncDay(StartDate, -1));
  FEndDate := EndOfTheDay(EndDate);
  FDayCount := DaysBetween(FStartDate, FEndDate) + 1;
  SetLength(FTable, PersonList.Count);
  for I := 0 to High(FTable) do begin
    FTable[I].PersonId := PersonList.Names[I];
    FTable[I].PersonName := PersonList.Values[FTable[I].PersonId];
    SetLength(FTable[I].Days, Self.FDayCount);
    for J := 0 to High(FTable[I].Days) do begin
      FTable[I].Days[J].NightBefore := 0;
      FTable[I].Days[J].Day := 0;
      FTable[I].Days[J].NightAfter := 0;
    end;
  end;
  PersonList.Free;
end;

function TTableAnalysis.Analysis: boolean;
var
  Pairs: TEmplPairs;
  I: integer;
begin
  Result := False;
  if (High(FTable) = 0) or (FDayCount <= 0) then Exit;
  for I := 0 to High(FTable) do begin
    Pairs := TEmplPairs.Create(FTable[I].PersonId, FMaxShiftLen);
    Pairs.CreatePairsFromBD(Settings.GetInstance.DBFileName,FStartDate, FEndDate);
    CreatePointsFromPairs(FTable[I], Pairs);
    NormalizeNight(FTable[I]);
    Pairs.Free;
  end;

  Result := True;
end;



end.
