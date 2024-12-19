unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DBGrids, DB, SQLDB, Unit2, Unit3;

type

  { TForm1 }

  TForm1 = class(TForm)
  private
    lblNombre, lblApellido, lblDNI, lblDireccion: TLabel;
    edtNombre, edtApellido, edtDNI, edtDireccion: TEdit;
    btnCrear, btnEditar, btnEliminar, btnLimpiar: TButton;
    DBGrid: TDBGrid;
    DataSource: TDataSource;
    SQLQuery: TSQLQuery;
    procedure CrearComponentes;
    procedure ConfigurarDBComponents;
    procedure LimpiarCampos;
    procedure DBGridCellClick(Column: TColumn);
    procedure btnCrearClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnEliminarClick(Sender: TObject);
    procedure btnLimpiarClick(Sender: TObject);
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

  // Iniciar conexión a la base de datos
  IniciarDB('localhost', 'SimpleCRUD', 'usuario', 'contraseña');

  // Crear componentes visuales
  CrearComponentes;

  // Configurar conexión a la base de datos y SQLQuery
  ConfigurarDBComponents;

  // Abrir consulta
  SQLQuery.Open;

  // Limpiar selección inicial
  DBGrid.SelectedIndex := -1;
  LimpiarCampos;
end;

destructor TForm1.Destroy;
begin
  SQLQuery.Close;
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

  btnLimpiar := TButton.Create(Self);
  btnLimpiar.Parent := Self;
  btnLimpiar.Caption := 'Limpiar Campos';
  btnLimpiar.Left := 320;
  btnLimpiar.Top := 150;
  btnLimpiar.Width := 150; // Aquí defines el ancho deseado
  btnLimpiar.OnClick := @btnLimpiarClick;


  // DBGrid para mostrar los datos
  DBGrid := TDBGrid.Create(Self);
  DBGrid.Parent := Self;
  DBGrid.Left := 20;
  DBGrid.Top := 200;
  DBGrid.Width := 500;
  DBGrid.Height := 200;
  DBGrid.OnCellClick := @DBGridCellClick;
end;

procedure TForm1.ConfigurarDBComponents;
begin
  // Configurar SQLQuery
  SQLQuery := TSQLQuery.Create(Self);
  SQLQuery.DataBase := Conn; // Usar conexión global de Unit2
  SQLQuery.Transaction := Transaccion; // Usar transacción global de Unit2
  SQLQuery.SQL.Text := 'SELECT ID, Nombre, Apellido, DNI, Direccion FROM Afiliados';

  // Configurar DataSource
  DataSource := TDataSource.Create(Self);
  DataSource.DataSet := SQLQuery;

  // Enlazar DBGrid al DataSource
  DBGrid.DataSource := DataSource;

  // Configurar columnas del DBGrid
  DBGrid.Columns.Clear;

  with DBGrid.Columns.Add do
  begin
    FieldName := 'ID';
    Title.Caption := 'Número Afiliado';
    Width := 100;
  end;

  with DBGrid.Columns.Add do
  begin
    FieldName := 'Nombre';
    Title.Caption := 'Nombre';
    Width := 150;
  end;

  with DBGrid.Columns.Add do
  begin
    FieldName := 'Apellido';
    Title.Caption := 'Apellido';
    Width := 150;
  end;

  with DBGrid.Columns.Add do
  begin
    FieldName := 'DNI';
    Title.Caption := 'DNI';
    Width := 100;
  end;

  with DBGrid.Columns.Add do
  begin
    FieldName := 'Direccion';
    Title.Caption := 'Dirección';
    Width := 200;
  end;
end;

procedure TForm1.LimpiarCampos;
begin
  edtNombre.Clear;
  edtApellido.Clear;
  edtDNI.Clear;
  edtDireccion.Clear;
end;



procedure TForm1.DBGridCellClick(Column: TColumn);
begin
  if not SQLQuery.IsEmpty then
  begin
    edtNombre.Text := SQLQuery.FieldByName('Nombre').AsString;
    edtApellido.Text := SQLQuery.FieldByName('Apellido').AsString;
    edtDNI.Text := SQLQuery.FieldByName('DNI').AsString;
    edtDireccion.Text := SQLQuery.FieldByName('Direccion').AsString;
  end;
end;

procedure TForm1.btnLimpiarClick(Sender: TObject);
begin
 LimpiarCampos;
end;

procedure TForm1.btnCrearClick(Sender: TObject);
begin
  if (edtNombre.Text = '') or (edtApellido.Text = '') or (edtDNI.Text = '') or (edtDireccion.Text = '') then
  begin
    ShowMessage('Por favor, completa todos los campos.');
    Exit;
  end;

  InsertarAfiliado(edtNombre.Text, edtApellido.Text, edtDNI.Text, edtDireccion.Text);

  // Refrescar los datos
  SQLQuery.Close;
  SQLQuery.Open;

  // Limpiar los campos
  LimpiarCampos;

  ShowMessage('Afiliado creado.');
end;

procedure TForm1.btnEditarClick(Sender: TObject);
begin
  if SQLQuery.IsEmpty then
  begin
    ShowMessage('Selecciona un registro para editar.');
    Exit;
  end;

  ActualizarAfiliado(SQLQuery.FieldByName('ID').AsInteger, edtNombre.Text, edtApellido.Text, edtDNI.Text, edtDireccion.Text);

  // Refrescar los datos
  SQLQuery.Close;
  SQLQuery.Open;

  // Limpiar los campos
  LimpiarCampos;

  ShowMessage('Afiliado actualizado.');
end;

procedure TForm1.btnEliminarClick(Sender: TObject);
begin
  if SQLQuery.IsEmpty then
  begin
    ShowMessage('Selecciona un registro para eliminar.');
    Exit;
  end;

  EliminarAfiliado(SQLQuery.FieldByName('ID').AsInteger);

  // Refrescar los datos
  SQLQuery.Close;
  SQLQuery.Open;

  // Limpiar los campos
  LimpiarCampos;

  ShowMessage('Afiliado eliminado.');
end;

end.
