unit uRegister;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  uBase, FMX.Layouts, FMX.ListBox, FMX.Controls.Presentation, FMX.Objects,
  FMX.Edit, System.ImageList, FMX.ImgList;

type
  TFrm_Register = class(TFormBase)
    Rec_Header: TRectangle;
    lbl_Header: TLabel;
    LB: TListBox;
    btn_Done: TButton;
    lbl_message: TLabel;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    ListBoxItem4: TListBoxItem;
    Edt_Name: TEdit;
    Edt_Login: TEdit;
    Edt_PW: TEdit;
    Edt_Token: TEdit;
    Ani: TAniIndicator;
    btn_PW_Show: TSpeedButton;
    procedure Edt_NameKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure Edt_LoginKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure Edt_PWKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure Edt_TokenKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure btn_DoneClick(Sender: TObject);
    procedure btn_PW_ShowClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Frm_Register: TFrm_Register;

implementation

{$R *.fmx}

uses DS_Functions, uClientModule, uLogin;

procedure TFrm_Register.btn_DoneClick(Sender: TObject);
begin
  inherited;
  Ani.Visible := True;
  Ani.Enabled := True;
  TThread.CreateAnonymousThread(procedure
  var
    Conn : TLoginClient;
    pID : Integer;
  begin
    try
      try
        if not DM_DataSnap.DSConn.Connected then
          DM_DataSnap.DSConn.Connected := True;

        Conn := TLoginClient.Create(DM_DataSnap.DSConn.DBXConnection);
        pID := Conn.Register_User(Edt_Name.Text, Edt_Login.Text, Edt_PW.Text, Edt_Token.Text);
        Conn.Register_Parish_User(pID, Conn.getParishIDByToken(Edt_Token.Text), Edt_Token.Text);

        TThread.Synchronize(nil, procedure
        begin
          Ani.Enabled := False;
          Ani.Visible := False;
          lbl_message.Text := '';
          ShowMessage('Cadastrado com sucesso');
          OpenForm(TFrm_Login);
        end);
      except on e : exception do
        TThread.Synchronize(nil, procedure
        begin
          Ani.Enabled := False;
          Ani.Visible := False;
          lbl_message.Text := e.Message;
        end);
      end;
    finally
      if Assigned(Conn) then
        FreeAndNil(Conn);
      if DM_DataSnap.DSConn.Connected then
        DM_DataSnap.DSConn.Connected := False;
    end;
  end).Start;
end;

procedure TFrm_Register.btn_PW_ShowClick(Sender: TObject);
begin
  inherited;
  case Edt_PW.Password of
    True : Edt_PW.Password := False;
    False : Edt_PW.Password := True;
  end;
end;

procedure TFrm_Register.Edt_LoginKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  inherited;
  if Key = vkReturn then
    Edt_PW.SetFocus;
end;

procedure TFrm_Register.Edt_NameKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  inherited;
  if Key = vkReturn then
    Edt_Login.SetFocus;
end;

procedure TFrm_Register.Edt_PWKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  inherited;
  if Key = vkReturn then
    Edt_Token.SetFocus;
end;

procedure TFrm_Register.Edt_TokenKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  inherited;
  if Key = vkReturn then
    btn_DoneClick(Self);
end;

end.
