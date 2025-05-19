unit APIProcessWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, TWebButton, ExtCtrls, TheAPIThreadEventsLoader,
  TheAPIThreadStateLoader, Grids;

type
  TfrmProcess = class(TForm)
    Label1: TLabel;
    Shape1: TShape;
    pnMessage: TPanel;
    btnProcess: TWebSpeedButton;
    lbProcess: TLabel;
    pbProcess: TProgressBar;
    btnUpdate: TWebSpeedButton;
    grStatuses: TStringGrid;
    tmProgress: TTimer;
    procedure btnUpdateClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tmProgressTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FEventsCount: integer;
    FEndTime: TDateTime;
    FDevStatuses: TDeviceStatuses;
    StateLoader: TAPIStateLoader;
    EventsLoader: TAPIThreadEventsLoader;
    procedure ResponseState(Sender: TObject);
    procedure ResponseEvents(Sender: TObject);
    procedure StopResponse(Sender: TObject);
    procedure OnGetState(Statuses: TDeviceStatuses);
    procedure OndGetPortion(Pos: integer; Device, Code: string);
    procedure OnGetAll(Count: integer);
    procedure PrepareBtnForStop;
    procedure PrepareBtnForBegin;
  public
    { Public declarations }
  end;



implementation

{$R *.dfm}

uses
  DateUtils;


procedure TfrmProcess.FormShow(Sender: TObject);
begin
  grStatuses.RowCount := 2;
  grStatuses.Rows[1].Clear;
  grStatuses.Cells[0, 0] := 'Устройство';
  grStatuses.Cells[1, 0] := 'Стат';
  grStatuses.Cells[2, 0] := 'Послед запись';
  grStatuses.Cells[3, 0] := 'Кол записей';
  Self.ResponseState(Self);
end;

procedure TfrmProcess.btnUpdateClick(Sender: TObject);
begin
  StopResponse(self);
  ResponseState(self);
end;

procedure TfrmProcess.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  StopResponse(Self);
  Action := caFree;
end;

procedure TfrmProcess.FormResize(Sender: TObject);
var
  Width, I: integer;
begin
  Width := 0;
  for I := 1 to grStatuses.ColCount - 1 do
    Width := Width + grStatuses.ColWidths[I] + 1;
  grStatuses.ColWidths[0] := grStatuses.ClientWidth - Width - 2;
end;

procedure TfrmProcess.tmProgressTimer(Sender: TObject);
begin
  pbProcess.Position := pbProcess.Position + 1;
  if pbProcess.Position >= pbProcess.Max then pbProcess.Position := 0;
end;

//

procedure TfrmProcess.ResponseState(Sender: TObject);
begin
  PrepareBtnForStop;
  FEndTime := Now;
  grStatuses.RowCount := 2;
  grStatuses.Rows[1].Clear;
  Self.FormResize(Self);
  lbProcess.Font.Color := clNavy;
  lbProcess.Caption := 'Идет обновление статуса ...';
  pbProcess.Position := 0;
  pbProcess.Max := 100;
  tmProgress.Enabled := True;
  StateLoader := TAPIStateLoader.Create(FEndTime);
  StateLoader.OnGetdata := Self.OnGetState;
  StateLoader.Resume;
end;

procedure TfrmProcess.StopResponse(Sender: TObject);
begin
  if Assigned(StateLoader) then begin
    StateLoader.OnGetdata := nil;
    StateLoader.Terminate;
    StateLoader := nil;
  end;
  if Assigned(EventsLoader) then begin
    EventsLoader.OnGetPortion := nil;
    EventsLoader.OnGetAll := nil;
    EventsLoader.Terminate;
    EventsLoader := nil;
  end;
  SetLength(FDevStatuses, 0);
  lbProcess.Font.Color := clRed;
  lbProcess.Caption := 'Процесс остановлен пользователем !';
  PrepareBtnForBegin;
  btnProcess.Enabled := False;
  tmProgress.Enabled := False;
end;

//

procedure TfrmProcess.PrepareBtnForStop;
begin
  btnProcess.Caption := 'Остановить';
  btnProcess.OnClick := StopResponse;
  btnUpdate.Enabled := False;
end;

procedure TfrmProcess.PrepareBtnForBegin;
begin
  btnProcess.Caption := 'Начать';
  btnProcess.OnClick := ResponseEvents;
  btnUpdate.Enabled := True;
end;

procedure TfrmProcess.ResponseEvents(Sender: TObject);
begin
  PrepareBtnForStop;
  lbProcess.Font.Color := clNavy;
  lbProcess.Caption := 'Начинается получение данных ...';
  pbProcess.Position := 0;
  EventsLoader := TAPIThreadEventsLoader.Create(FEndTime);
  EventsLoader.OnGetPortion := Self.OndGetPortion;
  EventsLoader.OnGetAll := Self.OnGetAll;
  EventsLoader.Resume;
end;

procedure TfrmProcess.OnGetState(Statuses: TDeviceStatuses);
var
  I: integer;
  AllDevEnabled: boolean;
begin
  tmProgress.Enabled := False;
  AllDevEnabled := True;
  FEventsCount := 0;
  if High(Statuses)  >= 0 then grStatuses.RowCount := High(Statuses) + 2;
  SetLength(FDevStatuses, High(Statuses) + 1);
  for I := 0 to High(Statuses) do begin
    FDevStatuses[I] := Statuses[i];
    grStatuses.Cells[0, i + 1] := Statuses[i].Name;
    if Statuses[i].Enabled then grStatuses.Cells[1, i + 1] := 'OK'
      else begin
        grStatuses.Cells[1, i + 1] := '-';
        AllDevEnabled := False;
      end;
    grStatuses.Cells[2, i + 1] := DateTimeToStr(Statuses[i].LastTimeInBD);
    grStatuses.Cells[3, i + 1] := IntToStr(Statuses[i].EventsCount);
    FEventsCount := FEventsCount + Statuses[i].EventsCount;
  end;
  Self.FormResize(Self);

  btnProcess.Enabled := AllDevEnabled;
  if not AllDevEnabled then begin
    lbProcess.Font.Color := clRed;
    lbProcess.Caption := 'Нет связи с некоторыми устройствами !';
  end else
    if FEventsCount > 0 then begin
      lbProcess.Font.Color := clGreen;
      lbProcess.Caption := 'Найдено ' + IntToStr(FEventsCount)
        + ' событий';
      pbProcess.Position := 0;
      pbProcess.Max := FEventsCount;
    end else begin
      lbProcess.Font.Color := clGreen;
      lbProcess.Caption := 'Нет данных для обновления !'
    end;
  PrepareBtnForBegin;
end;

procedure TfrmProcess.OndGetPortion(Pos: integer; Device, Code: string);
var
  Text: string;
begin
  lbProcess.Font.Color := clNavy;
  Text :=  'Получение событий от устройства "' + Device
    + '" по коду "' + Code + '" '
    + '(всего ' + IntToStr(Pos)
    + '/' + IntToStr(FEventsCount) + ')...';
  lbProcess.Caption := Text;
  pbProcess.Position := Pos;
end;

procedure TfrmProcess.OnGetAll(Count: integer);
begin
  lbProcess.Font.Color := clGreen;
  lbProcess.Caption := 'Все события успешно получены !';
  PrepareBtnForBegin;
  btnProcess.Enabled := False;
end;


end.
