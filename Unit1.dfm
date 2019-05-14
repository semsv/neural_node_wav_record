object Form1: TForm1
  Left = 267
  Top = 186
  Width = 788
  Height = 354
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PaintBox1: TPaintBox
    Left = 200
    Top = 8
    Width = 561
    Height = 225
  end
  object Image1: TImage
    Left = 200
    Top = 8
    Width = 561
    Height = 225
  end
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 83
    Height = 13
    Caption = #1055#1077#1088#1077#1082#1083#1102#1095#1072#1090#1077#1083#1100':'
  end
  object Label2: TLabel
    Left = 100
    Top = 9
    Width = 6
    Height = 13
    Caption = '0'
  end
  object Label3: TLabel
    Left = 8
    Top = 35
    Width = 115
    Height = 13
    Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090'  '#1089#1088#1072#1074#1085#1077#1085#1080#1103':'
  end
  object Label4: TLabel
    Left = 128
    Top = 36
    Width = 6
    Height = 13
    Caption = '0'
  end
  object Label5: TLabel
    Left = 8
    Top = 64
    Width = 107
    Height = 13
    Caption = #1059#1076#1072#1083#1077#1085#1086' '#1089#1083#1086#1084#1072#1085#1085#1099#1093':'
  end
  object Label6: TLabel
    Left = 120
    Top = 64
    Width = 6
    Height = 13
    Caption = '0'
  end
  object Button1: TButton
    Left = 104
    Top = 168
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 104
    Top = 208
    Width = 75
    Height = 25
    Caption = 'Button2'
    TabOrder = 1
    OnClick = Button2Click
  end
  object CheckBox1: TCheckBox
    Left = 104
    Top = 240
    Width = 97
    Height = 17
    Caption = 'CheckBox1'
    TabOrder = 2
    OnClick = CheckBox1Click
  end
  object TrackBar1: TTrackBar
    Left = 200
    Top = 248
    Width = 561
    Height = 45
    TabOrder = 3
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 3000
    OnTimer = Timer1Timer
    Left = 104
    Top = 264
  end
end
