object frmScheduleEdit: TfrmScheduleEdit
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1064#1072#1073#1083#1086#1085' '#1075#1088#1072#1092#1080#1082#1072
  ClientHeight = 312
  ClientWidth = 819
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label3: TLabel
    Left = 24
    Top = 26
    Width = 73
    Height = 13
    Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
  end
  object Label2: TLabel
    Left = 24
    Top = 61
    Width = 64
    Height = 13
    Caption = #1058#1080#1087' '#1075#1088#1072#1092#1080#1082#1072
  end
  object Shape1: TShape
    Left = 681
    Top = 0
    Width = 138
    Height = 312
    Align = alRight
    Brush.Color = clBlack
    ExplicitHeight = 320
  end
  object btnsave: TWebSpeedButton
    Left = 713
    Top = 26
    Width = 106
    Height = 35
    Caption = #1047#1072#1087#1080#1089#1072#1090#1100
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
    Color = clInactiveCaption
    SelectColor = clActiveCaption
    ActiveColor = clActiveCaption
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    DisableFontColor = clGray
    SelectFontColor = clBlack
    ActiveFontColor = clBlack
    OnClick = btnsaveClick
    Margin = 0
    SpaceWidth = 5
  end
  object btnCancel: TWebSpeedButton
    Left = 713
    Top = 77
    Width = 106
    Height = 35
    Caption = #1054#1090#1084#1077#1085#1080#1090#1100
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
    Color = cl3DDkShadow
    SelectColor = clMaroon
    ActiveColor = clMaroon
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    DisableFontColor = clBtnShadow
    SelectFontColor = clWhite
    ActiveFontColor = clWhite
    OnClick = btnCancelClick
    Margin = 0
    SpaceWidth = 5
  end
  object Label5: TLabel
    Left = 312
    Top = 61
    Width = 65
    Height = 13
    Caption = #1044#1072#1090#1072' '#1085#1072#1095#1072#1083#1072
  end
  object Label1: TLabel
    Left = 24
    Top = 96
    Width = 38
    Height = 13
    Caption = #1055#1077#1088#1080#1086#1076
  end
  object edTitle: TEdit
    Left = 120
    Top = 23
    Width = 385
    Height = 21
    TabOrder = 0
    Text = 'edTitle'
    OnChange = edTitleChange
  end
  object dtpStartDate: TDateTimePicker
    Left = 408
    Top = 58
    Width = 97
    Height = 21
    Date = 45798.834614710650000000
    Time = 45798.834614710650000000
    TabOrder = 1
  end
  object edLateness: TEdit
    Left = 120
    Top = 93
    Width = 49
    Height = 21
    TabOrder = 2
    Text = 'edLateness'
    OnChange = edLatenessChange
    OnKeyPress = edLatenessKeyPress
  end
  object cbType: TComboBox
    Left = 120
    Top = 58
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 3
    OnChange = cbTypeChange
    Items.Strings = (
      #1085#1077#1076#1077#1083#1100#1085#1099#1081
      #1087#1077#1088#1077#1086#1076#1080#1095#1077#1089#1082#1080#1081)
  end
  object pnPicture: TScrollBox
    Left = 24
    Top = 144
    Width = 625
    Height = 145
    BevelInner = bvNone
    BevelOuter = bvNone
    BevelKind = bkFlat
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 4
  end
end
