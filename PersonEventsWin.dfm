object frmPervonEvents: TfrmPervonEvents
  Left = 197
  Top = 117
  BorderWidth = 20
  Caption = 'MDI Child'
  ClientHeight = 432
  ClientWidth = 906
  Color = clWhite
  ParentFont = True
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object PairGrid: TStringGrid
    Left = 361
    Top = 0
    Width = 545
    Height = 432
    Align = alClient
    ColCount = 4
    Ctl3D = False
    FixedCols = 0
    ParentCtl3D = False
    TabOrder = 0
    ColWidths = (
      58
      90
      89
      104)
  end
  object pnLeft: TPanel
    Left = 0
    Top = 0
    Width = 361
    Height = 432
    Align = alLeft
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 1
    object WebSpeedButton1: TWebSpeedButton
      Left = 88
      Top = 152
      Width = 130
      Height = 40
      Caption = #1056#1072#1089#1089#1095#1080#1090#1072#1090#1100
      Aligment = taCenter
      Color = clGradientInactiveCaption
      SelectColor = clActiveCaption
      ActiveColor = clBlack
      DisableFontColor = clBlack
      SelectFontColor = clBlack
      ActiveFontColor = clBlack
      OnClick = WebSpeedButton1Click
      Margin = 0
      SpaceWidth = 2
    end
    object GridPanel1: TGridPanel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 328
      Height = 137
      Margins.Right = 30
      Align = alTop
      BevelOuter = bvNone
      Color = clWhite
      ColumnCollection = <
        item
          SizeStyle = ssAbsolute
          Value = 120.000000000000000000
        end
        item
          Value = 100.000000000000000000
        end>
      ControlCollection = <
        item
          Column = 0
          Control = Label1
          Row = 0
        end
        item
          Column = 1
          Control = Edit1
          Row = 0
        end
        item
          Column = 0
          Control = Label4
          Row = 1
        end
        item
          Column = 1
          Control = Panel1
          Row = 1
        end
        item
          Column = 0
          Control = Label2
          Row = 2
        end
        item
          Column = 1
          Control = DateTimePicker2
          Row = 2
        end
        item
          Column = 0
          Control = Label3
          Row = 3
        end
        item
          Column = 1
          Control = DateTimePicker1
          Row = 3
        end>
      RowCollection = <
        item
          SizeStyle = ssAbsolute
          Value = 30.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 30.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 30.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 30.000000000000000000
        end
        item
          Value = 100.000000000000000000
        end>
      TabOrder = 0
      object Label1: TLabel
        Left = 0
        Top = 0
        Width = 120
        Height = 13
        Align = alTop
        Caption = 'Id '#1089#1086#1090#1088#1091#1076#1085#1080#1082#1072
        ExplicitLeft = 1
        ExplicitTop = 1
        ExplicitWidth = 73
      end
      object Edit1: TEdit
        AlignWithMargins = True
        Left = 120
        Top = 0
        Width = 58
        Height = 21
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 150
        Margins.Bottom = 0
        Align = alTop
        TabOrder = 0
        Text = 'Edit1'
        ExplicitLeft = 121
        ExplicitTop = 1
        ExplicitWidth = 56
      end
      object Label4: TLabel
        Left = 0
        Top = 30
        Width = 120
        Height = 13
        Align = alTop
        Caption = #1057#1086#1090#1088#1091#1076#1085#1080#1082
        ExplicitLeft = 1
        ExplicitTop = 31
        ExplicitWidth = 56
      end
      object Panel1: TPanel
        Left = 120
        Top = 30
        Width = 208
        Height = 30
        Align = alClient
        BevelOuter = bvNone
        Color = clWhite
        TabOrder = 1
        ExplicitLeft = 121
        ExplicitTop = 31
        ExplicitWidth = 206
        object SpeedButton1: TSpeedButton
          AlignWithMargins = True
          Left = 185
          Top = 0
          Width = 23
          Height = 21
          Margins.Left = 0
          Margins.Top = 0
          Margins.Right = 0
          Margins.Bottom = 9
          Align = alRight
          Caption = '...'
          Flat = True
          ExplicitLeft = 96
          ExplicitTop = 8
          ExplicitHeight = 22
        end
        object Edit2: TEdit
          AlignWithMargins = True
          Left = 0
          Top = 0
          Width = 185
          Height = 21
          Margins.Left = 0
          Margins.Top = 0
          Margins.Right = 0
          Margins.Bottom = 9
          Align = alClient
          ReadOnly = True
          TabOrder = 0
          Text = 'Edit2'
          ExplicitWidth = 183
        end
      end
      object Label2: TLabel
        Left = 0
        Top = 60
        Width = 120
        Height = 13
        Align = alTop
        Caption = #1044#1072#1090#1072' '#1085#1072#1095#1072#1083#1072
        ExplicitLeft = 1
        ExplicitTop = 61
        ExplicitWidth = 65
      end
      object DateTimePicker2: TDateTimePicker
        AlignWithMargins = True
        Left = 120
        Top = 60
        Width = 78
        Height = 21
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 130
        Margins.Bottom = 0
        Align = alTop
        Date = 45795.816870324070000000
        Time = 45795.816870324070000000
        TabOrder = 2
        ExplicitLeft = 121
        ExplicitTop = 61
        ExplicitWidth = 76
      end
      object Label3: TLabel
        Left = 0
        Top = 90
        Width = 120
        Height = 13
        Align = alTop
        Caption = #1044#1072#1090#1072' '#1086#1082#1085#1095#1072#1085#1080#1103
        ExplicitLeft = 1
        ExplicitTop = 91
        ExplicitWidth = 77
      end
      object DateTimePicker1: TDateTimePicker
        AlignWithMargins = True
        Left = 120
        Top = 90
        Width = 78
        Height = 21
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 130
        Margins.Bottom = 0
        Align = alTop
        Date = 45795.816858587960000000
        Time = 45795.816858587960000000
        TabOrder = 3
        ExplicitLeft = 121
        ExplicitTop = 91
        ExplicitWidth = 76
      end
    end
  end
end
