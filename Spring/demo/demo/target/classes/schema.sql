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
