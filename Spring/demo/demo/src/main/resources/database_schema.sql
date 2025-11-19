-- ============================================================================
-- MedLink Patient Transport System - PostgreSQL Database Schema
-- Compliant with Normal Forms: 1NF, 2NF, and 3NF
-- ============================================================================
-- 
-- INSTRUÇÕES DE USO (Windows CMD):
-- 1. Abra o CMD como Administrador
-- 2. Navegue até o diretório do PostgreSQL bin:
--    cd "C:\Program Files\PostgreSQL\16\bin"
-- 3. Conecte ao PostgreSQL:
--    psql -U postgres
-- 4. Crie o banco de dados:
--    CREATE DATABASE medlink;
-- 5. Conecte ao banco:
--    \c medlink
-- 6. Execute este script:
--    \i caminho/completo/para/database_schema.sql
--    OU copie e cole o conteúdo completo no prompt do psql
--
-- ============================================================================

-- Drop existing tables (reverse dependency order)
DROP TABLE IF EXISTS agendamento CASCADE;
DROP TABLE IF EXISTS chamado CASCADE;
DROP TABLE IF EXISTS ambulancia_motorista CASCADE;
DROP TABLE IF EXISTS ambulancia CASCADE;
DROP TABLE IF EXISTS motorista CASCADE;
DROP TABLE IF EXISTS cliente_acompanhante CASCADE;
DROP TABLE IF EXISTS cliente CASCADE;
DROP TABLE IF EXISTS usuario CASCADE;
DROP TABLE IF EXISTS hospital CASCADE;

-- ============================================================================
-- TABELA: hospital
-- Armazena informações dos hospitais/destinos
-- 1NF: Todos os atributos são atômicos
-- 2NF: Não há dependências parciais (chave primária é simples)
-- 3NF: Não há dependências transitivas
-- ============================================================================
CREATE TABLE hospital (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    endereco VARCHAR(500),
    bairro VARCHAR(100),
    telefone VARCHAR(20),
    especialidades TEXT,
    capacidade_atendimento INTEGER,
    horario_funcionamento VARCHAR(100),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- TABELA: usuario
-- Armazena usuários do sistema (administradores, operadores, etc.)
-- 1NF: Todos os atributos são atômicos
-- 2NF: Não há dependências parciais
-- 3NF: Não há dependências transitivas
-- ============================================================================
CREATE TABLE usuario (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    funcao VARCHAR(50) NOT NULL, -- 'ADMIN', 'OPERADOR', 'SUPERVISOR'
    telefone VARCHAR(20),
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- TABELA: cliente
-- Armazena pacientes que solicitam transporte
-- 1NF: Todos os atributos são atômicos (acompanhante em tabela separada)
-- 2NF: Todos os atributos dependem da chave primária completa
-- 3NF: Removidas dependências transitivas (hospital_id referencia tabela hospital)
-- ============================================================================
CREATE TABLE cliente (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    cartao VARCHAR(50) UNIQUE,
    data_nascimento DATE,
    telefone VARCHAR(20),
    endereco VARCHAR(500),
    bairro VARCHAR(100),
    
    -- Informações de atendimento
    tipo VARCHAR(100), -- tipo de atendimento (consulta, exame, etc.)
    tratamento VARCHAR(255),
    prioridade_saude VARCHAR(20) CHECK (prioridade_saude IN ('ALTA', 'MEDIA', 'BAIXA')),
    grupo_vulneravel VARCHAR(50), -- 'IDOSO', 'DEFICIENTE', 'BAIXA_RENDA'
    
    -- Destino (normalizado via FK)
    hospital_id INTEGER REFERENCES hospital(id) ON DELETE SET NULL,
    
    -- Status e controle
    atendido BOOLEAN DEFAULT FALSE,
    vagas INTEGER DEFAULT 1, -- número de vagas necessárias
    
    -- ODS (Objetivos de Desenvolvimento Sustentável)
    inovacao VARCHAR(100), -- tecnologia assistiva utilizada
    transporte_sustentavel VARCHAR(50), -- tipo de veículo preferencial
    
    -- Auditoria
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- TABELA: cliente_acompanhante
-- Armazena acompanhantes dos clientes (Normalização 1NF)
-- Separada para evitar repetição de grupos e manter atomicidade
-- ============================================================================
CREATE TABLE cliente_acompanhante (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL REFERENCES cliente(id) ON DELETE CASCADE,
    nome VARCHAR(255) NOT NULL,
    cartao VARCHAR(50),
    data_nascimento DATE,
    parentesco VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- TABELA: motorista
-- Armazena informações dos motoristas
-- 1NF, 2NF, 3NF: Estrutura normalizada sem dependências transitivas
-- ============================================================================
CREATE TABLE motorista (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    cnh VARCHAR(20) NOT NULL UNIQUE,
    categoria_cnh VARCHAR(5) NOT NULL, -- 'B', 'C', 'D', 'E'
    validade_cnh DATE NOT NULL,
    telefone VARCHAR(20),
    endereco VARCHAR(500),
    data_contratacao DATE,
    status VARCHAR(20) DEFAULT 'DISPONIVEL' CHECK (status IN ('DISPONIVEL', 'EM_ROTA', 'INDISPONIVEL')),
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- TABELA: ambulancia
-- Armazena informações das ambulâncias
-- 1NF, 2NF, 3NF: Estrutura normalizada
-- ============================================================================
CREATE TABLE ambulancia (
    id SERIAL PRIMARY KEY,
    placa VARCHAR(10) NOT NULL UNIQUE,
    modelo VARCHAR(100) NOT NULL,
    ano INTEGER,
    capacidade INTEGER NOT NULL DEFAULT 4,
    tipo VARCHAR(50), -- 'BASICA', 'UTI_MOVEL', 'RESGATE'
    status VARCHAR(20) DEFAULT 'DISPONIVEL' CHECK (status IN ('DISPONIVEL', 'EM_SERVICO', 'MANUTENCAO', 'INDISPONIVEL')),
    
    -- Localização atual (GPS)
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    ultima_atualizacao_gps TIMESTAMP,
    
    -- Características
    equipamentos TEXT, -- lista de equipamentos disponíveis
    km_rodados INTEGER DEFAULT 0,
    
    -- Sustentabilidade (ODS 11)
    veiculo_eletrico BOOLEAN DEFAULT FALSE,
    ano_fabricacao INTEGER,
    
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- TABELA: ambulancia_motorista
-- Relacionamento N:N entre ambulância e motorista (Normalização correta)
-- Uma ambulância pode ter vários motoristas ao longo do tempo
-- Um motorista pode dirigir várias ambulâncias
-- ============================================================================
CREATE TABLE ambulancia_motorista (
    id SERIAL PRIMARY KEY,
    ambulancia_id INTEGER NOT NULL REFERENCES ambulancia(id) ON DELETE CASCADE,
    motorista_id INTEGER NOT NULL REFERENCES motorista(id) ON DELETE CASCADE,
    data_inicio DATE NOT NULL DEFAULT CURRENT_DATE,
    data_fim DATE,
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Garantir que não haja duplicatas de associação ativa
    CONSTRAINT unique_active_association UNIQUE (ambulancia_id, motorista_id, ativo)
);

-- ============================================================================
-- TABELA: chamado
-- Armazena chamados/solicitações de transporte
-- 1NF, 2NF, 3NF: Todas as FKs referenciam entidades apropriadas
-- ============================================================================
CREATE TABLE chamado (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL REFERENCES cliente(id) ON DELETE CASCADE,
    ambulancia_id INTEGER REFERENCES ambulancia(id) ON DELETE SET NULL,
    motorista_id INTEGER REFERENCES motorista(id) ON DELETE SET NULL,
    hospital_origem_id INTEGER REFERENCES hospital(id) ON DELETE SET NULL,
    hospital_destino_id INTEGER NOT NULL REFERENCES hospital(id) ON DELETE CASCADE,
    
    -- Informações da solicitação
    data_chamado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    horario_atendimento TIME,
    data_atendimento DATE,
    
    -- Status do chamado
    status VARCHAR(20) DEFAULT 'PENDENTE' CHECK (status IN ('PENDENTE', 'ACEITO', 'EM_ROTA', 'FINALIZADO', 'CANCELADO')),
    prioridade VARCHAR(20) DEFAULT 'NORMAL' CHECK (prioridade IN ('BAIXA', 'NORMAL', 'ALTA', 'URGENTE')),
    
    -- Localização
    endereco_origem VARCHAR(500),
    latitude_origem DECIMAL(10, 8),
    longitude_origem DECIMAL(11, 8),
    
    -- Tempos e distância
    distancia_km DECIMAL(8, 2),
    tempo_estimado_minutos INTEGER,
    horario_inicio_rota TIMESTAMP,
    horario_chegada_destino TIMESTAMP,
    
    -- Observações
    observacoes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- TABELA: agendamento
-- Armazena agendamentos futuros de transporte
-- 1NF, 2NF, 3NF: Normalizado corretamente
-- ============================================================================
CREATE TABLE agendamento (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL REFERENCES cliente(id) ON DELETE CASCADE,
    hospital_destino_id INTEGER NOT NULL REFERENCES hospital(id) ON DELETE CASCADE,
    
    data_agendamento DATE NOT NULL,
    horario_agendamento TIME NOT NULL,
    tipo_atendimento VARCHAR(100),
    observacoes TEXT,
    
    status VARCHAR(20) DEFAULT 'AGENDADO' CHECK (status IN ('AGENDADO', 'CONFIRMADO', 'REALIZADO', 'CANCELADO')),
    
    -- Vinculação com chamado quando executado
    chamado_id INTEGER REFERENCES chamado(id) ON DELETE SET NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Garantir que não haja agendamentos duplicados
    CONSTRAINT unique_agendamento UNIQUE (cliente_id, data_agendamento, horario_agendamento)
);

-- ============================================================================
-- ÍNDICES para melhorar performance
-- ============================================================================

-- Cliente
CREATE INDEX idx_cliente_cartao ON cliente(cartao);
CREATE INDEX idx_cliente_hospital ON cliente(hospital_id);
CREATE INDEX idx_cliente_atendido ON cliente(atendido);

-- Motorista
CREATE INDEX idx_motorista_cnh ON motorista(cnh);
CREATE INDEX idx_motorista_status ON motorista(status);

-- Ambulância
CREATE INDEX idx_ambulancia_placa ON ambulancia(placa);
CREATE INDEX idx_ambulancia_status ON ambulancia(status);
CREATE INDEX idx_ambulancia_localizacao ON ambulancia(latitude, longitude);

-- Chamado
CREATE INDEX idx_chamado_cliente ON chamado(cliente_id);
CREATE INDEX idx_chamado_ambulancia ON chamado(ambulancia_id);
CREATE INDEX idx_chamado_motorista ON chamado(motorista_id);
CREATE INDEX idx_chamado_status ON chamado(status);
CREATE INDEX idx_chamado_data ON chamado(data_chamado);

-- Agendamento
CREATE INDEX idx_agendamento_cliente ON agendamento(cliente_id);
CREATE INDEX idx_agendamento_data ON agendamento(data_agendamento);
CREATE INDEX idx_agendamento_status ON agendamento(status);

-- ============================================================================
-- DADOS DE EXEMPLO (Opcional - para testes)
-- ============================================================================

-- Hospitais de exemplo
INSERT INTO hospital (nome, endereco, bairro, telefone, especialidades, latitude, longitude) VALUES
('Hospital Central', 'Av. Principal, 1000', 'Centro', '(11) 3333-1000', 'Emergência, Cardiologia, Ortopedia', -23.5505, -46.6333),
('Clínica São Paulo', 'Rua das Flores, 500', 'Jardim Paulista', '(11) 3333-2000', 'Exames, Consultas', -23.5629, -46.6544),
('Hospital Norte', 'Av. Norte, 2500', 'Vila Norte', '(11) 3333-3000', 'Emergência, Pediatria', -23.5205, -46.6122);

-- Usuários de exemplo
INSERT INTO usuario (nome, email, senha, funcao, telefone) VALUES
('Admin Sistema', 'admin@medlink.com', '$2a$10$abcdefghijklmnopqrstuv', 'ADMIN', '(11) 99999-0000'),
('João Operador', 'joao@medlink.com', '$2a$10$abcdefghijklmnopqrstuv', 'OPERADOR', '(11) 99999-0001');

-- Motoristas de exemplo
INSERT INTO motorista (nome, cnh, categoria_cnh, validade_cnh, telefone, data_contratacao) VALUES
('Carlos Silva', '12345678901', 'D', '2025-12-31', '(11) 98888-0001', '2023-01-15'),
('Maria Santos', '98765432109', 'D', '2026-06-30', '(11) 98888-0002', '2023-03-20'),
('José Oliveira', '55544433322', 'D', '2025-09-15', '(11) 98888-0003', '2023-05-10');

-- Ambulâncias de exemplo
INSERT INTO ambulancia (placa, modelo, ano, capacidade, tipo, latitude, longitude) VALUES
('ABC-1234', 'Mercedes Sprinter', 2022, 6, 'BASICA', -23.5505, -46.6333),
('DEF-5678', 'Fiat Ducato', 2023, 4, 'UTI_MOVEL', -23.5629, -46.6544),
('GHI-9012', 'Renault Master', 2021, 5, 'BASICA', -23.5205, -46.6122);

-- Associar motoristas às ambulâncias
INSERT INTO ambulancia_motorista (ambulancia_id, motorista_id, data_inicio) VALUES
(1, 1, '2023-01-15'),
(2, 2, '2023-03-20'),
(3, 3, '2023-05-10');

-- Clientes de exemplo
INSERT INTO cliente (nome, cartao, data_nascimento, telefone, endereco, bairro, tipo, prioridade_saude, hospital_id, vagas) VALUES
('Ana Maria da Silva', '1001', '1965-05-15', '(11) 97777-0001', 'Rua A, 123', 'Centro', 'Consulta Cardiologia', 'ALTA', 1, 1),
('Pedro Santos', '1002', '1980-08-20', '(11) 97777-0002', 'Rua B, 456', 'Jardim', 'Exame de Sangue', 'NORMAL', 2, 1),
('Maria Oliveira', '1003', '1955-12-10', '(11) 97777-0003', 'Av. C, 789', 'Vila Norte', 'Fisioterapia', 'MEDIA', 3, 2);

-- ============================================================================
-- FIM DO SCRIPT
-- ============================================================================

-- Verificar criação das tabelas
\dt

-- Mensagem de sucesso
SELECT 'Database schema created successfully! ✅' AS status;
