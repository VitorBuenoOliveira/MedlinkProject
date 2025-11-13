# 🚀 GUIA DE MIGRAÇÃO - Correções Críticas

Este documento fornece um roteiro passo a passo para implementar as correções mais críticas identificadas na revisão de código.

## 📋 ÍNDICE

1. [Preparação do Ambiente](#1-preparação-do-ambiente)
2. [Correções Críticas de Segurança](#2-correções-críticas-de-segurança)
3. [Refatoração de Arquitetura](#3-refatoração-de-arquitetura)
4. [Melhorias de Qualidade](#4-melhorias-de-qualidade)
5. [Testes](#5-testes)
6. [Deploy](#6-deploy)

---

## 1. Preparação do Ambiente

### 1.1. Backup do Banco de Dados

```bash
# Faça backup do banco antes de qualquer mudança
pg_dump -U ambulancia_user -d ambulancia > backup_$(date +%Y%m%d).sql
```

### 1.2. Criar Branch de Desenvolvimento

```bash
git checkout -b refactor/security-improvements
```

### 1.3. Configurar Variáveis de Ambiente

```bash
# Copiar template
cp .env.example .env

# Gerar JWT Secret seguro
openssl rand -base64 32

# Editar .env com suas credenciais
nano .env
```

### 1.4. Atualizar .gitignore

Adicionar ao `.gitignore` existente:

```
# Arquivos de ambiente
.env
.env.*
!.env.example

# Dados sensíveis
secrets/
*.key
*.pem
```

---

## 2. Correções Críticas de Segurança

### 2.1. Trocar NoOpPasswordEncoder por BCrypt

**PRIORIDADE: 🔴 CRÍTICA**

#### Passo 1: Atualizar SecurityConfig.java

```java
@Bean
public PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder(12);
}
```

#### Passo 2: Migrar Senhas Existentes

Criar script de migração `MigrarSenhas.java`:

```java
package com.seuprojeto.demo.migration;

import com.seuprojeto.demo.model.Usuario;
import com.seuprojeto.demo.repository.UsuarioRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
public class PasswordMigration {

    @Bean
    CommandLineRunner migrateSenhas(UsuarioRepository usuarioRepository, 
                                    PasswordEncoder passwordEncoder) {
        return args -> {
            // ATENÇÃO: Executar apenas uma vez!
            // Comentar após primeira execução
            
            usuarioRepository.findAll().forEach(usuario -> {
                // Apenas migrar se ainda não estiver em BCrypt
                if (!usuario.getSenha().startsWith("$2a$")) {
                    String senhaCriptografada = passwordEncoder.encode(usuario.getSenha());
                    usuario.setSenha(senhaCriptografada);
                    usuarioRepository.save(usuario);
                    System.out.println("Senha migrada para: " + usuario.getEmail());
                }
            });
        };
    }
}
```

**⚠️ IMPORTANTE:** Comentar ou remover este bean após primeira execução!

### 2.2. Externalizar JWT Secret

#### Passo 1: Atualizar application.properties

```properties
# JWT Configuration
jwt.secret=${JWT_SECRET}
jwt.expiration=${JWT_EXPIRATION:86400000}
```

#### Passo 2: Atualizar JwtUtil.java

```java
@Component
public class JwtUtil {

    @Value("${jwt.secret}")
    private String secret;
    
    @Value("${jwt.expiration}")
    private long jwtExpiration;
    
    // ... resto do código
}
```

#### Passo 3: Configurar Variável de Ambiente

```bash
# .env
JWT_SECRET=$(openssl rand -base64 32)
```

### 2.3. Externalizar Credenciais do Banco

#### Passo 1: Atualizar application.properties

```properties
spring.datasource.url=${DB_URL:jdbc:postgresql://localhost:5432/ambulancia}
spring.datasource.username=${DB_USERNAME:ambulancia_user}
spring.datasource.password=${DB_PASSWORD}
```

#### Passo 2: Configurar .env

```bash
DB_URL=jdbc:postgresql://localhost:5432/ambulancia
DB_USERNAME=ambulancia_user
DB_PASSWORD=sua_senha_segura_aqui
```

### 2.4. Configurar Autenticação Adequada

#### Passo 1: Atualizar SecurityConfig.java

```java
.authorizeHttpRequests(authz -> authz
    // Endpoints públicos
    .requestMatchers("/auth/login", "/auth/register").permitAll()
    
    // Endpoints protegidos
    .requestMatchers("/usuarios/**").hasRole("ADMIN")
    .requestMatchers("/ambulancias/**").hasAnyRole("ADMIN", "AGENTE")
    .requestMatchers("/motoristas/**").hasAnyRole("ADMIN", "AGENTE")
    .requestMatchers("/hospitais/**").hasAnyRole("ADMIN", "AGENTE")
    .requestMatchers("/clientes/**").hasAnyRole("ADMIN", "AGENTE")
    
    .anyRequest().authenticated()
)
```

#### Passo 2: Testar Autenticação

```bash
# Login
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@test.com","senha":"123456"}'

# Usar token retornado
curl -X GET http://localhost:8080/ambulancias \
  -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

### 2.5. Atualizar Spring Boot para Versão Estável

#### Passo 1: Atualizar pom.xml

```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.2.0</version> <!-- Versão estável -->
    <relativePath/>
</parent>

<properties>
    <java.version>21</java.version> <!-- ou 17 LTS -->
</properties>
```

#### Passo 2: Rebuild

```bash
mvn clean install
```

---

## 3. Refatoração de Arquitetura

### 3.1. Criar Estrutura de Pacotes

```bash
mkdir -p src/main/java/com/seuprojeto/demo/{dto,service,exception}
mkdir -p src/main/java/com/seuprojeto/demo/dto/{request,response}
mkdir -p src/main/java/com/seuprojeto/demo/model/enums
```

### 3.2. Criar Enums

Criar arquivo `src/main/java/com/seuprojeto/demo/model/enums/AmbulanciaStatus.java`:

```java
package com.seuprojeto.demo.model.enums;

public enum AmbulanciaStatus {
    DISPONIVEL("disponivel"),
    EM_USO("em_uso"),
    MANUTENCAO("manutencao");

    private final String valor;

    AmbulanciaStatus(String valor) {
        this.valor = valor;
    }

    public String getValor() {
        return valor;
    }
}
```

Repetir para `UsuarioRole`, `PrioridadeSaude`, etc.

### 3.3. Atualizar Entidades

#### Ambulancia.java

```java
@Enumerated(EnumType.STRING)
@Column(nullable = false)
private AmbulanciaStatus status = AmbulanciaStatus.DISPONIVEL;

@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "motorista_id")
private Motorista motorista;
```

### 3.4. Criar DTOs

Exemplo para `AmbulanciaDTO.java`:

```java
package com.seuprojeto.demo.dto;

import com.seuprojeto.demo.model.enums.AmbulanciaStatus;
import jakarta.validation.constraints.*;

public class AmbulanciaDTO {
    
    private Long id;
    
    @NotBlank
    @Pattern(regexp = "[A-Z]{3}-[0-9]{4}")
    private String placa;
    
    @NotBlank
    private String modelo;
    
    @NotNull
    @Min(1)
    @Max(20)
    private Integer capacidade;
    
    @NotNull
    private AmbulanciaStatus status;
    
    private Long motoristaId;
    
    @DecimalMin("-90.0")
    @DecimalMax("90.0")
    private Double latitude;
    
    @DecimalMin("-180.0")
    @DecimalMax("180.0")
    private Double longitude;

    // Constructors, Getters, Setters
}
```

### 3.5. Criar Services

Exemplo para `AmbulanciaService.java`:

```java
package com.seuprojeto.demo.service;

@Service
@Transactional(readOnly = true)
public class AmbulanciaService {

    private final AmbulanciaRepository ambulanciaRepository;
    private final MotoristaRepository motoristaRepository;

    public AmbulanciaService(AmbulanciaRepository ambulanciaRepository, 
                            MotoristaRepository motoristaRepository) {
        this.ambulanciaRepository = ambulanciaRepository;
        this.motoristaRepository = motoristaRepository;
    }

    public List<AmbulanciaDTO> listarTodas() {
        return ambulanciaRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public AmbulanciaDTO criar(AmbulanciaDTO dto) {
        Ambulancia ambulancia = convertToEntity(dto);
        Ambulancia saved = ambulanciaRepository.save(ambulancia);
        return convertToDTO(saved);
    }

    // Métodos privados de conversão
    private AmbulanciaDTO convertToDTO(Ambulancia ambulancia) {
        // Conversão
    }

    private Ambulancia convertToEntity(AmbulanciaDTO dto) {
        // Conversão
    }
}
```

### 3.6. Refatorar Controllers

```java
@RestController
@RequestMapping("/api/v1/ambulancias")
public class AmbulanciaController {

    private final AmbulanciaService ambulanciaService;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'AGENTE')")
    public ResponseEntity<List<AmbulanciaDTO>> listar() {
        return ResponseEntity.ok(ambulanciaService.listarTodas());
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AmbulanciaDTO> criar(@Valid @RequestBody AmbulanciaDTO dto) {
        AmbulanciaDTO created = ambulanciaService.criar(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }
}
```

### 3.7. Criar Exception Handler Global

```java
package com.seuprojeto.demo.exception;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ErrorResponse handleResourceNotFound(ResourceNotFoundException ex) {
        return new ErrorResponse(
                HttpStatus.NOT_FOUND.value(),
                ex.getMessage(),
                LocalDateTime.now()
        );
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ValidationErrorResponse handleValidationExceptions(
            MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach((error) -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            errors.put(fieldName, errorMessage);
        });
        
        return new ValidationErrorResponse(
                HttpStatus.BAD_REQUEST.value(),
                "Erro de validação",
                errors,
                LocalDateTime.now()
        );
    }

    public record ErrorResponse(int status, String message, LocalDateTime timestamp) {}
    
    public record ValidationErrorResponse(int status, String message, 
                                         Map<String, String> errors, 
                                         LocalDateTime timestamp) {}
}
```

### 3.8. Consolidar Pacotes de Controllers

```bash
# Mover todos os controllers para um único pacote
mv src/main/java/com/seuprojeto/demo/controller/* \
   src/main/java/com/seuprojeto/demo/controllers/
   
# Remover pacote antigo
rm -rf src/main/java/com/seuprojeto/demo/controller
```

---

## 4. Melhorias de Qualidade

### 4.1. Adicionar Dependências de Validação

Já incluído no `spring-boot-starter-web`, mas verificar:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
</dependency>
```

### 4.2. Adicionar Bean Validation nas Entidades

```java
@Entity
public class Usuario {
    
    @NotBlank(message = "Nome é obrigatório")
    @Size(min = 3, max = 255)
    private String nome;
    
    @NotBlank
    @Email(message = "Email inválido")
    private String email;
    
    // ...
}
```

### 4.3. Configurar Flyway para Migrations

#### Adicionar dependência:

```xml
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-core</artifactId>
</dependency>
```

#### Criar estrutura:

```bash
mkdir -p src/main/resources/db/migration
```

#### Criar migration inicial:

`V1__create_initial_schema.sql`:

```sql
-- Copiar conteúdo de schema.sql
```

#### Atualizar application.properties:

```properties
spring.jpa.hibernate.ddl-auto=validate
spring.flyway.enabled=true
spring.flyway.baseline-on-migrate=true
```

### 4.4. Adicionar Documentação OpenAPI

#### Adicionar dependência:

```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.2.0</version>
</dependency>
```

#### Configurar:

```java
@Configuration
public class OpenApiConfig {
    
    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Medlink Ambulance API")
                        .version("1.0")
                        .description("API para gerenciamento de ambulâncias"));
    }
}
```

Acessar: `http://localhost:8080/swagger-ui.html`

---

## 5. Testes

### 5.1. Adicionar Dependências de Teste

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.springframework.security</groupId>
    <artifactId>spring-security-test</artifactId>
    <scope>test</scope>
</dependency>
```

### 5.2. Criar Testes de Integração

```java
@SpringBootTest
@AutoConfigureMockMvc
class AmbulanciaControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @Test
    @WithMockUser(roles = "ADMIN")
    void deveCriarAmbulancia() throws Exception {
        String json = """
            {
                "placa": "ABC-1234",
                "modelo": "Fiat Ducato",
                "capacidade": 4,
                "status": "DISPONIVEL"
            }
            """;
        
        mockMvc.perform(post("/api/v1/ambulancias")
                .contentType(MediaType.APPLICATION_JSON)
                .content(json))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.placa").value("ABC-1234"));
    }
}
```

### 5.3. Executar Testes

```bash
mvn test
```

---

## 6. Deploy

### 6.1. Criar Dockerfile

```dockerfile
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### 6.2. Criar docker-compose.yml

```yaml
version: '3.8'
services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: ${DB_NAME:-ambulancia}
      POSTGRES_USER: ${DB_USERNAME:-ambulancia_user}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ambulancia_user"]
      interval: 10s
      timeout: 5s
      retries: 5

  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      DB_URL: jdbc:postgresql://postgres:5432/${DB_NAME:-ambulancia}
      DB_USERNAME: ${DB_USERNAME:-ambulancia_user}
      DB_PASSWORD: ${DB_PASSWORD}
      JWT_SECRET: ${JWT_SECRET}
      SPRING_PROFILES_ACTIVE: ${SPRING_PROFILES_ACTIVE:-prod}
    depends_on:
      postgres:
        condition: service_healthy
    restart: unless-stopped

volumes:
  postgres_data:
```

### 6.3. Build e Deploy

```bash
# Build da aplicação
mvn clean package -DskipTests

# Build do Docker
docker build -t medlink-ambulance:latest .

# Iniciar serviços
docker-compose up -d

# Ver logs
docker-compose logs -f app
```

---

## ✅ Checklist Final

### Segurança
- [ ] BCrypt implementado
- [ ] JWT secret externalizado
- [ ] Credenciais do banco externalizadas
- [ ] Autenticação configurada corretamente
- [ ] CORS configurado adequadamente
- [ ] Spring Boot atualizado para versão estável

### Arquitetura
- [ ] Camada de Service criada
- [ ] DTOs implementados
- [ ] Enums criados
- [ ] Relacionamentos JPA corrigidos
- [ ] Exception Handler global implementado
- [ ] Pacotes consolidados

### Qualidade
- [ ] Validações adicionadas
- [ ] Flyway configurado
- [ ] OpenAPI documentado
- [ ] Testes implementados
- [ ] Logging configurado

### Deploy
- [ ] Dockerfile criado
- [ ] docker-compose.yml criado
- [ ] Variáveis de ambiente configuradas
- [ ] Healthcheck implementado

---

## 📞 Suporte

Em caso de dúvidas:
1. Consultar o `CODE_REVIEW.md` completo
2. Verificar logs da aplicação
3. Consultar documentação do Spring Boot

**Boa sorte! 🚀**
