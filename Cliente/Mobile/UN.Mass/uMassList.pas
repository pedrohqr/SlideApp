unit uMassList;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  uBase, FMX.Layouts, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.Controls.Presentation, FMX.ListView,
  FMX.Objects, FMX.Edit, FMX.ListBox, System.ImageList, FMX.ImgList;

type
  TFrm_Mass = class(TFormBase)
    LV: TListView;
    lbl_info_LV_Mass: TLabel;
    Rectangle1: TRectangle;
    Label1: TLabel;
    Rectangle5: TRectangle;
    Edt_Search: TEdit;
    SearchEditButton1: TSearchEditButton;
    ClearEditButton1: TClearEditButton;
    btn_filter: TButton;
    Rec_Filter: TRectangle;
    Label2: TLabel;
    cbb_Filter: TComboBox;
    lbi_mass_date: TListBoxItem;
    lbi_gen_mass: TListBoxItem;
    lbi_title: TListBoxItem;
    lbi_user: TListBoxItem;
    btn_asc_desc: TButton;
    Rectangle2: TRectangle;
    Label3: TLabel;
    btn_all_users: TButton;
    Ani: TAniIndicator;
    ImageList1: TImageList;
    PB: TProgressBar;
    procedure FormCreate(Sender: TObject);
    procedure btn_asc_descClick(Sender: TObject);
    procedure cbb_FilterChange(Sender: TObject);
    procedure btn_filterClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure btn_all_usersClick(Sender: TObject);
    procedure ClearEditButton1Click(Sender: TObject);
    procedure SearchEditButton1Click(Sender: TObject);
    procedure LVItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
  private
    ASC : Boolean;
    ALL_USERS : Boolean;
    Filter : String;
    Page : SmallInt;
    procedure Insert_LV(Mass_ID : Integer; UName, MassTitle, Mass_Date, Gen_Mass : String);
    procedure Edit_Item(AIndex : Integer);
    procedure LoadMass(Pag : SmallInt; Text : String; User_ID,
                        Parish_ID : Integer);
    procedure DownloadMass(Mass_ID, ItemIndex : Integer);
  public

  end;

var
  Frm_Mass: TFrm_Mass;

implementation

{$R *.fmx}

uses DS_Functions, Data.FireDACJSONReflect, FireDAC.Comp.Client, uClientModule,
  uMain, FMX.Ani, uHome, Data.DB, System.IOUtils, FMX.DialogService,
  Lib_General, System.JSON, Data.DBXJSONCommon;

const FilterHeight = 111;

{ TFrm_Mass }

procedure TFrm_Mass.btn_asc_descClick(Sender: TObject);
begin
  inherited;
  if ASC then
  begin
    ASC := False;
    btn_asc_desc.Text := 'Decrescente';
  end
  else
  begin
    ASC := True;
    btn_asc_desc.Text := 'Crescente';
  end;

  btn_filterClick(Sender);

  LV.ScrollViewPos := 0;
  Page := 1;
  LV.Items.Clear;
  if ALL_USERS then
  LoadMass(Page, Trim(Edt_Search.Text), 0, Frm_Main.ID_Parish_Active)
  else
  LoadMass(Page, Trim(Edt_Search.Text), Frm_Main.ID_User, Frm_Main.ID_Parish_Active);
end;

procedure TFrm_Mass.btn_filterClick(Sender: TObject);
begin
  inherited;
  if Rec_Filter.Visible then  //se fechado
  begin
//    TAnimator.AnimateFloat(Rec_Filter, 'Height', FilterHeight, 0.2, TAnimationType.In, TInterpolationType.Linear);
    Rec_Filter.Visible := False;
  end
  else //se nao, aberto
  begin
//    TAnimator.AnimateFloat(Rec_Filter, 'Height', 0, 0.2, TAnimationType.Out, TInterpolationType.Linear);
    Rec_Filter.Visible := True;
  end;
end;

procedure TFrm_Mass.btn_all_usersClick(Sender: TObject);
begin
  inherited;
  if ALL_USERS then
  begin
    ALL_USERS := False;
    btn_all_users.Text := 'Somente as minhas';
  end
  else
  begin
    ALL_USERS := True;
    btn_all_users.Text := 'Todos os usu�rios';
  end;

  btn_filterClick(Sender);

  LV.ScrollViewPos := 0;
  Page := 1;
  LV.Items.Clear;
  if ALL_USERS then
  LoadMass(Page, Trim(Edt_Search.Text), 0, Frm_Main.ID_Parish_Active)
  else
  LoadMass(Page, Trim(Edt_Search.Text), Frm_Main.ID_User, Frm_Main.ID_Parish_Active);
end;

procedure TFrm_Mass.cbb_FilterChange(Sender: TObject);
begin
  inherited;
  case cbb_Filter.ItemIndex of
    0 : Filter := 'DATE';
    1 : Filter := 'DATE_GEN';
    2 : Filter := 'TITLE';
    3 : Filter := 'USER_ID';
  end;

  btn_filterClick(Sender);

  LV.ScrollViewPos := 0;
  Page := 1;
  LV.Items.Clear;
  if ALL_USERS then
  LoadMass(Page, Trim(Edt_Search.Text), 0, Frm_Main.ID_Parish_Active)
  else
  LoadMass(Page, Trim(Edt_Search.Text), Frm_Main.ID_User, Frm_Main.ID_Parish_Active);
end;

procedure TFrm_Mass.ClearEditButton1Click(Sender: TObject);
begin
  inherited;
  if Rec_Filter.Visible then
    btn_filterClick(Sender);

  LV.ScrollViewPos := 0;
  Page := 1;
  LV.Items.Clear;
  if ALL_USERS then
  LoadMass(Page, '', 0, Frm_Main.ID_Parish_Active)
  else
  LoadMass(Page, '', Frm_Main.ID_User, Frm_Main.ID_Parish_Active);
end;

procedure TFrm_Mass.DownloadMass(Mass_ID, ItemIndex: Integer);
begin
  PB.Value := 0;
  PB.Visible := True;

  TThread.CreateAnonymousThread(procedure
  begin
    try
      repeat
        Sleep(100);
        TThread.Synchronize(nil, procedure
        begin
          PB.Value := PB.Value + 1;
        end);
      until (PB.Value = 50);
    except on e : exception do
      TThread.Synchronize(nil, procedure
      begin
        ShowMessage(e.Message);
      end);
    end;
  end).Start;

  TThread.CreateAnonymousThread(procedure
  var
    Mass : TMassClient;
    FStream : TFileStream;
    InStream : TStream;
    FBuffer : Array[0..1023] of Byte;
    ReadByte : SmallInt;
  begin
    if not DM_DataSnap.DSConn.Connected then
      DM_DataSnap.DSConn.Connected := True;
    Mass := TMassClient.Create(DM_DataSnap.DSConn.DBXConnection);
    FStream := TFileStream.Create(PathSlide + '/Missa_'+Mass_ID.ToString+'.pptx', fmCreate);
    try
      try
        InStream := TDBXJSONTools.JSONToStream(Mass.DownloadSlide(Mass_ID));

        repeat
          ReadByte := InStream.Read(FBuffer,1024);
          FStream.Write(FBuffer,ReadByte);

          TThread.Synchronize(nil, procedure
          begin
            PB.Value := PB.Value + 1;
          end);
        until(ReadByte=0);

        TThread.Synchronize(nil, procedure
        begin
          Edit_Item(ItemIndex);
          ShowMessage('Download conclu�do!');
        end);
      except on e : exception do
        TThread.Synchronize(nil, procedure
        begin
          ShowMessage('N�o foi poss�vel baixar este arquivo: ' + e.Message);
        end);
      end;
    finally
      if Assigned(Mass) then
        FreeAndNil(Mass);
      if Assigned(FStream) then
        FreeAndNil(FStream);
      if Assigned(InStream) then
        FreeAndNil(InStream);
      TThread.Synchronize(nil, procedure
      begin
        PB.Value := PB.Max;
        PB.Visible := False;
      end);
    end;
  end).Start;

end;

/// <summary> Change the LVItem to 'downloaded'
/// </summary>
procedure TFrm_Mass.Edit_Item(AIndex: Integer);
begin
  LV.BeginUpdate;
  with LV.Items[AIndex] do
  begin
    Data['img_status'] := ImageList1.Bitmap(TSizeF.Create(30, 30), 1);
    Data['img_share']  := ImageList1.Bitmap(TSizeF.Create(30, 30), 2);
  end;
  LV.EndUpdate;
end;

procedure TFrm_Mass.FormCreate(Sender: TObject);
begin
  inherited;
  Filter := 'DATE';
  ASC := False;
  ALL_USERS := True;
  Page := 1;

  LV.Items.Clear;
  if ALL_USERS then
  LoadMass(Page, Trim(Edt_Search.Text), 0, Frm_Main.ID_Parish_Active)
  else
  LoadMass(Page, Trim(Edt_Search.Text), Frm_Main.ID_User, Frm_Main.ID_Parish_Active);
end;

procedure TFrm_Mass.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  inherited;
  if Key = vkHardwareBack then
  begin
    Key := 0;
    if Rec_Filter.Visible then //filtro aberto
      btn_filterClick(Sender)
    else
      OpenForm(TFrm_Home);
  end;
end;

procedure TFrm_Mass.Insert_LV(Mass_ID : Integer; UName, MassTitle, Mass_Date, Gen_Mass : String);
var
  AItem : TListViewItem;
begin
  LV.BeginUpdate;
  with AItem do
  begin
    AItem := LV.Items.Add;

    Data['lbl_user']      := 'USU�RIO:';
    Data['lbl_mass_date'] := 'DATA DA MISSA:';
    Data['lbl_gen_mass']  := 'GERADO EM:';

    Data['user']      := UName;
    Data['title']     := MassTitle;
    Data['mass_date'] := Mass_Date;
    Data['gen_mass']  := Gen_Mass;

    if FileExists(TPath.Combine(PathSlide, 'Missa_'+Mass_ID.ToString+'.pptx')) then
    begin
      Data['img_status'] := ImageList1.Bitmap(TSizeF.Create(30, 30), 1);
      Data['img_share']  := ImageList1.Bitmap(TSizeF.Create(30, 30), 2);
    end
    else
      Data['img_status'] := ImageList1.Bitmap(TSizeF.Create(30, 30), 0);

    Tag := Mass_ID;
  end;
  LV.EndUpdate;
end;

procedure TFrm_Mass.LoadMass(Pag : SmallInt; Text : String; User_ID,
                            Parish_ID : Integer);
begin
  Ani.Visible := True;
  Ani.Enabled := True;
  TThread.CreateAnonymousThread(procedure
  var
    DS : TFDJSONDataSets;
    MT : TFDMemTable;
    Mass : TMassClient;
  begin
    if not DM_DataSnap.DSConn.Connected then
     DM_DataSnap.DSConn.Connected := True;
    MT := TFDMemTable.Create(nil);
    Mass := TMassClient.Create(DM_DataSnap.DSConn.DBXConnection);
    try
      try
        DS := Mass.Get_Mass(Pag, User_ID, Parish_ID, Filter, Text, ASC);
        MT.Active := False;
        MT.AppendData(TFDJSONDataSetsReader.GetListValue(DS, 0));
        MT.Active := True;

        TThread.Synchronize(nil, procedure
        begin
          Ani.Visible := False;
          Ani.Enabled := False;
          while not MT.Eof do
          with MT do
          begin
            Insert_LV(FieldByName('MASS_ID').AsInteger,
                      FieldByName('UNAME').AsString,
                      FieldByName('TITLE').AsString,
                      FieldByName('MASS_DATE').AsString,
                      FieldByName('GENERATE_DATE').AsString);
            Next;
          end;

          if (MT.IsEmpty) and (LV.Items.Count = 0) then
          begin
            if Edt_Search.Text.IsEmpty then
            lbl_info_LV_Mass.Text := 'N�o h� missas realizadas'
            else
            lbl_info_LV_Mass.Text := 'Missa n�o encontrada';
            lbl_info_LV_Mass.Visible := True;
          end
          else
            lbl_info_LV_Mass.Visible := False;
        end);
      except on e : exception do
        TThread.Synchronize(nil, procedure
        begin
          Ani.Visible := False;
          Ani.Enabled := False;
          ShowMessage(e.Message);
        end);
      end;
    finally
      if DM_DataSnap.DSConn.Connected then
        DM_DataSnap.DSConn.Connected := False;
      if Assigned(Mass) then
        FreeAndNil(Mass);
      if Assigned(MT) then
        FreeAndNil(MT);
    end;
  end).Start;
end;

procedure TFrm_Mass.LVItemClickEx(const Sender: TObject; ItemIndex: Integer;
  const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
var
  Stream : TFileStream;
begin
  inherited;
  if Assigned(ItemObject) then
  begin
    if (ItemObject.Name = 'img_status') and (not LV.Items[ItemIndex].HasData['img_share']) then
    begin
      Vibrate(50);
      var Text : String;
      Text := 'Deseja fazer o download do slide "'+LV.Items[ItemIndex].Data['title'].ToString+
              '" de "'+LV.Items[ItemIndex].Data['user'].ToString+'"?';
      TDialogService.MessageDialog(Text, TMsgDlgType.mtInformation,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbYes, 0,
      procedure(const AResult: TModalResult)
      begin
        case AResult of
          mrYES:
          begin
            DownloadMass(LV.Items[ItemIndex].Tag, ItemIndex);
          end;
        end;
      end);
    end
    else
    if (ItemObject.Name = 'img_share') and (LV.Items[ItemIndex].HasData['img_share']) then
      if FileExists(PathSlide + '/Missa_'+LV.Items[ItemIndex].Tag.ToString+'.pptx') then
      begin
//        ShowMessage(TPath.Combine(TPath.GetHomePath, 'Missa_'+LV.Items[ItemIndex].Tag.ToString+'.pptx'));
        OpenPPTX(PathSlide + '/Missa_'+LV.Items[ItemIndex].Tag.ToString+'.pptx')
      end
      else
        ShowMessage('Erro: Arquivo n�o encontrado');
  end;
end;

procedure TFrm_Mass.SearchEditButton1Click(Sender: TObject);
begin
  inherited;
  if Rec_Filter.Height > 0 then
    btn_filterClick(Sender);

  LV.ScrollViewPos := 0;
  Page := 1;
  LV.Items.Clear;
  if ALL_USERS then
  LoadMass(Page, Trim(Edt_Search.Text), 0, Frm_Main.ID_Parish_Active)
  else
  LoadMass(Page, Trim(Edt_Search.Text), Frm_Main.ID_User, Frm_Main.ID_Parish_Active);
end;

end.
