-- Dados de demonstração do MedLink. Todos fictícios (nomes, telefones, cartões, placas).
-- Recarregado a cada inicialização. Senha de todos os usuários de teste: 123456 (BCrypt).

DELETE FROM chamados;
DELETE FROM cliente;
DELETE FROM ambulancia;
DELETE FROM motorista;
DELETE FROM hospital;
DELETE FROM usuario;

INSERT INTO usuario (nome, email, senha, role) VALUES
('Administrador', 'admin@test.com', '$2a$10$t5yuiQiMohmFKplKxHpDm.6hj8EMi1LuJ7VbO4VPqNevHoz/PzpK.', 'ADMIN'),
('Agente da Central', 'agente@test.com', '$2a$10$t5yuiQiMohmFKplKxHpDm.6hj8EMi1LuJ7VbO4VPqNevHoz/PzpK.', 'AGENTE'),
('Motorista', 'motorista@test.com', '$2a$10$t5yuiQiMohmFKplKxHpDm.6hj8EMi1LuJ7VbO4VPqNevHoz/PzpK.', 'MOTORISTA');

-- Destinos de tratamento
INSERT INTO hospital (nome, endereco, especialidades) VALUES
('Hospital Municipal', 'Av. da Saúde, 100 - Hortolândia', 'Clínica Geral,Alta Hospitalar,Pediatria'),
('Unidade de Hemodiálise', 'Rua dos Rins, 250 - Sumaré', 'Hemodiálise'),
('Centro de Oncologia', 'Av. Esperança, 800 - Campinas', 'Quimioterapia,Radioterapia'),
('Centro de Reabilitação', 'Rua do Movimento, 45 - Hortolândia', 'Fisioterapia,Reabilitação'),
('Ambulatório de Especialidades', 'Av. Brasil, 1200 - Campinas', 'Cardiologia,Ortopedia,Consultas');

INSERT INTO motorista (nome, carteira_habilitacao, telefone, regiao_atuacao) VALUES
('Carlos Mendes', '10000000001', '(19) 90000-0001', 'Centro'),
('Marcos Ribeiro', '10000000002', '(19) 90000-0002', 'Zona Norte'),
('Paulo Teixeira', '10000000003', '(19) 90000-0003', 'Zona Sul'),
('Rogério Alves', '10000000004', '(19) 90000-0004', 'Zona Leste'),
('Edson Martins', '10000000005', '(19) 90000-0005', 'Zona Oeste');

-- Frota (posições em Hortolândia/SP)
INSERT INTO ambulancia (placa, modelo, capacidade, status, motorista_id, latitude, longitude)
SELECT v.placa, v.modelo, v.capacidade, v.status, m.id, v.lat, v.lng
FROM (VALUES
 ('MLK-1A01', 'Van Sprinter 16 lugares', 14, 'em_uso', '10000000001', -22.8583, -47.2208),
 ('MLK-1A02', 'Van adaptada (cadeirantes)', 6, 'em_uso', '10000000002', -22.8421, -47.2145),
 ('MLK-1A03', 'Van Ducato', 10, 'disponivel', '10000000003', -22.8710, -47.2290),
 ('MLK-1A04', 'Carro sedan', 3, 'disponivel', '10000000004', -22.8650, -47.1990),
 ('MLK-1A05', 'Ambulância simples (maca)', 2, 'em_uso', '10000000005', -22.8512, -47.2331),
 ('MLK-1A06', 'Van Master', 12, 'manutencao', NULL, -22.8600, -47.2200)
) AS v(placa, modelo, capacidade, status, cnh, lat, lng)
LEFT JOIN motorista m ON m.carteira_habilitacao = v.cnh;

-- Pacientes do dia (atendimento = hoje)
INSERT INTO cliente (cartao, tipo, horario_van, data_nascimento, data_atendimento, nome, endereco, bairro, telefone, destino, horario_atendimento, vagas, tratamento, atendido, prioridade_saude, grupo_vulneravel) VALUES
('900000000001', 'Hemodiálise', '05:30', '1951-03-12', CURRENT_DATE, 'Antônio Ferreira', 'Rua das Acácias, 120', 'Jardim Amanda', '(19) 90000-1001', 'Unidade de Hemodiálise', '07:00', 1, 'Hemodiálise', true, 'alta', 'idoso'),
('900000000002', 'Hemodiálise', '05:30', '1948-07-22', CURRENT_DATE, 'Benedita Souza', 'Rua das Palmeiras, 88', 'Jardim Amanda', '(19) 90000-1002', 'Unidade de Hemodiálise', '07:00', 1, 'Hemodiálise', true, 'alta', 'idoso'),
('900000000003', 'Hemodiálise', '05:40', '1962-11-03', CURRENT_DATE, 'José Carlos Lima', 'Av. Santana, 410', 'Jardim Santa Amélia', '(19) 90000-1003', 'Unidade de Hemodiálise', '07:00', 1, 'Hemodiálise', true, 'alta', 'cadeirante'),
('900000000004', 'Hemodiálise', '05:40', '1957-01-19', CURRENT_DATE, 'Maria das Dores', 'Rua do Sol, 15', 'Jardim Santa Amélia', '(19) 90000-1004', 'Unidade de Hemodiálise', '07:00', 1, 'Hemodiálise', false, 'alta', 'idoso'),
('900000000005', 'Hemodiálise', '12:30', '1969-05-30', CURRENT_DATE, 'Raimundo Nonato', 'Rua Goiás, 200', 'Vila Real', '(19) 90000-1005', 'Unidade de Hemodiálise', '14:00', 1, 'Hemodiálise', false, 'alta', 'nenhum'),
('900000000006', 'Hemodiálise', '12:30', '1944-09-09', CURRENT_DATE, 'Joana Darc Pereira', 'Rua Bahia, 77', 'Vila Real', '(19) 90000-1006', 'Unidade de Hemodiálise', '14:00', 1, 'Hemodiálise', false, 'alta', 'idoso'),
('900000000007', 'Quimioterapia', '06:00', '1959-02-14', CURRENT_DATE, 'Lúcia Helena Prado', 'Rua Ipê, 301', 'Jardim Nova Europa', '(19) 90000-1007', 'Centro de Oncologia', '08:00', 1, 'Quimioterapia', true, 'alta', 'nenhum'),
('900000000008', 'Quimioterapia', '06:00', '1973-06-27', CURRENT_DATE, 'Sérgio Nogueira', 'Rua Jasmim, 52', 'Jardim Nova Europa', '(19) 90000-1008', 'Centro de Oncologia', '08:00', 1, 'Quimioterapia', true, 'alta', 'nenhum'),
('900000000009', 'Quimioterapia', '07:15', '1981-12-01', CURRENT_DATE, 'Fernanda Alcântara', 'Av. das Nações, 900', 'Parque Orestes Ongaro', '(19) 90000-1009', 'Centro de Oncologia', '09:00', 2, 'Quimioterapia', false, 'alta', 'nenhum'),
('900000000010', 'Fisioterapia', '08:00', '2016-04-18', CURRENT_DATE, 'Pedro Henrique (criança)', 'Rua Girassol, 14', 'Jardim Amanda', '(19) 90000-1010', 'Centro de Reabilitação', '09:00', 2, 'Fisioterapia', true, 'media', 'crianca'),
('900000000011', 'Fisioterapia', '08:00', '2018-08-25', CURRENT_DATE, 'Ana Clara (criança)', 'Rua Violeta, 60', 'Jardim Amanda', '(19) 90000-1011', 'Centro de Reabilitação', '09:00', 2, 'Fisioterapia', true, 'media', 'crianca'),
('900000000012', 'Fisioterapia', '09:30', '1965-10-10', CURRENT_DATE, 'Wilson Batista', 'Rua Minas Gerais, 5', 'Jardim Santa Clara', '(19) 90000-1012', 'Centro de Reabilitação', '10:30', 1, 'Fisioterapia', false, 'media', 'cadeirante'),
('900000000013', 'Fisioterapia', '09:30', '1954-03-03', CURRENT_DATE, 'Terezinha de Jesus', 'Rua Paraná, 330', 'Jardim Santa Clara', '(19) 90000-1013', 'Centro de Reabilitação', '10:30', 1, 'Fisioterapia', false, 'media', 'idoso'),
('900000000014', 'Consulta', '10:00', '1949-12-20', CURRENT_DATE, 'Osvaldo Moreira', 'Av. Brasil, 2200', 'Centro', '(19) 90000-1014', 'Ambulatório de Especialidades', '11:30', 1, 'Cardiologia', false, 'media', 'idoso'),
('900000000015', 'Consulta', '10:00', '1960-07-07', CURRENT_DATE, 'Neusa Maria Gomes', 'Rua São Paulo, 410', 'Centro', '(19) 90000-1015', 'Ambulatório de Especialidades', '11:30', 1, 'Ortopedia', false, 'baixa', 'idoso'),
('900000000016', 'Consulta', '13:00', '1977-02-02', CURRENT_DATE, 'Rafael Domingues', 'Rua Rio Branco, 18', 'Vila Real', '(19) 90000-1016', 'Ambulatório de Especialidades', '14:30', 1, 'Cardiologia', false, 'baixa', 'nenhum'),
('900000000017', 'Alta hospitalar', '11:00', '1946-05-05', CURRENT_DATE, 'Genésio Almeida', 'Rua Mato Grosso, 90', 'Jardim Santa Amélia', '(19) 90000-1017', 'Hospital Municipal', '11:00', 1, 'Alta hospitalar', false, 'alta', 'maca'),
('900000000018', 'Alta hospitalar', '15:30', '1953-08-16', CURRENT_DATE, 'Isabel Cristina', 'Rua Acre, 7', 'Jardim Nova Europa', '(19) 90000-1018', 'Hospital Municipal', '15:30', 1, 'Alta hospitalar', false, 'alta', 'maca'),
('900000000019', 'Alta hospitalar', '16:00', '1938-01-30', CURRENT_DATE, 'Dionísio Barros', 'Rua Alagoas, 140', 'Parque Orestes Ongaro', '(19) 90000-1019', 'Hospital Municipal', '16:00', 1, 'Alta hospitalar', false, 'alta', 'idoso'),
('900000000020', 'Hemodiálise', '17:30', '1966-09-14', CURRENT_DATE, 'Cláudio Ramos', 'Rua Pernambuco, 66', 'Jardim Santa Clara', '(19) 90000-1020', 'Unidade de Hemodiálise', '19:00', 1, 'Hemodiálise', false, 'alta', 'cadeirante');
