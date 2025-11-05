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
