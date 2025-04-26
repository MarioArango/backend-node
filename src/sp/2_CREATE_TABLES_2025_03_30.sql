-- Creación de la tabla empresa (Versión final sin índices)
DROP TABLE IF EXISTS dbo.TMEmpresa;
CREATE TABLE TMEmpresa (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    RazonSocial NVARCHAR(150) NOT NULL,
    NombreComercial NVARCHAR(100) NOT NULL,
    RUC NVARCHAR(11) NOT NULL,
    Direccion NVARCHAR(200),
    Ubigeo VARCHAR(10),
    LogoUrl NVARCHAR(255),
    TelefonoPrincipal NVARCHAR(20),
    TelefonoSecundario NVARCHAR(20),
    CorreoElectronico NVARCHAR(100),
    SitioWeb NVARCHAR(255),
    RepresentanteLegal NVARCHAR(150),
    DniRepresentante NVARCHAR(8),    
    MaxIntentosSesion INT DEFAULT 1,
    IGV DECIMAL(14,6) DEFAULT 18,
    Activo BIT NOT NULL DEFAULT 1,
);

GO

--Generales
-- Catálogo de ubigeo
-- Catálogo de bancos
-- Catálogo de monedas
-- Catálogo de comprobantes
DROP TABLE IF EXISTS dbo.TMGeneral;
CREATE TABLE TMGeneral (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Codigo VARCHAR(20) UNIQUE NOT NULL,
    Descripcion VARCHAR(50) NOT NULL,
    TipoEntidad VARCHAR(30) NOT NULL,
    ValorOpcional VARCHAR(20),
    Activo BIT NOT NULL DEFAULT(1),
    OrdenVisualizacion INT,
    FechaCreacion DATETIMEOFFSET NOT NULL,
    UsuarioCreacion VARCHAR(20) NOT NULL,
    FechaModificacion DATETIMEOFFSET NULL,
    UsuarioModificacion VARCHAR(20) NULL,
)

GO

DROP TABLE IF EXISTS dbo.TMBancos;
CREATE TABLE TMBancos (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    IdCatalogoBanco NVARCHAR(4) NOT NULL, -- Código oficial según SUNAT (Ej: '011', '002')
    Nombre NVARCHAR(100) NOT NULL,    -- Ej: 'Banco de Crédito del Perú'
    Sigla NVARCHAR(10),               -- Ej: 'BCP'
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    UsuarioCreacion VARCHAR(20) NOT NULL,
    FechaModificacion DATETIMEOFFSET NULL,
    UsuarioModificacion VARCHAR(20) NULL,
    CONSTRAINT fk_cuenta_bancaria_tmgeneral FOREIGN KEY (IdCatalogoBanco) REFERENCES TMGeneral(Id),
);

GO

-- Creación de tabla para cuentas bancarias
DROP TABLE IF EXISTS dbo.TMCuentasBancarias;
CREATE TABLE TMCuentasBancarias (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    IdEmpresa INT NOT NULL,
    IdBanco INT,
    TipoCuenta NVARCHAR(50) NOT NULL, -- Corriente, Ahorros
    NumeroCuenta NVARCHAR(50) NOT NULL,
    CCI NVARCHAR(20) NOT NULL, -- Código de Cuenta Interbancario (20 dígitos en Perú)
    IdMoneda NVARCHAR(20) NOT NULL, -- Soles, Dólares, etc.
    CuentaPrincipal BIT DEFAULT 0,
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIMEOFFSET NOT NULL,
    UsuarioCreacion VARCHAR(20) NOT NULL,
    FechaModificacion DATETIMEOFFSET NULL,
    UsuarioModificacion VARCHAR(20) NULL,
    CONSTRAINT fk_cuenta_bancaria_empresa FOREIGN KEY (IdEmpresa) REFERENCES TMEmpresa(Id),
    CONSTRAINT fk_cuenta_bancaria_bancos FOREIGN KEY (IdEmpresa) REFERENCES TMBancos(Id),
    CONSTRAINT fk_cuenta_bancaria_moneda FOREIGN KEY (IdMoneda) REFERENCES TMGeneral(Id)
);

GO

-- Crear la tabla Almacenes
DROP TABLE IF EXISTS dbo.TMAlmacenes;
CREATE TABLE dbo.TMAlmacenes (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Codigo VARCHAR(20) UNIQUE NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Direccion VARCHAR(200),
    CodigoPostal VARCHAR(10),
    TelefonoPrincipal VARCHAR(20),
    TelefonoSecundario VARCHAR(20),
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIMEOFFSET NOT NULL,
    UsuarioCreacion VARCHAR(20) NOT NULL,
    FechaModificacion DATETIMEOFFSET NULL,
    UsuarioModificacion VARCHAR(20) NULL,
);

GO

-- Tabla de Categorías --Motor, Frenos, Carroceria, Suspension
DROP TABLE IF EXISTS dbo.CategoriasProductos;
CREATE TABLE CategoriasProductos (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Descripcion VARCHAR(255),
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIMEOFFSET NOT NULL,
    UsuarioCreacion VARCHAR(20) NOT NULL,
    FechaModificacion DATETIMEOFFSET NULL,
    UsuarioModificacion VARCHAR(20) NULL,
);

GO

-- Crear la tabla Productos
DROP TABLE IF EXISTS dbo.Productos;
CREATE TABLE dbo.Productos (
    Id INT PRIMARY KEY IDENTITY(1,1),
    IdTipo INT, --(tipo_producto IN ('Producto', 'Servicio', 'Kit', 'Paquete')),
    IdSubtipo INT, --CHECK (subtipo_producto IN ('Repuesto', 'Consumible', 'Lubricante', 'Herramienta', 'Accesorio', 'Mano de obra', 'Diagnóstico', 'Otro')),
    IdMarca INT,
    IdCategoria INT NOT NULL,


    IdUnidadAlmacen INT, --unidad de almacen, solo es como se almacena, solo sirve para mostrar stock del almacen cuando se va a inventarios
    FactorConversion DECIMAL(10, 4), --factor conversion
    IdUnidadBase INT, --unidad de medida base, todos los calculos son en base a el
    Stock DECIMAL(18,2) DEFAULT 0, -- cantidad de productos que hay, si el producto es con lote es la suma de los lotes. Se opera con la uniadad base
    StockMinima DECIMAL(18,2) DEFAULT 0,
    --el stock se muestra segun el usuario, si es un cliente en la unidad base, si es un personal de inventario en ambos, unidad almacen y base, como todo se trabaja en uniadad base solo faltaria hacer la conversion a unidad almacen para mostrar el stock segun unidad almacen
    
    
    EsKitArmado BIT NOT NULL DEFAULT 0, --solo cuando es kit y es armado es decir consume stock de sus componentes, 1: pre formado, ensamblado, consume stock, se ingresa su stock - 0: bajo demanda, no tiene stock, cada componente maneja su stock y al usarlo se verifica que tenga
    --si es armado el sistema debera validar si hay suficiente stock de los componentes, descontara stock por componente, ingresar el stock que formara y aumentara el stock del kit que ya es un producto

    Codigo VARCHAR(30) NOT NULL UNIQUE, --SKU, por tipo laptop HP500
    CodigoBarras VARCHAR(50) NULL,
    Nombre VARCHAR(150) NOT NULL,
    Descripcion VARCHAR(500) NULL,
  
    ImagenUrl VARCHAR(255) NULL,

    CostoPromedioSoles DECIMAL(18,2) DEFAULT 0,
    CostoPromedioDolares DECIMAL(18,2) DEFAULT 0,

    EsVendible BIT DEFAULT 1, --productos internos de la empresa o regalos
    RequiereLote BIT DEFAULT 0,
    Activo BIT NOT NULL DEFAULT 1,

    --DETRACCIONES

    FechaCreacion DATETIMEOFFSET NOT NULL,
    UsuarioCreacion VARCHAR(20) NOT NULL,
    FechaModificacion DATETIMEOFFSET NULL,
    UsuarioModificacion VARCHAR(20) NULL,

    CONSTRAINT FK_TMProductos_TMGeneral_Tipo FOREIGN KEY (IdTipo) REFERENCES dbo.TMGeneral (Id),
    CONSTRAINT FK_TMProductos_TMGeneral_SubTipo FOREIGN KEY (IdSubTipo) REFERENCES dbo.TMGeneral (Id),
    CONSTRAINT FK_TMProductos_TMGeneral_Marca FOREIGN KEY (IdMarca) REFERENCES dbo.TMGeneral (Id),
    CONSTRAINT FK_TMProductos_TMGeneral_UnidadMedida FOREIGN KEY (IdUnidadAlmacen) REFERENCES dbo.TMGeneral (Id),
    CONSTRAINT FK_TMProductos_TMGeneral_UnidadMedidaFactorConversion FOREIGN KEY (IdUnidadBase) REFERENCES dbo.TMGeneral (Id),
    CONSTRAINT FK_TMProductos_TMGeneral_Categoria FOREIGN KEY (IdCategoria) REFERENCES dbo.CategoriasProductos (Id),
);

GO

DROP TABLE IF EXISTS dbo.Lotes;
CREATE TABLE dbo.Lotes (
    Id INT PRIMARY KEY IDENTITY(1,1),
    IdProducto INT NOT NULL, -- Relacionado con la tabla de productos
    Lote VARCHAR(50) NOT NULL, -- Número de lote
    FechaIngreso DATE NOT NULL, -- Fecha de ingreso del lote
    FechaCaducidad DATE, -- Fecha de caducidad del lote (si aplica)
    Stock DECIMAL(18,2) NOT NULL DEFAULT 0, -- Stock disponible en este lote
    Costo DECIMAL(18,2) NOT NULL, -- Costo de este lote

    Activo BIT NOT NULL DEFAULT 1, -- Si el lote está activo
    FechaCreacion DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    UsuarioCreacion VARCHAR(20) NOT NULL,
    FechaModificacion DATETIMEOFFSET NULL,
    UsuarioModificacion VARCHAR(20) NULL,


    -- Relación con el producto
    CONSTRAINT FK_Lotes_Productos FOREIGN KEY (IdProducto) REFERENCES dbo.Productos (Id)
);

GO

DROP TABLE IF EXISTS dbo.KitsProductos; --cuando creo kits debo mostrar los lotes si lo tuviera
CREATE TABLE dbo.KitsProductos (
    Id INT PRIMARY KEY IDENTITY(1,1),
    IdProductoKit INT NOT NULL, -- El producto final (el KIT)
    IdProductoComponente INT NOT NULL,
    Cantidad DECIMAL(18,2) NOT NULL, --Cuantos productos especificos contiene

    FechaCreacion DATETIMEOFFSET NOT NULL,
    UsuarioCreacion VARCHAR(20) NOT NULL,
    FechaModificacion DATETIMEOFFSET NULL,
    UsuarioModificacion VARCHAR(20) NULL,

    CONSTRAINT FK_KitsProducto_ProductoKit FOREIGN KEY (IdProductoKit) REFERENCES dbo.Productos(Id),
    CONSTRAINT FK_KitsProducto_Componente FOREIGN KEY (IdProductoComponente) REFERENCES dbo.Productos(Id)
);


GO

DROP TABLE IF EXISTS dbo.PaquetesProductos;
CREATE TABLE dbo.PaquetesProductos (
    Id INT PRIMARY KEY IDENTITY(1,1),
    IdProductoPaquete INT NOT NULL, -- El producto agrupador (el PAQUETE)
    IdProductoComponente INT NULL,
    Cantidad DECIMAL(18,2) NOT NULL, --Cuantos productos especificos contiene

    FechaCreacion DATETIMEOFFSET NOT NULL,
    UsuarioCreacion VARCHAR(20) NOT NULL,
    FechaModificacion DATETIMEOFFSET NULL,
    UsuarioModificacion VARCHAR(20) NULL,
    CONSTRAINT FK_PaquetesProducto_Paquete FOREIGN KEY (IdProductoPaquete) REFERENCES dbo.Productos(Id),
    CONSTRAINT FK_PaquetesProducto_Componente FOREIGN KEY (IdProductoComponente) REFERENCES dbo.Productos(Id)
    -- Podrías agregar FK a Servicios si los manejas en otra tabla
);


GO

-- Lista de precios
CREATE TABLE dbo.TMListaPrecios (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Codigo VARCHAR(20) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(200),
    Activa BIT DEFAULT 1,
    FechaCreacion DATETIMEOFFSET NOT NULL,
    UsuarioCreacion VARCHAR(20) NOT NULL,
    FechaModificacion DATETIMEOFFSET NULL,
    UsuarioModificacion VARCHAR(20) NULL,
);

CREATE TABLE dbo.ListaPreciosProductos (
    Id INT PRIMARY KEY IDENTITY(1,1),
    IdListaPrecio INT NOT NULL,
    IdProducto INT NOT NULL,
    IdMoneda INT NOT NULL,
    PrecioBase DECIMAL(14,6) NOT NULL,
    PrecioVenta DECIMAL(14,6) NOT NULL,
    Contribucion DECIMAL(14,6) NOT NULL,
    PrecioAnterior DECIMAL(18,2),
    PorcentajeDescuento DECIMAL(5,2) DEFAULT 0,
    Activo BIT DEFAULT 1,
    FechaCreacion DATETIMEOFFSET NOT NULL,
    UsuarioCreacion VARCHAR(20) NOT NULL,
    FechaModificacion DATETIMEOFFSET NULL,
    UsuarioModificacion VARCHAR(20) NULL,
    CONSTRAINT FK_TMListaPreciosProductos_TMListaPrecios FOREIGN KEY (IdListaPrecio) REFERENCES dbo.TMListaPrecios(Id),
    CONSTRAINT FK_TMListaPreciosProductos_TMProducto FOREIGN KEY (IdProducto) REFERENCES TMProducto(Id),
    CONSTRAINT FK_TMListaPreciosProductos_TMGeneral FOREIGN KEY (IdMoneda) REFERENCES TMGeneral(Id),

);

GO

DROP TABLE IF EXISTS dbo.TMClientes;
CREATE TABLE dbo.TMClientes (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(50) NOT NULL,
    Documento VARCHAR(30) NOT NULL,
    IdTipoDocumento INT,
    TelefonoPrincipal VARCHAR(30),
    TelefonoSecundario VARCHAR(30),
    Correo VARCHAR(100),
    Direccion VARCHAR(50),
    Ubigeo VARCHAR(10),
    Edad INT,
    Genero CHAR(1) DEFAULT 'O' CHECK (Genero IN ('M', 'F', 'O')),

    Activo BIT NOT NULL DEFAULT(1),
    FechaCreacion DATETIMEOFFSET NOT NULL,
    UsuarioCreacion VARCHAR(20) NOT NULL,
    FechaModificacion DATETIMEOFFSET NULL,
    UsuarioModificacion VARCHAR(20) NULL,

    CONSTRAINT FK_TMClientes_TMGeneralTipoDocumento FOREIGN KEY (IdTipoDocumento) REFERENCES TMGeneral(Id),
);

GO

DROP TABLE IF EXISTS dbo.TMClienteVehiculos;
CREATE TABLE dbo.TMClienteVehiculos (
    Id INT PRIMARY KEY IDENTITY(1,1),
    IdCliente INT NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    Placa VARCHAR(20) NOT NULL,
    IdModelo INT,
    IdMarca INT,
    FechaRevisionLegal DATETIME NULL,
    SOAT VARCHAR(30) NULL,
    UltimaFechaRevisionInterna DATETIME NULL,

    Activo BIT NOT NULL DEFAULT(1),
    FechaCreacion DATETIMEOFFSET NOT NULL,
    UsuarioCreacion VARCHAR(20) NOT NULL,
    FechaModificacion DATETIMEOFFSET NULL,
    UsuarioModificacion VARCHAR(20) NULL,

    CONSTRAINT FK_TMClienteVehiculos_TMClientes FOREIGN KEY (IdCliente) REFERENCES TMClientes(Id),
    CONSTRAINT FK_TMClienteVehiculos_TMGeneralModelo FOREIGN KEY (IdModelo) REFERENCES TMGeneral(Id),
    CONSTRAINT FK_TMClienteVehiculos_TMGeneralMarca FOREIGN KEY (IdMarca) REFERENCES TMGeneral(Id),
);

DROP TABLE IF EXISTS dbo.TMClienteContactos;
CREATE TABLE dbo.TMClienteContactos (
    Id INT PRIMARY KEY IDENTITY(1,1),
    IdCliente INT NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    Documento VARCHAR(30) NOT NULL,
    IdTipoDocumento INT,
    Telefono VARCHAR(30),
    Observacion VARCHAR(100),    

    Activo BIT NOT NULL DEFAULT(1),
    FechaCreacion DATETIMEOFFSET NOT NULL,
    UsuarioCreacion VARCHAR(20) NOT NULL,
    FechaModificacion DATETIMEOFFSET NULL,
    UsuarioModificacion VARCHAR(20) NULL,

    CONSTRAINT FK_TMClienteContactos_TMClientes FOREIGN KEY (IdCliente) REFERENCES TMClientes(Id),
);

GO

--Sucursales
DROP TABLE IF EXISTS dbo.TMSucursales;
CREATE TABLE TMSucursales (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    IdEmpresa INT NOT NULL,
    IdAlmacenDefecto INT NULL,
    IdListaPrecioDefecto INT NULL,
    IdClienteDefecto INT NULL,
    RazonSocial NVARCHAR(150),
    NombreComercial NVARCHAR(100),
    RUC NVARCHAR(11),
    Codigo VARCHAR(20) NOT NULL UNIQUE,
    Nombre VARCHAR(100) NOT NULL,
    Direccion VARCHAR(200) NOT NULL,
    CodigoPostal VARCHAR(10),
    TelefonoPrincipal NVARCHAR(20),
    TelefonoSecundario NVARCHAR(20),
    CorreoElectronico VARCHAR(100),
    CodigoEstablecimiento VARCHAR(30),

    Activo BIT NOT NULL DEFAULT(1),
    FechaCreacion DATETIMEOFFSET NOT NULL,
    UsuarioCreacion VARCHAR(20) NOT NULL,
    FechaModificacion DATETIMEOFFSET NULL,
    UsuarioModificacion VARCHAR(20) NULL,
    
    CONSTRAINT FK_TMSucursal_TMEmpresa FOREIGN KEY (IdEmpresa) REFERENCES TMEmpresa(Id),
    CONSTRAINT FK_TMSucursal_TMAlmacenes FOREIGN KEY (IdAlmacenDefecto) REFERENCES TMAlmacenes(Id),
    CONSTRAINT FK_TMSucursal_TMListaPrecios FOREIGN KEY (IdListaPrecioDefecto) REFERENCES TMListaPrecios(Id),
    CONSTRAINT FK_TMSucursal_TMClientes FOREIGN KEY (IdClienteDefecto) REFERENCES TMClientes(Id),
    CONSTRAINT FK_TMSucursal_TMGeneral FOREIGN KEY (IdFormatoImpresionTicket) REFERENCES TMGeneral(Id),
)

GO

--Permisos
DROP TABLE IF EXISTS dbo.TMPermisos;
CREATE TABLE TMPermisos (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Permisos VARCHAR(MAX)    
)

GO

--Roles
DROP TABLE IF EXISTS dbo.TMRol;
CREATE TABLE TMRol (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(30),
    Permisos VARCHAR(MAX),
    Activo BIT NOT NULL DEFAULT(1),
    FechaCreacion DATETIMEOFFSET NOT NULL,
    UsuarioCreacion VARCHAR(20) NOT NULL,
    FechaModificacion DATETIMEOFFSET NULL,
    UsuarioModificacion VARCHAR(20) NULL,
)

--Usuarios
DROP TABLE IF EXISTS dbo.TMUsuarios;
CREATE TABLE TMUsuarios (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    IdRol INT,
    Dni VARCHAR(8),
    Nombre VARCHAR(30),
    ApellidoPaterno VARCHAR(30),
    ApellidoMaterno VARCHAR(30) NULL,
    CorreoElectronico VARCHAR(100),
    TelefonoPrincipal NVARCHAR(20),
    Usuario VARCHAR(20),
    Contrasena VARCHAR(20),
    SesionesPermitidas INT DEFAULT 1,

    Activo BIT NOT NULL DEFAULT(1),
    FechaCreacion DATETIMEOFFSET NOT NULL,
    UsuarioCreacion VARCHAR(20) NOT NULL,
    FechaModificacion DATETIMEOFFSET NULL,
    UsuarioModificacion VARCHAR(20) NULL,
    CONSTRAINT FK_TMRol FOREIGN KEY (IdRol) REFERENCES TMRol(Id)
)

GO

--Usuario sesion
DROP TABLE IF EXISTS dbo.TMUsuarioSesion;
CREATE TABLE TMUsuarioSesion (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    IdUsuario INT,
    Token NVARCHAR(100),
    Dispositivo VARCHAR(100),
    IntentosSesion INT,
    Ip VARCHAR(30),
    Activo BIT NOT NULL DEFAULT(1),
    FechaInicio DATETIMEOFFSET NOT NULL,
    FechaCierre DATETIMEOFFSET NULL,
    CONSTRAINT FK_TMUsuarios FOREIGN KEY (IdUsuario) REFERENCES TMUsuarios(Id)
)

GO

CREATE TABLE TMLogs (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Modulo VARCHAR(100) NOT NULL,
    Accion VARCHAR(100) NOT NULL,
    Descripcion TEXT NULL,
    IpOrigen VARCHAR(45) NULL,
    UserAgent TEXT NULL,
    Estado VARCHAR(20) NOT NULL DEFAULT 'EXITO',
    ErrorStack TEXT NULL,
    EntidadAfectada VARCHAR(100) NULL,
    EntidadId INT NULL
);


-- Ver la configuración actual de tiempo del servidor
-- SELECT SYSDATETIMEOFFSET();
-- SELECT SWITCHOFFSET(SYSDATETIMEOFFSET(), 0);
