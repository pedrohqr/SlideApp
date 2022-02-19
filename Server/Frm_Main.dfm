object FMain: TFMain
  Left = 0
  Top = 0
  Caption = 'AppSlide | Server'
  ClientHeight = 299
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 258
    Width = 635
    Height = 41
    Align = alBottom
    TabOrder = 0
    object btn_Management: TButton
      Left = 536
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Gerenciar'
      TabOrder = 0
      OnClick = btn_ManagementClick
    end
  end
end
