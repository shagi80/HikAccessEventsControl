unit ShiftEditWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, TWebButton, ExtCtrls, ComCtrls, StdCtrls;

type
  TForm1 = class(TForm)
    Shape1: TShape;
    btnCancel: TWebSpeedButton;
    btnsave: TWebSpeedButton;
    Label3: TLabel;
    edTitle: TEdit;
    Label2: TLabel;
    dtpStartTime: TDateTimePicker;
    Label1: TLabel;
    dtpLength: TDateTimePicker;
    Label4: TLabel;
    edLateness: TEdit;
    Label5: TLabel;
    DateTimePicker1: TDateTimePicker;
    Label6: TLabel;
    DateTimePicker2: TDateTimePicker;
    DateTimePicker3: TDateTimePicker;
    Label7: TLabel;
    DateTimePicker4: TDateTimePicker;
    Label8: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

end.
