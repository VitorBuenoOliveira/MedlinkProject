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
