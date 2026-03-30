
-- ==================================
-- ℌ𝔢𝔠𝔥𝔬 𝔭𝔬𝔯: Á𝔫𝔤𝔢𝔩 𝔉𝔢𝔩𝔦𝔭𝔢 ℜ𝔬𝔡𝔯í𝔤𝔲𝔢𝔷 𝔙𝔞𝔯𝔤𝔞𝔰
-- ==================================

-- =========================
--   Creé la base de datos
-- =========================

    USE master;
    GO

-- IF EXIST para evitar errores de duplicado
    IF EXISTS (SELECT name FROM sys.databases WHERE name = 'BibliotecaCaso2')
    BEGIN
        ALTER DATABASE BibliotecaCaso2 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE BibliotecaCaso2;
    END
    GO

    CREATE DATABASE BibliotecaCaso2;
    GO 

    USE BibliotecaCaso2;
    GO

-- =========================
--      Creé las tablas
-- =========================

    CREATE TABLE Cliente (
        cliente_id INT PRIMARY KEY IDENTITY (1,1),
        nombre VARCHAR (100),
        apellido VARCHAR (100),
        email VARCHAR (150)	
    );

    CREATE TABLE Libro (
        libro_id INT PRIMARY KEY IDENTITY (1,1),
        titulo VARCHAR (200),
        autor VARCHAR (150)
    );

    CREATE TABLE Prestamo (
        prestamo_id INT PRIMARY KEY IDENTITY (1,1),
        cliente_id INT,
        libro_id INT,
        fecha_prestamo DATE, 
        FOREIGN KEY (cliente_id) REFERENCES Cliente (cliente_id),
        FOREIGN KEY (libro_id) REFERENCES Libro(libro_id)
    );

    CREATE TABLE BitacoraCliente (
        bitacora_id INT PRIMARY KEY IDENTITY (1,1),
        cliente_id INT,
        nombre VARCHAR (100),
        apellido VARCHAR (100),
        email VARCHAR (150),
        fecha_accion DATETIME,
        accion VARCHAR (50),
        usuario VARCHAR (100)
    );
    GO

-- =========================
--     Inserté los datos
-- =========================

    INSERT INTO Cliente (nombre, apellido, email) VALUES
        ('Ana', 'Gómez', 'ana@ejemplo.com'),
        ('Carlos', 'Pérez', 'carlos@ejemplo.com' ),
        ('Ángel', 'Vargas', 'vangelfelipe01@gmail.com');

    INSERT INTO Libro (titulo, autor) VALUES
        ('Cien años de soledad', 'Gabriel García Márquez'),
        ('El principito', 'Antonie de Saint-Exupéry'),
        ('Don Quijote de la Mancha', 'Miguel de Cervantes');

    INSERT INTO Prestamo (cliente_id, libro_id, fecha_prestamo) VALUES
        (1, 1, '2026-03-01'),
        (2, 3, '2026-03-10'),
        (3, 2, '2026-03-15');
    GO

-- =========================
--      Creé la ista
-- =========================

    CREATE VIEW VistaPrestamos AS
    SELECT
        p.prestamo_id,
        c.nombre + ' ' + c.apellido AS [Nombre Completo Cliente],
        l.titulo AS [Titulo del Libro],
        p.fecha_prestamo
    FROM Prestamo p
    JOIN Cliente c ON p.cliente_id = c.cliente_id 
    JOIN Libro l ON p.libro_id = l.libro_id;
    GO 

-- ==========================
--  Procedimiento Almacenado
-- ==========================

    CREATE PROCEDURE sp_AgregarCliente
        @nombre VARCHAR (100),
        @apellido VARCHAR (100),
        @email VARCHAR (150)
    AS
    BEGIN
        INSERT INTO Cliente (nombre, apellido, email)
        VALUES (@nombre, @apellido, @email);
    END;
    GO

-- =========================
--    Trigger de Auditoría
-- =========================

    CREATE TRIGGER trg_auditoria_eliminacion_cliente
    ON Cliente
    AFTER DELETE 
    AS
    BEGIN
        INSERT INTO BitacoraCliente (cliente_id, nombre, apellido, email, fecha_accion, accion, usuario)
        SELECT 
            cliente_id, nombre, apellido, email, GETDATE(), 'DELETE', SYSTEM_USER
        FROM deleted;
    END;
    GO

-- =================================
--  PRUEBAS (Para saber si está OK)
-- =================================

-- Proceso almacenado
    EXEC sp_AgregarCliente 'Tuty', 'Lovebird', 'tuttyfrutti@gmail.com';

-- Join General
    SELECT c.nombre AS Cliente, l.titulo AS Libro, l.autor AS Autor
    FROM Cliente c
    JOIN Prestamo p ON c.cliente_id = p.cliente_id
    JOIN Libro l ON p.libro_id = l.libro_id;

-- Prueba de vista
    SELECT * FROM VistaPrestamos;

-- Prueba trigger (Eliminar préstamos primero por integridad referencial)
    DELETE FROM Prestamo WHERE cliente_id = 1;
    DELETE FROM Cliente WHERE cliente_id = 1;
	
-- Verificación final de la bitácora
    SELECT * FROM BitacoraCliente;