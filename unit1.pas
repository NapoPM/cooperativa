unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids, CRUDUnit, DBUnit, SQLDB;

type

  { TForm1 }

  TForm1 = class(TForm)
  private
    lblName, lblLastName, lblDNI, lblAddress: TLabel;
    edtName, edtLastName, edtDNI, edtAddress: TEdit;
    btnCreate, btnEdit, btnDelete: TButton;
    StringGrid: TStringGrid;
    procedure CreateComponents;      // Crear componentes dinámicamente
    procedure RefreshGrid;           // Refrescar datos en el TStringGrid
    procedure btnCreateClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

constructor TForm1.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);

  // Crear componentes visuales
  CreateComponents;

  // Conectar a la base de datos
  InitializeDatabase('localhost', 'SimpleCRUD', '', '');

  // Cargar datos en el TStringGrid
  RefreshGrid;
end;

destructor TForm1.Destroy;
begin
  // Finalizar la conexión a la base de datos
  FinalizeDatabase;
  inherited Destroy;
end;

procedure TForm1.CreateComponents;
begin
  // Etiquetas y campos de texto
  lblName := TLabel.Create(Self);
  lblName.Parent := Self;
  lblName.Caption := 'Nombre:';
  lblName.Left := 20;
  lblName.Top := 20;

  edtName := TEdit.Create(Self);
  edtName.Parent := Self;
  edtName.Left := 100;
  edtName.Top := 20;
  edtName.Width := 200;

  lblLastName := TLabel.Create(Self);
  lblLastName.Parent := Self;
  lblLastName.Caption := 'Apellido:';
  lblLastName.Left := 20;
  lblLastName.Top := 50;

  edtLastName := TEdit.Create(Self);
  edtLastName.Parent := Self;
  edtLastName.Left := 100;
  edtLastName.Top := 50;
  edtLastName.Width := 200;

  lblDNI := TLabel.Create(Self);
  lblDNI.Parent := Self;
  lblDNI.Caption := 'DNI:';
  lblDNI.Left := 20;
  lblDNI.Top := 80;

  edtDNI := TEdit.Create(Self);
  edtDNI.Parent := Self;
  edtDNI.Left := 100;
  edtDNI.Top := 80;
  edtDNI.Width := 200;

  lblAddress := TLabel.Create(Self);
  lblAddress.Parent := Self;
  lblAddress.Caption := 'Dirección:';
  lblAddress.Left := 20;
  lblAddress.Top := 110;

  edtAddress := TEdit.Create(Self);
  edtAddress.Parent := Self;
  edtAddress.Left := 100;
  edtAddress.Top := 110;
  edtAddress.Width := 200;

  // Botones
  btnCreate := TButton.Create(Self);
  btnCreate.Parent := Self;
  btnCreate.Caption := 'Crear';
  btnCreate.Left := 20;
  btnCreate.Top := 150;
  btnCreate.OnClick := @btnCreateClick;

  btnEdit := TButton.Create(Self);
  btnEdit.Parent := Self;
  btnEdit.Caption := 'Editar';
  btnEdit.Left := 120;
  btnEdit.Top := 150;
  btnEdit.OnClick := @btnEditClick;

  btnDelete := TButton.Create(Self);
  btnDelete.Parent := Self;
  btnDelete.Caption := 'Eliminar';
  btnDelete.Left := 220;
  btnDelete.Top := 150;
  btnDelete.OnClick := @btnDeleteClick;

  // StringGrid para mostrar los datos
  StringGrid := TStringGrid.Create(Self);
  StringGrid.Parent := Self;
  StringGrid.Left := 20;
  StringGrid.Top := 200;
  StringGrid.Width := 500;
  StringGrid.Height := 200;

  // Configuración del StringGrid
  StringGrid.ColCount := 5;
  StringGrid.RowCount := 1; // Encabezado
  StringGrid.FixedRows := 1;

  StringGrid.Cells[0, 0] := 'Número Afiliado';
  StringGrid.Cells[1, 0] := 'Nombre';
  StringGrid.Cells[2, 0] := 'Apellido';
  StringGrid.Cells[3, 0] := 'DNI';
  StringGrid.Cells[4, 0] := 'Dirección';
end;

procedure TForm1.RefreshGrid;
var
  SQLQuery: TSQLQuery;
  RowIndex: Integer;
begin
  StringGrid.RowCount := 1; // Limpiar el TStringGrid dejando solo el encabezado

  SQLQuery := TSQLQuery.Create(nil);
  try
    SQLQuery.DataBase := ODBCConnection; // Usar conexión global de DBUnit
    SQLQuery.SQL.Text := 'SELECT ID, Nombre, Apellido, DNI, Direccion FROM Afiliados';
    SQLQuery.Open;

    RowIndex := 1;
    while not SQLQuery.EOF do
    begin
      StringGrid.RowCount := StringGrid.RowCount + 1; // Agregar una nueva fila

      // Asignar valores a cada celda en la fila
      StringGrid.Cells[0, RowIndex] := SQLQuery.FieldByName('ID').AsString;
      StringGrid.Cells[1, RowIndex] := SQLQuery.FieldByName('Nombre').AsString;
      StringGrid.Cells[2, RowIndex] := SQLQuery.FieldByName('Apellido').AsString;
      StringGrid.Cells[3, RowIndex] := SQLQuery.FieldByName('DNI').AsString;
      StringGrid.Cells[4, RowIndex] := SQLQuery.FieldByName('Direccion').AsString;

      Inc(RowIndex);
      SQLQuery.Next;
    end;
  finally
    SQLQuery.Free;
  end;
end;

procedure TForm1.btnCreateClick(Sender: TObject);
begin
  if (edtName.Text = '') or (edtLastName.Text = '') or (edtDNI.Text = '') or (edtAddress.Text = '') then
  begin
    ShowMessage('Por favor, completa todos los campos.');
    Exit;
  end;

  InsertAffiliate(edtName.Text, edtLastName.Text, edtDNI.Text, edtAddress.Text);
  RefreshGrid;

  // Limpiar los campos
  edtName.Clear;
  edtLastName.Clear;
  edtDNI.Clear;
  edtAddress.Clear;
  ShowMessage('Afiliado creado.');
end;

procedure TForm1.btnEditClick(Sender: TObject);
var
  Id: Integer;
begin
  if StringGrid.Row < 1 then
  begin
    ShowMessage('Selecciona un registro para editar.');
    Exit;
  end;

  Id := StrToInt(StringGrid.Cells[0, StringGrid.Row]);
  UpdateAffiliate(Id, edtName.Text, edtLastName.Text, edtDNI.Text, edtAddress.Text);
  RefreshGrid;
  ShowMessage('Afiliado actualizado.');
end;

procedure TForm1.btnDeleteClick(Sender: TObject);
var
  Id: Integer;
begin
  if StringGrid.Row < 1 then
  begin
    ShowMessage('Selecciona un registro para eliminar.');
    Exit;
  end;

  Id := StrToInt(StringGrid.Cells[0, StringGrid.Row]);
  DeleteAffiliate(Id);
  RefreshGrid;
  ShowMessage('Afiliado eliminado.');
end;

end.
