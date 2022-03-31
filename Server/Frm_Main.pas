unit Frm_Main;

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, REST.Types, REST.Client, Data.Bind.Components,
  Data.Bind.ObjectScope;

type
  TFMain = class(TForm)
    Panel1: TPanel;
    btn_Management: TButton;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    lbl_ip_remote: TLabel;
    procedure btn_ManagementClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FMain: TFMain;

implementation

{$R *.dfm}

uses Frm_Management;

procedure TFMain.btn_ManagementClick(Sender: TObject);
begin
  if not Assigned(FManagement) then
    FManagement := TFManagement.Create(nil);
  FManagement.Show;
  Hide;
end;

procedure TFMain.FormCreate(Sender: TObject);
begin
  ForceDirectories(ExtractFilePath(ParamStr(0)) + 'reports\');
end;

procedure TFMain.FormShow(Sender: TObject);
begin
  try
    RESTRequest1.Execute;
    lbl_ip_remote.Caption := RESTResponse1.Content;
  except on e : exception do
    lbl_ip_remote.Caption := e.Message;
  end;
end;

end.

