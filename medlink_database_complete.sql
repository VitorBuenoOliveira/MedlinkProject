-- ======================================
-- MEDLINK DATABASE - COMPLETE SQL SCRIPT
-- Sistema de Transporte de Pacientes com Normas NF1, NF2, NF3 e Segurança
-- ======================================
-- Este arquivo contém todo o código SQL necessário para criar e popular
-- o banco de dados do projeto Medlink com integração às normas regulatórias
-- ======================================

-- ======================================
-- PARTE 1: CONFIGURAÇÃO DO BANCO E USUÁRIO
-- ======================================
-- Execute estes comandos como superusuário (postgres) ANTES de executar o resto

-- Desconectar usuários ativos do banco (se existir)
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'ambulancia' AND pid <> pg_backend_pid();

-- Dropar banco existente (se existir)
DROP DATABASE IF EXISTS ambulancia;

-- Criar novo banco de dados
CREATE DATABASE ambulancia
    WITH
    OWNER = ambulancia_user
    ENCODING = 'UTF8'
    LC_COLLATE = 'pt_BR.UTF-8'
    LC_CTYPE = 'pt_BR.UTF-8'
    TEMPLATE = template0;

-- Criar ou atualizar usuário com senha
DO $$
BEGIN
   IF EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'ambulancia_user') THEN
      ALTER ROLE ambulancia_user PASSWORD '1234567';
   ELSE
      CREATE ROLE ambulancia_user LOGIN PASSWORD '1234567';
   END IF;
END
$$;

-- Conceder privilégios
GRANT ALL PRIVILEGES ON DATABASE ambulancia TO ambulancia_user;

-- ======================================
-- PARTE 2: SCHEMA - CRIAÇÃO DAS TABELAS
-- ======================================

-- Schema SQL for Patient Transportation Management System
-- Database: ambulancia
-- User: ambulancia_user

-- Table for Usuario (Users with roles)
CREATE TABLE IF NOT EXISTS usuario (
    id BIGSERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL
);

-- Table for Motorista (Drivers)
CREATE TABLE IF NOT EXISTS motorista (
    id BIGSERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    carteira_habilitacao VARCHAR(50) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    regiao_atuacao VARCHAR(255)
);

-- Table for Ambulancia (Ambulances)
CREATE TABLE IF NOT EXISTS ambulancia (
    id BIGSERIAL PRIMARY KEY,
    placa VARCHAR(10) UNIQUE NOT NULL,
    modelo VARCHAR(255) NOT NULL,
    capacidade INTEGER NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'disponivel',
    motorista_id BIGINT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION
);

-- Table for Hospital (Hospitals)
CREATE TABLE IF NOT EXISTS hospital (
    id BIGSERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    endereco VARCHAR(500) NOT NULL,
    especialidades TEXT
);

-- Table for Cliente (Patients/Clients)
CREATE TABLE IF NOT EXISTS cliente (
    id BIGSERIAL PRIMARY KEY,
    cartao VARCHAR(50),
    tipo VARCHAR(100),
    horario_van VARCHAR(20),
    data_nascimento DATE,
    data_atendimento DATE,
    nome VARCHAR(255) NOT NULL,
    endereco VARCHAR(500),
    bairro VARCHAR(255),
    telefone VARCHAR(20),
    destino VARCHAR(255),
    horario_atendimento VARCHAR(20),
    vagas INTEGER,
    tratamento VARCHAR(255),
    cartao_acompanhante VARCHAR(50),
    nome_acompanhante VARCHAR(255),
    data_nascimento_acompanhante DATE,
    atendido BOOLEAN DEFAULT FALSE,
    prioridade_saude VARCHAR(255),  -- ODS 3: Health
    inovacao VARCHAR(255),          -- ODS 9: Innovation
    grupo_vulneravel VARCHAR(255),  -- ODS 10: Inequality
    transporte_sustentavel VARCHAR(255)  -- ODS 11: Sustainable Cities
);

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_cliente_data_nascimento ON cliente(data_nascimento);
CREATE INDEX IF NOT EXISTS idx_cliente_atendido ON cliente(atendido);
CREATE INDEX IF NOT EXISTS idx_motorista_regiao_atuacao ON motorista(regiao_atuacao);
CREATE INDEX IF NOT EXISTS idx_ambulancia_status ON ambulancia(status);

-- ======================================
-- NOVAS TABELAS PARA NORMAS E SEGURANÇA
-- ======================================

-- Table for Norma (Normas regulatórias)
CREATE TABLE IF NOT EXISTS norma (
    id BIGSERIAL PRIMARY KEY,
    tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('NF1', 'NF2', 'NF3', 'SEGURANCA')),
    codigo VARCHAR(50) UNIQUE NOT NULL,
    descricao TEXT NOT NULL,
    data_publicacao DATE,
    ativo BOOLEAN DEFAULT TRUE
);

-- Table for Requisito Norma (Requisitos específicos de cada norma)
CREATE TABLE IF NOT EXISTS requisito_norma (
    id BIGSERIAL PRIMARY KEY,
    norma_id BIGINT NOT NULL,
    categoria VARCHAR(100) NOT NULL,
    descricao TEXT NOT NULL,
    obrigatorio BOOLEAN DEFAULT TRUE,
    aplicavel_a VARCHAR(100), -- 'ambulancia', 'hospital', 'equipamento'
    FOREIGN KEY (norma_id) REFERENCES norma(id) ON DELETE CASCADE
);

-- Table for Equipamento (Equipamentos médicos/hospitalares)
CREATE TABLE IF NOT EXISTS equipamento (
    id BIGSERIAL PRIMARY KEY,
    tipo VARCHAR(100) NOT NULL,
    modelo VARCHAR(255),
    numero_serie VARCHAR(255) UNIQUE,
    data_aquisicao DATE,
    status VARCHAR(50) DEFAULT 'ativo' CHECK (status IN ('ativo', 'inativo', 'manutencao')),
    ambulancia_id BIGINT,
    hospital_id BIGINT,
    FOREIGN KEY (ambulancia_id) REFERENCES ambulancia(id) ON DELETE SET NULL,
    FOREIGN KEY (hospital_id) REFERENCES hospital(id) ON DELETE SET NULL,
    CHECK (ambulancia_id IS NOT NULL OR hospital_id IS NOT NULL) -- Deve estar associado a pelo menos uma entidade
);

-- Table for Conformidade (Verificações de conformidade com normas)
CREATE TABLE IF NOT EXISTS conformidade (
    id BIGSERIAL PRIMARY KEY,
    entidade_tipo VARCHAR(50) NOT NULL CHECK (entidade_tipo IN ('ambulancia', 'hospital', 'equipamento')),
    entidade_id BIGINT NOT NULL,
    requisito_id BIGINT NOT NULL,
    status VARCHAR(50) NOT NULL CHECK (status IN ('conforme', 'nao_conforme', 'pendente')),
    data_verificacao DATE NOT NULL,
    observacoes TEXT,
    verificado_por BIGINT,
    FOREIGN KEY (requisito_id) REFERENCES requisito_norma(id) ON DELETE CASCADE,
    FOREIGN KEY (verificado_por) REFERENCES usuario(id) ON DELETE SET NULL
);

-- Table for Auditoria Normas (Auditorias de conformidade)
CREATE TABLE IF NOT EXISTS auditoria_normas (
    id BIGSERIAL PRIMARY KEY,
    entidade_tipo VARCHAR(50) NOT NULL CHECK (entidade_tipo IN ('ambulancia', 'hospital', 'equipamento')),
    entidade_id BIGINT NOT NULL,
    data_auditoria DATE NOT NULL,
    resultado VARCHAR(50) NOT NULL CHECK (resultado IN ('aprovado', 'reprovado', 'pendente')),
    relatorio TEXT,
    auditor_id BIGINT,
    FOREIGN KEY (auditor_id) REFERENCES usuario(id) ON DELETE SET NULL
);

-- Indexes for new tables
CREATE INDEX IF NOT EXISTS idx_requisito_norma_norma_id ON requisito_norma(norma_id);
CREATE INDEX IF NOT EXISTS idx_equipamento_ambulancia_id ON equipamento(ambulancia_id);
CREATE INDEX IF NOT EXISTS idx_equipamento_hospital_id ON equipamento(hospital_id);
CREATE INDEX IF NOT EXISTS idx_conformidade_entidade ON conformidade(entidade_tipo, entidade_id);
CREATE INDEX IF NOT EXISTS idx_conformidade_requisito_id ON conformidade(requisito_id);
CREATE INDEX IF NOT EXISTS idx_auditoria_normas_entidade ON auditoria_normas(entidade_tipo, entidade_id);

-- ======================================
-- PARTE 3: DADOS INICIAIS
-- ======================================

-- Default users for testing
-- Passwords are encoded with BCrypt (all passwords are '123456')

DELETE FROM usuario;
DELETE FROM hospital;
DELETE FROM ambulancia;
DELETE FROM motorista;
DELETE FROM cliente;

INSERT INTO usuario (nome, email, senha, role) VALUES
('Admin User', 'admin@test.com', '$2a$10$8K3ds.9Xp/6Hk5qoVSkTqeS0NSuEpfFkJ8mBh9Yz1U2ZrJDcR1QyO', 'ADMIN'),
('Agente User', 'agente@test.com', '$2a$10$8K3ds.9Xp/6Hk5qoVSkTqeS0NSuEpfFkJ8mBh9Yz1U2ZrJDcR1QyO', 'AGENTE'),
('Motorista User', 'motorista@test.com', '$2a$10$8K3ds.9Xp/6Hk5qoVSkTqeS0NSuEpfFkJ8mBh9Yz1U2ZrJDcR1QyO', 'MOTORISTA');

-- Default hospitals
INSERT INTO hospital (nome, endereco, especialidades) VALUES
('Hospital Central', 'Rua Principal, 123', 'Cardiologia,Ortopedia,Emergência'),
('Hospital Municipal', 'Av. Saúde, 456', 'Pediatria,Ginecologia,Clínica Geral');

-- Default ambulances
INSERT INTO ambulancia (placa, modelo, capacidade, status) VALUES
('ABC-1234', 'Fiat Ducato', 4, 'disponivel'),
('DEF-5678', 'Mercedes Sprinter', 6, 'disponivel'),
('GHI-9012', 'VW Crafter', 8, 'manutencao');

-- Default drivers
INSERT INTO motorista (nome, carteira_habilitacao, telefone, regiao_atuacao) VALUES
('João Silva', '12345678901', '(11) 99999-0001', 'Centro'),
('Maria Santos', '23456789012', '(11) 99999-0002', 'Zona Norte'),
('Pedro Oliveira', '34567890123', '(11) 99999-0003', 'Zona Sul');

-- Default patients
INSERT INTO cliente (cartao, tipo, horario_van, data_nascimento, data_atendimento, nome, endereco, bairro, telefone, destino, horario_atendimento, vagas, tratamento, atendido, prioridade_saude, inovacao, grupo_vulneravel, transporte_sustentavel) VALUES
('CART001', 'Consulta', '08:00', '1980-05-15', '2024-01-15', 'Ana Costa', 'Rua das Flores, 100', 'Centro', '(11) 88888-0001', 'Hospital Central', '09:00', 1, 'Cardiologia', false, 'alta', 'telemedicina', 'idoso', 'veiculo_eletrico'),
('CART002', 'Exame', '10:00', '1975-03-20', '2024-01-15', 'Carlos Lima', 'Av. Brasil, 200', 'Zona Norte', '(11) 88888-0002', 'Hospital Municipal', '11:00', 1, 'Raio-X', false, 'media', 'monitoramento_remoto', 'deficiente', 'otimizacao_rotas'),
('CART003', 'Tratamento', '14:00', '1990-08-10', '2024-01-16', 'Beatriz Souza', 'Rua Verde, 300', 'Zona Sul', '(11) 88888-0003', 'Hospital Central', '15:00', 2, 'Fisioterapia', true, 'baixa', 'tecnologia_assistiva', 'baixa_renda', 'veiculo_eletrico');

-- ======================================
-- DADOS PARA NORMAS E SEGURANÇA
-- ======================================

-- Normas regulatórias
INSERT INTO norma (tipo, codigo, descricao, data_publicacao, ativo) VALUES
('NF1', 'NF1-2018', 'Norma para Ambulâncias - Equipamentos obrigatórios e procedimentos de emergência', '2018-01-01', true),
('NF2', 'NF2-2019', 'Norma para Equipamentos Médicos - Certificações e manutenção', '2019-01-01', true),
('NF3', 'NF3-2020', 'Norma para Equipamentos Hospitalares - Segurança e qualidade', '2020-01-01', true),
('SEGURANCA', 'ISO 45001', 'Sistema de Gestão de Segurança e Saúde Ocupacional', '2018-03-12', true);

-- Requisitos das normas
INSERT INTO requisito_norma (norma_id, categoria, descricao, obrigatorio, aplicavel_a) VALUES
(1, 'Equipamentos Obrigatórios', 'Ambulância deve ter desfibrilador cardíaco', true, 'ambulancia'),
(1, 'Equipamentos Obrigatórios', 'Ambulância deve ter maca com rodas', true, 'ambulancia'),
(1, 'Procedimentos', 'Motorista deve ter treinamento em primeiros socorros', true, 'ambulancia'),
(2, 'Certificações', 'Equipamentos médicos devem ter certificação ANVISA', true, 'equipamento'),
(2, 'Manutenção', 'Equipamentos devem passar por manutenção anual', true, 'equipamento'),
(3, 'Segurança', 'Equipamentos hospitalares devem ter proteção contra sobrecarga', true, 'equipamento'),
(3, 'Qualidade', 'Equipamentos devem atender padrões de esterilidade', true, 'equipamento'),
(4, 'Treinamento', 'Funcionários devem receber treinamento anual em segurança', true, 'hospital'),
(4, 'Equipamentos de Proteção', 'Hospital deve fornecer EPIs adequados', true, 'hospital');

-- Equipamentos de exemplo
INSERT INTO equipamento (tipo, modelo, numero_serie, data_aquisicao, status, ambulancia_id, hospital_id) VALUES
('Desfibrilador', 'Philips HeartStart', 'DEF123456', '2023-01-15', 'ativo', 1, NULL),
('Maca', 'Ferno 35-A', 'MAC789012', '2022-06-20', 'ativo', 1, NULL),
('Ventilador', 'Dräger Oxylog', 'VEN345678', '2023-03-10', 'ativo', NULL, 1),
('Monitor Cardíaco', 'Philips IntelliVue', 'MON901234', '2022-11-05', 'manutencao', NULL, 1);

-- Verificações de conformidade (exemplo)
INSERT INTO conformidade (entidade_tipo, entidade_id, requisito_id, status, data_verificacao, observacoes, verificado_por) VALUES
('ambulancia', 1, 1, 'conforme', '2024-01-10', 'Desfibrilador testado e funcional', 1),
('ambulancia', 1, 2, 'conforme', '2024-01-10', 'Maca em boas condições', 1),
('equipamento', 1, 4, 'conforme', '2024-01-12', 'Certificação ANVISA válida', 1),
('hospital', 1, 8, 'pendente', '2024-01-15', 'Aguardando relatório de treinamento', 1);

-- Auditorias de exemplo
INSERT INTO auditoria_normas (entidade_tipo, entidade_id, data_auditoria, resultado, relatorio, auditor_id) VALUES
('ambulancia', 1, '2024-01-20', 'aprovado', 'Ambulância atende todos os requisitos NF1. Equipamentos em dia.', 1),
('hospital', 1, '2024-01-22', 'pendente', 'Auditoria em andamento. Faltam verificações de EPIs.', 1);

-- ======================================
-- PARTE 4: CONSULTAS ÚTEIS PARA RELATÓRIOS
-- ======================================

-- Verificar conformidade de uma ambulância específica
-- SELECT a.placa, n.tipo, n.codigo, rn.descricao AS requisito, c.status, c.data_verificacao, c.observacoes, u.nome AS verificado_por
-- FROM conformidade c
-- JOIN requisito_norma rn ON c.requisito_id = rn.id
-- JOIN norma n ON rn.norma_id = n.id
-- LEFT JOIN usuario u ON c.verificado_por = u.id
-- WHERE c.entidade_tipo = 'ambulancia' AND c.entidade_id = 1
-- ORDER BY n.tipo, rn.descricao;

-- Listar equipamentos de uma ambulância
-- SELECT e.tipo, e.modelo, e.numero_serie, e.status AS status_equipamento, n.tipo AS norma_tipo, rn.descricao AS requisito, c.status AS status_conformidade
-- FROM equipamento e
-- LEFT JOIN conformidade c ON c.entidade_tipo = 'equipamento' AND c.entidade_id = e.id
-- LEFT JOIN requisito_norma rn ON c.requisito_id = rn.id
-- LEFT JOIN norma n ON rn.norma_id = n.id
-- WHERE e.ambulancia_id = 1
-- ORDER BY e.tipo;

-- Relatório de auditorias
-- SELECT an.entidade_tipo, CASE WHEN an.entidade_tipo = 'ambulancia' THEN (SELECT placa FROM ambulancia WHERE id = an.entidade_id) WHEN an.entidade_tipo = 'hospital' THEN (SELECT nome FROM hospital WHERE id = an.entidade_id) WHEN an.entidade_tipo = 'equipamento' THEN (SELECT tipo FROM equipamento WHERE id = an.entidade_id) END AS entidade_nome, an.data_auditoria, an.resultado, an.relatorio, u.nome AS auditor
-- FROM auditoria_normas an
-- LEFT JOIN usuario u ON an.auditor_id = u.id
-- ORDER BY an.data_auditoria DESC;

-- ======================================
-- INSTRUÇÕES DE USO
-- ======================================
-- 1. Execute a PARTE 1 como superusuário (postgres)
-- 2. Execute as PARTES 2 e 3 conectando como ambulancia_user
-- 3. Use as consultas da PARTE 4 para relatórios
-- 4. Para backup: pg_dump -U ambulancia_user -h localhost ambulancia > backup.sql
-- 5. Para restaurar: psql -U ambulancia_user -h localhost ambulancia < backup.sql
-- ======================================
