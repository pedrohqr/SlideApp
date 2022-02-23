object FManagement: TFManagement
  Left = 0
  Top = 0
  Caption = 'AppSlide | Gerenciamento do servidor'
  ClientHeight = 796
  ClientWidth = 1030
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lbl_song: TLabel
    Left = 32
    Top = 21
    Width = 36
    Height = 13
    Caption = 'M'#250'sica:'
  end
  object lbl_artist: TLabel
    Left = 32
    Top = 61
    Width = 36
    Height = 13
    Caption = 'Artista:'
  end
  object lbl_lyrics: TLabel
    Left = 32
    Top = 173
    Width = 29
    Height = 13
    Caption = 'Letra:'
  end
  object lbl_status: TLabel
    Left = 352
    Top = 130
    Width = 257
    Height = 21
    Alignment = taRightJustify
    AutoSize = False
  end
  object lbl_id_art: TLabel
    Left = 617
    Top = 83
    Width = 3
    Height = 13
  end
  object lbl_id_song: TLabel
    Left = 617
    Top = 43
    Width = 3
    Height = 13
  end
  object lbl_audio_link: TLabel
    Left = 33
    Top = 481
    Width = 72
    Height = 13
    Caption = 'Link da M'#250'sica:'
  end
  object Memo: TMemo
    Left = 32
    Top = 192
    Width = 577
    Height = 273
    MaxLength = 10000
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object Edt_Song: TEdit
    Left = 32
    Top = 40
    Width = 577
    Height = 21
    TabOrder = 0
  end
  object Edt_Artist: TEdit
    Left = 32
    Top = 80
    Width = 577
    Height = 21
    TabOrder = 1
  end
  object Btn_Search: TButton
    Left = 534
    Top = 107
    Width = 75
    Height = 25
    Caption = 'Pesquisar'
    TabOrder = 2
    OnClick = Btn_SearchClick
  end
  object Animation: TActivityIndicator
    Left = 32
    Top = 104
  end
  object btn_register_song: TButton
    Left = 534
    Top = 528
    Width = 75
    Height = 25
    Caption = 'Cadastrar'
    TabOrder = 5
    OnClick = btn_register_songClick
  end
  object Edt_Audio_Link: TEdit
    Left = 32
    Top = 501
    Width = 577
    Height = 21
    TabOrder = 4
  end
  object Client: TRESTClient
    BaseURL = 'https://api.vagalume.com.br'
    Params = <>
    Left = 888
    Top = 16
  end
  object Request: TRESTRequest
    Client = Client
    Params = <
      item
        Kind = pkURLSEGMENT
        Name = 'artist'
        Options = [poAutoCreated]
      end
      item
        Kind = pkURLSEGMENT
        Name = 'song'
        Options = [poAutoCreated]
      end>
    Resource = 
      'search.php?art={artist}&mus={song}&apikey=55429740edbe1b9fe049c5' +
      '1aea1f659b'
    Response = Response
    Left = 952
    Top = 24
  end
  object Response: TRESTResponse
    Left = 824
    Top = 16
  end
end
