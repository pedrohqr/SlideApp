unit uHome;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  uBase, FMX.Layouts, FMX.ListBox;

type
  TFrm_Home = class(TFormBase)
    LB: TListBox;
    lbi_New_Mass: TListBoxItem;
    lbi_Masses: TListBoxItem;
    lbi_Songs: TListBoxItem;
    cbb_parish: TComboBox;
    procedure lbi_New_MassClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure lbi_SongsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbb_parishChange(Sender: TObject);
    procedure lbi_MassesClick(Sender: TObject);
  private
    procedure LoadParish;
  public
    { Public declarations }
  end;

var
  Frm_Home: TFrm_Home;

implementation

{$R *.fmx}

uses
{$IFDEF ANDROID}
  Androidapi.Helpers,
  Androidapi.JNI.App,
{$ENDIF}
  FMX.DialogService, uNewMass, uMain, uSong, uMassList;

procedure TFrm_Home.cbb_parishChange(Sender: TObject);
begin
  inherited;
  if cbb_parish.ItemIndex <> -1 then
    Frm_Main.ID_Parish_Active := Frm_Main.Parishes[cbb_parish.ItemIndex].ID;
end;

procedure TFrm_Home.FormCreate(Sender: TObject);
begin
  inherited;
  LoadParish;
end;

procedure TFrm_Home.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  inherited;
  if Key = vkHardwareBack then
  begin
    Key := 0;

    TDialogService.MessageDialog('Deseja fechar a aplica��o?', TMsgDlgType.mtInformation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbYes, 0,
    procedure(const AResult: TModalResult)
    begin
      case AResult of
        mrYES:
        begin
          {$IFDEF ANDROID}
            TAndroidHelper.Activity.finish;
          {$ENDIF}
        end;
      end;
    end);
  end;
end;

procedure TFrm_Home.lbi_MassesClick(Sender: TObject);
begin
  inherited;
  OpenForm(TFrm_Mass);
end;

procedure TFrm_Home.lbi_New_MassClick(Sender: TObject);
begin
  inherited;
  Frm_Main.OpenForm(TFrm_New_Mass);
end;

procedure TFrm_Home.lbi_SongsClick(Sender: TObject);
begin
  inherited;
  OpenForm(TFrm_Songs);
end;

procedure TFrm_Home.LoadParish;
var
  I: Integer;
begin
  for I := 0 to pred(Frm_Main.Parishes.Count) do
  begin
    cbb_parish.Items.Add(Frm_Main.Parishes[I].Name);
    cbb_parish.ItemIndex := 0;
  end;
end;

end.
