unit ScheduleEditWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, TWebButton, StdCtrls, ComCtrls, Grids, TheShift,
  TheSchedule,  ScheduleTemplatePresent, TheBreaks;

type
  TfrmScheduleEdit = class(TForm)
    Label3: TLabel;
    Label2: TLabel;
    edTitle: TEdit;
    Shape1: TShape;
    btnsave: TWebSpeedButton;
    btnCancel: TWebSpeedButton;
    Label5: TLabel;
    dtpStartDate: TDateTimePicker;
    edLateness: TEdit;
    Label1: TLabel;
    cbType: TComboBox;
    pnPicture: TScrollBox;
    procedure edTitleChange(Sender: TObject);
    procedure cbTypeChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edLatenessKeyPress(Sender: TObject; var Key: Char);
    procedure btnCancelClick(Sender: TObject);
    procedure btnsaveClick(Sender: TObject);
    procedure edLatenessChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FSchedule: TSchedule;
    FShiftList: TShiftList;
    FPresent: TScheduleTemplatePresent;
    procedure OnClickAddShiftBtn(DayNum: integer);
    procedure OnClickDelShiftBtn(DayNum: integer; Shift: TShift);
    procedure SetSaveBtnEnabled;
  public
    { Public declarations }
    function Edit(var Schedule: TSchedule; ShiftList: TShiftList): boolean;
  end;

var
  frmScheduleEdit: TfrmScheduleEdit;

implementation

{$R *.dfm}

uses  TheSettings, DateUtils, ObjectListWin;


procedure TfrmScheduleEdit.FormCreate(Sender: TObject);
begin
  Self.DoubleBuffered := True;
  FSchedule := TSchedule.Create;
  FPresent := TScheduleTemplatePresent.Create(pnPicture);
  FPresent.Top := 4;
  FPresent.Left := 4;
  FPresent.OnClickAddButton := Self.OnClickAddShiftBtn;
  FPresent.OnClickDeleteButton := Self.OnClickDelShiftBtn;
  pnPicture.InsertControl(FPresent);
end;

procedure TfrmScheduleEdit.FormDestroy(Sender: TObject);
begin
  FSchedule.Free;
  FPresent.Free;
end;

{ Основная процедура. }

function TfrmScheduleEdit.Edit(var Schedule: TSchedule; ShiftList: TShiftList): boolean;
begin
  FShiftList := ShiftList;
  FSchedule.Copy(Schedule);
  edTitle.Text := FSchedule.Title;
  dtpStartDate.Date := FSchedule.StartDate;
  edLateness.Text := IntToStr(FSchedule.DayCount);
  FPresent.Schedule := FSchedule;
  cbType.ItemIndex := Ord(FSchedule.ScheduleType);
  SetSaveBtnEnabled;

  Result := (Self.ShowModal = mrOk);
  if Result then begin
    FSchedule.StartDate := DateOf(dtpStartDate.Date);
    Schedule.Copy(FSchedule);
  end;
end;

{ Изменение списка смен икол-ва дней.}

procedure TfrmScheduleEdit.cbTypeChange(Sender: TObject);
var
  NewType: TScheduleType;
begin
  NewType := stWeek;
  case cbType.ItemIndex of
    0: NewType := stWeek;
    1: NewType := stPeriod;
  end;
  if FSchedule.ScheduleType = NewType then Exit;
  if (FSchedule.ScheduleType <> NewType) and (NewType = stWeek) then
    edLateness.Text := '7';
  FSchedule.ScheduleType := NewType;
  Self.edLatenessChange(Self);
end;

procedure TfrmScheduleEdit.OnClickAddShiftBtn(DayNum: integer);
var
  NewShift, Shift: TShift;
  I: integer;
  Text: string;
begin
  NewShift := frmObjectList.GetShift(FShiftList);
  if NewShift = nil then Exit;
  Text := '';
  I := 0;
  while (I < FSchedule.Day[DayNum].Count) and (Length(Text) = 0) do begin
    Shift := FSchedule.Day[DayNum].Items[I];
    if IsEqualGUID(Shift.GUID, NewShift.GUID) then Exit;
    if ((NewShift.StartTime > Shift.StartTime)
      and (NewShift.StartTime < Shift.EndTime))
      or ((NewShift.EndTime > Shift.StartTime)
      and (NewShift.EndTime < Shift.EndTime)) then
        Text := 'Смена пересекается с другой в этом же дне !';
    inc(I);
  end;
  if Length(Text) = 0 then begin
    FSchedule.AddShiftToDay(DayNum, NewShift);
    FPresent.UpdateSchedule;
    SetSaveBtnEnabled;
  end else MessageDlg(Text, mtWarning, [mbOk], 0);
end;

procedure TfrmScheduleEdit.OnClickDelShiftBtn(DayNum: Integer; Shift: TShift);
var
  Text: string;
begin
  Text := 'Вы действительно хотите удалить смену "'
    + Shift.Title + '" из ' + IntToStr(DayNum + 1) + ' дня графика ?';
  if not (MessageDlg(Text, mtConfirmation, [mbYes, mbNo], 0) = mrYes) then Exit;
  FSchedule.Day[DayNum].Extract(Shift);
  FPresent.UpdateSchedule;
  SetSaveBtnEnabled;
end;

procedure TfrmScheduleEdit.edLatenessChange(Sender: TObject);
begin
  SetSaveBtnEnabled;
  if StrToIntDef(edLateness.Text, 0) > 0 then begin
    FSchedule.DayCount := StrToIntDef(edLateness.Text, 0);
    FPresent.UpdateSchedule;
  end;
end;

procedure TfrmScheduleEdit.edLatenessKeyPress(Sender: TObject; var Key: Char);
const
  Toolskey = [13, 8, 46, 38..40, 48..57];
begin
  if not(ord(Key) in ToolsKey) then Key := chr(0);
end;

procedure TfrmScheduleEdit.edTitleChange(Sender: TObject);
begin
  FSchedule.Title := edTitle.Text;
  SetSaveBtnEnabled;
end;

{ Кнопки сохранения и отмены. }

procedure TfrmScheduleEdit.SetSaveBtnEnabled;
var
  I: integer;
  HaveShift: boolean;
begin
  I := 0;
  HaveShift := False;
  while ((I < FSchedule.DayCount) and (not HaveShift)) do
    if FSchedule.Day[I].Count > 0 then HaveShift := True else inc(I);
  btnSave.Enabled := (HaveShift) and (StrToIntDef(edLateness.Text, 0) > 0)
    and (Length(FSchedule.Title) > 0);
end;

procedure TfrmScheduleEdit.btnCancelClick(Sender: TObject);
begin
  Self.ModalResult := mrCancel;
end;

procedure TfrmScheduleEdit.btnSaveClick(Sender: TObject);
begin
  Self.ModalResult := mrOk;
end;


end.
