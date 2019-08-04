object frmmain: Tfrmmain
  Left = 0
  Top = 0
  ClientHeight = 444
  ClientWidth = 864
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object b_strtest1: TButton
    Left = 8
    Top = 232
    Width = 75
    Height = 25
    Caption = 'strtest1'
    TabOrder = 0
    OnClick = b_strtest1Click
  end
  object b_gridtest: TButton
    Left = 8
    Top = 127
    Width = 75
    Height = 25
    Caption = 'b_gridtest'
    TabOrder = 1
    OnClick = b_gridtestClick
  end
  object b_strtest2: TButton
    Left = 89
    Top = 232
    Width = 75
    Height = 25
    Caption = 'strtest2'
    TabOrder = 2
    OnClick = b_strtest2Click
  end
  object StringGrid1: TStringGrid
    Left = 8
    Top = 8
    Width = 265
    Height = 113
    ColCount = 1
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    TabOrder = 3
  end
  object pnlgrid: TPanel
    Left = 296
    Top = 8
    Width = 473
    Height = 161
    TabOrder = 4
  end
end
