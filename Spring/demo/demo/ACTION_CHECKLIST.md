# ⚡ CHECKLIST DE AÇÃO RÁPIDA - Correções Prioritárias

## 🔴 CRÍTICO - Fazer HOJE (Bloqueadores de Produção)

### 1. Segurança - Password Encoder
- [ ] **Trocar NoOpPasswordEncoder por BCryptPasswordEncoder**
  - Arquivo: `SecurityConfig.java`
  - Linha: 48
  - Ação: Substituir `NoOpPasswordEncoder.getInstance()` por `new BCryptPasswordEncoder(12)`
  - Impacto: Senhas passam a ser criptografadas

### 2. Segurança - JWT Secret
- [ ] **Externalizar JWT secret**
  - Arquivo: `JwtUtil.java`
  - Ação: Adicionar `@Value("${jwt.secret}")` e configurar em `.env`
  - Comando: `openssl rand -base64 32` para gerar secret
  - Impacto: Secret não fica exposto no código

### 3. Segurança - Credenciais do Banco
- [ ] **Remover credenciais hardcoded**
  - Arquivo: `application.properties`
  - Ação: Usar `${DB_PASSWORD}` ao invés de senha em texto
  - Impacto: Credenciais não ficam no repositório

### 4. Segurança - Autenticação
- [ ] **Habilitar autenticação**
  - Arquivo: `SecurityConfig.java`
  - Linha: 36
  - Ação: Remover `.anyRequest().permitAll()` e configurar por roles
  - Impacto: Endpoints ficam protegidos

### 5. Versão do Spring Boot
- [ ] **Atualizar para versão estável**
  - Arquivo: `pom.xml`
  - Ação: Mudar de `4.0.0-M2` para `3.2.0` (estável)
  - Impacto: Aplicação fica estável para produção

---

## 🟠 ALTO - Fazer esta semana

### 6. Exception Handler
- [ ] **Criar GlobalExceptionHandler**
  - Criar: `exception/GlobalExceptionHandler.java`
  - Impacto: Erros tratados adequadamente

### 7. Camada de Service
- [ ] **Criar Services para cada Controller**
  - Criar: `service/AmbulanciaService.java`
  - Criar: `service/ClienteService.java`
  - Criar: `service/MotoristaService.java`
  - Criar: `service/HospitalService.java`
  - Impacto: Separação de responsabilidades (SOLID)

### 8. DTOs
- [ ] **Criar DTOs para request/response**
  - Criar: `dto/AmbulanciaDTO.java`
  - Criar: `dto/ClienteDTO.java`
  - Impacto: Entidades não ficam expostas

### 9. Enums
- [ ] **Converter Strings em Enums**
  - Criar: `model/enums/AmbulanciaStatus.java`
  - Criar: `model/enums/UsuarioRole.java`
  - Criar: `model/enums/PrioridadeSaude.java`
  - Impacto: Type safety, menos erros

### 10. Validações
- [ ] **Adicionar Bean Validation**
  - Adicionar: `@Valid`, `@NotNull`, `@Email`, etc.
  - Impacto: Validação de dados na entrada

---

## 🟡 MÉDIO - Fazer nas próximas 2 semanas

### 11. Relacionamentos JPA
- [ ] **Corrigir relacionamento Ambulancia-Motorista**
  - Arquivo: `Ambulancia.java`
  - Ação: Trocar `Long motoristaId` por `@ManyToOne Motorista motorista`

### 12. Consolidar Controllers
- [ ] **Unificar pacotes de controllers**
  - Ação: Mover tudo para `controllers/` (sem duplicação)

### 13. Profiles Spring
- [ ] **Criar profiles de ambiente**
  - Criar: `application-dev.properties`
  - Criar: `application-prod.properties`

### 14. Flyway
- [ ] **Implementar migrations**
  - Adicionar: dependência Flyway
  - Criar: `db/migration/V1__create_initial_schema.sql`

### 15. OpenAPI/Swagger
- [ ] **Documentar API**
  - Adicionar: dependência springdoc-openapi
  - Criar: `OpenApiConfig.java`

### 16. Testes
- [ ] **Implementar testes unitários e de integração**
  - Criar: `AmbulanciaServiceTest.java`
  - Criar: `AmbulanciaControllerTest.java`

---

## 🔵 BAIXO - Melhorias futuras

### 17. Docker
- [ ] Criar Dockerfile
- [ ] Criar docker-compose.yml

### 18. Logging
- [ ] Configurar logback-spring.xml
- [ ] Adicionar logs estruturados

### 19. Monitoring
- [ ] Configurar Spring Actuator
- [ ] Adicionar health checks

### 20. Cache
- [ ] Implementar cache com Redis (se necessário)

---

## 📊 Progresso Geral

**Crítico:** 0/5 ⬜⬜⬜⬜⬜  
**Alto:** 0/5 ⬜⬜⬜⬜⬜  
**Médio:** 0/6 ⬜⬜⬜⬜⬜⬜  
**Baixo:** 0/4 ⬜⬜⬜⬜  

**Total:** 0/20 (0%)

---

## 🎯 Meta por Sprint

### Sprint 1 (Semana 1-2): Segurança
- Completar todos os 5 itens CRÍTICOS
- Meta: 5/5 ✅

### Sprint 2 (Semana 3-4): Arquitetura
- Completar itens 6-10 (ALTO)
- Meta: 5/5 ✅

### Sprint 3 (Semana 5-6): Qualidade
- Completar itens 11-16 (MÉDIO)
- Meta: 6/6 ✅

### Sprint 4 (Semana 7-8): Deploy
- Completar itens 17-20 (BAIXO)
- Meta: 4/4 ✅

---

## 💡 Dicas

1. **NÃO pule os itens CRÍTICOS** - São bloqueadores de produção
2. **Teste após cada mudança** - Use `mvn test` frequentemente
3. **Faça commits pequenos** - Facilita rollback se necessário
4. **Leia o CODE_REVIEW.md completo** - Tem exemplos de código
5. **Use o MIGRATION_GUIDE.md** - Tem passo a passo detalhado

---

## 📁 Arquivos de Referência

- `CODE_REVIEW.md` - Análise completa com código corrigido
- `MIGRATION_GUIDE.md` - Guia passo a passo de migração
- `.env.example` - Template de variáveis de ambiente

---

**Última atualização:** 06/11/2025  
**Próxima revisão:** Após completar Sprint 1
