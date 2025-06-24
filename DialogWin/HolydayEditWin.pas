unit HolydayEditWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, TWebButton, ExtCtrls, TheSchedule, TheHolyday, ComCtrls;

type
  TfrmHolydayEdit = class(TForm)
    Shape1: TShape;
    btnsave: TWebSpeedButton;
    btnCancel: TWebSpeedButton;
    Label1: TLabel;
    edTitle: TEdit;
    cbSchedule: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    dtpStartDate: TDateTimePicker;
    dtpStartTime: TDateTimePicker;
    Label5: TLabel;
    dtpEndDate: TDateTimePicker;
    dtpEndTime: TDateTimePicker;
    procedure edTimeKeyPress(Sender: TObject; var Key: Char);
    procedure btnCancelClick(Sender: TObject);
    procedure btnsaveClick(Sender: TObject);
    procedure UpdateBtnState(Sender: TObject);
  private
    { Private declarations }
    procedure UpdateScheduleListForHolyday(ScheduleList: TScheduleList;
      CurSchedule: TSchedule);
    function GetStartTime: TDateTime;
    function GetEndTime: TDateTime;
  public
    { Public declarations }
    function Edit(var Holyday: THolyday; ScheduleList: TScheduleList): boolean;
  end;

var
  frmHolydayEdit: TfrmHolydayEdit;

implementation

{$R *.dfm}

uses DateUtils;

procedure TfrmHolydayEdit.UpdateScheduleListForHolyday(
  ScheduleList: TScheduleList; CurSchedule: TSchedule);
var
  I, ItemInd: integer;
  Schedule: TSchedule;
begin
  cbSchedule.Clear;
  cbSchedule.Items.AddObject('не задан', nil);
  ItemInd := 0;
  for I := 0 to ScheduleList.Count - 1 do begin
    Schedule := ScheduleList.Items[I];
    cbSchedule.Items.AddObject(Schedule.Title, Schedule);
    if Schedule = CurSchedule then ItemInd := I + 1;
  end;
  cbSchedule.ItemIndex := ItemInd;
end;

procedure TfrmHolydayEdit.UpdateBtnState;
begin
  Self.btnSave.Enabled := (Length(edTitle.Text) > 0)
    and (GetEndTime > GetStartTime);
end;

procedure TfrmHolydayEdit.btnCancelClick(Sender: TObject);
begin
  Self.ModalResult := mrCancel;
end;

procedure TfrmHolydayEdit.btnsaveClick(Sender: TObject);
begin
  Self.ModalResult := mrOk;
end;


function TfrmHolydayEdit.GetStartTime: TDateTime;
begin
  Result := IncMinute(StartOfTheDay(dtpStartDate.Date),
    MinuteOfTheDay(dtpStartTime.Time));
end;

function TfrmHolydayEdit.GetEndTime: TDateTime;
begin
  Result := IncMinute(StartOfTheDay(dtpEndDate.Date),
    MinuteOfTheDay(dtpEndTime.Time));
end;

function TfrmHolydayEdit.Edit(var Holyday: THolyday;
  ScheduleList: TScheduleList): boolean;
begin
  dtpStartDate.Date := DateOf(Holyday.StartTime);
  dtpStartTime.Time := TimeOf(Holyday.StartTime);
  dtpEndDate.Date := DateOf(Holyday.EndTime);
  dtpEndTime.Time := TimeOf(Holyday.EndTime);
  edTitle.Text := Holyday.Title;
  UpdateScheduleListForHolyday(ScheduleList, Holyday.Schedule);
  //
  Result := (ShowModal = mrOk);
  if Result then begin
    Holyday.Title := edTitle.Text;
    Holyday.StartTime := Self.GetStartTime;
    Holyday.EndTime := Self.GetEndTime;
    Holyday.Schedule := TSchedule(cbSchedule.Items.Objects[
      cbSchedule.ItemIndex]);
  end;
end;

procedure TfrmHolydayEdit.edTimeKeyPress(Sender: TObject; var Key: Char);
const
  Toolskey = [13, 8, 46, 38..40, 48..57];
begin
  if not(ord(Key) in ToolsKey) then Key := chr(0);
end;

end.
