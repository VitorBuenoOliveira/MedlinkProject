# MedLink

**Gestão do transporte sanitário do SUS para prefeituras.**

Todo município é responsável por levar os pacientes do SUS até o tratamento: hemodiálise, quimioterapia, reabilitação, consultas e altas hospitalares. Esse é o **transporte sanitário eletivo** (Resolução CIT nº 13/2017): programado, de todo dia, feito com vans, carros, vans adaptadas e ambulâncias.

> ⚠️ **O MedLink não é um sistema de urgência/emergência (SAMU).** Ele organiza o transporte agendado e recorrente de pacientes, além das altas e voltas que surgem ao longo do plantão.

O projeto nasceu da experiência de um dos integrantes na central de ambulâncias de Hortolândia/SP, onde cerca de 300 pacientes por dia são organizados com e-mail, planilha impressa e papel recortado à mão.

## O protótipo (Projeto Integrador 2025)

Este repositório contém o **protótipo funcional** apresentado no Projeto Integrador de 2025:

- Cadastro de pacientes, motoristas, veículos e hospitais (destinos)
- Login com perfis de acesso (administrador, agente e motorista) usando JWT
- Agenda do dia com o status de cada paciente
- Mapa com a localização da frota
- Painel e relatórios com indicadores

**Tecnologias:** Java 22, Spring Boot 4 (milestone), Spring Security + JWT, Spring Data JPA, PostgreSQL, HTML/CSS/JavaScript.

## Próximos passos (2026)

O produto está sendo reconstruído a partir da operação real de uma central:

1. **Triagem:** indicar o veículo certo para cada paciente (van, carro, van adaptada ou ambulância)
2. **Planejamento:** montar as linhas fixas e encaixar os pacientes recorrentes, como os de hemodiálise
3. **Despacho:** um painel digital para o controlador do plantão, no lugar do papel
4. **Execução:** um app em que o motorista registra embarque, falta e quilometragem
5. **Indicadores:** ocupação, faltas e custo por paciente, inclusive do serviço terceirizado

## Como rodar

Pré-requisitos: **Java 22+** e **Docker**.

```bash
cd Spring/demo/demo

# 1. Banco de dados (PostgreSQL na porta 5432)
docker compose up -d postgres

# 2. Aplicação (porta 8080)
./mvnw spring-boot:run        # no Windows: mvnw.cmd spring-boot:run
```

Abra **http://localhost:8080/login.html** e entre com um dos usuários de teste:

| Perfil | E-mail | Senha |
|---|---|---|
| Administrador | `admin@test.com` | `123456` |
| Agente | `agente@test.com` | `123456` |
| Motorista | `motorista@test.com` | `123456` |

O arquivo `src/main/resources/data.sql` recria os dados de exemplo (todos fictícios) a cada inicialização.

Os mapas usam Leaflet + OpenStreetMap (sem chave de API, mas precisam de internet). O relatório de QA, com capturas de tela e limitações, está em [`docs/qa/RELATORIO_QA.md`](docs/qa/RELATORIO_QA.md).

## Limitações conhecidas

Por ser um protótipo acadêmico, ainda não está pronto para produção:

- as telas e a API estão liberadas sem autenticação (`permitAll`); o login só emite o token;
- a chave do JWT e as credenciais do banco estão fixas no código e no `compose.yml`, para uso local;
- usa uma versão milestone do Spring Boot 4.

## Equipe

Mateus Alves e Vitor Bueno, Engenharia de Computação.
