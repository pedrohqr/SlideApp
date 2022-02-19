unit uNewMass;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  uBase, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.Controls.Presentation, FMX.Objects,
  FMX.ListView, FMX.Layouts, FMX.TabControl, FMX.Edit,
  Data.DBXDataSnap, Data.DBXCommon, IPPeerClient, Data.DB, Data.SqlExpr,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.StorageJSON,
  FMX.Gestures, uMass, FMX.Calendar, FMX.ListBox;

type
  TFrm_New_Mass = class(TFormBase)
    LV_MM: TListView;
    Rectangle1: TRectangle;
    Label1: TLabel;
    Lay_Tab1: TLayout;
    btn_add_music: TButton;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    Lay_Tools: TLayout;
    Lay_Tab2: TLayout;
    LV_Search: TListView;
    Rectangle2: TRectangle;
    Label2: TLabel;
    Rectangle3: TRectangle;
    cbb_Moments: TComboBox;
    Rectangle4: TRectangle;
    Label3: TLabel;
    Edt_Search_Music: TEdit;
    Rectangle5: TRectangle;
    SearchEditButton1: TSearchEditButton;
    btn_add: TRectangle;
    Label4: TLabel;
    lbl_info_lv_search: TLabel;
    GestureManager1: TGestureManager;
    lbl_info_LV_Mass: TLabel;
    btn_Done_Mass: TRectangle;
    lbl_done_mass: TLabel;
    Rectangle6: TRectangle;
    Edt_Title: TEdit;
    Calendar: TCalendar;
    btn_Mass_Date: TButton;
    Ani: TAniIndicator;
    ClearEditButton1: TClearEditButton;
    procedure btn_add_musicClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SearchEditButton1Click(Sender: TObject);
    procedure LV_SearchItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure Edt_Search_MusicKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure btn_addClick(Sender: TObject);
    procedure LV_MMDeletingItem(Sender: TObject; AIndex: Integer;
      var ACanDelete: Boolean);
    procedure LV_MMDeleteItem(Sender: TObject; AIndex: Integer);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure btn_Done_MassClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btn_Mass_DateClick(Sender: TObject);
    procedure ClearEditButton1Click(Sender: TObject);
    procedure CalendarDateSelected(Sender: TObject);
  private
    Mass : TMass;
    Page : SmallInt;
    procedure LoadMoments;
    procedure InsertMoments(AID : SmallInt; AName : String);
    procedure SearchMusic(Text : String);
    procedure ClearSearch;
    procedure Insert_LVItem_Music(AID : Integer; AName, AArtist, ALink: String);
    procedure Insert_LVItem_Mass(ASongID : SmallInt; AMoment, ASong, AArtist : String);
    procedure Send_Mass;
  public

  end;

var
  Frm_New_Mass: TFrm_New_Mass;

implementation

{$R *.fmx}

uses
  Data.FireDACJSONReflect, DS_Functions, uClientModule, Lib_General, uHome,
  uMain, FMX.Ani, FMX.DialogService;

procedure TFrm_New_Mass.btn_addClick(Sender: TObject);
begin
  inherited;
  if cbb_Moments.ItemIndex < 0 then
    ShowMessage('Selecione o momento!')
  else if LV_Search.ItemIndex < 0 then
    ShowMessage('Selecione a m�sica na caixa de pesquisas!')
  else
  begin
    Mass.AddSong(LV_Search.Items[LV_Search.ItemIndex].Tag,
                 cbb_Moments.ListItems[cbb_Moments.ItemIndex].Tag,
                 LV_Search.Items[LV_Search.ItemIndex].Data['song'].ToString,
                 cbb_Moments.Items[cbb_Moments.ItemIndex]);
    Insert_LVItem_Mass(LV_Search.Items[LV_Search.ItemIndex].Tag,
                       cbb_Moments.Items[cbb_Moments.ItemIndex],
                       LV_Search.Items[LV_Search.ItemIndex].Data['song'].ToString,
                       LV_Search.Items[LV_Search.ItemIndex].Data['artist'].ToString);
    TabControl1.ActiveTab := TabItem1;
  end;
end;

procedure TFrm_New_Mass.btn_add_musicClick(Sender: TObject);
begin
  inherited;
  ClearSearch;
  TabControl1.ActiveTab := TabItem2;
end;

/// <summary> Create fields to use in insert of MASS_SONG table on Server
/// </summary>
procedure CreateFieldsMass_Song(var MT : TFDMemTable);
begin
  with MT.FieldDefs do
  begin
    with AddFieldDef do
    begin
      Name := 'MASS_SONG_ID';
      DataType := ftInteger;
    end;
    with AddFieldDef do
    begin
      Name := 'MASS_ID';
      DataType := ftInteger;
    end;
    with AddFieldDef do
    begin
      Name := 'SONG_ID';
      DataType := ftInteger;
    end;
    with AddFieldDef do
    begin
      Name := 'MOMENT_ID';
      DataType := ftInteger;
    end;
    with AddFieldDef do
    begin
      Name := 'SONG_ORDER';
      DataType := ftInteger;
    end;
  end;
end;

/// <summary> Create fields to use in insert of MASS table on Server
/// </summary>
procedure CreateFieldsMass(var MT : TFDMemTable);
begin
  with MT.FieldDefs do
  begin
    with AddFieldDef do
    begin
      Name := 'MASS_ID';
      DataType := ftInteger;
    end;
    with AddFieldDef do
    begin
      Name := 'TITLE';
      DataType := ftString;
      Size := 200;
    end;
    with AddFieldDef do
    begin
      Name := 'MASS_DATE';
      DataType := ftDate;
    end;
    with AddFieldDef do
    begin
      Name := 'LIT_TIME_ID';
      DataType := ftInteger;
    end;
    with AddFieldDef do
    begin
      Name := 'GENERATE_DATE';
      DataType := ftDateTime;
    end;
    with AddFieldDef do
    begin
      Name := 'USER_ID';
      DataType := ftInteger;
    end;
    with AddFieldDef do
    begin
      Name := 'PARISH_ID';
      DataType := ftInteger;
    end;
  end;
end;

/// <summary> Send all musics of the ListView to server
procedure TFrm_New_Mass.Send_Mass;
begin
  TThread.CreateAnonymousThread(procedure
  var
    Connection : TMassClient;
    DS : TFDJSONDataSets;
    MT_Mass : TFDMemTable;
    MT_Song : TFDMemTable;
    I : SmallInt;
  begin
    if not DM_DataSnap.DSConn.Connected then
     DM_DataSnap.DSConn.Connected := True;
    Connection := TMassClient.Create(DM_DataSnap.DSConn.DBXConnection);
    DS := TFDJSONDataSets.Create;
    MT_Mass := TFDMemTable.Create(nil);
    MT_Song := TFDMemTable.Create(nil);

    try
      try
        CreateFieldsMass(MT_Mass);
        CreateFieldsMass_Song(MT_Song);
        MT_Mass.Open;
        MT_Song.Open;
        with MT_Mass do
        begin
          Append;
          FieldByName('MASS_ID').AsInteger        := Mass.ID;
          FieldByName('TITLE').AsString           := Mass.Title;
          FieldByName('MASS_DATE').AsDateTime     := Mass.Date;
          FieldByName('LIT_TIME_ID').AsInteger    := 1;
          FieldByName('GENERATE_DATE').AsDateTime := Now;
          FieldByName('USER_ID').AsInteger        := Frm_Main.ID_User;
          FieldByName('PARISH_ID').AsInteger      := Frm_Main.ID_Parish_Active;
          Post;
        end;

        with MT_Song do
        for I := 0 to pred(Mass.Songs.Count) do
        begin
          Append;
          FieldByName('MASS_SONG_ID').Clear;
          FieldByName('MASS_ID').AsInteger := Mass.ID;
          FieldByName('SONG_ID').AsInteger := Mass.Songs[I].ID;
          FieldByName('MOMENT_ID').AsInteger := Mass.Songs[I].Moment.ID;
          FieldByName('SONG_ORDER').Clear;
          Post;
        end;

        TFDJSONDataSetsWriter.ListAdd(DS, MT_Mass);
        TFDJSONDataSetsWriter.ListAdd(DS, MT_Song);
        Connection.Register_Mass(DS);

        TThread.Synchronize(nil, procedure
        begin
          ShowMessage('Enviado!');
          if Assigned(Mass) then
            FreeAndNil(Mass);
          OpenForm(TFrm_Home);
        end);

      except on e : exception do
        TThread.Synchronize(nil, procedure
        begin
          ShowMessage(e.Message)
        end);
      end;
    finally
      if DM_DataSnap.DSConn.Connected then
        DM_DataSnap.DSConn.Connected := False;
      if Assigned(Connection) then
        FreeAndNil(Connection);
      if Assigned(MT_Mass) then
        FreeAndNil(MT_Mass);
      if Assigned(MT_Song) then
        FreeAndNil(MT_Song);
//      if Assigned(DS) then
//        FreeAndNil(DS);
    end;
  end).Start;
end;

procedure TFrm_New_Mass.btn_Done_MassClick(Sender: TObject);
begin
  inherited;
  Mass.Title := Edt_Title.Text;
  if LV_MM.Items.Count = 0 then
    ShowMessage('N�o � poss�vel finalizar uma missa sem m�sicas!')
  else
  begin
    TDialogService.MessageDialog('Deseja finalizar e enviar todas as m�sicas?', TMsgDlgType.mtInformation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbYes, 0,
    procedure(const AResult: TModalResult)
    begin
      case AResult of
        mrYES:
        begin
          Send_Mass;
        end;
      end;
    end);
  end;
end;

procedure TFrm_New_Mass.btn_Mass_DateClick(Sender: TObject);
begin
  inherited;
  if Calendar.Height = 0 then
    TAnimator.AnimateFloat(Calendar, 'Height', Lay_Tab1.Height-Lay_Tools.Height,
                          0.1, TAnimationType.InOut, TInterpolationType.Linear)
  else
    TAnimator.AnimateFloat(Calendar, 'Height', 0,
                          0.1, TAnimationType.InOut, TInterpolationType.Linear)
end;

/// <summary> Clear all results of music
procedure TFrm_New_Mass.CalendarDateSelected(Sender: TObject);
begin
  inherited;
  Mass.Date := Calendar.Date;
end;

procedure TFrm_New_Mass.ClearEditButton1Click(Sender: TObject);
begin
  inherited;
  Page := 1;
  LV_Search.Items.Clear;
end;

procedure TFrm_New_Mass.ClearSearch;
begin
  cbb_Moments.ItemIndex := -1;
  Edt_Search_Music.Text := '';
  lbl_info_lv_search.Visible := False;
  LV_Search.Items.Clear;
end;

procedure TFrm_New_Mass.Edt_Search_MusicKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  inherited;
  if Key = 13 then
    SearchEditButton1Click(Sender);
end;

procedure TFrm_New_Mass.FormCreate(Sender: TObject);
begin
  inherited;
  TabControl1.ActiveTab := TabItem1;
  LoadMoments;
  lbl_info_LV_Mass.Visible := True;
  Mass := TMass.Create;
  Mass.Date := Now;
end;

procedure TFrm_New_Mass.FormDestroy(Sender: TObject);
begin
  inherited;
  if Assigned(Mass) then
    FreeAndNil(Mass);
end;

procedure TFrm_New_Mass.FormKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  inherited;
  if Key = vkHardwareBack then
  begin
    Key := 0;
    if TabControl1.ActiveTab = TabItem2 then
      TabControl1.ActiveTab := TabItem1
    else
    begin
      if Calendar.Height > 0 then
        btn_Mass_DateClick(Sender)
      else
      OpenForm(TFrm_Home);
    end;

  end;
end;

/// <summary> Insert the moment in the ComboBox
/// </summary>
procedure TFrm_New_Mass.InsertMoments(AID: SmallInt; AName: String);
var
  Item : TListBoxItem;
begin
  Item := TListBoxItem.Create(cbb_Moments);
  cbb_Moments.BeginUpdate;
  Item.Parent := cbb_Moments;
  Item.Text := AName;
  Item.Tag := AID;
  cbb_Moments.EndUpdate;
end;

/// <summary> Insert the ListViewItem in the LV of the mass
/// </summary>
procedure TFrm_New_Mass.Insert_LVItem_Mass(ASongID : SmallInt; AMoment, ASong, AArtist: String);
var
  AItem : TListViewItem;
begin
  LV_MM.BeginUpdate;
  with AItem do
  begin
    AItem := LV_MM.Items.Add;

    Data['moment'] := AMoment;
    Data['song']   := ASong;
    Data['artist'] := AArtist;
    Tag := ASongID;

  end;
  LV_MM.EndUpdate;

  if LV_MM.Items.Count > 0 then
    lbl_info_LV_Mass.Visible := False
  else
    lbl_info_LV_Mass.Visible := True;
end;

/// <summary> Insert the ListViewItem in the LV of the music search
/// </summary>
procedure TFrm_New_Mass.Insert_LVItem_Music(AID : Integer; AName, AArtist, ALink: String);
var
  AItem : TListViewItem;
begin
  LV_Search.BeginUpdate;
  with AItem do
  begin
    AItem := LV_Search.Items.Add;

    Data['song'] := AName;
    Data['artist'] := AArtist;
    Data['link'] := ALink;
    Tag := AID;
  end;
  LV_Search.EndUpdate;
end;

/// <summary> Load all moments of mass in the ComboBox
/// </summary>
procedure TFrm_New_Mass.LoadMoments;
begin
  TThread.CreateAnonymousThread(procedure
  var
    DS : TFDJSONDataSets;
    MT : TFDMemTable;
    Moments : TMassClient;
  begin
    if not DM_DataSnap.DSConn.Connected then
     DM_DataSnap.DSConn.Connected := True;
    MT := TFDMemTable.Create(nil);
    Moments := TMassClient.Create(DM_DataSnap.DSConn.DBXConnection);
    try
      try
        DS := Moments.Get_Moments;
        MT.Active := False;
        MT.AppendData(TFDJSONDataSetsReader.GetListValue(DS, 0));
        MT.Active := True;

        TThread.Synchronize(nil, procedure
        begin
          cbb_Moments.Items.Clear;
          while not MT.Eof do
          with MT do
          begin
            InsertMoments(FieldByName('MOMENT_ID').AsInteger,
                          FieldByName('NAME').AsString);
            Next;
          end;
        end);
      except on e : exception do
        TThread.Synchronize(nil, procedure
        begin
          ShowMessage(e.Message);
        end);
      end;
    finally
      if DM_DataSnap.DSConn.Connected then
        DM_DataSnap.DSConn.Connected := False;
      if Assigned(Moments) then
        FreeAndNil(Moments);
      if Assigned(MT) then
        FreeAndNil(MT);
    end;
  end).Start;
end;

procedure TFrm_New_Mass.LV_MMDeleteItem(Sender: TObject; AIndex: Integer);
begin
  inherited;
  if LV_MM.Items.Count > 0 then
    lbl_info_LV_Mass.Visible := False
  else
    lbl_info_LV_Mass.Visible := True;
end;

procedure TFrm_New_Mass.LV_MMDeletingItem(Sender: TObject; AIndex: Integer;
  var ACanDelete: Boolean);
begin
  inherited;
  ACanDelete := True;
  Mass.RemoveSong(LV_MM.Items[AIndex].Tag);
  Vibrate(50);
end;

procedure TFrm_New_Mass.LV_SearchItemClickEx(const Sender: TObject;
  ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
begin
  inherited;
  if ItemObject.Name = 'link' then
  begin
    OpenYouTubeVideo(ItemObject.Data.AsString);
  end;
end;

procedure TFrm_New_Mass.SearchEditButton1Click(Sender: TObject);
begin
  inherited;
  Page := 1;
  LV_Search.Items.Clear;
  SearchMusic(Edt_Search_Music.Text);
end;

/// <summary> Search for music typed in Edt_Search with page of Query
/// </summary>
procedure TFrm_New_Mass.SearchMusic(Text : String);
begin
  Ani.Visible := True;
  Ani.Enabled := True;
  TThread.CreateAnonymousThread(procedure
  var
    DS : TFDJSONDataSets;
    MT : TFDMemTable;
    Song : TSongClient;
  begin
    if not DM_DataSnap.DSConn.Connected then
     DM_DataSnap.DSConn.Connected := True;
    MT := TFDMemTable.Create(nil);
    Song := TSongClient.Create(DM_DataSnap.DSConn.DBXConnection);
    try
      try
        DS := Song.Get_Songs(Page, Text);
        MT.Active := False;
        MT.AppendData(TFDJSONDataSetsReader.GetListValue(DS, 0));
        MT.Active := True;

        TThread.Synchronize(nil, procedure
        begin
          while not MT.Eof do
          with MT do
          begin
            Insert_LVItem_Music(FieldByName('SONG_ID').AsInteger,
                               FieldByName('SONG_TITLE').AsString,
                               FieldByName('ARTIST_NAME').AsString,
                               FieldByName('AUDIO_LINK').AsString);
            Next;
          end;
          if (MT.IsEmpty) and (LV_Search.Items.Count = 0) then
          begin
            lbl_info_lv_search.Visible := True;
            lbl_info_lv_search.Text := 'M�sica n�o encontrada...';
          end
          else
            lbl_info_lv_search.Visible := False;
          Ani.Enabled := False;
          Ani.Visible := False;
        end);
      except on e : exception do
        TThread.Synchronize(nil, procedure
        begin
          Ani.Enabled := False;
          Ani.Visible := False;
          ShowMessage(e.Message);
        end);
      end;
    finally
      if DM_DataSnap.DSConn.Connected then
        DM_DataSnap.DSConn.Connected := False;
      FreeAndNil(MT);
      FreeAndNil(Song);
    end;
  end).Start;
end;

end.