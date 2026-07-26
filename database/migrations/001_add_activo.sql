USE gestion_usuarios;

ALTER TABLE usuarios
ADD COLUMN activo BOOLEAN DEFAULT TRUE;