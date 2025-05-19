unit PersonEventsWin;

interface

uses Windows, Classes, Graphics, Forms, Controls, StdCtrls, TWebButton,
  ComCtrls, ExtCtrls, Grids, Buttons;

type
  TfrmPervonEvents = class(TForm)
    PairGrid: TStringGrid;
    pnLeft: TPanel;
    WebSpeedButton1: TWebSpeedButton;
    GridPanel1: TGridPanel;
    Label1: TLabel;
    Edit1: TEdit;
    Label4: TLabel;
    Panel1: TPanel;
    Label2: TLabel;
    DateTimePicker2: TDateTimePicker;
    Label3: TLabel;
    DateTimePicker1: TDateTimePicker;
    Edit2: TEdit;
    SpeedButton1: TSpeedButton;
    procedure WebSpeedButton1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses  TheSettings, SysUtils, DateUtils, TheEventPairs;

procedure TfrmPervonEvents.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmPervonEvents.WebSpeedButton1Click(Sender: TObject);
var
  Pairs: TEmplPairs;
  Date, PreviosDate: TDate;
  I: integer;
begin
  Pairs := TEmplPairs.Create('1', 10);
  Pairs.CreatePairsFromBD(Settings.GetInstance.DBFileName,
    StrToDateTime('16.04.2025'), now);

  PairGrid.RowCount := Pairs.Count + 1;
  for I := 0 to Pairs.Count - 1 do begin
    PairGrid.Cells[0, I + 1] := IntToStr(I + 1);
    if Pairs.Pair[I].InTime > 0 then Date := DateOf(Pairs.Pair[I].InTime)
      else Date := DateOf(Pairs.Pair[I].OutTime);
    if I = 0 then PairGrid.Cells[1, I + 1] := DateToStr(Date)
      else begin
        if Pairs.Pair[I - 1].InTime > 0 then
            PreviosDate := DateOf(Pairs.Pair[I - 1].InTime)
          else 
            PreviosDate := DateOf(Pairs.Pair[I - 1].OutTime);
        if PreviosDate = Date then PairGrid.Cells[1, I + 1] := ''
          else PairGrid.Cells[1, I + 1] := DateToStr(Date);
      end;


      
      
    
    if Pairs.Pair[I].InTime = 0  then PairGrid.Cells[2, I + 1] := '-'
      else PairGrid.Cells[2, I + 1] := DateTimeToStr(Pairs.Pair[I].InTime);
    if Pairs.Pair[I].OutTime = 0  then PairGrid.Cells[3, I + 1] := '-'
      else PairGrid.Cells[3, I + 1] := DateTimeToStr(Pairs.Pair[I].OutTime);
  end;
  Pairs.Free;

end;

end.
