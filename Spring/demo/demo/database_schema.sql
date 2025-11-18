-- =====================================================
-- MedLink - Sistema de Transporte de Pacientes
-- PostgreSQL Database Schema
-- Normalized to 1NF, 2NF, and 3NF
-- =====================================================

-- Drop existing tables if they exist (cascade to handle dependencies)
DROP TABLE IF EXISTS ambulancia_motorista CASCADE;
DROP TABLE IF EXISTS chamados CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;
DROP TABLE IF EXISTS ambulancias CASCADE;
DROP TABLE IF EXISTS motoristas CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;
DROP TABLE IF EXISTS hospitais CASCADE;

-- =====================================================
-- TABLE: hospitais
-- Purpose: Store hospital/destination information
-- =====================================================
CREATE TABLE hospitais (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    endereco VARCHAR(500) NOT NULL,
    telefone VARCHAR(20),
    especialidades TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT uk_hospital_nome UNIQUE (nome)
);

-- Index for performance
CREATE INDEX idx_hospitais_ativo ON hospitais(ativo);
CREATE INDEX idx_hospitais_nome ON hospitais(nome);

-- =====================================================
-- TABLE: clientes
-- Purpose: Store patient/client information
-- Normalized: All attributes depend on primary key (id)
-- =====================================================
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    cartao VARCHAR(50),
    tipo VARCHAR(100),
    data_nascimento DATE,
    telefone VARCHAR(20),
    endereco VARCHAR(500),
    bairro VARCHAR(100),
    
    -- Appointment details
    destino VARCHAR(255),
    data_atendimento DATE,
    horario_atendimento TIME,
    horario_van TIME,
    tratamento VARCHAR(255),
    vagas INTEGER DEFAULT 1,
    
    -- Companion information
    cartao_acompanhante VARCHAR(50),
    nome_acompanhante VARCHAR(255),
    data_nascimento_acompanhante DATE,
    
    -- Status
    atendido BOOLEAN DEFAULT FALSE,
    
    -- ODS (Sustainable Development Goals) related fields
    prioridade_saude VARCHAR(50), -- e.g., 'alta', 'media', 'baixa'
    grupo_vulneravel VARCHAR(100), -- e.g., 'idoso', 'deficiente', 'baixa_renda'
    inovacao VARCHAR(100), -- e.g., 'tecnologia_assistiva', 'monitoramento_remoto'
    transporte_sustentavel VARCHAR(100), -- e.g., 'veiculo_eletrico', 'otimizacao_rotas'
    
    -- Location coordinates
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    
    -- Audit fields
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_vagas CHECK (vagas >= 1 AND vagas <= 10),
    CONSTRAINT chk_prioridade CHECK (prioridade_saude IN ('alta', 'media', 'baixa'))
);

-- Indexes for performance
CREATE INDEX idx_clientes_nome ON clientes(nome);
CREATE INDEX idx_clientes_cartao ON clientes(cartao);
CREATE INDEX idx_clientes_data_atendimento ON clientes(data_atendimento);
CREATE INDEX idx_clientes_atendido ON clientes(atendido);

-- =====================================================
-- TABLE: motoristas
-- Purpose: Store driver information
-- Normalized: All attributes directly depend on id
-- =====================================================
CREATE TABLE motoristas (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    cnh VARCHAR(20) NOT NULL,
    categoria_cnh VARCHAR(5) NOT NULL,
    data_validade_cnh DATE NOT NULL,
    telefone VARCHAR(20),
    endereco VARCHAR(500),
    
    -- Status
    ativo BOOLEAN DEFAULT TRUE,
    disponivel BOOLEAN DEFAULT TRUE,
    
    -- Location (current position)
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT uk_motorista_cnh UNIQUE (cnh),
    CONSTRAINT chk_categoria_cnh CHECK (categoria_cnh IN ('A', 'B', 'C', 'D', 'E', 'AB', 'AC', 'AD', 'AE'))
);

-- Indexes
CREATE INDEX idx_motoristas_nome ON motoristas(nome);
CREATE INDEX idx_motoristas_ativo ON motoristas(ativo);
CREATE INDEX idx_motoristas_disponivel ON motoristas(disponivel);

-- =====================================================
-- TABLE: ambulancias
-- Purpose: Store ambulance/vehicle information
-- Normalized: All non-key attributes depend only on id
-- =====================================================
CREATE TABLE ambulancias (
    id SERIAL PRIMARY KEY,
    placa VARCHAR(20) NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    ano INTEGER,
    capacidade INTEGER NOT NULL DEFAULT 4,
    tipo VARCHAR(50), -- e.g., 'UTI', 'Simples', 'Resgate'
    
    -- Status
    status VARCHAR(50) DEFAULT 'disponivel', -- 'disponivel', 'em_servico', 'manutencao', 'inativa'
    ativo BOOLEAN DEFAULT TRUE,
    
    -- Location (current position)
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    
    -- Maintenance
    data_ultima_revisao DATE,
    km_rodados INTEGER DEFAULT 0,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT uk_ambulancia_placa UNIQUE (placa),
    CONSTRAINT chk_capacidade CHECK (capacidade >= 1 AND capacidade <= 20),
    CONSTRAINT chk_ano CHECK (ano >= 1990 AND ano <= 2100),
    CONSTRAINT chk_status CHECK (status IN ('disponivel', 'em_servico', 'manutencao', 'inativa'))
);

-- Indexes
CREATE INDEX idx_ambulancias_placa ON ambulancias(placa);
CREATE INDEX idx_ambulancias_status ON ambulancias(status);
CREATE INDEX idx_ambulancias_ativo ON ambulancias(ativo);

-- =====================================================
-- TABLE: ambulancia_motorista
-- Purpose: Many-to-many relationship between ambulances and drivers
-- Normalized: Composite key, no partial dependencies (2NF satisfied)
-- =====================================================
CREATE TABLE ambulancia_motorista (
    id SERIAL PRIMARY KEY,
    ambulancia_id INTEGER NOT NULL,
    motorista_id INTEGER NOT NULL,
    data_vinculo DATE NOT NULL DEFAULT CURRENT_DATE,
    data_desvinculo DATE,
    ativo BOOLEAN DEFAULT TRUE,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_ambulancia FOREIGN KEY (ambulancia_id) REFERENCES ambulancias(id) ON DELETE CASCADE,
    CONSTRAINT fk_motorista FOREIGN KEY (motorista_id) REFERENCES motoristas(id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT uk_ambulancia_motorista UNIQUE (ambulancia_id, motorista_id, ativo),
    CONSTRAINT chk_data_desvinculo CHECK (data_desvinculo IS NULL OR data_desvinculo >= data_vinculo)
);

-- Indexes
CREATE INDEX idx_amb_mot_ambulancia ON ambulancia_motorista(ambulancia_id);
CREATE INDEX idx_amb_mot_motorista ON ambulancia_motorista(motorista_id);
CREATE INDEX idx_amb_mot_ativo ON ambulancia_motorista(ativo);

-- =====================================================
-- TABLE: usuarios
-- Purpose: Store system users (admin, operators, etc.)
-- Normalized: All attributes depend on id
-- =====================================================
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    senha VARCHAR(255) NOT NULL, -- Should be hashed (bcrypt, etc.)
    funcao VARCHAR(100) NOT NULL, -- e.g., 'admin', 'operador', 'motorista', 'atendente'
    
    -- Status
    ativo BOOLEAN DEFAULT TRUE,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_login TIMESTAMP,
    
    -- Constraints
    CONSTRAINT uk_usuario_email UNIQUE (email),
    CONSTRAINT chk_funcao CHECK (funcao IN ('admin', 'operador', 'motorista', 'atendente', 'gestor'))
);

-- Indexes
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_funcao ON usuarios(funcao);
CREATE INDEX idx_usuarios_ativo ON usuarios(ativo);

-- =====================================================
-- TABLE: chamados
-- Purpose: Store service calls/requests
-- Normalized: Foreign keys reference other tables, no transitive dependencies (3NF)
-- =====================================================
CREATE TABLE chamados (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    hospital_id INTEGER,
    ambulancia_id INTEGER,
    motorista_id INTEGER,
    
    -- Call details
    data_chamado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_aceite TIMESTAMP,
    data_chegada_paciente TIMESTAMP,
    data_chegada_hospital TIMESTAMP,
    data_finalizacao TIMESTAMP,
    
    -- Status tracking
    status VARCHAR(50) DEFAULT 'aguardando', -- 'aguardando', 'aceito', 'a_caminho', 'em_atendimento', 'finalizado', 'cancelado'
    prioridade VARCHAR(20) DEFAULT 'normal', -- 'urgente', 'alta', 'normal', 'baixa'
    
    -- Location details
    endereco_origem VARCHAR(500),
    latitude_origem DECIMAL(10, 8),
    longitude_origem DECIMAL(11, 8),
    
    endereco_destino VARCHAR(500),
    latitude_destino DECIMAL(10, 8),
    longitude_destino DECIMAL(11, 8),
    
    -- Distance and time estimates
    distancia_km DECIMAL(8, 2),
    tempo_estimado_minutos INTEGER,
    
    -- Additional info
    observacoes TEXT,
    tipo_chamado VARCHAR(100), -- e.g., 'consulta', 'emergencia', 'exame', 'cirurgia'
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_chamado_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE,
    CONSTRAINT fk_chamado_hospital FOREIGN KEY (hospital_id) REFERENCES hospitais(id) ON DELETE SET NULL,
    CONSTRAINT fk_chamado_ambulancia FOREIGN KEY (ambulancia_id) REFERENCES ambulancias(id) ON DELETE SET NULL,
    CONSTRAINT fk_chamado_motorista FOREIGN KEY (motorista_id) REFERENCES motoristas(id) ON DELETE SET NULL,
    
    -- Constraints
    CONSTRAINT chk_chamado_status CHECK (status IN ('aguardando', 'aceito', 'a_caminho', 'em_atendimento', 'finalizado', 'cancelado')),
    CONSTRAINT chk_chamado_prioridade CHECK (prioridade IN ('urgente', 'alta', 'normal', 'baixa')),
    CONSTRAINT chk_data_sequence CHECK (
        data_aceite IS NULL OR data_aceite >= data_chamado
    )
);

-- Indexes
CREATE INDEX idx_chamados_cliente ON chamados(cliente_id);
CREATE INDEX idx_chamados_hospital ON chamados(hospital_id);
CREATE INDEX idx_chamados_ambulancia ON chamados(ambulancia_id);
CREATE INDEX idx_chamados_motorista ON chamados(motorista_id);
CREATE INDEX idx_chamados_status ON chamados(status);
CREATE INDEX idx_chamados_data_chamado ON chamados(data_chamado);
CREATE INDEX idx_chamados_prioridade ON chamados(prioridade);

-- =====================================================
-- TRIGGERS FOR AUTO-UPDATE TIMESTAMPS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to all tables with updated_at
CREATE TRIGGER update_hospitais_updated_at BEFORE UPDATE ON hospitais
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clientes_updated_at BEFORE UPDATE ON clientes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_motoristas_updated_at BEFORE UPDATE ON motoristas
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ambulancias_updated_at BEFORE UPDATE ON ambulancias
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_usuarios_updated_at BEFORE UPDATE ON usuarios
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chamados_updated_at BEFORE UPDATE ON chamados
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- SAMPLE DATA INSERTS
-- =====================================================

-- Insert sample hospitals
INSERT INTO hospitais (nome, endereco, telefone, especialidades, latitude, longitude) VALUES
('Hospital Central', 'Av. Principal, 1000 - Centro', '(11) 3333-1000', 'Clínica Geral, Emergência, UTI', -23.550520, -46.633308),
('Hospital São Lucas', 'Rua das Flores, 500 - Jardins', '(11) 3333-2000', 'Cardiologia, Ortopedia, Pediatria', -23.561420, -46.656250),
('Clínica Vida', 'Av. Saúde, 250 - Vila Mariana', '(11) 3333-3000', 'Exames, Consultas, Fisioterapia', -23.588251, -46.632263);

-- Insert sample drivers
INSERT INTO motoristas (nome, cnh, categoria_cnh, data_validade_cnh, telefone, endereco, latitude, longitude) VALUES
('João Silva', '12345678901', 'D', '2026-12-31', '(11) 98765-4321', 'Rua A, 100', -23.550000, -46.630000),
('Maria Santos', '98765432109', 'D', '2027-06-30', '(11) 98765-4322', 'Rua B, 200', -23.560000, -46.640000),
('Pedro Oliveira', '45678912345', 'D', '2025-09-15', '(11) 98765-4323', 'Rua C, 300', -23.570000, -46.650000);

-- Insert sample ambulances
INSERT INTO ambulancias (placa, modelo, ano, capacidade, tipo, status, latitude, longitude) VALUES
('ABC-1234', 'Mercedes Sprinter', 2022, 6, 'UTI', 'disponivel', -23.552000, -46.632000),
('XYZ-5678', 'Fiat Ducato', 2021, 4, 'Simples', 'disponivel', -23.562000, -46.642000),
('DEF-9012', 'Renault Master', 2023, 5, 'Resgate', 'manutencao', -23.572000, -46.652000);

-- Link drivers to ambulances
INSERT INTO ambulancia_motorista (ambulancia_id, motorista_id) VALUES
(1, 1),
(2, 2),
(3, 3);

-- Insert sample users
INSERT INTO usuarios (nome, email, senha, funcao) VALUES
('Admin Sistema', 'admin@medlink.com', '$2a$10$dummyhash...', 'admin'),
('Operador 1', 'operador@medlink.com', '$2a$10$dummyhash...', 'operador');

-- Insert sample clients
INSERT INTO clientes (nome, cartao, tipo, data_nascimento, telefone, endereco, bairro, destino, data_atendimento, horario_atendimento, prioridade_saude, grupo_vulneravel, latitude, longitude) VALUES
('Carlos Mendes', '123456', 'Consulta', '1960-05-15', '(11) 91234-5678', 'Rua das Acácias, 45', 'Jardim Paulista', 'Hospital Central', CURRENT_DATE + 1, '09:00:00', 'media', 'idoso', -23.553000, -46.635000),
('Ana Paula', '654321', 'Exame', '1975-08-20', '(11) 91234-5679', 'Av. Independência, 123', 'Centro', 'Clínica Vida', CURRENT_DATE + 2, '14:00:00', 'baixa', NULL, -23.563000, -46.645000);

-- =====================================================
-- USEFUL QUERIES / VIEWS
-- =====================================================

-- View: Combined ambulance and driver information
CREATE OR REPLACE VIEW vw_ambulancias_combined AS
SELECT 
    a.id,
    a.placa,
    a.modelo,
    a.ano,
    a.capacidade,
    a.tipo,
    a.status,
    a.latitude,
    a.longitude,
    m.id AS motorista_id,
    m.nome AS motorista_nome,
    m.telefone AS motorista_telefone,
    m.disponivel AS motorista_disponivel
FROM ambulancias a
LEFT JOIN ambulancia_motorista am ON a.id = am.ambulancia_id AND am.ativo = TRUE
LEFT JOIN motoristas m ON am.motorista_id = m.id
WHERE a.ativo = TRUE;

-- View: Active calls summary
CREATE OR REPLACE VIEW vw_chamados_ativos AS
SELECT 
    c.id,
    c.status,
    c.prioridade,
    c.data_chamado,
    cl.nome AS cliente_nome,
    cl.telefone AS cliente_telefone,
    h.nome AS hospital_nome,
    a.placa AS ambulancia_placa,
    m.nome AS motorista_nome,
    c.distancia_km,
    c.tempo_estimado_minutos
FROM chamados c
INNER JOIN clientes cl ON c.cliente_id = cl.id
LEFT JOIN hospitais h ON c.hospital_id = h.id
LEFT JOIN ambulancias a ON c.ambulancia_id = a.id
LEFT JOIN motoristas m ON c.motorista_id = m.id
WHERE c.status NOT IN ('finalizado', 'cancelado')
ORDER BY c.prioridade DESC, c.data_chamado ASC;

-- =====================================================
-- COMMENTS / DOCUMENTATION
-- =====================================================

COMMENT ON TABLE hospitais IS 'Stores hospital and clinic information';
COMMENT ON TABLE clientes IS 'Stores patient/client information with ODS-related fields';
COMMENT ON TABLE motoristas IS 'Stores ambulance driver information';
COMMENT ON TABLE ambulancias IS 'Stores ambulance/vehicle fleet information';
COMMENT ON TABLE ambulancia_motorista IS 'Many-to-many relationship between ambulances and drivers';
COMMENT ON TABLE usuarios IS 'System users with different roles';
COMMENT ON TABLE chamados IS 'Service call requests and tracking';

-- =====================================================
-- NORMALIZATION VERIFICATION
-- =====================================================
-- 1NF: All tables have atomic values, no repeating groups
-- 2NF: All non-key attributes fully depend on primary key
-- 3NF: No transitive dependencies (non-key attributes don't depend on other non-key attributes)
--
-- Example: In 'chamados' table:
--   - Foreign keys (cliente_id, hospital_id, etc.) reference other tables
--   - Direct attributes (status, prioridade, data_chamado) depend only on chamado.id
--   - No transitive dependencies exist
-- =====================================================

-- End of schema
