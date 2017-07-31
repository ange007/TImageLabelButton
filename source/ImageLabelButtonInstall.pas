unit ImageLabelButtonInstall;

interface

uses
  System.SysUtils, System.Classes, ImgList, Graphics, System.Types,
  DesignIntf, DesignEditors, VCLEditors, Messages, Controls;

type
  TImageIndexPropertyEditor = class(TIntegerProperty, ICustomPropertyListDrawing)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
    function GetImageListAt(Index: Integer): TCustomImageList; virtual;

    procedure ListMeasureHeight(const Value: string; ACanvas: TCanvas; var AHeight: Integer);
    procedure ListMeasureWidth(const Value: string; ACanvas: TCanvas; var AWidth: Integer);
    procedure ListDrawValue(const Value: string; ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean);
  end;

procedure Register;

implementation

uses
  ImageLabelButton;

procedure Register;
begin
  RegisterComponents('Buttons', [TImageLabelButton]);
  RegisterPropertyEditor(TypeInfo(TImageIndex), TImageLabelButton, '', TImageIndexPropertyEditor);
end;

{--- TImageIndexPropertyEditor ---}

function TImageIndexPropertyEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paMultiSelect, paValueList, paRevertable];
end;

function TImageIndexPropertyEditor.GetImageListAt(Index: Integer): TCustomImageList;
var
  C: TPersistent;
  Item: TImageLabelButton;
begin
  Result := nil;
  C := GetComponent(Index);
  if C is TImageLabelButton then Result := TImageLabelButton(C).Images;
end;

procedure TImageIndexPropertyEditor.GetValues(Proc: TGetStrProc);
var
  ImgList: TCustomImageList;
  I: Integer;
begin
  ImgList := GetImageListAt(0);
  if Assigned(ImgList) then
    for I := 0 to ImgList.Count-1 do Proc(IntToStr(I));
end;

procedure TImageIndexPropertyEditor.ListMeasureHeight(const Value: string;
          ACanvas: TCanvas; var AHeight: Integer);
var
  ImgList: TCustomImageList;
begin
  ImgList := GetImageListAt(0);
  AHeight := ACanvas.TextHeight(Value) + 2;
  if Assigned(ImgList) and (ImgList.Height + 4 > AHeight) then AHeight := ImgList.Height + 4;
end;

procedure TImageIndexPropertyEditor.ListMeasureWidth(const Value: string;
              ACanvas: TCanvas; var AWidth: Integer);
var
  ImgList: TCustomImageList;
begin
  ImgList := GetImageListAt(0);
  AWidth := ACanvas.TextWidth(Value) + 4;
  if Assigned(ImgList) then Inc(AWidth, ImgList.Width);
end;

procedure TImageIndexPropertyEditor.ListDrawValue(const Value: string;
              ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean);
var
  ImgList: TCustomImageList;
  X: Integer;
begin
  ImgList := GetImageListAt(0);
  ACanvas.FillRect(ARect);
  X := ARect.Left + 2;
  if Assigned(ImgList) then
  begin
    ImgList.Draw(ACanvas, X, ARect.Top + 2, StrToInt(Value));
    Inc(X, ImgList.Width);
  end;
  ACanvas.TextOut(X + 3, ARect.Top + 1, Value);
end;

end.
