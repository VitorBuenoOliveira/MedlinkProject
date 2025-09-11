-- Script para remover usuários duplicados mantendo apenas o registro com menor id para cada email duplicado

-- Ajustado para remover especificamente os IDs 13, mantendo o ID 1 para admin@test.com

DELETE FROM usuario WHERE id = 13;

-- Verificar se a restrição UNIQUE está ativa (deve estar conforme schema.sql)
-- Caso não esteja, criar a restrição:
-- ALTER TABLE usuario ADD CONSTRAINT unique_email UNIQUE (email);
