-- ======================================
-- CONSULTAS PARA RELATÓRIOS DE CONFORMIDADE
-- ======================================

-- 1. Verificar conformidade de uma ambulância específica (ex.: ID 1)
SELECT
    a.placa,
    n.tipo,
    n.codigo,
    rn.descricao AS requisito,
    c.status,
    c.data_verificacao,
    c.observacoes,
    u.nome AS verificado_por
FROM conformidade c
JOIN requisito_norma rn ON c.requisito_id = rn.id
JOIN norma n ON rn.norma_id = n.id
LEFT JOIN usuario u ON c.verificado_por = u.id
WHERE c.entidade_tipo = 'ambulancia' AND c.entidade_id = 1
ORDER BY n.tipo, rn.descricao;

-- 2. Listar equipamentos de uma ambulância com status de conformidade
SELECT
    e.tipo,
    e.modelo,
    e.numero_serie,
    e.status AS status_equipamento,
    n.tipo AS norma_tipo,
    rn.descricao AS requisito,
    c.status AS status_conformidade
FROM equipamento e
LEFT JOIN conformidade c ON c.entidade_tipo = 'equipamento' AND c.entidade_id = e.id
LEFT JOIN requisito_norma rn ON c.requisito_id = rn.id
LEFT JOIN norma n ON rn.norma_id = n.id
WHERE e.ambulancia_id = 1
ORDER BY e.tipo;

-- 3. Relatório de auditorias por entidade
SELECT
    an.entidade_tipo,
    CASE
        WHEN an.entidade_tipo = 'ambulancia' THEN (SELECT placa FROM ambulancia WHERE id = an.entidade_id)
        WHEN an.entidade_tipo = 'hospital' THEN (SELECT nome FROM hospital WHERE id = an.entidade_id)
        WHEN an.entidade_tipo = 'equipamento' THEN (SELECT tipo FROM equipamento WHERE id = an.entidade_id)
    END AS entidade_nome,
    an.data_auditoria,
    an.resultado,
    an.relatorio,
    u.nome AS auditor
FROM auditoria_normas an
LEFT JOIN usuario u ON an.auditor_id = u.id
ORDER BY an.data_auditoria DESC;

-- 4. Contar requisitos não conformes por norma
SELECT
    n.tipo,
    n.codigo,
    COUNT(*) AS total_requisitos,
    SUM(CASE WHEN c.status = 'nao_conforme' THEN 1 ELSE 0 END) AS nao_conformes,
    SUM(CASE WHEN c.status = 'pendente' THEN 1 ELSE 0 END) AS pendentes
FROM norma n
JOIN requisito_norma rn ON n.id = rn.norma_id
LEFT JOIN conformidade c ON rn.id = c.requisito_id
GROUP BY n.id, n.tipo, n.codigo
ORDER BY n.tipo;

-- 5. Equipamentos que precisam de manutenção (status 'manutencao' ou sem conformidade)
SELECT
    e.id,
    e.tipo,
    e.modelo,
    e.numero_serie,
    e.data_aquisicao,
    e.status,
    CASE
        WHEN e.ambulancia_id IS NOT NULL THEN 'Ambulância: ' || (SELECT placa FROM ambulancia WHERE id = e.ambulancia_id)
        WHEN e.hospital_id IS NOT NULL THEN 'Hospital: ' || (SELECT nome FROM hospital WHERE id = e.hospital_id)
    END AS associado_a
FROM equipamento e
WHERE e.status = 'manutencao'
   OR e.id NOT IN (SELECT entidade_id FROM conformidade WHERE entidade_tipo = 'equipamento' AND status = 'conforme')
ORDER BY e.status, e.data_aquisicao;

-- 6. Normas ativas com seus requisitos
SELECT
    n.tipo,
    n.codigo,
    n.descricao AS norma_descricao,
    rn.categoria,
    rn.descricao AS requisito_descricao,
    rn.obrigatorio,
    rn.aplicavel_a
FROM norma n
JOIN requisito_norma rn ON n.id = rn.norma_id
WHERE n.ativo = true
ORDER BY n.tipo, rn.categoria, rn.descricao;
