# MedLink — Relatório de QA do protótipo (07/10/2026)

Escopo: protótipo web do Vitor (Spring Boot + HTML/JS + PostgreSQL), branch `demo/visual-pitch`
(= `copilot/improve-visual-design` + `main` + correções desta rodada). Dados 100% fictícios.

## Resultado em uma frase

O protótipo que rodava antes (`main`) tinha dashboard com **números inventados**, 4 telas de mapa quebradas
(chave do Google inválida) e 3 erros de JavaScript. Depois da rodada: **19/19 telas carregam sem erro**,
**22/23 → 23/23 verificações ponta a ponta passam** e o dashboard mostra dados reais do banco.

## O que foi testado

| Camada | Como | Resultado |
|---|---|---|
| Telas (19 páginas) | Varredura com Playwright/Chromium: status HTTP, erros de console, requisições falhas, captura | Antes: 7 páginas com erro. Depois: 0 |
| Fluxos de usuário (23 verificações) | Login errado/certo, dashboard, menu, agenda (marcar atendido), cadastro de paciente pelo formulário, mapa, filtro, rastreio, painel do motorista, chatbot | 23/23 passam |
| Responsivo | 14 telas em 375 px (celular), checando rolagem horizontal | 14/14 sem estouro |
| API REST | `curl` em GET/POST/PUT/DELETE de pacientes, motoristas, veículos, hospitais, usuários, login, ids inexistentes, JSON inválido | 2 bugs corrigidos, 4 limitações registradas (abaixo) |

Capturas: `docs/qa/telas/` e `docs/qa/dashboard_antes_depois.png`.

## Problemas encontrados e corrigidos

| # | Problema | Correção |
|---|---|---|
| 1 | **Dashboard com números fixos no código** (247 clientes, 32 motoristas…), sem relação com o banco | Novo endpoint `GET /api/dashboard/stats`; dashboard redesenhado, atualiza a cada 15 s |
| 2 | `/api/dashboard/stats` e `/clientes/estatisticas` inexistentes (404/400) | Endpoints criados |
| 3 | `PUT /clientes/{id}/atender` **não existia** — botão "Marcar como atendido" da Agenda falhava em silêncio | Endpoint criado; testado pela interface |
| 4 | `GET /usuarios` devolvia o **hash da senha** de todos os usuários | `senha` marcada como somente-escrita (`WRITE_ONLY`) |
| 5 | Chart.js ausente em `client_management` e `grafico` (`Chart is not defined`) | Biblioteca incluída |
| 6 | 4 telas de mapa quebradas (`ApiNotActivatedMapError` / `InvalidKeyMapError`), **2 chaves do Google hardcoded no repositório** | Telas refeitas com Leaflet + OpenStreetMap (sem chave); chaves removidas do código |
| 7 | Cadastro de paciente aceitava nome vazio | `POST /clientes` agora responde 400 |
| 8 | Seed (`data.sql`) referenciava tabelas inexistentes e dados não coerentes com o produto | Novo seed: 3 usuários, 5 destinos, 5 motoristas, 6 veículos, 20 pacientes do dia |
| 9 | Interface em roxo/gradientes, título ilegível, login com texto invisível, cards laranja/rosa na agenda, nome "MediLink"/"Admin User" | Tema único `medlink-theme.css` (azul-marinho + azul-céu, igual ao pitch), login e home refeitos |
| 10 | Tabelas estouravam a largura no celular | Rolagem interna nas tabelas |
| 11 | Página "Sobre" prometia "rastreamento GPS em tempo real" | Texto ajustado para o que existe |

## Telas novas / refeitas

- **Dashboard "Operação de hoje"**: 5 indicadores, 5 gráficos, próximas saídas — tudo vindo do banco.
- **Mapa da frota**: veículos por status (em rota / disponível / manutenção), filtro, lista lateral, atualização a cada 10 s.
- **Rastreio do paciente**: simulação do veículo se aproximando do paciente (distância, tempo, etapas).
- **Painel do motorista**: paradas do dia em ordem de horário; "Embarcou" grava no cadastro do paciente.
- **Login** em duas colunas e **Home** com atalhos.

## Limitações conhecidas (honestas — não esconder na apresentação)

1. **Sem controle de acesso real.** Todas as rotas estão `permitAll`; o login gera um token que o servidor não exige. Para produção: JWT validado + perfis ADMIN/AGENTE/MOTORISTA.
2. **Segredo do JWT fixo no código** e senha do banco no `application.properties` (uso local). Mover para variáveis de ambiente.
3. **Spring Boot 4.0.0-M2** (versão *milestone*) — migrar para versão estável.
4. **Sem validação de unicidade**: placa, CNH e cartão duplicados são aceitos (e-mail de usuário duplicado já é bloqueado).
5. **`PUT /clientes/{id}` substitui o registro inteiro**: enviar só `{"nome":"x"}` apaga os demais campos. Falta atualização parcial.
6. **Posições do mapa são de demonstração.** Veículos têm latitude/longitude cadastradas (não há GPS); pacientes não têm coordenadas — usamos posições aproximadas por bairro. Rastreio é simulação.
7. **Modelo `Chamado` é de emergência** (herança do projeto anterior), não de transporte eletivo; não aparece nas telas novas.
8. **Mapa depende de internet** (tiles do OpenStreetMap) — ter conexão na apresentação do dia 14/10.
9. **Sem testes automatizados no repositório.** Os scripts de QA desta rodada ficaram fora do repo; vale convertê-los em testes de regressão.

## Como reproduzir o demo

```bash
# banco
cd Spring/demo/demo && docker compose up -d
# aplicação (a cada início o seed é recarregado)
./mvnw -DskipTests package && java -jar target/demo-0.0.1-SNAPSHOT.jar
# http://localhost:8080/login.html   usuário: admin@test.com   senha: 123456
```

Usuários de teste (apenas ambiente local): `admin@test.com`, `agente@test.com`, `motorista@test.com` — senha `123456`.
