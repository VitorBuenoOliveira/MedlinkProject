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
