unit uLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  uBase, FMX.Controls.Presentation, FMX.Edit, FMX.Layouts, Data.DBXDataSnap,
  Data.DBXCommon, IPPeerClient, Data.DB, Data.SqlExpr;

type
  TFrm_Login = class(TFormBase)
    Edt_Username: TEdit;
    LayoutCenter: TLayout;
    Edt_Password: TEdit;
    btn_sign_in: TButton;
    lbl_username: TLabel;
    lbl_password: TLabel;
    AniIndicator: TAniIndicator;
    procedure btn_sign_inClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Frm_Login: TFrm_Login;

implementation

{$R *.fmx}

uses uHome, uMain, DS_Functions, uClientModule, FireDAC.Comp.Client,
  Data.FireDACJSONReflect, uMass, Lib_General;

procedure TFrm_Login.btn_sign_inClick(Sender: TObject);
begin
  inherited;
  AniIndicator.Enabled := True;
  TThread.CreateAnonymousThread(procedure
  var
   Conn : TLoginClient;
   MT : TFDMemTable;
   DS : TFDJSONDataSets;
  begin
    try
      try
        if not DM_DataSnap.DSConn.Connected then
          DM_DataSnap.DSConn.Connected := True;
        Conn := TLoginClient.Create(DM_DataSnap.DSConn.DBXConnection);
        Frm_Main.ID_User := Conn.Auth_Login(Trim(Edt_Username.Text), Trim(Edt_Password.Text));
        if Frm_Main.ID_User <> 0 then
        begin
          DS := Conn.LoadParish(Frm_Main.ID_User);
          MT := TFDMemTable.Create(nil);
          try
            MT.AppendData(TFDJSONDataSetsReader.GetListValue(DS, 0));
            while not MT.Eof do
            begin
              Frm_Main.Parishes.Add(TParish.Create(MT.FieldByName('PARISH_ID').AsInteger,
                                                   MT.FieldByName('NAME').AsString)
                                    );
              Frm_Main.ID_Parish_Active := Frm_Main.Parishes[0].ID;
              MT.Next;
            end;

          finally
            if Assigned(MT) then
              FreeAndNil(MT);
          end;
        end;

        TThread.Synchronize(nil, procedure
        begin
          AniIndicator.Enabled := False;
          if Frm_Main.ID_User <> 0 then
          begin
            OpenForm(TFrm_Home);
          end
          else
            raise Exception.Create('Nome de usu�rio ou senha inv�lidos!');
        end);
      except
        on e : Exception do
        TThread.Synchronize(nil, procedure
        begin
          AniIndicator.Enabled := False;
          ShowMessage(e.Message);
        end);
      end;

    finally
      if DM_DataSnap.DSConn.Connected then
        DM_DataSnap.DSConn.Connected := False;
      FreeAndNil(Conn);
    end;

  end).Start;
end;

procedure TFrm_Login.FormCreate(Sender: TObject);
begin
  inherited;
  StoragePermission;
end;

end.
