object frmProgress: TfrmProgress
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  BorderWidth = 20
  Caption = #1042#1099#1087#1086#1083#1085#1103#1077#1090#1089#1103' ...'
  ClientHeight = 50
  ClientWidth = 475
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object lbText: TLabel
    Left = 0
    Top = 0
    Width = 475
    Height = 13
    Align = alTop
    Caption = 'lbText'
    ExplicitWidth = 30
  end
  object pbProgress: TProgressBar
    AlignWithMargins = True
    Left = 3
    Top = 33
    Width = 469
    Height = 7
    Margins.Top = 20
    Align = alTop
    Smooth = True
    Step = 1
    TabOrder = 0
  end
  object tmMain: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Tik
    Left = 440
    Top = 8
  end
end
