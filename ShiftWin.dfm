object frmShift: TfrmShift
  Left = 197
  Top = 117
  Caption = 'MDI Child'
  ClientHeight = 425
  ClientWidth = 744
  Color = clBtnFace
  ParentFont = True
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object grBreaks: TStringGrid
    Left = 16
    Top = 112
    Width = 609
    Height = 120
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
    TabOrder = 0
    ColWidths = (
      64
      64
      64
      64
      64)
  end
  object grShifts: TStringGrid
    Left = 16
    Top = 264
    Width = 601
    Height = 120
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
    TabOrder = 1
  end
  object Button1: TButton
    Left = 648
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 32
    Top = 26
    Width = 593
    Height = 21
    TabOrder = 3
    Text = 'Edit1'
  end
  object Button2: TButton
    Left = 648
    Top = 55
    Width = 75
    Height = 25
    Caption = 'Button2'
    TabOrder = 4
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 648
    Top = 96
    Width = 75
    Height = 25
    Caption = 'Button3'
    TabOrder = 5
    OnClick = Button3Click
  end
end
