DROP DATABASE IF EXISTS gestion_usuarios_devops;

CREATE DATABASE gestion_usuarios
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE gestion_usuarios_devops;

CREATE TABLE usuarios (

    id INT AUTO_INCREMENT PRIMARY KEY,

    nombre VARCHAR(100) NOT NULL,

    apellido VARCHAR(100) NOT NULL,

    fecha_nacimiento DATE,

    sexo ENUM('Masculino','Femenino','Otro'),

    direccion VARCHAR(250),

    telefono VARCHAR(30),

    email VARCHAR(150) NOT NULL UNIQUE,

    provincia VARCHAR(100),

    nivel_educacion VARCHAR(100),

    password VARCHAR(255) NOT NULL,

    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    ultimo_login DATETIME NULL,

    activo BOOLEAN DEFAULT TRUE

);