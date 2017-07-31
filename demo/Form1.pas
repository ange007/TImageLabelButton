unit Form1;

interface

uses
  Windows, SysUtils, Forms, ImgList, StdCtrls, pngimage,
  ExtCtrls, Classes, Controls, Dialogs,
  {}
  ImageLabelButton, Vcl.Imaging.jpeg;

type
  TForm3 = class(TForm)
    il_list: TImageList;
    img1: TImage;
    il_list48: TImageList;
    mmo1: TMemo;
    cb1: TCheckBox;
    cb2: TCheckBox;
    img2: TImage;
    pnl1: TPanel;
    ImageListButton1: TImageLabelButton;
    ImageListButton2: TImageLabelButton;
    imglstbtn1: TImageLabelButton;
    imglstbtn2: TImageLabelButton;
    ImageListButton3: TImageLabelButton;
    ImageListButton4: TImageLabelButton;
    ImageListButton5: TImageLabelButton;
    ImageListButton6: TImageLabelButton;
    ImageListButton7: TImageLabelButton;
    ImageListButton8: TImageLabelButton;
    ImageListButton9: TImageLabelButton;
    procedure ImageListButton1Click(Sender: TObject);
    procedure ImageListButton1DblClick(Sender: TObject);
    procedure ImageListButton1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImageListButton1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cb1Click(Sender: TObject);
    procedure cb2Click(Sender: TObject);
    procedure ImageListButton2Click(Sender: TObject);
    procedure ImageListButton2DblClick(Sender: TObject);
    procedure ImageListButton2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImageListButton2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

procedure TForm3.cb1Click(Sender: TObject);
begin
  ImageListButton1.Enabled := cb1.checked;
  ImageListButton2.Enabled := cb1.checked;
  ImageListButton3.Enabled := cb1.checked;
  ImageListButton4.Enabled := cb1.checked;
  ImageListButton5.Enabled := cb1.checked;
  ImageListButton6.Enabled := cb1.checked;
  ImageListButton7.Enabled := cb1.checked;
  ImageListButton8.Enabled := cb1.checked;
  ImageListButton9.Enabled := cb1.checked;
end;

procedure TForm3.cb2Click(Sender: TObject);
begin
  ImageListButton1.Pressed := cb2.checked;
  ImageListButton2.Pressed := cb2.checked;
  ImageListButton3.Pressed := cb2.checked;
  ImageListButton4.Pressed := cb2.checked;
  ImageListButton5.Pressed := cb2.checked;
  ImageListButton6.Pressed := cb2.checked;
  ImageListButton7.Pressed := cb2.checked;
  ImageListButton8.Pressed := cb2.checked;
  ImageListButton9.Pressed := cb2.checked;
end;

procedure TForm3.ImageListButton1Click(Sender: TObject);
begin
  mmo1.Lines.Add('Кнопка1: Клик');
end;

procedure TForm3.ImageListButton1DblClick(Sender: TObject);
begin
  mmo1.Lines.Add('Кнопка1: Дабл.Клик');
end;

procedure TForm3.ImageListButton1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  mmo1.Lines.Add('Кнопка1: Вниз');
end;

procedure TForm3.ImageListButton1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  mmo1.Lines.Add('Кнопка1: Вверх');
end;

procedure TForm3.ImageListButton2Click(Sender: TObject);
begin
  mmo1.Lines.Add('Кнопка2: Клик');
end;

procedure TForm3.ImageListButton2DblClick(Sender: TObject);
begin
  mmo1.Lines.Add('Кнопка2: Дабл.Клик');
end;

procedure TForm3.ImageListButton2MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  mmo1.Lines.Add('Кнопка2: Вниз');
end;

procedure TForm3.ImageListButton2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  mmo1.Lines.Add('Кнопка2: Вверх');
end;

end.
