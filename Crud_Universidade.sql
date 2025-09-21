-- ======================================
-- CRIAÇÃO DO BANCO
-- ======================================
DROP DATABASE IF EXISTS universidade;
CREATE DATABASE universidade;
USE universidade;

-- ======================================
-- TABELAS PRINCIPAIS
-- ======================================

-- Tabela de Alunos
CREATE TABLE alunos (
    id_aluno INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    idade INT,
    email VARCHAR(100) UNIQUE
);

-- Tabela de Cursos
CREATE TABLE cursos (
    id_curso INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    carga_horaria INT
);

-- Tabela de Professores
CREATE TABLE professores (
    id_professor INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    especialidade VARCHAR(100)
);

-- ======================================
-- TABELA DE ASSOCIAÇÃO (Muitos-para-Muitos)
-- ======================================
CREATE TABLE alunos_cursos (
    id_aluno INT,
    id_curso INT,
    PRIMARY KEY (id_aluno, id_curso),
    FOREIGN KEY (id_aluno) REFERENCES alunos(id_aluno) ON DELETE CASCADE,
    FOREIGN KEY (id_curso) REFERENCES cursos(id_curso) ON DELETE CASCADE
);

-- ======================================
-- RELACIONAMENTO PROFESSORES → CURSOS (1:N)
-- ======================================
ALTER TABLE cursos ADD COLUMN id_professor INT;
ALTER TABLE cursos ADD CONSTRAINT fk_professor FOREIGN KEY (id_professor) REFERENCES professores(id_professor);

-- ======================================
-- INSERÇÃO DE DADOS (CREATE)
-- ======================================

-- Professores
INSERT INTO professores (nome, especialidade) VALUES
('Carlos Souza', 'Matemática'),
('Ana Lima', 'História'),
('João Pereira', 'Programação'),
('Mariana Alves', 'Física');

-- Cursos
INSERT INTO cursos (nome, carga_horaria, id_professor) VALUES
('Matemática Básica', 40, 1),
('História do Brasil', 60, 2),
('Introdução à Programação', 80, 3),
('Física Experimental', 50, 4);

-- Alunos
INSERT INTO alunos (nome, idade, email) VALUES
('Pedro Santos', 20, 'pedro@email.com'),
('Maria Silva', 22, 'maria@email.com'),
('Lucas Oliveira', 19, 'lucas@email.com'),
('Juliana Costa', 21, 'juliana@email.com'),
('Fernanda Lima', 23, 'fernanda@email.com'),
('André Souza', 20, 'andre@email.com'),
('Camila Rocha', 24, 'camila@email.com'),
('Bruno Martins', 22, 'bruno@email.com'),
('Patrícia Gomes', 21, 'patricia@email.com'),
('Ricardo Alves', 25, 'ricardo@email.com');

-- Associação Alunos ↔ Cursos
INSERT INTO alunos_cursos (id_aluno, id_curso) VALUES
(1, 1), (1, 3),
(2, 2), (2, 3),
(3, 1), (3, 4),
(4, 2),
(5, 3),
(6, 1), (6, 4),
(7, 2),
(8, 4),
(9, 1), (9, 2), (9, 3),
(10, 4);

-- ======================================
-- CONSULTAS (READ)
-- ======================================

-- Lista todos os alunos
SELECT * FROM alunos;

-- Lista todos os cursos com seus professores
SELECT c.nome AS curso, p.nome AS professor
FROM cursos c
JOIN professores p ON c.id_professor = p.id_professor;

-- Lista alunos e os cursos em que estão matriculados
SELECT a.nome AS aluno, c.nome AS curso
FROM alunos a
JOIN alunos_cursos ac ON a.id_aluno = ac.id_aluno
JOIN cursos c ON ac.id_curso = c.id_curso
ORDER BY a.nome;

-- Quantos alunos há em cada curso
SELECT c.nome AS curso, COUNT(ac.id_aluno) AS total_alunos
FROM cursos c
LEFT JOIN alunos_cursos ac ON c.id_curso = ac.id_curso
GROUP BY c.id_curso;

-- ======================================
-- ATUALIZAÇÃO DE DADOS (UPDATE)
-- ======================================

-- Atualizar email de um aluno
UPDATE alunos SET email = 'pedro.santos@email.com'
WHERE id_aluno = 1;

-- Atualizar professor de um curso
UPDATE cursos SET id_professor = 2
WHERE id_curso = 3;

-- ======================================
-- EXCLUSÃO DE DADOS (DELETE)
-- ======================================

-- Remover um aluno de um curso
DELETE FROM alunos_cursos WHERE id_aluno = 1 AND id_curso = 3;

-- Remover um aluno completamente
DELETE FROM alunos WHERE id_aluno = 10;

-- Remover um curso (isso também remove as associações automaticamente)
DELETE FROM cursos WHERE id_curso = 4;

