unit ImageLabelButton;

{
  TImageLabelButton
  Версия: 0.95
  Автор: Владимир Борисенко (ЛеНтЯй)

  #! Нежелательно использовать на подложке с прозрачностью - начинает моргать

  -0.95-
  * Добавлено обесцвечивание иконки при неустановленной иконке и состоянии - "неактивен"
  * Добавлено обесцвечивание текста при состоянии - "неактивен"

  -0.92-
  * Добавлен "AutoPressed" параметр
  * Добавлены параметры расположения текста и иконок

  -0.90-
  * Оптимизирована работа с TImageList
  * Теперь удаление TImageList у компонента производится корректно
}

{
todo:
  * Сделать перенос текста в Caption
}

interface

uses
 Windows, Messages, SysUtils, Classes, Graphics, Controls, Math,
 CommCtrl, ImgList, UITypes {$IF CompilerVersion >= 23}, Vcl.Themes {$IFEND};

type
  TMouseState = (msCreate, msNormal, msDown, msUp, msEnter, msLeave);

  TImageLabelButton = class(TGraphicControl)
  private
    FMainImageIndex: TImageIndex;
    FDisabledImageIndex: TImageIndex;
    FEnterImageIndex: TImageIndex;
    FPressImageIndex: TImageIndex;
    FPressedImageIndex: TImageIndex;
    {}
    FIcon: TIcon;
    FImages: TCustomImageList;
    FInternalImageList: TImageList;
    FImageChangeLink: TChangeLink;
    {}
    FAlignment: TAlignment;
    FVerticalAlignment: TVerticalAlignment;
    FState: TMouseState;
    FEnabled: Boolean;
    FAutoSize: Boolean;
    FAutoPressed: Boolean;
    FTransparent: Boolean;
    FPressed: Boolean;
    {}
    FOnChange: TNotifyEvent;
    {}
    procedure SetImages(const Value: TCustomImageList);
    procedure UpdateImageList;
    procedure ImageListChange(Sender: TObject);
    {}
    procedure SetCaption(const Value: TCaption);
    function GetCaption: TCaption;
    procedure SetAlignment(const Value: TAlignment);
    procedure SetVerticalAlignment(const Value: TVerticalAlignment);
    procedure SetTransparent(const Value: Boolean);
    procedure SetEnabled(const Value: Boolean);
    procedure SetPressed(const Value: Boolean);
    {}
    procedure SetImageIndex(Value, Tag: integer);
    procedure SetMainImageIndex(const Value: TImageIndex);
    procedure SetDisabledImageIndex(const Value: TImageIndex);
    procedure SetEnterImageIndex(const Value: TImageIndex);
    procedure SetPressImageIndex(const Value: TImageIndex);
    procedure SetPressedImageIndex(const Value: TImageIndex);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    {}
    procedure SetState(const Value: TMouseState);
    {}
    procedure Paint; override;
    procedure Click; override;
    procedure DblClick; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure MouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMEraseBkGnd(var Message: TMessage); message WM_ERASEBKGND;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Caption: TCaption read GetCaption write SetCaption;
    property Visible;
    property Align;
    property Hint;
    property ShowHint;
    property ParentShowHint;
    property Color;
    property ParentColor;
    property Font;
    {}
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property VerticalAlignment: TVerticalAlignment read FVerticalAlignment write SetVerticalAlignment default taVerticalCenter;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property Transparent: Boolean read FTransparent write SetTransparent default True;
    property AutoSize: Boolean read FAutoSize write SetAutoSize default False;
    property Pressed: Boolean read FPressed write SetPressed default False;
    property AutoPressed: Boolean read FAutoPressed write FAutoPressed default False;

    property Images: TCustomImageList read FImages write SetImages;
    property ImageIndex: TImageIndex read FMainImageIndex write SetMainImageIndex default -1;
    property DisabledImageIndex: TImageIndex read FDisabledImageIndex write SetDisabledImageIndex default -1;
    property EnterImageIndex: TImageIndex read FEnterImageIndex write SetEnterImageIndex default -1;
    property PressImageIndex: TImageIndex read FPressImageIndex write SetPressImageIndex default -1;
    property PressedImageIndex: TImageIndex read FPressedImageIndex write SetPressedImageIndex default -1;

    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseUp;
    property OnChangeState: TNotifyEvent read FOnChange write FOnChange;
 end;

implementation

{--- TImageLabelButton ---}

constructor TImageLabelButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  {}
  FState := msCreate;
  Canvas.Brush.Color := {$IF CompilerVersion >= 23} StyleServices.GetSystemColor(Color); {$ELSE} Color; {$IFEND}

  {Подготовка дополнительных компонентов}
  FIcon := TIcon.Create;
  FImageChangeLink := TChangeLink.Create;
  FImageChangeLink.OnChange := ImageListChange;
  FInternalImageList := nil;

  {Состояние по умолчанию}
  Enabled := True;
  Width := 24;
  Height := 24;
  Cursor := crHandPoint;

  {Расположение}
  FAlignment := taLeftJustify;
  FVerticalAlignment := taVerticalCenter;

  {}
  FAutoSize := False;
  FPressed := False;
  FTransparent := True;

  {Индекси изображений}
  FMainImageIndex := -1;
  FDisabledImageIndex := -1;
  FEnterImageIndex := -1;
  FPressImageIndex := -1;
  FPressedImageIndex := -1;
end;

destructor TImageLabelButton.Destroy;
begin
  FreeAndNil(FIcon);
  FreeAndNil(FImageChangeLink);
  if Assigned(FInternalImageList) then FreeAndNil(FInternalImageList);

  inherited;
end;

procedure TImageLabelButton.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if (Operation = opRemove) and (AComponent = FImages) then
  begin
    SetImages(nil);
    FIcon.SetSize(0,0);
    Invalidate;
  end;
end;

{--//--}

procedure TImageLabelButton.SetImages(const Value: TCustomImageList);
begin
  if not (Assigned(Value)) then
  begin
    FImages := nil;
    if Assigned(FInternalImageList) then FInternalImageList.Clear;

    SetState(msCreate);
  end
  else if Value <> FImages then
  begin
    {}
    if FImages <> nil then FImages.UnRegisterChanges(FImageChangeLink);

    {}
    FImages := Value;

    {}
    if FImages <> nil then
    begin
      FImages.RegisterChanges(FImageChangeLink);
      FImages.FreeNotification(Self);
    end;

    {}
    UpdateImageList;
    SetState(msNormal);
    Invalidate;
  end;
end;

procedure TImageLabelButton.UpdateImageList;

  function GetColor(Value: DWORD): TColor;
  begin
    case Value of
      CLR_NONE: Result := clNone;
      CLR_DEFAULT: Result := clDefault;
      else Result := TColor(Value);
    end;
  end;

const
  PBS_NORMAL = 1;
  PBS_HOT = 2;
  PBS_PRESSED = 3;
  PBS_DISABLED = 4;
  PBS_DEFAULTED = 5;
  PBS_STYLUSHOT = 6;
begin
  if (CheckWin32Version(5, 1)) and (FImages <> nil) then
  begin
    if not (Assigned(FInternalImageList)) then FInternalImageList := TImageList.Create(nil);
    FInternalImageList.Clear;

    {}
    with FInternalImageList do
    begin
      ColorDepth := FImages.ColorDepth;
      Masked := FImages.Masked;
      ImageType := FImages.ImageType;
      DrawingStyle := FImages.DrawingStyle;
      ShareImages := FImages.ShareImages;
      SetSize(FImages.Width, FImages.Height);
      ImageList_SetIconSize(Handle, Width, Height);
      BkColor := GetColor(ImageList_GetBkColor(FImages.Handle));
      BlendColor := FImages.BlendColor;
    end;

    {}
    FInternalImageList.AddImages(FImages);
    if FState = msCreate then SetState(msNormal);
  end;
end;

procedure TImageLabelButton.ImageListChange(Sender: TObject);
begin
  UpdateImageList;
  Invalidate;
end;

{--//--}

procedure TImageLabelButton.SetCaption(const Value: TCaption);
begin
  Text := Value;
  Invalidate;
end;

function TImageLabelButton.GetCaption: TCaption;
begin
  Result := Text;
end;

procedure TImageLabelButton.SetAlignment(const Value: TAlignment);
begin
  FAlignment := Value;
  Invalidate;
end;

procedure TImageLabelButton.SetVerticalAlignment(const Value: TVerticalAlignment);
begin
  FVerticalAlignment := Value;
  Invalidate;
end;

procedure TImageLabelButton.SetTransparent(const Value: Boolean);
begin
  FTransparent := Value;
  Invalidate;
end;

procedure TImageLabelButton.SetEnabled(const Value: Boolean);
begin
  inherited Enabled := Value;

  FEnabled := Value;
  if not (FState = msCreate) then
  begin
    SetState(msNormal);
    Invalidate;
  end;
end;

procedure TImageLabelButton.SetPressed(const Value: Boolean);
begin
  FPressed := Value;

  if not (FState = msCreate) then
  begin
    SetState(msNormal);
    Invalidate;
  end;

  if (Enabled) and (Assigned(FOnChange)) then FOnChange(Self);
end;

{--//--}

procedure TImageLabelButton.SetImageIndex(Value, Tag: integer);
begin
  {}
  if Assigned(FInternalImageList) then
  begin
    if Value >= FInternalImageList.Count then Value := FInternalImageList.Count-1
      else if FInternalImageList.Count <= 0 then Value := -1;
  end;

  {}
  if Value < -1 then Value := -1;

  {Записываем состояние}
  case Tag of
    1: FDisabledImageIndex := Value;
    2: FEnterImageIndex := Value;
    3: FPressImageIndex := Value;
    4: FPressedImageIndex := Value;
    else FMainImageIndex := Value;
  end;

  {Устанавливаем состояние}
  if Assigned(FInternalImageList) then SetState(msNormal);
end;

procedure TImageLabelButton.SetMainImageIndex(const Value: TImageIndex);
begin
  SetImageIndex(Value, 0);
end;

procedure TImageLabelButton.SetDisabledImageIndex(const Value: TImageIndex);
begin
  SetImageIndex(Value, 1);
end;

procedure TImageLabelButton.SetEnterImageIndex(const Value: TImageIndex);
begin
  SetImageIndex(Value, 2);
end;

procedure TImageLabelButton.SetPressImageIndex(const Value: TImageIndex);
begin
  SetImageIndex(Value, 3);
end;

procedure TImageLabelButton.SetPressedImageIndex(const Value: TImageIndex);
begin
  SetImageIndex(Value, 4);
end;

{--//--}

procedure TImageLabelButton.SetState(const Value: TMouseState);

  procedure SetIcon(const iconIndex: TImageIndex);
  begin
    if not (Assigned(FInternalImageList)) or (FInternalImageList.Count < 0)
      or not (iconIndex <> -1) or (iconIndex >= FInternalImageList.Count) then
    begin
      FIcon.Destroy;
      FIcon := TIcon.Create;

      Exit;
    end;

    FInternalImageList.GetIcon(iconIndex, FIcon);
  end;

  procedure SetGrayIcon(const iconIndex: TImageIndex);
  var
    bitmap: TBitmap;
    n: Byte;
    x, y: Integer;
    dest: pRGBTriple;
  begin
    if not (Assigned(FInternalImageList)) or (FInternalImageList.Count < 0)
      or not (iconIndex <> -1) or (iconIndex >= FInternalImageList.Count) then
    begin
      FIcon.Destroy;
      FIcon := TIcon.Create;

      Exit;
    end;

    {}
    bitmap := TBitmap.Create;
    bitmap.PixelFormat := pf32Bit;
    bitmap.AlphaFormat := {afIgnored, afDefined, }afPremultiplied;
    bitmap.Transparent := True;
    bitmap.TransparentMode := tmFixed;
    bitmap.TransparentColor := clFuchsia;
    try
      {Считываем изображение}
      FInternalImageList.ColorDepth := cd32bit;
      FInternalImageList.DrawingStyle := dsTransparent;
      FInternalImageList.GetBitmap(iconIndex, bitmap);

      {Обесцвечиваем изображение}
      bitmap.PixelFormat := pf24Bit;
      for y := 0 to bitmap.Height - 1 do
      begin
        dest := bitmap.ScanLine[y];

        for x := 0 to bitmap.Width - 1 do
        begin
          with Dest^ do
          begin
            n := Trunc((rgbtBlue + rgbtGreen + rgbtRed) / 3);
            rgbtBlue := n;
            rgbtGreen := n;
            rgbtRed := n;
          end;

          Inc(Dest);
        end;
      end;

      {Преобазуем изображение в иконку}
      with TImageList.CreateSize(bitmap.Width, bitmap.Height) do
      begin
        try
          AllocBy := 1;
          AddMasked(bitmap, clWhite);

          {Сохраняем иконку}
          FIcon.Transparent := True;
          try
            GetIcon(0, FIcon);
          except
            FIcon.Free;
            raise;
          end;
        finally
          Free;
        end;
      end;
    finally
      FreeAndNil(bitmap);
    end;
  end;

begin
  FState := Value;

  if not (Enabled) then
  begin
    if FDisabledImageIndex > -1 then SetIcon(FDisabledImageIndex)
      else SetGrayIcon(FMainImageIndex);
  end
  else if (FPressed) and (FPressedImageIndex > -1) then SetIcon(FPressedImageIndex)
  else
  begin
    if Value = msEnter then SetIcon(FEnterImageIndex)
    else if Value = msDown then SetIcon(FPressImageIndex)
    else SetIcon(FMainImageIndex);
  end;

  Invalidate;
end;

procedure TImageLabelButton.Paint;
var
  IconTop, IconLeft, IconWidth, IconHeight: Integer;
  TextTop, TextLeft, TextWidth, TextHeight: Integer;
begin
  inherited Paint;

  {Подготавливаем полотно}
  if FTransparent then Canvas.Brush.Style := bsClear
  else
  begin
    Canvas.Brush.Style := bsSolid;
    Canvas.FillRect(Canvas.ClipRect);
  end;

  {Шрифт}
  Canvas.Font := Self.Font;

  {Текст}
  if Caption <> '' then
  begin
    TextWidth := Canvas.TextWidth(Caption);
    TextHeight := Canvas.TextHeight(Caption);
  end
  else
  begin
    TextWidth := 0;
    TextHeight := 0;
  end;

  {Изображение}
  if not (FIcon.Empty) then
  begin
    IconWidth := FIcon.Width;
    IconHeight := FIcon.Height;
  end
  else
  begin
    IconWidth := 0;
    IconHeight := 0;
  end;

  {Рисуем}
  if (Caption = '') and (FIcon.Empty or (IconWidth < 0) or (IconHeight < 0)) then Canvas.RoundRect(0, 0, Width, Height, 10, 10)
  else
  begin
    {Вертикальное расположение}
    case FVerticalAlignment of
      taAlignBottom: IconTop := Height - IconHeight;
      taVerticalCenter: IconTop := IfThen(FAlignment = taCenter, (Height - (IconHeight + TextHeight)) div 2, (Height - IconHeight) div 2);
      else IconTop := 0;
    end;

    {Горизонтальное расположение}
    case FAlignment of
      taRightJustify: IconLeft := Width - IconWidth;
      taCenter: IconLeft := (Width - IconWidth) div 2;
      else IconLeft := 0;
    end;

    {Рисуем}
    Canvas.Draw(IconLeft, IconTop, FIcon);
  end;

  {Рисуем текст}
  if Caption <> '' then
  begin
    {Вертикальное расположение}
    case FVerticalAlignment of
      taAlignBottom: TextTop := IfThen(IconHeight > 0, Height - ((IconHeight + TextHeight) div 2), Height - TextHeight);
      taVerticalCenter: TextTop := (Height - TextHeight) div 2;
      else TextTop := IfThen(IconHeight > 0, (IconHeight - TextHeight) div 2, 0);
    end;

    {Горизонтальное расположение}
    case FAlignment of
      taRightJustify: TextLeft := IconLeft - TextWidth - 5;
      taCenter:
      begin
        TextLeft := (Width - TextWidth) div 2;
        if FVerticalAlignment = taAlignBottom then TextTop := IfThen(FIcon.Empty, Height - TextHeight, Height - (IconHeight + TextHeight))
          else TextTop := IfThen(FIcon.Empty, 0, IconTop + IconHeight);
      end;
      else TextLeft := IconLeft + IconWidth + 5;
    end;

    {Выводим текст}
    if Enabled then Canvas.TextOut(TextLeft, TextTop, Caption)
    else
    begin
      Canvas.Font.Color := clBtnShadow;
      Canvas.TextOut(TextLeft - 1, TextTop - 1, Caption);
    end;
  end;

  {Высчитываем размеры}
  if {not (FIcon.Empty) and ((Width < FIcon.Width) or} ((FAutoSize) and (Align in [alNone, alCustom])){)} then
  begin
    Width := FIcon.Width + IfThen(Caption <> '', 5 + TextWidth, 0);
    if Width < 16 then Width := 16;
  end;

  if {not (FIcon.Empty) and ((Height < FIcon.Height) or} ((FAutoSize) and (Align in [alNone, alCustom])){)} then
  begin
    Height := FIcon.Height + IfThen(Caption <> '', 5 + TextHeight, 0);
    if Height < 16 then Height := 16;
  end;
end;

procedure TImageLabelButton.Click;
var
  Msg: TMsg;
  TargetTime: Longint;
begin
  {Отделение клика и дабл клика}
  TargetTime := GetTickCount + 60 {GetDoubleClickTime};
  while GetTickCount <  TargetTime do
   if PeekMessage(Msg, 0, WM_LBUTTONDBLCLK, WM_LBUTTONDBLCLK, 0)
      then Exit;

  {Автосмена состояния}
  if FAutoPressed then SetPressed(not FPressed);

  {}
  inherited;
end;

procedure TImageLabelButton.DblClick;
begin
  inherited;
end;

procedure TImageLabelButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  if (Enabled) and not (FPressed) and (Button = mbLeft) then
  begin
    if FPressImageIndex > -1 then SetState(msDown);
  end;
end;

procedure TImageLabelButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

  function MouseInControl: Boolean;
  var
    x1, x2, y1, y2: INTEGER;
    point: TPoint;
  begin
    point := Mouse.CursorPos;

    x1 := ClientOrigin.X;
    y1 := ClientOrigin.Y;
    x2 := x1 + Width;
    y2 := y1 + Height;
    Result := (point.X >= x1) and (point.X <= x2) and (point.Y >= y1) and (point.Y <= y2);
  end;

begin
  inherited;

  if (Enabled) and not (FPressed) then
  begin
    if (FEnterImageIndex > -1) and (MouseInControl) then SetState(msEnter)
      else SetState(msUp);
  end;
end;

procedure TImageLabelButton.MouseEnter(var Message: TMessage);
begin
  inherited;

  if not (FState = msEnter) then
  begin
    if (Enabled) and not (FPressed) and (FEnterImageIndex > -1) then SetState(msEnter);
  end;
end;

procedure TImageLabelButton.MouseLeave(var Message: TMessage);
begin
  inherited;

  if (Enabled) and (FState = msEnter) and not (FPressed) then SetState(msLeave);
end;

procedure TImageLabelButton.WMEraseBkGnd(var Message: TMessage);
begin
  // Message.result := 1;
  // SendMessage(Canvas.Handle, WM_SETREDRAW, 0, 0);
end;

end.
