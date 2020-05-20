object FormKeystrokeDynamics: TFormKeystrokeDynamics
  Left = 0
  Top = 0
  Caption = 'Keystroke Dynamics'
  ClientHeight = 592
  ClientWidth = 1001
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 632
    Top = 25
    Width = 43
    Height = 13
    Caption = #1055#1086#1074#1086#1088#1086#1090
  end
  object Label2: TLabel
    Left = 632
    Top = 59
    Width = 37
    Height = 13
    Caption = #1042#1099#1089#1086#1090#1072
  end
  object Label3: TLabel
    Left = 632
    Top = 88
    Width = 45
    Height = 13
    Caption = #1052#1072#1089#1096#1090#1072#1073
  end
  object GroupBox1: TGroupBox
    Left = 24
    Top = 24
    Width = 369
    Height = 393
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103' '#1080#1083#1080' '#1074#1099#1073#1088#1072#1090#1100' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
    TabOrder = 0
    object LabelStatus: TLabel
      Left = 24
      Top = 96
      Width = 40
      Height = 13
      Caption = #1057#1090#1072#1090#1091#1089':'
    end
    object EditNameUser: TEdit
      Left = 16
      Top = 32
      Width = 321
      Height = 21
      TabOrder = 0
      Text = #1048#1084#1103' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
      OnClick = EditNameUserClick
    end
    object EditUserText: TEdit
      Left = 16
      Top = 114
      Width = 342
      Height = 21
      TabOrder = 1
      OnClick = EditUserTextClick
    end
    object ButtonStart: TButton
      Left = 54
      Top = 59
      Width = 115
      Height = 25
      Caption = #1053#1072#1095#1072#1090#1100' '#1089#1073#1086#1088' '#1083#1086#1075#1086#1074
      TabOrder = 2
      OnClick = ButtonStartClick
    end
    object Button2: TButton
      Left = 192
      Top = 59
      Width = 129
      Height = 25
      Caption = #1047#1072#1082#1086#1085#1095#1080#1090#1100
      TabOrder = 3
      OnClick = Button2Click
    end
    object Memo1: TMemo
      Left = 16
      Top = 160
      Width = 337
      Height = 201
      TabOrder = 4
    end
  end
  object Button1: TButton
    Left = 413
    Top = 20
    Width = 75
    Height = 25
    Caption = #1040#1085#1072#1083#1080#1079
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button3: TButton
    Left = 413
    Top = 72
    Width = 75
    Height = 25
    Caption = #1055#1086#1082#1072#1079#1072#1090#1100
    TabOrder = 2
    OnClick = Button3Click
  end
  object CheckBox1: TCheckBox
    Left = 413
    Top = 103
    Width = 97
    Height = 17
    Caption = 'Data1'
    Checked = True
    State = cbChecked
    TabOrder = 3
    OnClick = CheckBox1Click
  end
  object CheckBox2: TCheckBox
    Left = 413
    Top = 126
    Width = 97
    Height = 17
    Caption = 'Data2'
    Checked = True
    State = cbChecked
    TabOrder = 4
    OnClick = CheckBox2Click
  end
  object TrackBarRotation: TTrackBar
    Left = 691
    Top = 20
    Width = 150
    Height = 37
    Max = 360
    Position = 345
    TabOrder = 5
    OnChange = TrackBarRotationChange
  end
  object TrackBarElevation: TTrackBar
    Left = 691
    Top = 53
    Width = 150
    Height = 37
    Max = 360
    Position = 345
    TabOrder = 7
    OnChange = TrackBarRotationChange
  end
  object TrackBarZoom: TTrackBar
    Left = 691
    Top = 83
    Width = 150
    Height = 37
    Max = 500
    Min = 1
    Position = 100
    TabOrder = 6
    OnChange = TrackBarRotationChange
  end
  object Chart1: TChart
    Left = 424
    Top = 167
    Width = 553
    Height = 386
    Title.Text.Strings = (
      #1054#1073#1083#1072#1082#1086' '#1076#1072#1085#1085#1099#1093)
    View3D = False
    TabOrder = 8
    DefaultCanvas = 'TGDIPlusCanvas'
    ColorPaletteIndex = 13
    object Data1: TPointSeries
      ClickableLine = False
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object Data2: TPointSeries
      ClickableLine = False
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object Data3: TPointSeries
      ClickableLine = False
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
  end
  object CheckBox3: TCheckBox
    Left = 413
    Top = 149
    Width = 97
    Height = 17
    Caption = 'Data3'
    Checked = True
    State = cbChecked
    TabOrder = 9
    OnClick = CheckBox3Click
  end
  object OpenDialog1: TOpenDialog
    Left = 32
    Top = 432
  end
end
