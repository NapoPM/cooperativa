unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids, CRUDUnit, DBUnit, SQLDB;

type

  { TForm1 }

  TForm1 = class(TForm)
  private
    lblNombre, lblApellido, lblDNI, lblDireccion: TLabel;
    edtNombre, edtApellido, edtDNI, edtDireccion: TEdit;
    btnCrear, btnEditar, btnEliminar: TButton;
    StringGrid: TStringGrid;
    procedure CrearComponentes;
    procedure RefrescarGrid;
    procedure btnCrearClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnEliminarClick(Sender: TObject);
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
  CrearComponentes;

  // Conectar a la base de datos
  IniciarDB('localhost', 'SimpleCRUD', '', '');

  // Cargar datos en el TStringGrid
  RefrescarGrid;
end;

destructor TForm1.Destroy;
begin
  // Finalizar la conexión a la base de datos
  CerrarDB;
  inherited Destroy;
end;

procedure TForm1.CrearComponentes;
begin
  // Etiquetas y campos de texto
  lblNombre := TLabel.Create(Self);
  lblNombre.Parent := Self;
  lblNombre.Caption := 'Nombre:';
  lblNombre.Left := 20;
  lblNombre.Top := 20;

  edtNombre := TEdit.Create(Self);
  edtNombre.Parent := Self;
  edtNombre.Left := 100;
  edtNombre.Top := 20;
  edtNombre.Width := 200;

  lblApellido := TLabel.Create(Self);
  lblApellido.Parent := Self;
  lblApellido.Caption := 'Apellido:';
  lblApellido.Left := 20;
  lblApellido.Top := 50;

  edtApellido := TEdit.Create(Self);
  edtApellido.Parent := Self;
  edtApellido.Left := 100;
  edtApellido.Top := 50;
  edtApellido.Width := 200;

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

  lblDireccion := TLabel.Create(Self);
  lblDireccion.Parent := Self;
  lblDireccion.Caption := 'Dirección:';
  lblDireccion.Left := 20;
  lblDireccion.Top := 110;

  edtDireccion := TEdit.Create(Self);
  edtDireccion.Parent := Self;
  edtDireccion.Left := 100;
  edtDireccion.Top := 110;
  edtDireccion.Width := 200;

  // Botones
  btnCrear := TButton.Create(Self);
  btnCrear.Parent := Self;
  btnCrear.Caption := 'Crear';
  btnCrear.Left := 20;
  btnCrear.Top := 150;
  btnCrear.OnClick := @btnCrearClick;

  btnEditar := TButton.Create(Self);
  btnEditar.Parent := Self;
  btnEditar.Caption := 'Editar';
  btnEditar.Left := 120;
  btnEditar.Top := 150;
  btnEditar.OnClick := @btnEditarClick;

  btnEliminar := TButton.Create(Self);
  btnEliminar.Parent := Self;
  btnEliminar.Caption := 'Eliminar';
  btnEliminar.Left := 220;
  btnEliminar.Top := 150;
  btnEliminar.OnClick := @btnEliminarClick;

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

procedure TForm1.RefrescarGrid;
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

procedure TForm1.btnCrearClick(Sender: TObject);
begin
  if (edtNombre.Text = '') or (edtApellido.Text = '') or (edtDNI.Text = '') or (edtDireccion.Text = '') then
  begin
    ShowMessage('Por favor, completa todos los campos.');
    Exit;
  end;

  InsertAffiliate(edtNombre.Text, edtApellido.Text, edtDNI.Text, edtDireccion.Text);
  RefrescarGrid;

  // Limpiar los campos
  edtNombre.Clear;
  edtApellido.Clear;
  edtDNI.Clear;
  edtDireccion.Clear;
  ShowMessage('Afiliado creado.');
end;

procedure TForm1.btnEditarClick(Sender: TObject);
var
  Id: Integer;
begin
  if StringGrid.Row < 1 then
  begin
    ShowMessage('Selecciona un registro para editar.');
    Exit;
  end;

  Id := StrToInt(StringGrid.Cells[0, StringGrid.Row]);
  UpdateAffiliate(Id, edtNombre.Text, edtApellido.Text, edtDNI.Text, edtDireccion.Text);
  RefrescarGrid;
  ShowMessage('Afiliado actualizado.');
end;

procedure TForm1.btnEliminarClick(Sender: TObject);
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
  RefrescarGrid;
  ShowMessage('Afiliado eliminado.');
end;

end.
