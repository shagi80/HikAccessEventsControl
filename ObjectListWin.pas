unit ObjectListWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, TWebButton, StdCtrls, TheBreaks, Theshift;

type
  TfrmObjectList = class(TForm)
    lbList: TListBox;
    btnOk: TWebSpeedButton;
    procedure lbListClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
    FSelectObject: TObject;
  public
    { Public declarations }
    function GetBreak(BreaksList: TBreakList): TBreak;
    function GetShift(ShiftsList: TShiftList): TShift;
  end;

var
  frmObjectList: TfrmObjectList;

implementation

{$R *.dfm}

function TfrmObjectList.GetBreak(BreaksList: TBreakList): TBreak;
var
  I: integer;
  Break: TBreak;
begin
  lbList.Clear;
  for I := 0 to BreaksList.Count - 1 do begin
    Break := BreaksList.Items[i];
    lbList.Items.AddObject(Break.Title, Break);
  end;
  btnOk.Enabled := False;

  if Self.ShowModal = mrOk then Result := TBreak(FSelectObject)
    else Result := nil;
end;

function TfrmObjectList.GetShift(ShiftsList: TShiftList): TShift;
var
  I: integer;
  Shift: TShift;
begin
  lbList.Clear;
  for I := 0 to ShiftsList.Count - 1 do begin
    Shift := ShiftsList.Items[i];
    lbList.Items.AddObject(Shift.Title, Shift);
  end;
  btnOk.Enabled := False;

  if Self.ShowModal = mrOk then Result := TShift(FSelectObject)
    else Result := nil;
end;

procedure TfrmObjectList.lbListClick(Sender: TObject);
begin
  btnOk.Enabled := (lbList.ItemIndex >= 0);
end;

procedure TfrmObjectList.btnOkClick(Sender: TObject);
begin
  if lbList.ItemIndex < 0 then Exit;
  FSelectObject := lbList.Items.Objects[lbList.ItemIndex];
  if not Assigned(FSelectObject) then Exit;
  Self.ModalResult := mrOk;
end;

end.
