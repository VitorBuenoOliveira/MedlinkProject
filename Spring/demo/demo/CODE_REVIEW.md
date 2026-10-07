# 🔍 REVISÃO COMPLETA DE CÓDIGO - MedlinkProject

**Data:** 06 de Novembro de 2025  
**Revisor:** GitHub Copilot  
**Projeto:** Sistema de Gerenciamento de Transporte de Pacientes (Ambulâncias)

---

## 📋 SUMÁRIO EXECUTIVO

Este documento apresenta uma análise detalhada do código do projeto MedlinkProject, identificando problemas críticos de segurança, violações de princípios SOLID, más práticas de Spring Boot, e sugestões de refatoração.

**Status Geral:** ⚠️ **CRÍTICO** - Múltiplos problemas de segurança e arquitetura necessitam correção imediata antes de produção.

---

## 🚨 PROBLEMAS POR SEVERIDADE

### 🔴 CRÍTICO (Impedem produção)

1. **[SEC-001] NoOpPasswordEncoder - Senhas em texto plano**
   - **Arquivo:** `SecurityConfig.java`
   - **Linha:** 48
   - **Descrição:** Uso de `NoOpPasswordEncoder.getInstance()` armazena senhas sem criptografia
   - **Impacto:** CRÍTICO - Violação grave de segurança, senhas expostas
   - **Severidade:** 🔴 BLOQUEADOR

2. **[SEC-002] Secret JWT hardcoded**
   - **Arquivo:** `JwtUtil.java`
   - **Linha:** 18
   - **Descrição:** Secret key em código-fonte: `"mySecretKeyForJwtTokenGenerationThatIsLongEnough"`
   - **Impacto:** CRÍTICO - Comprometimento total da autenticação JWT
   - **Severidade:** 🔴 BLOQUEADOR

3. **[SEC-003] Credenciais do banco no código**
   - **Arquivo:** `application.properties`
   - **Linhas:** 3-5
   - **Descrição:** Senha do banco em texto plano no repositório
   - **Impacto:** CRÍTICO - Exposição de credenciais
   - **Severidade:** 🔴 BLOQUEADOR

4. **[SEC-004] Autenticação completamente desabilitada**
   - **Arquivo:** `SecurityConfig.java`
   - **Linha:** 36
   - **Descrição:** `.anyRequest().permitAll()` permite acesso sem autenticação
   - **Impacto:** CRÍTICO - Qualquer pessoa pode acessar todos os endpoints
   - **Severidade:** 🔴 BLOQUEADOR

5. **[SEC-005] CSRF desabilitado sem justificativa**
   - **Arquivo:** `SecurityConfig.java`
   - **Linha:** 35
   - **Descrição:** CSRF completamente desabilitado
   - **Impacto:** ALTO - Vulnerável a ataques CSRF
   - **Severidade:** 🔴 CRÍTICO

6. **[DATA-001] Dados hardcoded no data.sql**
   - **Arquivo:** `data.sql`
   - **Linhas:** 8-10
   - **Descrição:** Senhas BCrypt commitadas no repositório (mesmo criptografadas, não é boa prática)
   - **Impacto:** MÉDIO - Facilita ataques de força bruta
   - **Severidade:** 🟡 ALTO

### 🟠 ALTO (Afetam qualidade e manutenibilidade)

7. **[ARCH-001] Ausência de camada de Service**
   - **Arquivos:** Todos os Controllers
   - **Descrição:** Lógica de negócio diretamente nos controllers, violando SRP
   - **Impacto:** ALTO - Dificuldade de manutenção e testes
   - **Severidade:** 🟠 ALTO

8. **[ARCH-002] Duplicação de controllers**
   - **Arquivos:** `controller/UsuarioController.java` e `controllers/` (pacote duplicado)
   - **Descrição:** Dois pacotes diferentes para controllers
   - **Impacto:** ALTO - Confusão, duplicação de código
   - **Severidade:** 🟠 ALTO

9. **[SOLID-001] Violação do Single Responsibility Principle**
   - **Arquivo:** `ClienteController.java`
   - **Linhas:** 47-66
   - **Descrição:** Método `updateCliente` com 20+ atribuições manuais
   - **Impacto:** ALTO - Difícil manutenção, alta complexidade ciclomática
   - **Severidade:** 🟠 ALTO

10. **[API-001] Falta de validação de entrada**
    - **Arquivos:** Todos os controllers
    - **Descrição:** Nenhuma validação com `@Valid`, `@NotNull`, etc.
    - **Impacto:** ALTO - Dados inválidos podem entrar no sistema
    - **Severidade:** 🟠 ALTO

11. **[API-002] Retornos inconsistentes**
    - **Arquivos:** Vários controllers
    - **Descrição:** Alguns retornam `ResponseEntity`, outros retornam entidades diretamente
    - **Impacto:** MÉDIO - API inconsistente
    - **Severidade:** 🟠 ALTO

12. **[ERROR-001] Tratamento de exceções inadequado**
    - **Arquivos:** Controllers (AmbulanciaController, MotoristaController, HospitalController)
    - **Descrição:** `RuntimeException` genéricas, sem handler global
    - **Impacto:** ALTO - Mensagens de erro expostas, stack traces vazados
    - **Severidade:** 🟠 ALTO

### 🟡 MÉDIO (Melhorias importantes)

13. **[MODEL-001] Entidades anêmicas**
    - **Arquivos:** Todas as entidades em `model/`
    - **Descrição:** Apenas getters/setters, sem lógica de domínio
    - **Impacto:** MÉDIO - Design pobre de domínio
    - **Severidade:** 🟡 MÉDIO

14. **[MODEL-002] Uso de Strings para enums**
    - **Arquivos:** `Usuario.java` (role), `Ambulancia.java` (status), `Cliente.java` (múltiplos campos)
    - **Descrição:** Campos como `status`, `role` deveriam ser enums
    - **Impacto:** MÉDIO - Validação fraca, propenso a erros
    - **Severidade:** 🟡 MÉDIO

15. **[DB-001] Relacionamento incorreto Ambulancia-Motorista**
    - **Arquivo:** `Ambulancia.java`
    - **Linha:** 16
    - **Descrição:** `Long motoristaId` ao invés de `@ManyToOne`
    - **Impacto:** MÉDIO - Perde benefícios de JPA, queries ineficientes
    - **Severidade:** 🟡 MÉDIO

16. **[DTO-001] Exposição de entidades diretamente**
    - **Arquivos:** Todos os controllers
    - **Descrição:** Retornam entidades JPA diretamente ao cliente
    - **Impacto:** MÉDIO - Expõe estrutura interna, problemas de serialização
    - **Severidade:** 🟡 MÉDIO

17. **[NAMING-001] Nome genérico do projeto**
    - **Arquivo:** `pom.xml`, package `com.seuprojeto.demo`
    - **Descrição:** "demo" e "seuprojeto" são nomes genéricos
    - **Impacto:** BAIXO - Falta de profissionalismo
    - **Severidade:** 🟡 MÉDIO

18. **[CONFIG-001] Configuração de ambiente misturada**
    - **Arquivo:** `application.properties`
    - **Descrição:** Apenas um arquivo de propriedades, sem perfis
    - **Impacato:** MÉDIO - Dificulta deployment em diferentes ambientes
    - **Severidade:** 🟡 MÉDIO

### 🔵 BAIXO (Boas práticas)

19. **[CODE-001] Falta de documentação**
    - **Arquivos:** Todos
    - **Descrição:** Sem Javadoc, sem comentários explicativos
    - **Impacto:** BAIXO - Dificulta compreensão
    - **Severidade:** 🔵 BAIXO

20. **[CODE-002] Código morto no application.properties**
    - **Arquivo:** `application.properties`
    - **Linhas:** 17-24
    - **Descrição:** Configuração H2 comentada
    - **Impacto:** BAIXO - Poluição de código
    - **Severidade:** 🔵 BAIXO

21. **[TEST-001] Ausência de testes**
    - **Arquivo:** `DemoApplicationTests.java`
    - **Descrição:** Apenas teste padrão, sem cobertura real
    - **Impacto:** ALTO - Sem garantia de qualidade
    - **Severidade:** 🟡 MÉDIO

22. **[VERSION-001] Uso de versão Milestone do Spring Boot**
    - **Arquivo:** `pom.xml`
    - **Linha:** 7
    - **Descrição:** Spring Boot 4.0.0-M2 (Milestone, não estável)
    - **Impacto:** ALTO - Instabilidade em produção
    - **Severidade:** 🟠 ALTO

---

## 📁 ARQUIVOS QUE PRECISAM DE REVISÃO URGENTE

### Prioridade CRÍTICA ⚠️

1. **SecurityConfig.java** - Refazer completamente a configuração de segurança
2. **JwtUtil.java** - Externalizar secret, usar variáveis de ambiente
3. **application.properties** - Remover credenciais, usar perfis Spring

### Prioridade ALTA 🔥

4. **AuthController.java** - Adicionar rate limiting, melhorar tratamento de erros
5. **UsuarioController.java** - Consolidar com controllers/, adicionar service layer
6. **ClienteController.java** - Simplificar método update, adicionar validações
7. **AmbulanciaController.java** - Adicionar service, tratar exceções
8. **Todos os models** - Adicionar validações, converter Strings para Enums

### Prioridade MÉDIA 📋

9. **pom.xml** - Atualizar para versão estável do Spring Boot
10. **data.sql** - Remover dados de usuários hardcoded
11. **Todos os repositories** - Adicionar queries customizadas quando necessário

---

## 🛠️ CÓDIGO CORRIGIDO

### 1. SecurityConfig.java - VERSÃO CORRIGIDA

```java
package com.seuprojeto.demo.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.ProviderManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import com.seuprojeto.demo.filter.JwtAuthenticationFilter;
import com.seuprojeto.demo.service.UserDetailsServiceImpl;

import java.util.List;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

    private final UserDetailsServiceImpl userDetailsService;
    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    @Value("${app.security.cors.allowed-origins:http://localhost:3000}")
    private String[] allowedOrigins;

    public SecurityConfig(UserDetailsServiceImpl userDetailsService, 
                         JwtAuthenticationFilter jwtAuthenticationFilter) {
        this.userDetailsService = userDetailsService;
        this.jwtAuthenticationFilter = jwtAuthenticationFilter;
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // CSRF pode ser desabilitado para API REST stateless, mas com cuidado
            .csrf(AbstractHttpConfigurer::disable)
            
            // Configuração de CORS adequada
            .cors(cors -> cors.configure(http))
            
            // Autorização baseada em roles
            .authorizeHttpRequests(authz -> authz
                // Endpoints públicos
                .requestMatchers("/auth/login", "/auth/register").permitAll()
                .requestMatchers("/h2-console/**").permitAll() // Apenas desenvolvimento
                
                // Endpoints protegidos por role
                .requestMatchers("/usuarios/**").hasAnyRole("ADMIN")
                .requestMatchers("/ambulancias/**").hasAnyRole("ADMIN", "AGENTE")
                .requestMatchers("/motoristas/**").hasAnyRole("ADMIN", "AGENTE")
                .requestMatchers("/hospitais/**").hasAnyRole("ADMIN", "AGENTE")
                .requestMatchers("/clientes/**").hasAnyRole("ADMIN", "AGENTE")
                
                // Qualquer outra requisição precisa autenticação
                .anyRequest().authenticated()
            )
            
            // Stateless session
            .sessionManagement(sess -> sess.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            
            // Adiciona filtro JWT
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
            
            // Configurações para H2 Console (remover em produção)
            .headers(headers -> headers.frameOptions(frame -> frame.sameOrigin()));

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        // CRÍTICO: Usar BCrypt ao invés de NoOpPasswordEncoder
        return new BCryptPasswordEncoder(12); // 12 rounds para maior segurança
    }

    @Bean
    public AuthenticationManager authenticationManager() {
        return new ProviderManager(List.of(authenticationProvider()));
    }

    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }
}
```

### 2. JwtUtil.java - VERSÃO CORRIGIDA

```java
package com.seuprojeto.demo.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Component
public class JwtUtil {

    // CRÍTICO: Externalizar secret para variável de ambiente
    @Value("${jwt.secret}")
    private String secret;
    
    @Value("${jwt.expiration:86400000}") // 24 horas como padrão
    private long jwtExpiration;

    private Key getSigningKey() {
        return Keys.hmacShaKeyFor(secret.getBytes());
    }

    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    public Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    private Claims extractAllClaims(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    private Boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    public String generateToken(UserDetails userDetails) {
        Map<String, Object> claims = new HashMap<>();
        
        // Adiciona roles ao token para controle de acesso
        claims.put("roles", userDetails.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .collect(Collectors.toList()));
        
        return createToken(claims, userDetails.getUsername());
    }

    private String createToken(Map<String, Object> claims, String subject) {
        return Jwts.builder()
                .setClaims(claims)
                .setSubject(subject)
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + jwtExpiration))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    public Boolean validateToken(String token, UserDetails userDetails) {
        final String username = extractUsername(token);
        return (username.equals(userDetails.getUsername()) && !isTokenExpired(token));
    }
}
```

### 3. application.properties - VERSÃO CORRIGIDA

```properties
# Application Name
spring.application.name=medlink-ambulance-system

# PostgreSQL Configuration
spring.datasource.url=${DB_URL:jdbc:postgresql://localhost:5432/ambulancia}
spring.datasource.username=${DB_USERNAME:ambulancia_user}
spring.datasource.password=${DB_PASSWORD}
spring.datasource.driver-class-name=org.postgresql.Driver

# Hibernate / JPA Configuration
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=${SHOW_SQL:false}
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.defer-datasource-initialization=false

# Flyway or Liquibase recommended for production
# spring.flyway.enabled=true

# Server Configuration
server.port=${SERVER_PORT:8080}

# JWT Configuration (USAR VARIÁVEIS DE AMBIENTE)
jwt.secret=${JWT_SECRET}
jwt.expiration=${JWT_EXPIRATION:86400000}

# CORS Configuration
app.security.cors.allowed-origins=${CORS_ALLOWED_ORIGINS:http://localhost:3000}

# Logging
logging.level.com.seuprojeto.demo=${LOG_LEVEL:INFO}
logging.level.org.springframework.security=DEBUG

# Actuator (para monitoramento em produção)
management.endpoints.web.exposure.include=health,info,metrics
management.endpoint.health.show-details=when-authorized
```

### 4. Enums para substituir Strings

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

```java
package com.seuprojeto.demo.model.enums;

public enum UsuarioRole {
    ADMIN("ADMIN"),
    AGENTE("AGENTE"),
    MOTORISTA("MOTORISTA");

    private final String valor;

    UsuarioRole(String valor) {
        this.valor = valor;
    }

    public String getValor() {
        return valor;
    }
}
```

```java
package com.seuprojeto.demo.model.enums;

public enum PrioridadeSaude {
    ALTA("alta"),
    MEDIA("media"),
    BAIXA("baixa");

    private final String valor;

    PrioridadeSaude(String valor) {
        this.valor = valor;
    }

    public String getValor() {
        return valor;
    }
}
```

### 5. Usuario.java - VERSÃO MELHORADA

```java
package com.seuprojeto.demo.model;

import com.seuprojeto.demo.model.enums.UsuarioRole;
import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;

@Entity
@Table(name = "usuario", indexes = {
    @Index(name = "idx_usuario_email", columnList = "email")
})
public class Usuario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Nome é obrigatório")
    @Size(min = 3, max = 255, message = "Nome deve ter entre 3 e 255 caracteres")
    private String nome;

    @NotBlank(message = "Email é obrigatório")
    @Email(message = "Email deve ser válido")
    @Column(unique = true, nullable = false)
    private String email;

    @NotBlank(message = "Senha é obrigatória")
    @Size(min = 6, message = "Senha deve ter no mínimo 6 caracteres")
    private String senha;

    @NotNull(message = "Role é obrigatória")
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private UsuarioRole role;

    @Column(name = "criado_em", nullable = false, updatable = false)
    private LocalDateTime criadoEm;

    @Column(name = "atualizado_em")
    private LocalDateTime atualizadoEm;

    @Column(name = "ativo")
    private boolean ativo = true;

    // Constructors
    public Usuario() {
        this.criadoEm = LocalDateTime.now();
    }

    public Usuario(String nome, String email, String senha, UsuarioRole role) {
        this();
        this.nome = nome;
        this.email = email;
        this.senha = senha;
        this.role = role;
    }

    // Lifecycle callbacks
    @PreUpdate
    protected void onUpdate() {
        this.atualizadoEm = LocalDateTime.now();
    }

    // Business methods
    public boolean isAdmin() {
        return this.role == UsuarioRole.ADMIN;
    }

    public boolean isAgente() {
        return this.role == UsuarioRole.AGENTE;
    }

    public boolean isMotorista() {
        return this.role == UsuarioRole.MOTORISTA;
    }

    // Getters and Setters
    public Long getId() { return id; }
    
    public String getNome() { return nome; }
    public void setNome(String nome) { 
        this.nome = nome;
        this.onUpdate();
    }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { 
        this.email = email;
        this.onUpdate();
    }
    
    public String getSenha() { return senha; }
    public void setSenha(String senha) { 
        this.senha = senha;
        this.onUpdate();
    }
    
    public UsuarioRole getRole() { return role; }
    public void setRole(UsuarioRole role) { 
        this.role = role;
        this.onUpdate();
    }

    public LocalDateTime getCriadoEm() { return criadoEm; }
    
    public LocalDateTime getAtualizadoEm() { return atualizadoEm; }
    
    public boolean isAtivo() { return ativo; }
    public void setAtivo(boolean ativo) { 
        this.ativo = ativo;
        this.onUpdate();
    }
}
```

### 6. Ambulancia.java - VERSÃO MELHORADA

```java
package com.seuprojeto.demo.model;

import com.seuprojeto.demo.model.enums.AmbulanciaStatus;
import jakarta.persistence.*;
import jakarta.validation.constraints.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "ambulancia", indexes = {
    @Index(name = "idx_ambulancia_status", columnList = "status"),
    @Index(name = "idx_ambulancia_placa", columnList = "placa")
})
public class Ambulancia {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Placa é obrigatória")
    @Pattern(regexp = "[A-Z]{3}-[0-9]{4}", message = "Placa deve seguir o padrão ABC-1234")
    @Column(unique = true, nullable = false, length = 8)
    private String placa;

    @NotBlank(message = "Modelo é obrigatório")
    @Size(max = 255)
    private String modelo;

    @NotNull(message = "Capacidade é obrigatória")
    @Min(value = 1, message = "Capacidade mínima é 1")
    @Max(value = 20, message = "Capacidade máxima é 20")
    private Integer capacidade;

    @NotNull(message = "Status é obrigatório")
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private AmbulanciaStatus status = AmbulanciaStatus.DISPONIVEL;

    // Relacionamento correto com JPA
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "motorista_id")
    private Motorista motorista;

    @DecimalMin(value = "-90.0", message = "Latitude deve estar entre -90 e 90")
    @DecimalMax(value = "90.0", message = "Latitude deve estar entre -90 e 90")
    private Double latitude;

    @DecimalMin(value = "-180.0", message = "Longitude deve estar entre -180 e 180")
    @DecimalMax(value = "180.0", message = "Longitude deve estar entre -180 e 180")
    private Double longitude;

    @Column(name = "criado_em", nullable = false, updatable = false)
    private LocalDateTime criadoEm;

    @Column(name = "atualizado_em")
    private LocalDateTime atualizadoEm;

    // Constructors
    public Ambulancia() {
        this.criadoEm = LocalDateTime.now();
    }

    // Lifecycle callbacks
    @PreUpdate
    protected void onUpdate() {
        this.atualizadoEm = LocalDateTime.now();
    }

    // Business methods
    public boolean isDisponivel() {
        return this.status == AmbulanciaStatus.DISPONIVEL;
    }

    public void alocarMotorista(Motorista motorista) {
        if (motorista == null) {
            throw new IllegalArgumentException("Motorista não pode ser nulo");
        }
        this.motorista = motorista;
        this.onUpdate();
    }

    public void removerMotorista() {
        this.motorista = null;
        this.onUpdate();
    }

    public void marcarComoDisponivel() {
        this.status = AmbulanciaStatus.DISPONIVEL;
        this.onUpdate();
    }

    public void marcarComoEmUso() {
        this.status = AmbulanciaStatus.EM_USO;
        this.onUpdate();
    }

    public void marcarComoManutencao() {
        this.status = AmbulanciaStatus.MANUTENCAO;
        this.motorista = null; // Remove motorista quando em manutenção
        this.onUpdate();
    }

    public void atualizarLocalizacao(Double latitude, Double longitude) {
        if (latitude < -90 || latitude > 90) {
            throw new IllegalArgumentException("Latitude inválida");
        }
        if (longitude < -180 || longitude > 180) {
            throw new IllegalArgumentException("Longitude inválida");
        }
        this.latitude = latitude;
        this.longitude = longitude;
        this.onUpdate();
    }

    // Getters and Setters
    public Long getId() { return id; }
    
    public String getPlaca() { return placa; }
    public void setPlaca(String placa) { 
        this.placa = placa;
        this.onUpdate();
    }

    public String getModelo() { return modelo; }
    public void setModelo(String modelo) { 
        this.modelo = modelo;
        this.onUpdate();
    }

    public Integer getCapacidade() { return capacidade; }
    public void setCapacidade(Integer capacidade) { 
        this.capacidade = capacidade;
        this.onUpdate();
    }

    public AmbulanciaStatus getStatus() { return status; }
    public void setStatus(AmbulanciaStatus status) { 
        this.status = status;
        this.onUpdate();
    }

    public Motorista getMotorista() { return motorista; }
    public void setMotorista(Motorista motorista) { 
        this.motorista = motorista;
        this.onUpdate();
    }

    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { 
        this.latitude = latitude;
        this.onUpdate();
    }

    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { 
        this.longitude = longitude;
        this.onUpdate();
    }

    public LocalDateTime getCriadoEm() { return criadoEm; }
    public LocalDateTime getAtualizadoEm() { return atualizadoEm; }
}
```

### 7. Service Layer - AmbulanciaService (NOVO)

```java
package com.seuprojeto.demo.service;

import com.seuprojeto.demo.dto.AmbulanciaDTO;
import com.seuprojeto.demo.dto.AmbulanciaMotoristaDTO;
import com.seuprojeto.demo.exception.ResourceNotFoundException;
import com.seuprojeto.demo.model.Ambulancia;
import com.seuprojeto.demo.model.Motorista;
import com.seuprojeto.demo.model.enums.AmbulanciaStatus;
import com.seuprojeto.demo.repository.AmbulanciaRepository;
import com.seuprojeto.demo.repository.MotoristaRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

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

    public AmbulanciaDTO buscarPorId(Long id) {
        Ambulancia ambulancia = ambulanciaRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Ambulância não encontrada com ID: " + id));
        return convertToDTO(ambulancia);
    }

    @Transactional
    public AmbulanciaDTO criar(AmbulanciaDTO dto) {
        // Validações de negócio
        validarPlaca(dto.getPlaca());
        
        Ambulancia ambulancia = convertToEntity(dto);
        Ambulancia saved = ambulanciaRepository.save(ambulancia);
        return convertToDTO(saved);
    }

    @Transactional
    public AmbulanciaDTO atualizar(Long id, AmbulanciaDTO dto) {
        Ambulancia ambulancia = ambulanciaRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Ambulância não encontrada com ID: " + id));

        // Atualiza campos
        ambulancia.setPlaca(dto.getPlaca());
        ambulancia.setModelo(dto.getModelo());
        ambulancia.setCapacidade(dto.getCapacidade());
        ambulancia.setStatus(dto.getStatus());
        
        if (dto.getLatitude() != null && dto.getLongitude() != null) {
            ambulancia.atualizarLocalizacao(dto.getLatitude(), dto.getLongitude());
        }

        Ambulancia updated = ambulanciaRepository.save(ambulancia);
        return convertToDTO(updated);
    }

    @Transactional
    public void deletar(Long id) {
        if (!ambulanciaRepository.existsById(id)) {
            throw new ResourceNotFoundException("Ambulância não encontrada com ID: " + id);
        }
        ambulanciaRepository.deleteById(id);
    }

    @Transactional
    public AmbulanciaDTO alocarMotorista(Long ambulanciaId, Long motoristaId) {
        Ambulancia ambulancia = ambulanciaRepository.findById(ambulanciaId)
                .orElseThrow(() -> new ResourceNotFoundException("Ambulância não encontrada"));
        
        Motorista motorista = motoristaRepository.findById(motoristaId)
                .orElseThrow(() -> new ResourceNotFoundException("Motorista não encontrado"));

        ambulancia.alocarMotorista(motorista);
        Ambulancia updated = ambulanciaRepository.save(ambulancia);
        return convertToDTO(updated);
    }

    public List<AmbulanciaMotoristaDTO> listarComMotoristas() {
        return ambulanciaRepository.findAll().stream()
                .map(this::convertToCombinedDTO)
                .collect(Collectors.toList());
    }

    public List<AmbulanciaDTO> buscarPorStatus(AmbulanciaStatus status) {
        return ambulanciaRepository.findByStatus(status).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    // Métodos privados de conversão
    private AmbulanciaDTO convertToDTO(Ambulancia ambulancia) {
        return new AmbulanciaDTO(
                ambulancia.getId(),
                ambulancia.getPlaca(),
                ambulancia.getModelo(),
                ambulancia.getCapacidade(),
                ambulancia.getStatus(),
                ambulancia.getMotorista() != null ? ambulancia.getMotorista().getId() : null,
                ambulancia.getLatitude(),
                ambulancia.getLongitude()
        );
    }

    private Ambulancia convertToEntity(AmbulanciaDTO dto) {
        Ambulancia ambulancia = new Ambulancia();
        ambulancia.setPlaca(dto.getPlaca());
        ambulancia.setModelo(dto.getModelo());
        ambulancia.setCapacidade(dto.getCapacidade());
        ambulancia.setStatus(dto.getStatus());
        ambulancia.setLatitude(dto.getLatitude());
        ambulancia.setLongitude(dto.getLongitude());
        return ambulancia;
    }

    private AmbulanciaMotoristaDTO convertToCombinedDTO(Ambulancia ambulancia) {
        Motorista motorista = ambulancia.getMotorista();
        return new AmbulanciaMotoristaDTO(
                ambulancia.getId(),
                ambulancia.getPlaca(),
                ambulancia.getModelo(),
                ambulancia.getCapacidade(),
                ambulancia.getStatus().name(),
                ambulancia.getLatitude(),
                ambulancia.getLongitude(),
                motorista != null ? motorista.getId() : null,
                motorista != null ? motorista.getNome() : null,
                motorista != null ? motorista.getTelefone() : null
        );
    }

    private void validarPlaca(String placa) {
        if (!placa.matches("[A-Z]{3}-[0-9]{4}")) {
            throw new IllegalArgumentException("Placa inválida. Use o formato ABC-1234");
        }
    }
}
```

### 8. DTOs (NOVOS)

```java
package com.seuprojeto.demo.dto;

import com.seuprojeto.demo.model.enums.AmbulanciaStatus;
import jakarta.validation.constraints.*;

public class AmbulanciaDTO {
    
    private Long id;
    
    @NotBlank(message = "Placa é obrigatória")
    @Pattern(regexp = "[A-Z]{3}-[0-9]{4}", message = "Placa deve seguir o padrão ABC-1234")
    private String placa;
    
    @NotBlank(message = "Modelo é obrigatório")
    private String modelo;
    
    @NotNull(message = "Capacidade é obrigatória")
    @Min(1)
    @Max(20)
    private Integer capacidade;
    
    @NotNull(message = "Status é obrigatório")
    private AmbulanciaStatus status;
    
    private Long motoristaId;
    
    @DecimalMin("-90.0")
    @DecimalMax("90.0")
    private Double latitude;
    
    @DecimalMin("-180.0")
    @DecimalMax("180.0")
    private Double longitude;

    // Constructors, Getters, Setters
    public AmbulanciaDTO() {}

    public AmbulanciaDTO(Long id, String placa, String modelo, Integer capacidade, 
                        AmbulanciaStatus status, Long motoristaId, Double latitude, Double longitude) {
        this.id = id;
        this.placa = placa;
        this.modelo = modelo;
        this.capacidade = capacidade;
        this.status = status;
        this.motoristaId = motoristaId;
        this.latitude = latitude;
        this.longitude = longitude;
    }

    // Getters e Setters omitidos por brevidade
}
```

### 9. Exception Handler Global (NOVO)

```java
package com.seuprojeto.demo.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

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

    @ExceptionHandler(BadCredentialsException.class)
    @ResponseStatus(HttpStatus.UNAUTHORIZED)
    public ErrorResponse handleBadCredentials(BadCredentialsException ex) {
        return new ErrorResponse(
                HttpStatus.UNAUTHORIZED.value(),
                "Credenciais inválidas",
                LocalDateTime.now()
        );
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ValidationErrorResponse handleValidationExceptions(MethodArgumentNotValidException ex) {
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

    @ExceptionHandler(IllegalArgumentException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErrorResponse handleIllegalArgument(IllegalArgumentException ex) {
        return new ErrorResponse(
                HttpStatus.BAD_REQUEST.value(),
                ex.getMessage(),
                LocalDateTime.now()
        );
    }

    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public ErrorResponse handleGenericException(Exception ex) {
        // Log the exception
        return new ErrorResponse(
                HttpStatus.INTERNAL_SERVER_ERROR.value(),
                "Erro interno do servidor",
                LocalDateTime.now()
        );
    }

    // Classes de resposta de erro
    public record ErrorResponse(int status, String message, LocalDateTime timestamp) {}
    
    public record ValidationErrorResponse(int status, String message, 
                                         Map<String, String> errors, LocalDateTime timestamp) {}
}
```

```java
package com.seuprojeto.demo.exception;

public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }
}
```

### 10. AmbulanciaController - VERSÃO REFATORADA

```java
package com.seuprojeto.demo.controller;

import com.seuprojeto.demo.dto.AmbulanciaDTO;
import com.seuprojeto.demo.dto.AmbulanciaMotoristaDTO;
import com.seuprojeto.demo.model.enums.AmbulanciaStatus;
import com.seuprojeto.demo.service.AmbulanciaService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/ambulancias")
public class AmbulanciaController {

    private final AmbulanciaService ambulanciaService;

    public AmbulanciaController(AmbulanciaService ambulanciaService) {
        this.ambulanciaService = ambulanciaService;
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'AGENTE')")
    public ResponseEntity<List<AmbulanciaDTO>> listar() {
        List<AmbulanciaDTO> ambulancias = ambulanciaService.listarTodas();
        return ResponseEntity.ok(ambulancias);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'AGENTE')")
    public ResponseEntity<AmbulanciaDTO> buscarPorId(@PathVariable Long id) {
        AmbulanciaDTO ambulancia = ambulanciaService.buscarPorId(id);
        return ResponseEntity.ok(ambulancia);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AmbulanciaDTO> criar(@Valid @RequestBody AmbulanciaDTO dto) {
        AmbulanciaDTO created = ambulanciaService.criar(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AmbulanciaDTO> atualizar(@PathVariable Long id, 
                                                   @Valid @RequestBody AmbulanciaDTO dto) {
        AmbulanciaDTO updated = ambulanciaService.atualizar(id, dto);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        ambulanciaService.deletar(id);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{ambulanciaId}/motorista/{motoristaId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'AGENTE')")
    public ResponseEntity<AmbulanciaDTO> alocarMotorista(@PathVariable Long ambulanciaId,
                                                         @PathVariable Long motoristaId) {
        AmbulanciaDTO updated = ambulanciaService.alocarMotorista(ambulanciaId, motoristaId);
        return ResponseEntity.ok(updated);
    }

    @GetMapping("/combined")
    @PreAuthorize("hasAnyRole('ADMIN', 'AGENTE')")
    public ResponseEntity<List<AmbulanciaMotoristaDTO>> listarComMotoristas() {
        List<AmbulanciaMotoristaDTO> ambulancias = ambulanciaService.listarComMotoristas();
        return ResponseEntity.ok(ambulancias);
    }

    @GetMapping("/status/{status}")
    @PreAuthorize("hasAnyRole('ADMIN', 'AGENTE')")
    public ResponseEntity<List<AmbulanciaDTO>> buscarPorStatus(@PathVariable AmbulanciaStatus status) {
        List<AmbulanciaDTO> ambulancias = ambulanciaService.buscarPorStatus(status);
        return ResponseEntity.ok(ambulancias);
    }
}
```

### 11. Repository melhorado

```java
package com.seuprojeto.demo.repository;

import com.seuprojeto.demo.model.Ambulancia;
import com.seuprojeto.demo.model.enums.AmbulanciaStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AmbulanciaRepository extends JpaRepository<Ambulancia, Long> {
    
    List<Ambulancia> findByStatus(AmbulanciaStatus status);
    
    Optional<Ambulancia> findByPlaca(String placa);
    
    @Query("SELECT a FROM Ambulancia a WHERE a.motorista.id = :motoristaId")
    Optional<Ambulancia> findByMotoristaId(@Param("motoristaId") Long motoristaId);
    
    @Query("SELECT a FROM Ambulancia a WHERE a.status = :status AND a.motorista IS NOT NULL")
    List<Ambulancia> findDisponivelComMotorista(@Param("status") AmbulanciaStatus status);
    
    boolean existsByPlaca(String placa);
}
```

---

## 🏗️ MELHORIAS ESTRUTURAIS GERAIS

### 1. **Reestruturação de Pacotes**

```
com.medlink.ambulance (renomear de com.seuprojeto.demo)
├── config
│   ├── SecurityConfig
│   ├── CorsConfig
│   └── OpenApiConfig (Swagger/OpenAPI)
├── controller
│   ├── AmbulanciaController
│   ├── AuthController
│   ├── ClienteController
│   ├── HospitalController
│   ├── MotoristaController
│   └── UsuarioController
├── dto
│   ├── request
│   │   ├── AmbulanciaCreateRequest
│   │   ├── LoginRequest
│   │   └── ...
│   └── response
│       ├── AmbulanciaResponse
│       ├── AuthResponse
│       └── ...
├── exception
│   ├── GlobalExceptionHandler
│   ├── ResourceNotFoundException
│   ├── BusinessException
│   └── ...
├── filter
│   └── JwtAuthenticationFilter
├── model
│   ├── Ambulancia
│   ├── Cliente
│   ├── Hospital
│   ├── Motorista
│   └── Usuario
├── model.enums
│   ├── AmbulanciaStatus
│   ├── UsuarioRole
│   └── ...
├── repository
│   ├── AmbulanciaRepository
│   ├── ClienteRepository
│   └── ...
├── service
│   ├── AmbulanciaService
│   ├── AuthService
│   ├── ClienteService
│   └── ...
└── util
    ├── JwtUtil
    └── ...
```

### 2. **Configuração de Ambientes**

Criar profiles Spring:
- `application.properties` (configurações comuns)
- `application-dev.properties` (desenvolvimento)
- `application-prod.properties` (produção)
- `application-test.properties` (testes)

### 3. **Implementar Migrations com Flyway**

```xml
<!-- pom.xml -->
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-core</artifactId>
</dependency>
```

Estrutura:
```
src/main/resources/db/migration/
├── V1__create_initial_schema.sql
├── V2__add_indexes.sql
└── V3__seed_default_data.sql
```

### 4. **Documentação de API com OpenAPI/Swagger**

```xml
<!-- pom.xml -->
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.2.0</version>
</dependency>
```

### 5. **Implementar Testes**

```java
@SpringBootTest
@AutoConfigureMockMvc
class AmbulanciaControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private AmbulanciaService ambulanciaService;
    
    @Test
    @WithMockUser(roles = "ADMIN")
    void deveCriarAmbulancia() throws Exception {
        // Teste aqui
    }
}
```

### 6. **Logging Adequado**

```xml
<!-- logback-spring.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <include resource="org/springframework/boot/logging/logback/defaults.xml"/>
    
    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss} - %msg%n</pattern>
        </encoder>
    </appender>
    
    <root level="INFO">
        <appender-ref ref="CONSOLE"/>
    </root>
</configuration>
```

### 7. **Monitoramento com Actuator**

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

### 8. **Cache com Redis (opcional)**

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
```

### 9. **Rate Limiting**

```java
@Component
public class RateLimitingFilter extends OncePerRequestFilter {
    // Implementar rate limiting para /auth/login
}
```

### 10. **Docker e Docker Compose**

```dockerfile
# Dockerfile
FROM eclipse-temurin:22-jre-alpine
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

```yaml
# docker-compose.yml
version: '3.8'
services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: ambulancia
      POSTGRES_USER: ambulancia_user
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      DB_URL: jdbc:postgresql://postgres:5432/ambulancia
      DB_USERNAME: ambulancia_user
      DB_PASSWORD: ${DB_PASSWORD}
      JWT_SECRET: ${JWT_SECRET}
    depends_on:
      - postgres

volumes:
  postgres_data:
```

---

## 📊 RESUMO DE PRIORIDADES

### ✅ Fazer IMEDIATAMENTE (Bloqueadores de Produção)

1. ✅ Trocar `NoOpPasswordEncoder` por `BCryptPasswordEncoder`
2. ✅ Externalizar JWT secret para variável de ambiente
3. ✅ Remover credenciais do application.properties
4. ✅ Configurar autenticação adequada (remover `.permitAll()`)
5. ✅ Atualizar Spring Boot para versão estável
6. ✅ Implementar exception handler global

### 🔥 Fazer em 1-2 sprints

7. Criar camada de Service completa
8. Implementar DTOs para todas as entidades
9. Adicionar validações com Bean Validation
10. Converter Strings para Enums
11. Corrigir relacionamentos JPA
12. Consolidar pacotes de controllers
13. Adicionar testes unitários e de integração

### 📋 Fazer em 2-4 sprints

14. Implementar Flyway/Liquibase
15. Adicionar OpenAPI/Swagger
16. Implementar logging adequado
17. Adicionar Actuator
18. Implementar rate limiting
19. Criar profiles de ambiente
20. Dockerizar aplicação

---

## 🎯 CONCLUSÃO

O projeto MedlinkProject apresenta uma estrutura básica funcional, mas possui **múltiplos problemas críticos de segurança** que impedem seu uso em produção. As principais áreas que necessitam atenção imediata são:

1. **Segurança**: Configuração completamente inadequada
2. **Arquitetura**: Falta de camada de service e DTOs
3. **Qualidade**: Ausência de testes e validações
4. **Manutenibilidade**: Violações de SOLID, código duplicado

Com as correções sugeridas neste documento, o projeto pode evoluir para um sistema robusto, seguro e pronto para produção.

**Estimativa de esforço total**: 4-6 sprints (8-12 semanas) para implementar todas as melhorias sugeridas.

---

**Gerado por:** GitHub Copilot  
**Data:** 06/11/2025
