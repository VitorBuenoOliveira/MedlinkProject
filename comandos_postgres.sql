-- ======================================
-- COMANDOS PARA RECRIAR E CONFIGURAR O BANCO DE DADOS POSTGRESQL
-- PARA O PROJETO MEDLINK COM NORMAS NF1, NF2, NF3 E SEGURANÇA
-- ======================================
-- ATENÇÃO: Estes comandos DROPARÃO o banco existente e recriarão tudo
-- Execute como superusuário (postgres)

-- 1. DESCONECTAR USUÁRIOS DO BANCO (se houver conexões ativas)
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'ambulancia' AND pid <> pg_backend_pid();

-- 2. DROPAR O BANCO EXISTENTE
DROP DATABASE IF EXISTS ambulancia;

-- 3. RECRIAR O BANCO DE DADOS
CREATE DATABASE ambulancia
    WITH
    OWNER = ambulancia_user
    ENCODING = 'UTF8'
    LC_COLLATE = 'pt_BR.UTF-8'
    LC_CTYPE = 'pt_BR.UTF-8'
    TEMPLATE = template0;

-- 4. RECRIAR OU ATUALIZAR O USUÁRIO COM NOVA SENHA
-- Substitua 'nova_senha_segura' pela senha desejada
DO $$
BEGIN
   IF EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'ambulancia_user') THEN
      ALTER ROLE ambulancia_user PASSWORD 'nova_senha_segura';
   ELSE
      CREATE ROLE ambulancia_user LOGIN PASSWORD 'nova_senha_segura';
   END IF;
END
$$;

-- 5. CONCEDER PRIVILÉGIOS NO BANCO
GRANT ALL PRIVILEGES ON DATABASE ambulancia TO ambulancia_user;

-- 3. CONECTAR AO BANCO (no psql ou cliente)
-- \c ambulancia ambulancia_user

-- 4. EXECUTAR O SCHEMA (cria todas as tabelas)
-- Copie e execute o conteúdo do arquivo schema.sql aqui
-- Ou execute o arquivo diretamente:
-- \i /caminho/para/schema.sql

-- 5. EXECUTAR OS DADOS INICIAIS
-- Copie e execute o conteúdo do arquivo data.sql aqui
-- Ou execute o arquivo diretamente:
-- \i /caminho/para/data.sql

-- 6. VERIFICAR SE AS TABELAS FORAM CRIADAS
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- 7. VERIFICAR DADOS INSERIDOS (exemplos)
SELECT COUNT(*) as total_normas FROM norma;
SELECT COUNT(*) as total_requisitos FROM requisito_norma;
SELECT COUNT(*) as total_equipamentos FROM equipamento;
SELECT COUNT(*) as total_conformidades FROM conformidade;

-- 8. TESTAR ALGUMAS CONSULTAS DE CONFORMIDADE
-- Copie e execute consultas do arquivo consultas_conformidade.sql

-- 9. BACKUP DO BANCO (opcional, mas recomendado)
-- pg_dump -U ambulancia_user -h localhost ambulancia > backup_medlink.sql

-- 10. RESTAURAR BACKUP (se necessário)
-- psql -U ambulancia_user -h localhost ambulancia < backup_medlink.sql

-- ======================================
-- NOTAS IMPORTANTES
-- ======================================
-- - Substitua 'senha_segura_aqui' por uma senha forte
-- - Ajuste os caminhos dos arquivos \i conforme necessário
-- - Execute os comandos na ordem: 1-5 primeiro, depois testes
-- - Para desenvolvimento, considere usar Docker para PostgreSQL isolado
