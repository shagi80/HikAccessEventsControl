object frmPervonEvents: TfrmPervonEvents
  Left = 197
  Top = 117
  Caption = #1054#1090#1095#1077#1090' '#1087#1086' '#1089#1086#1090#1088#1091#1076#1085#1080#1082#1091
  ClientHeight = 472
  ClientWidth = 946
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
    Width = 785
    Height = 472
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 10
    Color = clWhite
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 305
      Top = 63
      Width = 1
      Height = 399
      Color = clSilver
      ParentColor = False
      ExplicitTop = 53
      ExplicitHeight = 409
    end
    object Panel3: TPanel
      AlignWithMargins = True
      Left = 10
      Top = 10
      Width = 765
      Height = 33
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 20
      Align = alTop
      BevelOuter = bvNone
      Color = clWhite
      TabOrder = 0
      object lbMessage: TLabel
        Left = 0
        Top = 0
        Width = 4
        Height = 16
        Align = alLeft
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
      end
      object btnClose: TWebSpeedButton
        AlignWithMargins = True
        Left = 725
        Top = 0
        Width = 40
        Height = 33
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
    end
    object pnPerson: TPanel
      Left = 10
      Top = 63
      Width = 295
      Height = 399
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
      TabOrder = 1
      object Label1: TLabel
        AlignWithMargins = True
        Left = 13
        Top = 13
        Width = 68
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
      end
      object lbPerson: TListBox
        AlignWithMargins = True
        Left = 13
        Top = 42
        Width = 269
        Height = 344
        Align = alClient
        BevelOuter = bvNone
        BorderStyle = bsNone
        ItemHeight = 16
        TabOrder = 0
        Visible = False
        OnDblClick = Analysis
      end
    end
    object pnData: TPanel
      Left = 306
      Top = 63
      Width = 469
      Height = 399
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
      TabOrder = 2
      object reEvents: TRichEdit
        Left = 10
        Top = 10
        Width = 449
        Height = 379
        Align = alClient
        Lines.Strings = (
          'reEvents')
        TabOrder = 0
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 161
    Height = 472
    Margins.Left = 20
    Align = alLeft
    BevelOuter = bvNone
    Color = clBlack
    TabOrder = 1
    object Label5: TLabel
      AlignWithMargins = True
      Left = 20
      Top = 20
      Width = 80
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
    end
    object Label6: TLabel
      AlignWithMargins = True
      Left = 20
      Top = 120
      Width = 83
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
    end
    object Label7: TLabel
      AlignWithMargins = True
      Left = 20
      Top = 70
      Width = 65
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
    end
    object Label8: TLabel
      AlignWithMargins = True
      Left = 20
      Top = 388
      Width = 116
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
      ItemHeight = 0
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
