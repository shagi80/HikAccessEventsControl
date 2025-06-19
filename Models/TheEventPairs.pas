unit TheEventPairs;

interface

uses Classes, SysUtils, DateUtils, SQLiteTable3;

type
  TPairState = (psNormal, psNotIn, psNotOut);

  TOnePair = record
    State: TPairState;
    InTime: TDateTime;
    OutTime: TDateTime;
  end;

  TPairsArray = array of TOnePair;

  TEmplPairs = class(TObject)
  private
    FEmployeeId: string;
    FPairs: TPairsArray;
    FMaxShiftLength: integer;
    function GetPair(Ind: integer): TOnePair;
    function GetCount: integer;
  public
    constructor Create(EmployeeId: string; MaxShiftLength: integer);
    destructor Destroy; override;
    procedure AddPair(InTime, OutTime: TDateTime);
    function CreatePairsFromBD(DBFileName: string; StartTime,
      EndTime: TDateTime): integer;
    property Count: integer read GetCount;
    property Pair[Ind: integer]: TOnePair read GetPair;
  end;


implementation

uses TheEventsLoader, Dialogs;


constructor TEmplPairs.Create(EmployeeId: string; MaxShiftLength: integer);
begin
  inherited Create;
  FEmployeeId := EmployeeId;
  FMaxShiftLength := MaxShiftLength;
end;

destructor TEmplPairs.Destroy;
begin
  SetLength(FPairs, 0);
  inherited Destroy;
end;

function TEmplPairs.GetPair(Ind: integer): TOnePair;
begin
  Result := FPairs[Ind];
end;

function TEmplPairs.GetCount: integer;
begin
  Result := High(FPairs) + 1;
end;

procedure TEmplPairs.AddPair(InTime, OutTime: TDateTime);
begin
  SetLength(FPairs, High(FPairs) + 2);
  FPairs[High(FPairs)].InTime := InTime;
  FPairs[High(FPairs)].OutTime := OutTime;
  FPairs[High(FPairs)].State := psNormal;
  if MinuteOfTheDay(OutTime) = 0 then FPairs[High(FPairs)].State := psNotOut;
  if MinuteOfTheDay(InTime) = 0 then FPairs[High(FPairs)].State := psNotIn;
end;

function TEmplPairs.CreatePairsFromBD(DBFileName: string; StartTime,
      EndTime: TDateTime): integer;
var
  DB: TSQLiteDatabase;
  Table: TSQLiteUniTable;
  SQL, StartTimeStr, EndTimeStr: string;
  WaitingOut: boolean;
  Direction: TEventDirection;
  InTime: TDateTime;
begin
  Result := 0;
  SetLength(FPairs, 0);
  if not FileExists(DBFIleName) then Exit;
  DB := TSQLiteDatabase.Create(DBFileName);
  Table := nil;
  StartTimeStr := StringReplace(FloatToStr(StartTime), ',', '.', [rfReplaceAll]);
  EndTimeStr := StringReplace(FloatToStr(EndTime), ',', '.', [rfReplaceAll]);
  SQL := 'SELECT device_direction, time FROM events WHERE employeeNoString='
    + Self.FEmployeeId + ' AND time BETWEEN ' + StartTimeStr + ' AND '
    + EndTimeStr + ' ORDER BY time';
  try
  Table := DB.GetUniTable(SQL);
  InTime := 0;
  WaitingOut := False;
  while not Table.EOF do begin
    Direction := TEventDirection(Table.FieldAsInteger(0) - 1);
    { Если событие вход то возможны два варианта:
      - время входа уже записано - сохраняем уже записанное время входа как
        пару с нулевым выходом
      - время входа еще не записано - записываем и ждем выход }
    if Direction = edIn then begin
      if not (InTime = 0) then AddPair(InTime, 0);
      InTime := Table.FieldAsDouble(1);
      WaitingOut := True;
    end;
    { Если событие "выход" то возможны два варианта:
      - если мы ждем выход то тоже возможны два варианта:
        - время выхода достаточно близко ко времени входа - сохраняем пару
        - время выхода далекот от времени входа - сохраняем пару времени входа
          с нулевым выходом и пару времени выхода с нулевым входом,
          все сбрасываем
      - еслимы не ждем выход - записываем время выхода как пару нулевым входмо,
        все сбрасываем. }
    if Direction = edOut then begin
      if WaitingOut then begin
          if HoursBetween(Table.FieldAsDouble(1), InTime) < FMaxShiftLength then
              AddPair(InTime, Table.FieldAsDouble(1))
            else begin
              AddPair(InTime, 0);
              AddPair(0, Table.FieldAsDouble(1));
            end;
        end else
          AddPair(0, Table.FieldAsDouble(1));
      InTime := 0;
      WaitingOut := False;
    end;
    Table.Next;
  end;
    Result := High(Self.FPairs) + 1;
  finally
    Table.Free;
    DB.Free;
  end;
end;


end.
