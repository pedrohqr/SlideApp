unit Frm_Main;

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFMain = class(TForm)
    Panel1: TPanel;
    btn_Management: TButton;
    procedure btn_ManagementClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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

end.

