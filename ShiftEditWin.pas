unit ShiftEditWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, TWebButton, ExtCtrls, ComCtrls, StdCtrls, TheShift, TheBreaks,
  ShiftPresent;

type
  TfrmShiftEdit = class(TForm)
    Shape1: TShape;
    btnCancel: TWebSpeedButton;
    btnsave: TWebSpeedButton;
    Label3: TLabel;
    edTitle: TEdit;
    Label2: TLabel;
    dtpStartTime: TDateTimePicker;
    Label1: TLabel;
    dtpInStart: TDateTimePicker;
    Label4: TLabel;
    edLateness: TEdit;
    Label5: TLabel;
    dtpLength: TDateTimePicker;
    Label6: TLabel;
    dtpInFinish: TDateTimePicker;
    dtpOutFinish: TDateTimePicker;
    Label7: TLabel;
    dtpOutStart: TDateTimePicker;
    Label8: TLabel;
    Label9: TLabel;
    lbBreaks: TListBox;
    pnPicture: TPanel;
    btnBreakAdd: TWebSpeedButton;
    btnBreakDelete: TWebSpeedButton;
    procedure btnBreakAddClick(Sender: TObject);
    procedure lbBreaksClick(Sender: TObject);
    procedure btnBreakDeleteClick(Sender: TObject);
    procedure edLatenessChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnsaveClick(Sender: TObject);
    procedure edTitleChange(Sender: TObject);
    procedure edLatenessKeyPress(Sender: TObject; var Key: Char);
    procedure OnChangeTime(Sender: TObject);
  private
    { Private declarations }
    FPresent: TShiftPresent;
    FShift: TShift;
    FBreaksList: TBreakList;
    procedure UpdateBreaksList;
    procedure SetSaveBtnEnabled;
  public
    { Public declarations }
    function Edit(var Shift: TShift; BreaksList: TBreakList): boolean;
  end;

var
  frmShiftEdit: TfrmShiftEdit;

implementation

{$R *.dfm}

uses ObjectListWin, ActiveX;

procedure TfrmShiftEdit.FormCreate(Sender: TObject);
begin
  FPresent := TShiftPresent.Create(Self.pnPicture);
  FPresent.Align := alClient;
  FShift := TShift.Create;
  pnPicture.InsertControl(FPresent);
end;

procedure TfrmShiftEdit.FormDestroy(Sender: TObject);
begin
  FPresent.Free;
  FShift.Free;
end;

{ Основная процедура. }

function TfrmShiftEdit.Edit(var Shift: TShift; BreaksList: TBreakList): boolean;
begin
  FBreaksList := BreaksList;
  FShift.Copy(Shift);
  edTitle.Text := FShift.Title;
  dtpStartTime.Time := FShift.StartTime;
  dtpLength.Time := FShift.Length;
  dtpInStart.Time := FShift.InStart;
  dtpInFinish.Time := FShift.InFinish;
  dtpOutStart.Time := FShift.OutStart;
  dtpOutFinish.Time := FShift.OutFinish;
  edLateness.Text := IntToStr(FShift.Lateness);
  FPresent.Shift := FShift;
  UpdateBreaksList;
  btnBreakDelete.Enabled := (FShift.Breaks.Count > 0)
    and (lbBreaks.ItemIndex >= 0);
  SetSaveBtnEnabled;

  Result := (Self.ShowModal = mrOk);
  if Result then Shift.Copy(FShift);
end;

{ События полей ввода. }

procedure TfrmShiftEdit.OnChangeTime(Sender: TObject);
begin
  FShift.StartTime := dtpStartTime.Time;
  FShift.Length := dtpLength.Time;
  FShift.InStart := dtpInStart.Time;
  FShift.InFinish := dtpInFinish.Time;
  FShift.OutStart := dtpOutStart.Time;
  FShift.OutFinish := dtpOutFinish.Time;
  SetSaveBtnEnabled;
  FPresent.Repaint;
end;

procedure TfrmShiftEdit.edLatenessChange(Sender: TObject);
begin
  FShift.Lateness := StrToIntDef(edLateness.Text, 0);
end;

procedure TfrmShiftEdit.edLatenessKeyPress(Sender: TObject; var Key: Char);
const
  Toolskey = [13, 8, 46, 38..40, 48..57];
begin
  if not(ord(Key) in ToolsKey) then Key := chr(0);
end;

procedure TfrmShiftEdit.edTitleChange(Sender: TObject);
begin
  FShift.Title := edTitle.Text;
  Self.SetSaveBtnEnabled;
end;

{ Кнопки сохранения и отмены. }

procedure TfrmShiftEdit.SetSaveBtnEnabled;
begin
  btnSave.Enabled := (not (FShift.Incorrect))
    and (Length(FShift.Title) > 0);
end;

procedure TfrmShiftEdit.btnCancelClick(Sender: TObject);
begin
  Self.ModalResult := mrCancel;
end;

procedure TfrmShiftEdit.btnsaveClick(Sender: TObject);
begin
  Self.ModalResult := mrOk;
end;

{ Методы списка перерывов. }

procedure TfrmShiftEdit.UpdateBreaksList;
var
  I: integer;
  Break: TBreak;
begin
  lbBreaks.Clear;
  for I := 0 to FShift.Breaks.Count - 1 do begin
    Break := FShift.Breaks.Items[i];
    lbBreaks.Items.AddObject(Break.Title, Break);
  end;
end;

procedure TfrmShiftEdit.lbBreaksClick(Sender: TObject);
begin
  btnBreakDelete.Enabled := (FShift.Breaks.Count > 0)
    and (lbBreaks.ItemIndex >= 0);
end;

procedure TfrmShiftEdit.btnBreakAddClick(Sender: TObject);
var
  NewBreak, Break: TBreak;
  I: integer;
  Text: string;
begin
  NewBreak := frmObjectList.GetBreak(FBreaksList);
  if NewBreak = nil then Exit;
  Text := '';
  I := 0;
  while (I < lbBreaks.Count) and (Length(Text) = 0) do begin
    Break := TBreak(lbBreaks.Items.Objects[I]);
    if IsEqualGUID(Break.GUID, NewBreak.GUID) then begin
      lbBreaks.ItemIndex := I;
      Exit;
    end;
    if ((NewBreak.StartTime > Break.StartTime)
      and (NewBreak.StartTime < Break.EndTime))
      or ((NewBreak.EndTime > Break.StartTime)
      and (NewBreak.EndTime < Break.EndTime)) then
        Text := 'Выбранный перерыв пересекается с другим !';
    inc(I);
  end;
  if Length(Text) = 0 then begin
    FShift.AddBreak(NewBreak);
    UpdateBreaksList;
    FPresent.Repaint;
  end else MessageDlg(Text, mtWarning, [mbOk], 0);
end;

procedure TfrmShiftEdit.btnBreakDeleteClick(Sender: TObject);
var
  Obj: TObject;
begin
  if lbBreaks.ItemIndex < 0 then Exit;
  Obj := lbBreaks.Items.Objects[lbBreaks.ItemIndex];
  if not Assigned(Obj) then Exit;
  FShift.Breaks.Extract(Obj);
  btnBreakDelete.Enabled := (FShift.Breaks.Count > 0);
  UpdateBreaksList;
  FPresent.Repaint;
end;

end.
