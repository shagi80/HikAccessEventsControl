object frmPervonEvents: TfrmPervonEvents
  Left = 197
  Top = 117
  Caption = #1054#1090#1095#1077#1090' '#1087#1086' '#1089#1086#1090#1088#1091#1076#1085#1080#1082#1091
  ClientHeight = 472
  ClientWidth = 1084
  Color = clWhite
  ParentFont = True
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnMain: TPanel
    Left = 161
    Top = 0
    Width = 923
    Height = 472
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 10
    Color = clWhite
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 305
      Top = 73
      Width = 1
      Height = 389
      Color = clSilver
      ParentColor = False
      ExplicitTop = 53
      ExplicitHeight = 409
    end
    object pnPerson: TPanel
      Left = 10
      Top = 73
      Width = 295
      Height = 389
      Align = alLeft
      BevelOuter = bvNone
      BorderWidth = 10
      Caption = #1053#1077#1090' '#1089#1086#1090#1088#1091#1076#1085#1080#1082#1086#1074
      Color = clWhite
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      object Label1: TLabel
        AlignWithMargins = True
        Left = 13
        Top = 13
        Width = 269
        Height = 16
        Margins.Bottom = 10
        Align = alTop
        Caption = #1057#1086#1090#1088#1091#1076#1085#1080#1082#1080
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clNavy
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ExplicitWidth = 68
      end
      object lbPerson: TListBox
        AlignWithMargins = True
        Left = 13
        Top = 42
        Width = 269
        Height = 334
        Align = alClient
        BevelOuter = bvNone
        BorderStyle = bsNone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ItemHeight = 16
        ParentFont = False
        TabOrder = 0
        Visible = False
        OnClick = lbPersonClick
      end
    end
    object pnData: TPanel
      Left = 306
      Top = 73
      Width = 607
      Height = 389
      Align = alClient
      BevelOuter = bvNone
      BorderWidth = 10
      Caption = #1053#1077#1090' '#1076#1072#1085#1085#1099#1093' '#1076#1083#1103' '#1086#1090#1086#1073#1088#1072#1078#1077#1085#1080#1103
      Color = clWhite
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      object Panel4: TPanel
        Left = 10
        Top = 338
        Width = 587
        Height = 41
        Align = alBottom
        Color = clWhite
        TabOrder = 0
        object cbResizeColumn: TCheckBox
          Left = 177
          Top = 1
          Width = 208
          Height = 39
          Align = alLeft
          Caption = #1087#1086#1076#1086#1075#1086#1085#1103#1090#1100' '#1096#1080#1088#1080#1085#1091' '#1082#1086#1083#1086#1085#1086#1082
          TabOrder = 0
          OnClick = cbResizeColumnClick
        end
        object cbWordBreak: TCheckBox
          Left = 1
          Top = 1
          Width = 176
          Height = 39
          Align = alLeft
          Caption = #1087#1077#1088#1077#1085#1086#1089#1080#1090#1100' '#1087#1086' '#1089#1083#1086#1074#1072#1084
          TabOrder = 1
          OnClick = cbWordBreakClick
        end
      end
      object pnTotalResult: TGridPanel
        AlignWithMargins = True
        Left = 10
        Top = 10
        Width = 587
        Height = 71
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 10
        Align = alTop
        BevelOuter = bvNone
        Color = clWhite
        ColumnCollection = <
          item
            SizeStyle = ssAbsolute
            Value = 220.000000000000000000
          end
          item
            SizeStyle = ssAbsolute
            Value = 100.000000000000000000
          end
          item
            SizeStyle = ssAbsolute
            Value = 220.000000000000000000
          end
          item
            SizeStyle = ssAbsolute
            Value = 100.000000000000000000
          end>
        ControlCollection = <
          item
            Column = 0
            Control = Label2
            Row = 0
          end
          item
            Column = 1
            Control = lbTotalSchedule
            Row = 0
          end
          item
            Column = 2
            Control = lbTotalWorkCaption
            Row = 0
          end
          item
            Column = 3
            Control = lbTotalWork
            Row = 0
          end
          item
            Column = 0
            Control = Label10
            Row = 1
          end
          item
            Column = 1
            Control = lbTotalWorkToSchedule
            Row = 1
          end
          item
            Column = 2
            Control = Label12
            Row = 1
          end
          item
            Column = 3
            Control = lbLateToShift
            Row = 1
          end
          item
            Column = 0
            Control = Label14
            Row = 2
          end
          item
            Column = 1
            Control = lbTotalOvertime
            Row = 2
          end
          item
            Column = 2
            Control = Label16
            Row = 2
          end
          item
            Column = 3
            Control = lbTotalHooky
            Row = 2
          end>
        RowCollection = <
          item
            Value = 33.345856604725460000
          end
          item
            Value = 33.321185976672110000
          end
          item
            Value = 33.332957418602430000
          end>
        TabOrder = 1
        Visible = False
        object Label2: TLabel
          Left = 0
          Top = 0
          Width = 220
          Height = 16
          Align = alTop
          Caption = #1042#1088#1077#1084#1103' '#1087#1086' '#1075#1088#1072#1092#1080#1082#1091
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ExplicitWidth = 106
        end
        object lbTotalSchedule: TLabel
          Left = 220
          Top = 0
          Width = 100
          Height = 16
          Align = alTop
          Caption = 'lbTotalSchedule'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ExplicitWidth = 91
        end
        object lbTotalWorkCaption: TLabel
          Left = 320
          Top = 0
          Width = 220
          Height = 16
          Align = alTop
          Caption = #1054#1090#1088#1072#1073#1086#1090#1072#1085#1085#1086' '#1074#1089#1077#1075#1086
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ExplicitWidth = 113
        end
        object lbTotalWork: TLabel
          Left = 540
          Top = 0
          Width = 100
          Height = 16
          Align = alTop
          Caption = 'lbTotalWork'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ExplicitWidth = 69
        end
        object Label10: TLabel
          Left = 0
          Top = 23
          Width = 220
          Height = 16
          Align = alTop
          Caption = #1054#1090#1088#1072#1073#1086#1090#1072#1085#1085#1086' '#1087#1086' '#1075#1088#1072#1092#1080#1082#1091
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ExplicitWidth = 147
        end
        object lbTotalWorkToSchedule: TLabel
          Left = 220
          Top = 23
          Width = 100
          Height = 16
          Align = alTop
          Caption = 'lbTotalWorkToSchedule'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ExplicitWidth = 136
        end
        object Label12: TLabel
          Left = 320
          Top = 23
          Width = 220
          Height = 16
          Align = alTop
          Caption = #1054#1087#1086#1079#1076#1072#1085#1080#1103' '#1085#1072' '#1089#1084#1077#1085#1091
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ExplicitWidth = 120
        end
        object lbLateToShift: TLabel
          Left = 540
          Top = 23
          Width = 100
          Height = 16
          Align = alTop
          Caption = 'lbLateToShift'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ExplicitWidth = 75
        end
        object Label14: TLabel
          Left = 0
          Top = 46
          Width = 220
          Height = 16
          Align = alTop
          Caption = #1054#1090#1088#1072#1073#1086#1090#1072#1085#1085#1086' '#1074#1085#1077' '#1075#1088#1072#1092#1080#1082#1072
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ExplicitWidth = 155
        end
        object lbTotalOvertime: TLabel
          Left = 220
          Top = 46
          Width = 100
          Height = 16
          Align = alTop
          Caption = 'lbTotalOvertime'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ExplicitWidth = 91
        end
        object Label16: TLabel
          Left = 320
          Top = 46
          Width = 220
          Height = 16
          Align = alTop
          Caption = #1042#1089#1077' '#1087#1088#1086#1075#1091#1083#1099' '#1080' '#1085#1072#1088#1091#1096#1077#1085#1080#1103
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ExplicitWidth = 152
        end
        object lbTotalHooky: TLabel
          Left = 540
          Top = 46
          Width = 100
          Height = 16
          Align = alTop
          Caption = 'lbTotalHooky'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ExplicitWidth = 73
        end
      end
    end
    object pnTop: TPanel
      AlignWithMargins = True
      Left = 13
      Top = 13
      Width = 897
      Height = 50
      Margins.Bottom = 10
      Align = alTop
      BevelOuter = bvNone
      Color = clWhite
      TabOrder = 2
      object lbOvertime: TLabel
        Left = 0
        Top = 32
        Width = 3
        Height = 18
        Align = alLeft
        Color = clWhite
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        ExplicitHeight = 13
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 897
        Height = 32
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 2
        Align = alTop
        BevelOuter = bvNone
        Color = clWhite
        TabOrder = 0
        object lbMessage: TLabel
          Left = 0
          Top = 0
          Width = 4
          Height = 32
          Align = alLeft
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          Layout = tlCenter
          ExplicitHeight = 16
        end
        object btnClose: TWebSpeedButton
          AlignWithMargins = True
          Left = 861
          Top = 0
          Width = 36
          Height = 32
          Margins.Top = 0
          Margins.Right = 0
          Margins.Bottom = 0
          Aligment = taCenter
          Glyph.Data = {
            36030000424D3603000000000000360000002800000010000000100000000100
            18000000000000030000120B0000120B00000000000000000000FFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE3E3E3232323ACACACFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFACACAC232323E3E3E3FFFFFFFFFFFFFFFFFFE7E7E7
            1F1F1F333333181818ACACACFFFFFFFFFFFFFFFFFFFFFFFFACACAC1818183333
            331F1F1FE7E7E7FFFFFFFFFFFF919191333333FDFDFDA3A3A3181818ACACACFF
            FFFFFFFFFFACACAC181818A3A3A3FDFDFD333333919191FFFFFFFFFFFFFCFCFC
            3B3B3B9E9E9EFFFFFFA3A3A3151515A5A5A5ACACAC1616169B9B9BFFFFFFA6A6
            A6353535FAFAFAFFFFFFFFFFFFFFFFFFFDFDFD464646A3A3A3FFFFFFA3A3A318
            1818161616A1A1A1FFFFFFA6A6A6474747FDFDFDFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFDFDFD515151A3A3A3FFFFFFA7A7A7A7A7A7FFFFFFA3A3A3505050FDFD
            FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFDFD414141A7A7A7FF
            FFFFFFFFFFA9A9A9414141FDFDFDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFACACAC161616A5A5A5FFFFFFFFFFFFA6A6A6171717A6A6A6FFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFACACAC181818A3A3A3FFFFFFA7
            A7A7A7A7A7FFFFFFA3A3A3181818ACACACFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            ACACAC161616A1A1A1FFFFFFA6A6A65A5A5A5B5B5BA3A3A3FFFFFFA3A3A31717
            17A6A6A6FFFFFFFFFFFFFFFFFFC9C9C91616169B9B9BFFFFFFA6A6A6565656FC
            FCFCFDFDFD5A5A5A9E9E9EFFFFFFA3A3A3151515C9C9C9FFFFFFFFFFFFA9A9A9
            343434FDFDFDA3A3A35B5B5BFDFDFDFFFFFFFFFFFFFDFDFD5B5B5BA3A3A3FDFD
            FD343434A9A9A9FFFFFFFFFFFFFFFFFF9E9E9E3C3C3C5B5B5BFDFDFDFFFFFFFF
            FFFFFFFFFFFFFFFFFDFDFD5B5B5B3D3D3D9F9F9FFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFD1D1D1FDFDFDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFDFDD1D1
            D1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
          Color = 10329087
          SelectColor = 6579455
          ActiveColor = clMedGray
          DisableFontColor = clGray
          SelectFontColor = clBlack
          ActiveFontColor = clBlack
          OnClick = btnCloseClick
          Margin = 0
          Align = alRight
          SpaceWidth = 2
          ExplicitLeft = 736
        end
        object btnPrint: TWebSpeedButton
          AlignWithMargins = True
          Left = 728
          Top = 0
          Width = 100
          Height = 32
          Margins.Left = 0
          Margins.Top = 0
          Margins.Right = 30
          Margins.Bottom = 0
          Caption = #1055#1077#1095#1072#1090#1100
          Aligment = taCenter
          Glyph.Data = {
            36030000424D3603000000000000360000002800000010000000100000000100
            18000000000000030000120B0000120B00000000000000000000FFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEF2E4FDEEDBFDEEDBFD
            EEDBFDEEDBFDEDDBFDEDDBFDEDDBFEFAF6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFEF7EEF9CA90F0B875ECAE68ECAE68ECAE68F0B875F9CA90F9CA90FDED
            DAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD0D0D0D2C3B0F9CA90F0B875ECAE68EC
            AE68ECAE68F0B875F9CA90F9CA90D2C3B0CACACAFDFDFDFFFFFFFFFFFFE0E0E0
            4242427F6F5CF9CA90E8A55BDF9240DF9240DF9240DF9240DF9240F9CA907F6F
            5C4242429F9F9FFFFFFFFFFFFFD0D0D04242426D573CCA8F46CA8F46CA8F46CA
            8F46CA8F46CA8F46CA8F46CA8F466D573C424242818181FFFFFFFFFFFFD8D8D8
            4242423A3A3A3838383838383838383838383838383838383838383838383A3A
            3A424242818181FFFFFFFFFFFFDCDCDC5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E
            5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E838383FFFFFFFFFFFFE5E5E5
            6161616161616161616161616161616161616161616161616161616161616161
            61616161969696FFFFFFFFFFFFE9E9E962626261616161616161616161616161
            6161616161616161616161616161616161678B42999999FFFFFFFFFFFFFDFDFD
            D3D3D36161616161616161616161616161616161616161616161616161616161
            61676767EFEFEFFFFFFFFFFFFFFFFFFFFFFFFFD2CDC6F9CA90F9CA90F9CA90F9
            CA90F9CA90F9CA90F9CA90F9CA907F6F5CFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFEF9CB92F9CA90F9CA90F9CA90F9CA90F9CA90F9CA90F9CA90FDED
            DBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFAD19FF9CA90F9CA90F9
            CA90F9CA90F9CA90F9CA90F9CA90FDF0E0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFEFDFEFAF5FEFAF4FEFAF5FEFAF4FEFAF4FEF9F3FEFAF4FFFE
            FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
          Color = clBtnFace
          SelectColor = clScrollBar
          ActiveColor = clMedGray
          DisableFontColor = clGray
          SelectFontColor = clBlack
          ActiveFontColor = clBlack
          Enabled = False
          OnClick = btnPrintClick
          Margin = 0
          Align = alRight
          SpaceWidth = 5
          ExplicitLeft = 472
        end
      end
    end
  end
  object pnLeft: TPanel
    Left = 0
    Top = 0
    Width = 161
    Height = 472
    Margins.Left = 20
    Align = alLeft
    BevelOuter = bvNone
    Caption = 'pnLeft'
    Color = clBlack
    TabOrder = 1
    object Label5: TLabel
      AlignWithMargins = True
      Left = 20
      Top = 20
      Width = 131
      Height = 13
      Margins.Left = 20
      Margins.Top = 20
      Margins.Right = 10
      Align = alTop
      Caption = #1055#1086#1076#1088#1072#1079#1076#1077#1083#1077#1085#1080#1077
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ExplicitWidth = 80
    end
    object Label6: TLabel
      AlignWithMargins = True
      Left = 20
      Top = 120
      Width = 131
      Height = 13
      Margins.Left = 20
      Margins.Top = 10
      Margins.Right = 10
      Align = alTop
      Caption = #1044#1072#1090#1072' '#1086#1082#1086#1085#1095#1072#1085#1080#1103
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ExplicitWidth = 83
    end
    object Label7: TLabel
      AlignWithMargins = True
      Left = 20
      Top = 70
      Width = 131
      Height = 13
      Margins.Left = 20
      Margins.Top = 10
      Margins.Right = 10
      Align = alTop
      Caption = #1044#1072#1090#1072' '#1085#1072#1095#1072#1083#1072
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ExplicitWidth = 65
    end
    object Label8: TLabel
      AlignWithMargins = True
      Left = 20
      Top = 388
      Width = 131
      Height = 13
      Margins.Left = 20
      Margins.Top = 70
      Margins.Right = 10
      Align = alBottom
      Caption = #1052#1072#1089#1096#1090#1072#1073' '#1086#1090#1086#1073#1088#1072#1078#1077#1085#1080#1103
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ExplicitWidth = 116
    end
    object btnCurrentMonth: TWebSpeedButton
      Tag = 3
      AlignWithMargins = True
      Left = 30
      Top = 180
      Width = 131
      Height = 27
      Margins.Left = 30
      Margins.Top = 20
      Margins.Right = 0
      Caption = #1058#1077#1082#1091#1097#1080#1081' '#1084#1077#1089#1103#1094
      Aligment = taLeftJustify
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000120B0000120B00000000000000000000FFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD6D6D688888860
        6060606060898989D7D7D7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFF1F1F15B5B5B0101010000000000000000000000000202025D5D5DF1F1
        F1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1F1F12D2D2D00000007070741414167
        67676767674141410707070000002E2E2EF1F1F1FFFFFFFFFFFFFFFFFFFFFFFF
        5A5A5A0000001D1D1D919191A6A6A6A6A6A6A6A6A6A6A6A69090901C1C1C0000
        005D5D5DFFFFFFFFFFFFFFFFFFD6D6D6010101080808919191A6A6A6A6A6A6A6
        A6A6A6A6A6A6A6A6A6A6A6909090070707020202D7D7D7FFFFFFFFFFFF858585
        000000434343A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A64141
        41000000878787FFFFFFFFFFFF616161000000676767A6A6A6A6A6A6A6A6A6A6
        A6A6A6A6A6A6A6A6A6A6A6A6A6A6666666000000626262FFFFFFFFFFFF616161
        000000676767A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A66666
        66000000626262FFFFFFFFFFFF858585000000424242A6A6A6A6A6A6A6A6A6A6
        A6A6A6A6A6A6A6A6A6A6A6A6A6A6414141000000878787FFFFFFFFFFFFD5D5D5
        010101080808929292A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A69191910707
        07010101D6D6D6FFFFFFFFFFFFFFFFFF5959590000001E1E1E929292A6A6A6A6
        A6A6A6A6A6A6A6A69191911D1D1D0000005C5C5CFFFFFFFFFFFFFFFFFFFFFFFF
        F0F0F02C2C2C0000000808084242426868686868684242420808080000002D2D
        2DF1F1F1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0F0F059595901010100000000
        00000000000000000101015A5A5AF1F1F1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFD5D5D5868686606060606060868686D6D6D6FFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
      Color = clWindowFrame
      SelectColor = clBtnShadow
      ActiveColor = clMaroon
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      DisableFontColor = clBlack
      SelectFontColor = clWhite
      ActiveFontColor = clWhite
      OnClick = btnCurrentMonthClick
      Margin = 0
      GroupIndex = 1
      Align = alTop
      SpaceWidth = 5
      ExplicitTop = 210
    end
    object btnUpdate: TWebSpeedButton
      Tag = 3
      AlignWithMargins = True
      Left = 30
      Top = 260
      Width = 131
      Height = 40
      Margins.Left = 30
      Margins.Top = 10
      Margins.Right = 0
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      Aligment = taLeftJustify
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000120B0000120B00000000000000000000FFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD6D6D688888860
        6060606060898989D7D7D7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFF1F1F15B5B5B0101010000000000000000000000000202025D5D5DF1F1
        F1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1F1F12D2D2D00000007070741414167
        67676767674141410707070000002E2E2EF1F1F1FFFFFFFFFFFFFFFFFFFFFFFF
        5A5A5A0000001D1D1D919191A6A6A6A6A6A6A6A6A6A6A6A69090901C1C1C0000
        005D5D5DFFFFFFFFFFFFFFFFFFD6D6D6010101080808919191A6A6A6A6A6A6A6
        A6A6A6A6A6A6A6A6A6A6A6909090070707020202D7D7D7FFFFFFFFFFFF858585
        000000434343A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A64141
        41000000878787FFFFFFFFFFFF616161000000676767A6A6A6A6A6A6A6A6A6A6
        A6A6A6A6A6A6A6A6A6A6A6A6A6A6666666000000626262FFFFFFFFFFFF616161
        000000676767A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A66666
        66000000626262FFFFFFFFFFFF858585000000424242A6A6A6A6A6A6A6A6A6A6
        A6A6A6A6A6A6A6A6A6A6A6A6A6A6414141000000878787FFFFFFFFFFFFD5D5D5
        010101080808929292A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A69191910707
        07010101D6D6D6FFFFFFFFFFFFFFFFFF5959590000001E1E1E929292A6A6A6A6
        A6A6A6A6A6A6A6A69191911D1D1D0000005C5C5CFFFFFFFFFFFFFFFFFFFFFFFF
        F0F0F02C2C2C0000000808084242426868686868684242420808080000002D2D
        2DF1F1F1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0F0F059595901010100000000
        00000000000000000101015A5A5AF1F1F1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFD5D5D5868686606060606060868686D6D6D6FFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
      Color = clWindowFrame
      SelectColor = clBtnShadow
      ActiveColor = clMaroon
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      DisableFontColor = clBlack
      SelectFontColor = clWhite
      ActiveFontColor = clWhite
      OnClick = btnUpdateClick
      Margin = 0
      GroupIndex = 1
      Align = alTop
      SpaceWidth = 5
      ExplicitLeft = 20
      ExplicitTop = 235
      ExplicitWidth = 141
    end
    object btnPreviosMonth: TWebSpeedButton
      Tag = 3
      AlignWithMargins = True
      Left = 30
      Top = 220
      Width = 131
      Height = 27
      Margins.Left = 30
      Margins.Top = 10
      Margins.Right = 0
      Caption = #1055#1088#1077#1076#1099#1076#1091#1097#1080#1081' '#1084#1077#1089
      Aligment = taLeftJustify
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000120B0000120B00000000000000000000FFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD6D6D688888860
        6060606060898989D7D7D7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFF1F1F15B5B5B0101010000000000000000000000000202025D5D5DF1F1
        F1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1F1F12D2D2D00000007070741414167
        67676767674141410707070000002E2E2EF1F1F1FFFFFFFFFFFFFFFFFFFFFFFF
        5A5A5A0000001D1D1D919191A6A6A6A6A6A6A6A6A6A6A6A69090901C1C1C0000
        005D5D5DFFFFFFFFFFFFFFFFFFD6D6D6010101080808919191A6A6A6A6A6A6A6
        A6A6A6A6A6A6A6A6A6A6A6909090070707020202D7D7D7FFFFFFFFFFFF858585
        000000434343A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A64141
        41000000878787FFFFFFFFFFFF616161000000676767A6A6A6A6A6A6A6A6A6A6
        A6A6A6A6A6A6A6A6A6A6A6A6A6A6666666000000626262FFFFFFFFFFFF616161
        000000676767A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A66666
        66000000626262FFFFFFFFFFFF858585000000424242A6A6A6A6A6A6A6A6A6A6
        A6A6A6A6A6A6A6A6A6A6A6A6A6A6414141000000878787FFFFFFFFFFFFD5D5D5
        010101080808929292A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A69191910707
        07010101D6D6D6FFFFFFFFFFFFFFFFFF5959590000001E1E1E929292A6A6A6A6
        A6A6A6A6A6A6A6A69191911D1D1D0000005C5C5CFFFFFFFFFFFFFFFFFFFFFFFF
        F0F0F02C2C2C0000000808084242426868686868684242420808080000002D2D
        2DF1F1F1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0F0F059595901010100000000
        00000000000000000101015A5A5AF1F1F1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFD5D5D5868686606060606060868686D6D6D6FFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
      Color = clWindowFrame
      SelectColor = clBtnShadow
      ActiveColor = clMaroon
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      DisableFontColor = clBlack
      SelectFontColor = clWhite
      ActiveFontColor = clWhite
      OnClick = btnPreviosMonthClick
      Margin = 0
      GroupIndex = 1
      Align = alTop
      SpaceWidth = 5
      ExplicitTop = 250
    end
    object cbDivision: TComboBox
      AlignWithMargins = True
      Left = 20
      Top = 39
      Width = 131
      Height = 21
      Margins.Left = 20
      Margins.Right = 10
      Margins.Bottom = 0
      Align = alTop
      Style = csDropDownList
      Ctl3D = True
      ItemHeight = 13
      ParentCtl3D = False
      TabOrder = 0
      OnChange = cbDivisionChange
    end
    object dtpEndDate: TDateTimePicker
      AlignWithMargins = True
      Left = 20
      Top = 139
      Width = 131
      Height = 21
      Margins.Left = 20
      Margins.Right = 10
      Margins.Bottom = 0
      Align = alTop
      Date = 45815.530015787040000000
      Time = 45815.530015787040000000
      TabOrder = 1
    end
    object dtpStartDate: TDateTimePicker
      AlignWithMargins = True
      Left = 20
      Top = 89
      Width = 131
      Height = 21
      Margins.Left = 20
      Margins.Right = 10
      Margins.Bottom = 0
      Align = alTop
      Date = 45815.530015787040000000
      Time = 45815.530015787040000000
      TabOrder = 2
    end
    object tbScale: TTrackBar
      AlignWithMargins = True
      Left = 20
      Top = 404
      Width = 131
      Height = 38
      Margins.Left = 20
      Margins.Top = 0
      Margins.Right = 10
      Margins.Bottom = 30
      Align = alBottom
      Max = 30
      Min = 1
      Position = 1
      TabOrder = 3
      TickMarks = tmBoth
    end
  end
end
