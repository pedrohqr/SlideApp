unit uBase;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  Data.DBXDataSnap, Data.DBXCommon, IPPeerClient, Data.DB, Data.SqlExpr,
  FireDAC.Stan.StorageJSON;

type
  TFormBase = class(TForm)
    LayoutClient: TLayout;
  private
    { Private declarations }
  public
    { Public declarations }
  protected
    procedure OpenForm(AForm : TComponentClass); virtual;
  end;

var
  FormBase: TFormBase;

implementation

{$R *.fmx}

uses uMain;

{ TFormBase }

/// <summary> References to OpenForm function of MainForm
/// </summary>
procedure TFormBase.OpenForm(AForm: TComponentClass);
begin
  Frm_Main.OpenForm(AForm);
end;

end.
