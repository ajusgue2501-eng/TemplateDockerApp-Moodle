-- Creamos el esquema si no existe
-- Se llama template_docker_app_dev y se define con charset utf8mb4 y colacion utf8mb4_general_ci
CREATE SCHEMA IF NOT EXISTS `template_docker_app_dev` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

-- Indicamos que vamos a usar el esquema recien creado
USE `template_docker_app_dev`;