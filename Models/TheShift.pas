unit TheShift;

interface

uses
  SysUtils, DateUtils, Contnrs, Controls;

type
  TBreak = class
  private
    FTitle: string;
    FStartTime: TTime;
    FLength: TTime;
    FLateness: integer;
    function GetLengthOfMinutes: integer;
  public
    property Title: string read FTitle write FTitle;
    property StartTime: TTime read FStartTime write FStartTime;
    property Length: TTime read FLength write FLength;
    property Lateness: integer read FLateness write FLateness;
    property LengthOfMinutes: integer read GetLengthOfMinutes;
  end;

  TShift = class(TObject)
  private
    FTitle: string;
    FStartTime: TTime;
    FLength: TTime;
    FEnterStart: TTime;
    FEnterFinish: TTime;
    FExitStart: TTime;
    FExitFinish: TTime;
    FLateness: integer;
    FOverwork: boolean;
    FBreaks: TObjectList;
    function GetLengthOfMinutes: integer;
    function GetBreakCount: integer;
    function GetBreak(I: integer): TBreak;
  public
    constructor Create;
    destructor Destroy; override;
    property Title: string read FTitle write FTitle;
    property StartTime: TTime read FStartTime write FStartTime;
    property Length: TTime read FLength write FLength;
    property LengthOfMinutes: integer read GetLengthOfMinutes;
    property EnterStart: TTime read FEnterStart write FEnterStart;
    property EnterFinish: TTime read FEnterFinish write FEnterFinish;
    property ExitStart: TTime read FExitStart write FExitStart;
    property ExitFinish: TTime read FExitFinish write FExitFinish;
    property Lateness: integer read FLateness write FLateness;
    property BreakCount: integer read GetBreakCount;
    property Break[I: integer]: TBreak read GetBreak;
  end;

implementation

{ TBreak }

function TBreak.GetLengthOfMinutes: integer;
begin
  Result := HourOf(FLength) * 60 + MinuteOf(FLength);
end;

{ TShift }

constructor TShift.Create;
begin
  inherited Create;
  FTitle := 'Стандартный рабочий день';
  FStartTime := StrToTime('20:00');
  FLength := StrToTime('12:00');
  FEnterStart := StrToTime('19:00');
  FEnterFinish := StrToTime('21:00');
  FExitStart := StrToTime('07:00');
  FExitFinish := StrToTime('09:00');
  FLateness := 0;
  FOverwork := False;
  FBreaks := TObjectList.Create(True);
  FBreaks.Add(TBreak.Create);
  with TBreak(FBreaks[0]) do begin
    Title := 'Обед';
    StartTime := StrToTime('23:30');
    Length := StrToTime('01:00');
    Lateness := 0;
  end;
  FBreaks.Add(TBreak.Create);
  with TBreak(FBreaks[1]) do begin
    Title := 'Доп. перерыв';
    StartTime := StrToTime('03:30');
    Length := StrToTime('00:30');
    Lateness := 0;
  end;
end;

destructor TShift.Destroy;
begin
  FBreaks.Free;
  inherited Destroy;
end;

function TShift.GetLengthOfMinutes: integer;
begin
  Result := HourOf(FLength) * 60 + MinuteOf(FLength);
end;

function TShift.GetBreakCount: integer;
begin
  Result := FBreaks.Count;
end;

function TShift.GetBreak(I: integer): TBreak;
begin
  Result := TBreak(FBreaks[I]);
end;

end.
