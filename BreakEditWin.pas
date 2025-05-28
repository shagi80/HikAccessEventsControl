unit BreakEditWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, TWebButton, ExtCtrls, TheBreaks;

type
  TfrmBreakEdit = class(TForm)
    Shape1: TShape;
    btnsave: TWebSpeedButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edTitle: TEdit;
    dtpStartTime: TDateTimePicker;
    dtpLength: TDateTimePicker;
    edLateness: TEdit;
    Label4: TLabel;
    btnCancel: TWebSpeedButton;
    procedure dtpLengthChange(Sender: TObject);
    procedure edTitleChange(Sender: TObject);
    procedure edLatenessKeyPress(Sender: TObject; var Key: Char);
    procedure btnCancelClick(Sender: TObject);
    procedure btnsaveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function Edit(var Break: TBreak): boolean;
  end;

var
  frmBreakEdit: TfrmBreakEdit;

implementation

{$R *.dfm}

uses DateUtils;


procedure TfrmBreakEdit.btnCancelClick(Sender: TObject);
begin
  Self.ModalResult := mrCancel;
end;

procedure TfrmBreakEdit.btnsaveClick(Sender: TObject);
begin
  Self.ModalResult := mrOk;
end;

procedure TfrmBreakEdit.dtpLengthChange(Sender: TObject);
begin
  btnSave.Enabled := (MinuteOfTheDay(dtpLength.Time) > 0)
end;

function TfrmBreakEdit.Edit(var Break: TBreak): boolean;
begin
  edTitle.Text := Break.Title;
  dtpStartTime.Time := Break.StartTime;
  dtpLength.Time := Break.Length;
  edLateness.Text := IntToStr(Break.Lateness);
  Result := (Self.ShowModal = mrOk);
  if Result then begin
    Break := Break;
    Break.Title := edTitle.Text;
    Break.StartTime := dtpStartTime.Time;
    Break.Length := dtpLength.Time;
    Break.Lateness := StrToIntDef(edLateness.Text, 0);
  end;
end;

procedure TfrmBreakEdit.edLatenessKeyPress(Sender: TObject; var Key: Char);
const
  Toolskey = [13, 8, 46, 38..40, 48..57];
begin
  if not(ord(Key) in ToolsKey) then Key := chr(0);
end;

procedure TfrmBreakEdit.edTitleChange(Sender: TObject);
begin
  btnSave.Enabled := Length(edTitle.Text) > 0;
end;

end.
