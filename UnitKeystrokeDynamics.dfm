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
  object GroupBox1: TGroupBox
    Left = 24
    Top = 20
    Width = 369
    Height = 554
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
      Top = 152
      Width = 337
      Height = 385
      TabOrder = 4
    end
  end
  object Button1: TButton
    Left = 440
    Top = 20
    Width = 233
    Height = 25
    Caption = #1048#1079#1074#1083#1077#1095#1077#1085#1080#1077' '#1086#1089#1086#1073#1077#1085#1086#1089#1090#1077#1081' '#1080#1079' '#1092#1072#1081#1083#1072
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button3: TButton
    Left = 440
    Top = 51
    Width = 233
    Height = 25
    Caption = #1056#1072#1089#1095#1077#1090' PCA'
    TabOrder = 2
    OnClick = Button3Click
  end
  object CheckBox1: TCheckBox
    Left = 576
    Top = 149
    Width = 97
    Height = 17
    Caption = 'FCM'
    Checked = True
    State = cbChecked
    TabOrder = 3
    OnClick = CheckBox1Click
  end
  object Chart1: TChart
    Left = 416
    Top = 188
    Width = 553
    Height = 386
    Title.Text.Strings = (
      #1054#1073#1083#1072#1082#1086' '#1076#1072#1085#1085#1099#1093)
    View3D = False
    Zoom.Animated = True
    TabOrder = 4
    DefaultCanvas = 'TGDIPlusCanvas'
    ColorPaletteIndex = 13
    object A: TPointSeries
      HoverElement = [heCurrent]
      ClickableLine = False
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object B: TPointSeries
      HoverElement = [heCurrent]
      SeriesColor = clLime
      ClickableLine = False
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object C: TPointSeries
      HoverElement = [heCurrent]
      ClickableLine = False
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object FCM: TPointSeries
      HoverElement = [heCurrent]
      ClickableLine = False
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
  end
  object CheckBox4: TCheckBox
    Left = 440
    Top = 149
    Width = 97
    Height = 17
    Caption = 'PCA'
    Checked = True
    State = cbChecked
    TabOrder = 5
    OnClick = CheckBox4Click
  end
  object Button4: TButton
    Left = 440
    Top = 82
    Width = 233
    Height = 25
    Caption = #1056#1072#1089#1095#1077#1090' PCA + FCA'
    TabOrder = 6
    OnClick = Button4Click
  end
  object GroupBox2: TGroupBox
    Left = 696
    Top = 13
    Width = 177
    Height = 169
    Caption = #1054#1090#1086#1073#1088#1072#1078#1077#1085#1080#1077' '#1087#1086' '#1082#1086#1084#1087#1086#1085#1077#1085#1090#1072#1084
    TabOrder = 7
    object Label4: TLabel
      Left = 30
      Top = 20
      Width = 19
      Height = 13
      Caption = 'PC1'
    end
    object Label5: TLabel
      Left = 30
      Top = 66
      Width = 19
      Height = 13
      Caption = 'PC2'
    end
    object ButtonShow: TButton
      Left = 46
      Top = 132
      Width = 75
      Height = 25
      Caption = #1055#1086#1082#1072#1079#1072#1090#1100
      TabOrder = 0
      OnClick = ButtonShowClick
    end
    object ComboBox1: TComboBox
      Left = 30
      Top = 39
      Width = 115
      Height = 21
      TabOrder = 1
      OnSelect = ComboBox1Select
    end
    object ComboBox2: TComboBox
      Left = 30
      Top = 85
      Width = 115
      Height = 21
      TabOrder = 2
      OnSelect = ComboBox2Select
    end
  end
  object Button5: TButton
    Left = 440
    Top = 118
    Width = 233
    Height = 25
    Caption = #1040#1091#1090#1077#1085#1090#1080#1092#1080#1094#1080#1088#1086#1074#1072#1090#1100' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
    TabOrder = 8
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 894
    Top = 65
    Width = 99
    Height = 54
    Caption = #1057#1086#1073#1088#1072#1090#1100' '#1086#1089#1086#1073#1077#1085#1086#1089#1090#1080' '#1074' '#1086#1076#1080#1085' '#1092#1072#1081#1083
    TabOrder = 9
    WordWrap = True
    OnClick = Button6Click
  end
  object OpenDialog1: TOpenDialog
    Left = 400
    Top = 8
  end
end
