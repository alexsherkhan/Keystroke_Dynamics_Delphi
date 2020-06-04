object FormDataPCA: TFormDataPCA
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = #1044#1072#1085#1085#1099#1077' '#1087#1086#1089#1083#1077' PCA'
  ClientHeight = 581
  ClientWidth = 774
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 329
    Height = 292
    Caption = #1053#1086#1088#1084#1080#1088#1086#1074#1072#1085#1099#1077' '#1076#1072#1085#1085#1099#1077', '#1084#1072#1090#1088#1080#1094#1099' '#1082#1086#1074#1072#1088#1080#1072#1094#1080#1081' '#1080' '#1082#1086#1088#1088#1077#1083#1103#1094#1080#1081
    TabOrder = 0
  end
  object GroupBox3: TGroupBox
    Left = 343
    Top = 8
    Width = 425
    Height = 292
    Caption = #1057#1086#1073#1089#1090#1074#1077#1085#1085#1099#1077' '#1079#1085#1072#1095#1077#1085#1080#1103' '#1080' '#1074#1077#1082#1090#1086#1088#1072
    TabOrder = 1
    object StringGridEigenvalues: TStringGrid
      Left = 19
      Top = 24
      Width = 390
      Height = 74
      ColCount = 6
      FixedCols = 0
      RowCount = 1
      FixedRows = 0
      TabOrder = 0
    end
    object StringGridEigenvectors: TStringGrid
      Left = 19
      Top = 104
      Width = 390
      Height = 174
      FixedCols = 0
      RowCount = 1
      FixedRows = 0
      TabOrder = 1
    end
  end
  object GroupBox4: TGroupBox
    Left = 8
    Top = 302
    Width = 329
    Height = 275
    Caption = #1043#1083#1072#1074#1085#1099#1077' '#1082#1086#1084#1087#1086#1085#1077#1085#1090#1099
    TabOrder = 2
    object StringGridPC: TStringGrid
      Left = 19
      Top = 33
      Width = 284
      Height = 230
      FixedCols = 0
      RowCount = 1
      FixedRows = 0
      TabOrder = 0
    end
  end
  object ChartEigenvalues: TChart
    Left = 343
    Top = 306
    Width = 425
    Height = 271
    BackWall.Brush.Gradient.Direction = gdBottomTop
    BackWall.Brush.Gradient.EndColor = clWhite
    BackWall.Brush.Gradient.StartColor = 15395562
    BackWall.Brush.Gradient.Visible = True
    BackWall.Transparent = False
    Foot.Font.Color = clBlue
    Foot.Font.Name = 'Verdana'
    Gradient.Direction = gdBottomTop
    Gradient.EndColor = clWhite
    Gradient.MidColor = 15395562
    Gradient.StartColor = 15395562
    Gradient.Visible = True
    LeftWall.Color = 14745599
    Legend.Font.Name = 'Verdana'
    Legend.Shadow.Transparency = 0
    RightWall.Color = 14745599
    Title.Font.Name = 'Verdana'
    Title.Text.Strings = (
      #1057#1086#1073#1089#1090#1074#1077#1085#1085#1099#1077' '#1079#1085#1072#1095#1077#1085#1080#1103)
    BottomAxis.Axis.Color = 4210752
    BottomAxis.Grid.Color = 11119017
    BottomAxis.LabelsFormat.Font.Name = 'Verdana'
    BottomAxis.TicksInner.Color = 11119017
    BottomAxis.Title.Font.Name = 'Verdana'
    DepthAxis.Axis.Color = 4210752
    DepthAxis.Grid.Color = 11119017
    DepthAxis.LabelsFormat.Font.Name = 'Verdana'
    DepthAxis.TicksInner.Color = 11119017
    DepthAxis.Title.Font.Name = 'Verdana'
    DepthTopAxis.Axis.Color = 4210752
    DepthTopAxis.Grid.Color = 11119017
    DepthTopAxis.LabelsFormat.Font.Name = 'Verdana'
    DepthTopAxis.TicksInner.Color = 11119017
    DepthTopAxis.Title.Font.Name = 'Verdana'
    LeftAxis.Axis.Color = 4210752
    LeftAxis.Grid.Color = 11119017
    LeftAxis.LabelsFormat.Font.Name = 'Verdana'
    LeftAxis.TicksInner.Color = 11119017
    LeftAxis.Title.Font.Name = 'Verdana'
    RightAxis.Axis.Color = 4210752
    RightAxis.Grid.Color = 11119017
    RightAxis.LabelsFormat.Font.Name = 'Verdana'
    RightAxis.TicksInner.Color = 11119017
    RightAxis.Title.Font.Name = 'Verdana'
    TopAxis.Axis.Color = 4210752
    TopAxis.Grid.Color = 11119017
    TopAxis.LabelsFormat.Font.Name = 'Verdana'
    TopAxis.TicksInner.Color = 11119017
    TopAxis.Title.Font.Name = 'Verdana'
    View3D = False
    TabOrder = 3
    DefaultCanvas = 'TGDIPlusCanvas'
    ColorPaletteIndex = 13
    object Eigenvalues: TLineSeries
      HoverElement = [heCurrent]
      Brush.BackColor = clDefault
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
  end
  object PageControl1: TPageControl
    Left = 27
    Top = 32
    Width = 292
    Height = 254
    ActivePage = TabSheet2
    TabOrder = 4
    object TabSheet1: TTabSheet
      Caption = #1053#1086#1088#1084#1080#1088#1086#1074#1072#1085#1099#1077' '#1076#1072#1085#1085#1099#1077
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 281
      ExplicitHeight = 165
      object StringGridNormData: TStringGrid
        Left = 1
        Top = -4
        Width = 283
        Height = 230
        FixedCols = 0
        RowCount = 1
        FixedRows = 0
        TabOrder = 0
      end
    end
    object TabSheet2: TTabSheet
      Caption = #1052#1072#1090#1088#1080#1094#1072' '#1082#1086#1074#1072#1088#1080#1072#1094#1080#1081
      ImageIndex = 1
      object StringGridCovarMatrix: TStringGrid
        Left = 1
        Top = -4
        Width = 283
        Height = 230
        FixedCols = 0
        RowCount = 1
        FixedRows = 0
        TabOrder = 0
      end
    end
  end
end
