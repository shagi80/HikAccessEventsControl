object frmReport: TfrmReport
  Left = 0
  Top = 0
  Caption = 'frmReport'
  ClientHeight = 412
  ClientWidth = 847
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Visible = True
  WindowState = wsMaximized
  PixelsPerInch = 96
  TextHeight = 13
  object frxPreview: TfrxPreview
    Left = 0
    Top = 52
    Width = 847
    Height = 360
    Align = alClient
    BevelOuter = bvNone
    BorderStyle = bsNone
    OutlineVisible = False
    OutlineWidth = 120
    ThumbnailVisible = False
    UseReportHints = True
    ExplicitLeft = -8
    ExplicitTop = 45
    ExplicitWidth = 640
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 847
    Height = 52
    Align = alTop
    BevelOuter = bvNone
    BorderWidth = 10
    Color = clGray
    TabOrder = 1
    ExplicitWidth = 640
    object btnClose: TWebSpeedButton
      AlignWithMargins = True
      Left = 801
      Top = 10
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
      ExplicitTop = 0
    end
    object btnPrint: TWebSpeedButton
      AlignWithMargins = True
      Left = 668
      Top = 10
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
      OnClick = btnPrintClick
      Margin = 0
      Align = alRight
      SpaceWidth = 5
      ExplicitLeft = 331
      ExplicitTop = 0
    end
    object btnPdfExport: TWebSpeedButton
      Tag = 3
      AlignWithMargins = True
      Left = 578
      Top = 10
      Width = 60
      Height = 32
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 30
      Margins.Bottom = 0
      Caption = 'PDF'
      Aligment = taCenter
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000120B0000120B00000000000000000000FFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0F0F0DBDBDBDBDBDBDBDBDBDB
        DBDBDBDBDBDBDBDBDBDBDBDBDBDBE2E2E2FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFF3945E81626F21626F21626F21626F21626F21626F21626F21626F23844
        E8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2E3BF10012FF0012FF0012FF00
        12FF0012FF0012FF0012FF0012FF2533F0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFF2E3CF10012FF0012FF0012FF0012FF0012FF0012FF0012FF0012FF2533
        F0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2A38F0434EDC0012FF0B1BF763
        6CD8303BD60919F63440E10012FF2533F0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFF2835F0B2B6EC757DDF2633EAA5AAEE9DA3F34C57E5ADB1E8303DE42533
        F0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2836F0A9AEEA636CDF777FEB8C
        92E26F77DD626CF1ACB0EA2E3BEB2533F0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFF2E3CF1707AF88E96F92634FD99A0F8707AFB1223FD9CA3F7707AF72533
        F0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF3945F10012FF0012FF0012FF00
        12FF0012FF0012FF0012FF0012FF2533F0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFF3441F10012FF0012FF0012FF0012FF0012FF000FD9000FDA0011F22634
        F1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF3542F10012FF0012FF0012FF00
        12FF0012FF5760E38287ED8286ED8389E5FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFF323FF10012FF0012FF0012FF0012FF0012FF6D74EBA1A4FE9499F1FFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7E87F70012FF0012FF0012FF00
        12FF0012FF6A71F0A7ACF9FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFBFCFFE7E9FFE1E3FFE2E4FFE1E3FFDFE2FFF0F1FFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
      Color = clBtnFace
      SelectColor = clScrollBar
      ActiveColor = clMedGray
      DisableFontColor = clGray
      SelectFontColor = clBlack
      ActiveFontColor = clBlack
      OnClick = btnExportClick
      Margin = 0
      Align = alRight
      SpaceWidth = 5
      ExplicitLeft = 538
    end
    object btnXlsExport: TWebSpeedButton
      Tag = 2
      AlignWithMargins = True
      Left = 513
      Top = 10
      Width = 60
      Height = 32
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 5
      Margins.Bottom = 0
      Caption = 'XLS'
      Aligment = taCenter
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000120B0000120B00000000000000000000FFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFEFEFE334E212A48182A48182A4818617B503F66273F66273F66
        273F662792A884FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2F4F13551242A48182A
        48182A4818617B503F66273F66273F66273F66277F996FFFFFFFFFFFFFFCFDFC
        CAD9BEBED0AF8DA67B2F56142F56142D53152A4818607A4F4067264067264067
        264067267F986DFFFFFFFFFFFFCFDCC438720C38720C38720C38720C38720C37
        720C2A4717658A485296125296125296125296128BB95FFFFFFFFFFFFFDAE5D2
        38720C89AC6F4C802498B6813C751138720C2A4717658A485296125296125296
        125296128BB95FFFFFFFFFFFFFDCE6D438720C51842ACAD9BE8CAE7338720C38
        720C2A4717658A485296125296125296125296128BB95FFFFFFFFFFFFFD9E4D1
        38720C4C8024D1DEC78BAD7138720C38720C45800C79AA4465AC1965AC1965AC
        1965AC1998C765FFFFFFFFFFFFDCE6D438720C7FA46357883295B47D3B741038
        720C45800C79AA4465AC1965AC1965AC1965AC1998C765FFFFFFFFFFFFEFF3EB
        4B7F2338720C38720C38720C38720C38730C45800C79AA4465AC1965AC1965AC
        1965AC1998C765FFFFFFFFFFFFFFFFFFFDFDFCFBFCFADFE9D64B87134B87134D
        891354911687BB507FC2297FC2297FC2297FC229AAD670FFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFEFEFD56921954911654911654911687BB507FC2297FC2297FC2
        297FC229AAD670FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFEBED5A87AA94979
        A9486DA138ACD086A8D56D9BCF5894CC4C97CD51E1F1CDFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
      Color = clBtnFace
      SelectColor = clScrollBar
      ActiveColor = clMedGray
      DisableFontColor = clGray
      SelectFontColor = clBlack
      ActiveFontColor = clBlack
      OnClick = btnExportClick
      Margin = 0
      Align = alRight
      SpaceWidth = 5
      ExplicitTop = 20
    end
    object btnOdsExport: TWebSpeedButton
      Tag = 1
      AlignWithMargins = True
      Left = 448
      Top = 10
      Width = 60
      Height = 32
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 5
      Margins.Bottom = 0
      Caption = 'ODS'
      Aligment = taCenter
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000120B0000120B00000000000000000000FFFFFFFFFFFF
        FFFFFFFFFFFF7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F
        7F7F7F7F7F7F7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7F7F7FF5F5FFF5F5FFF5
        F5FFF5F5FFF5F5FFF5F5FFF5F5FFF5F5FFF5F5FF7F7F7FFFFFFFFFFFFFFFFFFF
        E3D6D6D4C0C4C3C3C3D0BDC4D0BDC4D0BDC4D0BDC4D0BDC4D0BDC4D0BDC4DCCF
        D7F5F5FF7F7F7FFFFFFFFFFFFFC9B0B0884E4E884F4F8A5151884E4E8B525288
        4E4E894F4F8F595A884E4E884E4E884E4EDDD0D87F7F7FFFFFFFFFFFFF9D6D6D
        884E4ED1BEC3D5C5CBA07375E0D6DDB8989B9A6A6BC2A8ACCBB5BA884E4E884E
        4ED3C0C77F7F7FFFFFFFFFFFFF9B6969884E4ECBB5BAB7979AAD8688B7979AD0
        BDC2905A5BC8B1B6C5ACB1884E4E884E4ED3C0C77F7F7FFFFFFFFFFFFF9D6C6C
        884E4ED3C3C9CCB6BBA77E80D0BDC2CDB8BDA88083C0A4A89E7071884E4E884E
        4ED3C0C77F7F7FFFFFFFFFFFFF9A6868884E4E9A6A6BA175778D5556AA83868C
        5454895050AB8487AA8285884E4E884E4ED5C5CC7F7F7FFFFFFFFFFFFF976767
        7F48489C7071B49195B49195B49195B49195B49195B49195B49195B49195BB9C
        A1F2F0FA7F7F7FFFFFFFFFFFFFAA8686713636A47F827F7F7FF5F5FFF5F5FFF5
        F5FFF5F5FFF5F5FFF5F5FFF5F5FFF5F5FFF5F5FF7F7F7FFFFFFFFFFFFFFDFDFD
        EFE8E8E8DFE17F7F7FEDE2ECEBDCE5EBDCE5EBDCE5EBDCE5EDE2ECF5F5FFF5F5
        FFF5F5FF7F7F7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7F7F7FEEE4EDECDEE8EC
        DEE8ECDEE8ECDEE8EEE4EDF5F5FFF5F5FFF5F5FF7F7F7FFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFF7F7F7FF1EAF3EEE6EEEEE6EEF3F1F9F4F3FCF4F3FDF5F5FFF4F0
        F97F7F7FFAF9FCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7F7F7FF1EBF5EFE7F0EF
        E7F0F4F2FCF5F5FFF5F5FFF5F5FF7F7F7FF3EAEEFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFF0F0F07F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7FFFFF
        FFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
      Color = clBtnFace
      SelectColor = clScrollBar
      ActiveColor = clMedGray
      DisableFontColor = clGray
      SelectFontColor = clBlack
      ActiveFontColor = clBlack
      OnClick = btnExportClick
      Margin = 0
      Align = alRight
      SpaceWidth = 5
      ExplicitLeft = 328
    end
  end
  object frxReport: TfrxReport
    Version = '4.15'
    DotMatrixReport = False
    IniFile = '\Software\Fast Reports'
    Preview = frxPreview
    PreviewOptions.Buttons = [pbPrint, pbLoad, pbSave, pbExport, pbZoom, pbFind, pbOutline, pbPageSetup, pbTools, pbEdit, pbNavigator, pbExportQuick]
    PreviewOptions.Zoom = 1.000000000000000000
    PrintOptions.Printer = 'Default'
    PrintOptions.PrintOnSheet = 0
    ReportOptions.CreateDate = 45845.789112430550000000
    ReportOptions.LastChange = 45845.843992569450000000
    ScriptLanguage = 'PascalScript'
    ScriptText.Strings = (
      'begin'
      ''
      'end.')
    Left = 16
    Top = 112
    Datasets = <
      item
        DataSet = frxUDS1
        DataSetName = 'frxUDS1'
      end>
    Variables = <>
    Style = <>
    object Data: TfrxDataPage
      Height = 1000.000000000000000000
      Width = 1000.000000000000000000
    end
    object Page1: TfrxReportPage
      Orientation = poLandscape
      PaperWidth = 297.000000000000000000
      PaperHeight = 210.000000000000000000
      PaperSize = 9
      LeftMargin = 10.000000000000000000
      RightMargin = 10.000000000000000000
      TopMargin = 10.000000000000000000
      BottomMargin = 10.000000000000000000
      object ReportTitle1: TfrxReportTitle
        Height = 128.504020000000000000
        Top = 18.897650000000000000
        Width = 1046.929810000000000000
        object Memo10: TfrxMemoView
          Align = baWidth
          Width = 1046.929810000000000000
          Height = 18.897650000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          HAlign = haCenter
          Memo.UTF8 = (
            #1056#1115#1056#1118#1056#167#1056#8226#1056#1118' '#1056#1119#1056#1115' '#1056#1119#1056#1115#1056#8221#1056#160#1056#1106#1056#8212#1056#8221#1056#8226#1056#8250#1056#8226#1056#1116#1056#152#1056#174)
          ParentFont = False
        end
        object Memo11: TfrxMemoView
          Align = baWidth
          Top = 18.897650000000000000
          Width = 1046.929810000000000000
          Height = 18.897650000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          HAlign = haCenter
          Memo.UTF8 = (
            '[RepCaption]')
          ParentFont = False
        end
        object Memo12: TfrxMemoView
          Top = 75.590600000000000000
          Width = 30.236240000000000000
          Height = 52.913420000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            #1074#8222#8211)
          ParentFont = False
          VAlign = vaCenter
        end
        object Memo13: TfrxMemoView
          Left = 30.236240000000000000
          Top = 75.590600000000000000
          Width = 219.212740000000000000
          Height = 52.913420000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            #1056#164#1056#152#1056#1115)
          ParentFont = False
          VAlign = vaCenter
        end
        object Memo14: TfrxMemoView
          Left = 249.448980000000000000
          Top = 94.488250000000000000
          Width = 113.385826770000000000
          Height = 34.015770000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            #1056#1169#1056#1109#1056#187#1056#182#1056#1029#1056#1109' '#1056#177#1057#8249#1057#8218#1057#1034' '#1056#1111#1056#1109' '#1056#1110#1057#1026#1056#176#1057#8222#1056#1105#1056#1108#1057#1107)
          ParentFont = False
        end
        object Memo15: TfrxMemoView
          Left = 362.834880000000000000
          Top = 94.488250000000000000
          Width = 113.385826770000000000
          Height = 34.015770000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            #1056#1109#1057#8218#1057#1026#1056#176#1056#177#1056#1109#1057#8218#1056#176#1056#1029#1056#1109' '#1056#1111#1056#1109' '#1056#1110#1057#1026#1056#176#1057#8222#1056#1105#1056#1108#1057#1107)
          ParentFont = False
        end
        object Memo16: TfrxMemoView
          Left = 476.220780000000000000
          Top = 94.488250000000000000
          Width = 113.385826770000000000
          Height = 34.015770000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            #1056#1109#1057#8218#1057#1026#1056#176#1056#177#1056#1109#1057#8218#1056#176#1056#1029#1056#1109' '#1056#1030#1056#1029#1056#181' '#1056#1110#1057#1026#1056#176#1057#8222#1056#1105#1056#1108#1056#176)
          ParentFont = False
        end
        object Memo17: TfrxMemoView
          Left = 589.606680000000000000
          Top = 94.488250000000000000
          Width = 143.622066770000000000
          Height = 34.015770000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            #1056#1030#1057#1027#1056#181#1056#1110#1056#1109' '#1056#1109#1057#8218#1057#1026#1056#176#1056#177#1056#1109#1057#8218#1056#176#1056#1029#1056#1109)
          ParentFont = False
        end
        object Memo18: TfrxMemoView
          Left = 933.543910000000000000
          Top = 94.488250000000000000
          Width = 113.385826770000000000
          Height = 34.015770000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            #1056#1030#1057#1027#1056#181#1056#1110#1056#1109' '#1056#1111#1057#1026#1056#1109#1056#1110#1057#1107#1056#187#1056#1109#1056#1030' '#1056#1105' '#1056#1029#1056#176#1057#1026#1057#1107#1057#8364#1056#181#1056#1029#1056#1105#1056#8470)
          ParentFont = False
        end
        object Memo19: TfrxMemoView
          Left = 820.158010000000000000
          Top = 94.488250000000000000
          Width = 113.385826770000000000
          Height = 34.015770000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            #1056#1109#1056#1111#1056#1109#1056#183#1056#1169#1056#176#1056#1029#1056#1105#1057#1039' '#1056#1029#1056#176' '#1057#1027#1056#1112#1056#181#1056#1029#1057#1107)
          ParentFont = False
        end
        object Memo20: TfrxMemoView
          Left = 733.228820000000000000
          Top = 94.488250000000000000
          Width = 86.929116770000000000
          Height = 34.015770000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            #1056#1030#1057#8249#1056#1111#1056#1109#1056#187#1056#1029#1056#181#1056#1029#1056#1105#1056#181' '#1056#1029#1056#1109#1057#1026#1056#1112#1057#8249)
          ParentFont = False
        end
        object Memo21: TfrxMemoView
          Left = 249.448980000000000000
          Top = 75.590600000000000000
          Width = 570.709030000000000000
          Height = 18.897650000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            #1056#167#1056#176#1057#1027#1057#8249)
          ParentFont = False
        end
        object Memo22: TfrxMemoView
          Left = 820.158010000000000000
          Top = 75.590600000000000000
          Width = 226.771800000000000000
          Height = 18.897650000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            #1056#1116#1056#176#1057#1026#1057#1107#1057#8364#1056#181#1056#1029#1056#1105#1057#1039' '#1056#1110#1057#1026#1056#176#1057#8222#1056#1105#1056#1108#1056#176)
          ParentFont = False
        end
      end
      object MasterData1: TfrxMasterData
        Height = 18.897650000000000000
        Top = 207.874150000000000000
        Width = 1046.929810000000000000
        DataSet = frxUDS1
        DataSetName = 'frxUDS1'
        RowCount = 0
        object Memo1: TfrxMemoView
          Top = 0.000000000000000014
          Width = 30.236240000000000000
          Height = 18.897650000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          Memo.UTF8 = (
            '[Line]')
          ParentFont = False
        end
        object Memo2: TfrxMemoView
          Left = 30.236240000000000000
          Top = 0.000000000000000014
          Width = 219.212740000000000000
          Height = 18.897650000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          Memo.UTF8 = (
            '[PersonName]')
          ParentFont = False
        end
        object Memo3: TfrxMemoView
          Left = 249.448980000000000000
          Top = 0.000000000000000014
          Width = 113.385826770000000000
          Height = 18.897650000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            '[ScheduleTime]')
          ParentFont = False
        end
        object Memo4: TfrxMemoView
          Left = 362.834880000000000000
          Top = 0.000000000000000014
          Width = 113.385826770000000000
          Height = 18.897650000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            '[ScheduleWork]')
          ParentFont = False
        end
        object Memo5: TfrxMemoView
          Left = 476.220780000000000000
          Top = 0.000000000000000014
          Width = 113.385826770000000000
          Height = 18.897650000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            '[OvertimeWork]')
          ParentFont = False
        end
        object Memo6: TfrxMemoView
          Left = 589.606680000000000000
          Width = 143.622066770000000000
          Height = 18.897650000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            '[TotalWork]')
          ParentFont = False
        end
        object Memo7: TfrxMemoView
          Left = 933.543910000000000000
          Top = 0.000000000000000014
          Width = 113.385826770000000000
          Height = 18.897650000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            '[TotalHooky]')
          ParentFont = False
        end
        object Memo8: TfrxMemoView
          Left = 820.158010000000000000
          Top = 0.000000000000000014
          Width = 113.385826770000000000
          Height = 18.897650000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            '[LateCount]')
          ParentFont = False
        end
        object Memo9: TfrxMemoView
          Left = 733.228820000000000000
          Top = 0.000000000000000014
          Width = 86.929116770000000000
          Height = 18.897650000000000000
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = []
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          HAlign = haCenter
          Memo.UTF8 = (
            '[WorkMark]')
          ParentFont = False
        end
      end
    end
  end
  object frxUDS1: TfrxUserDataSet
    RangeEnd = reCount
    UserName = 'frxUDS1'
    Left = 16
    Top = 152
  end
  object frxXLSExport: TfrxXLSExport
    UseFileCache = True
    ShowProgress = True
    OverwritePrompt = False
    DataOnly = False
    ExportEMF = True
    AsText = False
    Background = True
    FastExport = True
    PageBreaks = True
    EmptyLines = True
    SuppressPageHeadersFooters = False
    Left = 16
    Top = 280
  end
  object frxODSExport: TfrxODSExport
    UseFileCache = True
    ShowProgress = True
    OverwritePrompt = False
    DataOnly = False
    PictureType = gpPNG
    Background = True
    Creator = 'FastReport'
    Language = 'en'
    SuppressPageHeadersFooters = False
    Left = 16
    Top = 240
  end
  object frxPDFExport1: TfrxPDFExport
    UseFileCache = True
    ShowProgress = True
    OverwritePrompt = False
    DataOnly = False
    PrintOptimized = False
    Outline = False
    Background = False
    HTMLTags = True
    Quality = 95
    Author = 'FastReport'
    Subject = 'FastReport PDF export'
    ProtectionFlags = [ePrint, eModify, eCopy, eAnnot]
    HideToolbar = False
    HideMenubar = False
    HideWindowUI = False
    FitWindow = False
    CenterWindow = False
    PrintScaling = False
    Left = 16
    Top = 200
  end
end
