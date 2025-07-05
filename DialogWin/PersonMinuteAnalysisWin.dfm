object frmPersonMinuteAnalysis: TfrmPersonMinuteAnalysis
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1047#1072' '#1086#1076#1080#1085' '#1076#1077#1085#1100
  ClientHeight = 347
  ClientWidth = 794
  Color = clWhite
  Constraints.MinHeight = 200
  Constraints.MinWidth = 400
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnMain: TPanel
    Left = 0
    Top = 185
    Width = 794
    Height = 162
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 20
    Color = clWhite
    TabOrder = 0
    object ScrollBox1: TScrollBox
      Left = 20
      Top = 20
      Width = 754
      Height = 115
      Align = alTop
      Ctl3D = False
      ParentCtl3D = False
      TabOrder = 0
      object imgBmp: TImage
        Left = 0
        Top = 0
        Width = 105
        Height = 105
      end
    end
  end
  object pnTop: TPanel
    Left = 0
    Top = 0
    Width = 794
    Height = 185
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 1
    object sgPairs: TStringGrid
      AlignWithMargins = True
      Left = 506
      Top = 20
      Width = 268
      Height = 165
      Margins.Left = 0
      Margins.Top = 20
      Margins.Right = 20
      Margins.Bottom = 0
      Align = alRight
      ColCount = 2
      Ctl3D = False
      DefaultColWidth = 120
      FixedCols = 0
      ParentCtl3D = False
      TabOrder = 0
    end
    object pnText: TPanel
      AlignWithMargins = True
      Left = 20
      Top = 20
      Width = 483
      Height = 165
      Margins.Left = 20
      Margins.Top = 20
      Margins.Bottom = 0
      Align = alClient
      BevelOuter = bvNone
      Color = clWhite
      TabOrder = 1
      object lbDate: TLabel
        AlignWithMargins = True
        Left = 0
        Top = 0
        Width = 483
        Height = 14
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 10
        Align = alTop
        Caption = 'lbDate'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitWidth = 40
      end
      object lbPerson: TLabel
        AlignWithMargins = True
        Left = 0
        Top = 24
        Width = 483
        Height = 16
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 10
        Align = alTop
        Caption = 'lbPerson'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clNavy
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitWidth = 56
      end
      object Label1: TLabel
        Left = 0
        Top = 58
        Width = 160
        Height = 13
        Caption = #1042#1089#1077#1075#1086' '#1076#1086#1083#1078#1085#1086' '#1073#1099#1090#1100' '#1087#1086' '#1075#1088#1072#1092#1080#1082#1091
      end
      object Label2: TLabel
        Left = 0
        Top = 79
        Width = 139
        Height = 13
        Caption = #1042#1089#1077#1075#1086' '#1085#1072#1093#1086#1076#1080#1083#1089#1103' '#1085#1072' '#1088#1072#1073#1086#1090#1077
      end
      object Label3: TLabel
        Left = 0
        Top = 121
        Width = 107
        Height = 13
        Caption = #1055#1088#1086#1075#1091#1083#1099', '#1085#1072#1088#1091#1096#1077#1085#1080#1103
      end
      object Label4: TLabel
        Left = 0
        Top = 142
        Width = 67
        Height = 13
        Caption = #1055#1077#1088#1077#1088#1072#1073#1086#1090#1082#1072
      end
      object lbScheduleTime: TLabel
        Left = 280
        Top = 58
        Width = 89
        Height = 13
        Caption = 'lbScheduleTime'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lbTotalWorkTime: TLabel
        Left = 280
        Top = 79
        Width = 79
        Height = 13
        Caption = 'lbTotalWorkTime'
      end
      object lbHookyTime: TLabel
        Left = 280
        Top = 121
        Width = 60
        Height = 13
        Caption = 'lbHookyTime'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lbOvertime: TLabel
        Left = 280
        Top = 142
        Width = 52
        Height = 13
        Caption = 'lbOvertime'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGreen
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label5: TLabel
        Left = 0
        Top = 100
        Width = 132
        Height = 13
        Caption = #1059#1095#1090#1077#1085#1086' '#1088#1072#1073#1086#1095#1077#1075#1086' '#1074#1088#1077#1084#1077#1085#1080
      end
      object lbWorkToReport: TLabel
        Left = 280
        Top = 100
        Width = 93
        Height = 13
        Caption = 'lbWorkToReport'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
  end
end
