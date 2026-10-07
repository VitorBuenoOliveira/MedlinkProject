# 🔄 EXEMPLOS ANTES/DEPOIS - Refatorações

Este documento mostra exemplos práticos de código ANTES e DEPOIS das correções.

---

## 1. SecurityConfig - Password Encoder

### ❌ ANTES (INSEGURO)

```java
@Bean
public PasswordEncoder passwordEncoder() {
    return NoOpPasswordEncoder.getInstance(); // ⚠️ SENHAS EM TEXTO PLANO!
}
```

### ✅ DEPOIS (SEGURO)

```java
@Bean
public PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder(12); // 12 rounds = alta segurança
}
```

**Por que mudar?**
- NoOpPasswordEncoder não criptografa senhas
- BCrypt é padrão da indústria
- Se banco vazar, senhas ficam protegidas

---

## 2. SecurityConfig - Autenticação

### ❌ ANTES (TODO MUNDO ACESSA TUDO)

```java
.authorizeHttpRequests(authz -> authz
    .anyRequest().permitAll() // ⚠️ SEM SEGURANÇA!
)
```

### ✅ DEPOIS (CONTROLE DE ACESSO)

```java
.authorizeHttpRequests(authz -> authz
    // Público
    .requestMatchers("/auth/login", "/auth/register").permitAll()
    
    // Somente Admin
    .requestMatchers("/usuarios/**").hasRole("ADMIN")
    
    // Admin ou Agente
    .requestMatchers("/ambulancias/**").hasAnyRole("ADMIN", "AGENTE")
    .requestMatchers("/motoristas/**").hasAnyRole("ADMIN", "AGENTE")
    .requestMatchers("/hospitais/**").hasAnyRole("ADMIN", "AGENTE")
    .requestMatchers("/clientes/**").hasAnyRole("ADMIN", "AGENTE")
    
    // Resto precisa estar autenticado
    .anyRequest().authenticated()
)
```

**Por que mudar?**
- Protege endpoints sensíveis
- Implementa controle de acesso baseado em roles
- Previne acesso não autorizado

---

## 3. JwtUtil - Secret Hardcoded

### ❌ ANTES (SECRET EXPOSTO)

```java
private static final String SECRET = "mySecretKeyForJwtTokenGenerationThatIsLongEnough";
private static final int JWT_EXPIRATION = 86400000;

private Key getSigningKey() {
    return Keys.hmacShaKeyFor(SECRET.getBytes()); // ⚠️ HARDCODED!
}
```

### ✅ DEPOIS (SECRET EXTERNALIZADO)

```java
@Value("${jwt.secret}")
private String secret;

@Value("${jwt.expiration:86400000}")
private long jwtExpiration;

private Key getSigningKey() {
    return Keys.hmacShaKeyFor(secret.getBytes());
}
```

**application.properties:**
```properties
jwt.secret=${JWT_SECRET}
jwt.expiration=${JWT_EXPIRATION:86400000}
```

**.env:**
```bash
JWT_SECRET=sua_chave_super_secreta_gerada_com_openssl_rand_base64_32
```

**Por que mudar?**
- Secret não fica no código-fonte
- Pode trocar sem recompilar
- Cada ambiente tem seu próprio secret

---

## 4. Ambulancia - Relacionamento JPA

### ❌ ANTES (RELACIONAMENTO MANUAL)

```java
@Column(name = "motorista_id")
private Long motoristaId; // ⚠️ JPA não gerencia relacionamento
```

**Controller tinha que fazer:**
```java
Motorista motorista = null;
if (ambulancia.getMotoristaId() != null) {
    motorista = motoristaRepository.findById(ambulancia.getMotoristaId()).orElse(null);
}
```

### ✅ DEPOIS (JPA GERENCIA)

```java
@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "motorista_id")
private Motorista motorista; // ✅ JPA gerencia automaticamente
```

**Uso:**
```java
// JPA busca automaticamente quando necessário
Motorista motorista = ambulancia.getMotorista();
```

**Por que mudar?**
- JPA gerencia o relacionamento
- Lazy loading automático
- Menos queries manuais
- Aproveita cache de segundo nível

---

## 5. Enums vs Strings

### ❌ ANTES (STRINGS SEM VALIDAÇÃO)

```java
private String status; // "disponivel", "em_uso", "manutencao"

// Uso sem validação
ambulancia.setStatus("dispunivel"); // ⚠️ TYPO! Aceita qualquer coisa
```

### ✅ DEPOIS (ENUM VALIDADO)

```java
@Enumerated(EnumType.STRING)
@Column(nullable = false)
private AmbulanciaStatus status;

// Uso com validação
ambulancia.setStatus(AmbulanciaStatus.DISPONIVEL); // ✅ Type safe!
// ambulancia.setStatus("xyz"); // ❌ Erro de compilação
```

**Enum:**
```java
public enum AmbulanciaStatus {
    DISPONIVEL("disponivel"),
    EM_USO("em_uso"),
    MANUTENCAO("manutencao");

    private final String valor;
    
    AmbulanciaStatus(String valor) {
        this.valor = valor;
    }
}
```

**Por que mudar?**
- Erro de compilação ao invés de runtime
- IDE mostra opções disponíveis
- Impossível ter valores inválidos

---

## 6. Controller com Service vs Sem Service

### ❌ ANTES (LÓGICA NO CONTROLLER)

```java
@RestController
@RequestMapping("/ambulancias")
public class AmbulanciaController {

    private final AmbulanciaRepository ambulanciaRepository;
    private final MotoristaRepository motoristaRepository;

    @GetMapping
    public List<Ambulancia> listar() {
        return ambulanciaRepository.findAll(); // ⚠️ Expõe entidade JPA
    }

    @PostMapping
    public Ambulancia salvar(@RequestBody Ambulancia ambulancia) {
        // ⚠️ SEM VALIDAÇÃO!
        return ambulanciaRepository.save(ambulancia);
    }

    @GetMapping("/{id}")
    public Ambulancia buscarPorId(@PathVariable Long id) {
        return ambulanciaRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Ambulância não encontrada")); 
            // ⚠️ RuntimeException genérica
    }
}
```

**Problemas:**
- Controller faz tudo (viola SRP)
- Expõe entidades JPA diretamente
- Sem validação de negócio
- Difícil de testar
- Sem tratamento adequado de erros

### ✅ DEPOIS (COM SERVICE E DTO)

```java
@RestController
@RequestMapping("/api/v1/ambulancias")
public class AmbulanciaController {

    private final AmbulanciaService ambulanciaService;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'AGENTE')")
    public ResponseEntity<List<AmbulanciaDTO>> listar() {
        List<AmbulanciaDTO> ambulancias = ambulanciaService.listarTodas();
        return ResponseEntity.ok(ambulancias); // ✅ Retorna DTO
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AmbulanciaDTO> criar(@Valid @RequestBody AmbulanciaDTO dto) {
        AmbulanciaDTO created = ambulanciaService.criar(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'AGENTE')")
    public ResponseEntity<AmbulanciaDTO> buscarPorId(@PathVariable Long id) {
        AmbulanciaDTO ambulancia = ambulanciaService.buscarPorId(id);
        return ResponseEntity.ok(ambulancia);
    }
}
```

**Service:**
```java
@Service
@Transactional(readOnly = true)
public class AmbulanciaService {

    private final AmbulanciaRepository ambulanciaRepository;

    public List<AmbulanciaDTO> listarTodas() {
        return ambulanciaRepository.findAll().stream()
                .map(this::convertToDTO) // ✅ Converte para DTO
                .collect(Collectors.toList());
    }

    @Transactional
    public AmbulanciaDTO criar(AmbulanciaDTO dto) {
        // ✅ Validações de negócio aqui
        validarPlaca(dto.getPlaca());
        
        Ambulancia ambulancia = convertToEntity(dto);
        Ambulancia saved = ambulanciaRepository.save(ambulancia);
        return convertToDTO(saved);
    }

    public AmbulanciaDTO buscarPorId(Long id) {
        Ambulancia ambulancia = ambulanciaRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException(
                    "Ambulância não encontrada com ID: " + id)); // ✅ Exception específica
        return convertToDTO(ambulancia);
    }

    private void validarPlaca(String placa) {
        if (!placa.matches("[A-Z]{3}-[0-9]{4}")) {
            throw new IllegalArgumentException("Placa inválida. Use formato ABC-1234");
        }
    }
}
```

**Por que mudar?**
- Separação de responsabilidades (SRP)
- Lógica de negócio no Service
- DTOs protegem estrutura interna
- Fácil de testar (mock do repository)
- Transações gerenciadas corretamente

---

## 7. ClienteController - Update com 20+ setters

### ❌ ANTES (MÉTODO GIGANTE)

```java
@PutMapping("/{id}")
public ResponseEntity<Cliente> updateCliente(@PathVariable Long id, 
                                             @RequestBody Cliente clienteDetails) {
    Optional<Cliente> optionalCliente = clienteRepository.findById(id);
    if (!optionalCliente.isPresent()) {
        return ResponseEntity.notFound().build();
    }
    Cliente cliente = optionalCliente.get();
    
    // ⚠️ 20+ linhas de setters manuais
    cliente.setNome(clienteDetails.getNome());
    cliente.setTelefone(clienteDetails.getTelefone());
    cliente.setEndereco(clienteDetails.getEndereco());
    cliente.setDataNascimento(clienteDetails.getDataNascimento());
    cliente.setCartao(clienteDetails.getCartao());
    cliente.setTipo(clienteDetails.getTipo());
    cliente.setHorarioVan(clienteDetails.getHorarioVan());
    cliente.setDataAtendimento(clienteDetails.getDataAtendimento());
    cliente.setBairro(clienteDetails.getBairro());
    cliente.setDestino(clienteDetails.getDestino());
    cliente.setHorarioAtendimento(clienteDetails.getHorarioAtendimento());
    cliente.setVagas(clienteDetails.getVagas());
    cliente.setTratamento(clienteDetails.getTratamento());
    cliente.setCartaoAcompanhante(clienteDetails.getCartaoAcompanhante());
    cliente.setNomeAcompanhante(clienteDetails.getNomeAcompanhante());
    cliente.setDataNascimentoAcompanhante(clienteDetails.getDataNascimentoAcompanhante());
    cliente.setAtendido(clienteDetails.isAtendido());
    cliente.setPrioridadeSaude(clienteDetails.getPrioridadeSaude());
    cliente.setInovacao(clienteDetails.getInovacao());
    cliente.setGrupoVulneravel(clienteDetails.getGrupoVulneravel());
    cliente.setTransporteSustentavel(clienteDetails.getTransporteSustentavel());

    Cliente updatedCliente = clienteRepository.save(cliente);
    return ResponseEntity.ok(updatedCliente);
}
```

### ✅ DEPOIS (COM SERVICE E MÉTODO AUXILIAR)

```java
@PutMapping("/{id}")
@PreAuthorize("hasAnyRole('ADMIN', 'AGENTE')")
public ResponseEntity<ClienteDTO> atualizar(@PathVariable Long id, 
                                           @Valid @RequestBody ClienteDTO dto) {
    ClienteDTO updated = clienteService.atualizar(id, dto);
    return ResponseEntity.ok(updated);
}
```

**Service:**
```java
@Transactional
public ClienteDTO atualizar(Long id, ClienteDTO dto) {
    Cliente cliente = clienteRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Cliente não encontrado"));
    
    // ✅ Método auxiliar para atualizar campos
    atualizarCampos(cliente, dto);
    
    Cliente updated = clienteRepository.save(cliente);
    return convertToDTO(updated);
}

private void atualizarCampos(Cliente cliente, ClienteDTO dto) {
    // Grupo: Dados Pessoais
    if (dto.getNome() != null) cliente.setNome(dto.getNome());
    if (dto.getTelefone() != null) cliente.setTelefone(dto.getTelefone());
    if (dto.getEndereco() != null) cliente.setEndereco(dto.getEndereco());
    
    // Grupo: Dados Atendimento
    if (dto.getDataAtendimento() != null) cliente.setDataAtendimento(dto.getDataAtendimento());
    if (dto.getDestino() != null) cliente.setDestino(dto.getDestino());
    
    // ... outros campos organizados em grupos
}
```

**Ou melhor ainda, usando ModelMapper/MapStruct:**
```java
@Transactional
public ClienteDTO atualizar(Long id, ClienteDTO dto) {
    Cliente cliente = clienteRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Cliente não encontrado"));
    
    // ✅ Framework faz o mapeamento automaticamente
    modelMapper.map(dto, cliente);
    
    Cliente updated = clienteRepository.save(cliente);
    return convertToDTO(updated);
}
```

**Por que mudar?**
- Menos código repetitivo
- Mais fácil de manter
- Validações centralizadas
- DTO protege a entidade

---

## 8. Exception Handling

### ❌ ANTES (MENSAGENS GENÉRICAS)

```java
@GetMapping("/{id}")
public Ambulancia buscarPorId(@PathVariable Long id) {
    return ambulanciaRepository.findById(id)
        .orElseThrow(() -> new RuntimeException("Ambulância não encontrada"));
        // ⚠️ RuntimeException genérica
}
```

**Resposta ao cliente:**
```json
{
  "timestamp": "2025-11-06T10:30:00",
  "status": 500,
  "error": "Internal Server Error",
  "message": "Ambulância não encontrada",
  "path": "/ambulancias/999"
}
```

### ✅ DEPOIS (EXCEPTION HANDLER GLOBAL)

```java
@GetMapping("/{id}")
public ResponseEntity<AmbulanciaDTO> buscarPorId(@PathVariable Long id) {
    AmbulanciaDTO ambulancia = ambulanciaService.buscarPorId(id);
    return ResponseEntity.ok(ambulancia);
}
```

**Service:**
```java
public AmbulanciaDTO buscarPorId(Long id) {
    Ambulancia ambulancia = ambulanciaRepository.findById(id)
        .orElseThrow(() -> new ResourceNotFoundException(
            "Ambulância não encontrada com ID: " + id));
    return convertToDTO(ambulancia);
}
```

**Exception Handler:**
```java
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

    public record ErrorResponse(int status, String message, LocalDateTime timestamp) {}
}
```

**Resposta ao cliente:**
```json
{
  "status": 404,
  "message": "Ambulância não encontrada com ID: 999",
  "timestamp": "2025-11-06T10:30:00"
}
```

**Por que mudar?**
- Status HTTP correto (404 ao invés de 500)
- Mensagens consistentes
- Mais fácil debugar
- Cliente recebe informações úteis

---

## 9. Validações

### ❌ ANTES (SEM VALIDAÇÃO)

```java
@PostMapping
public Ambulancia salvar(@RequestBody Ambulancia ambulancia) {
    return ambulanciaRepository.save(ambulancia); 
    // ⚠️ Aceita qualquer coisa!
}
```

**Cliente pode enviar:**
```json
{
  "placa": "",
  "modelo": null,
  "capacidade": -5,
  "latitude": 999
}
```
E o sistema aceita! 😱

### ✅ DEPOIS (COM VALIDAÇÃO)

```java
@PostMapping
@PreAuthorize("hasRole('ADMIN')")
public ResponseEntity<AmbulanciaDTO> criar(@Valid @RequestBody AmbulanciaDTO dto) {
    AmbulanciaDTO created = ambulanciaService.criar(dto);
    return ResponseEntity.status(HttpStatus.CREATED).body(created);
}
```

**DTO com validações:**
```java
public class AmbulanciaDTO {
    
    @NotBlank(message = "Placa é obrigatória")
    @Pattern(regexp = "[A-Z]{3}-[0-9]{4}", message = "Placa deve seguir padrão ABC-1234")
    private String placa;
    
    @NotBlank(message = "Modelo é obrigatório")
    private String modelo;
    
    @NotNull(message = "Capacidade é obrigatória")
    @Min(value = 1, message = "Capacidade mínima é 1")
    @Max(value = 20, message = "Capacidade máxima é 20")
    private Integer capacidade;
    
    @DecimalMin(value = "-90.0", message = "Latitude entre -90 e 90")
    @DecimalMax(value = "90.0", message = "Latitude entre -90 e 90")
    private Double latitude;
    
    // ...
}
```

**Exception Handler para validações:**
```java
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
```

**Resposta ao cliente:**
```json
{
  "status": 400,
  "message": "Erro de validação",
  "errors": {
    "placa": "Placa é obrigatória",
    "modelo": "Modelo é obrigatório",
    "capacidade": "Capacidade mínima é 1",
    "latitude": "Latitude entre -90 e 90"
  },
  "timestamp": "2025-11-06T10:30:00"
}
```

**Por que mudar?**
- Valida dados antes de processar
- Mensagens de erro claras
- Evita dados inválidos no banco
- Melhora experiência do usuário

---

## 10. Entidade Anêmica vs Rica

### ❌ ANTES (ENTIDADE ANÊMICA)

```java
@Entity
public class Ambulancia {
    private Long id;
    private String placa;
    private String status;
    private Long motoristaId;
    
    // Apenas getters e setters
}
```

**Uso no controller/service:**
```java
// ⚠️ Lógica de negócio espalhada
if (ambulancia.getStatus().equals("disponivel")) {
    ambulancia.setStatus("em_uso");
    ambulancia.setMotoristaId(motoristaId);
}
```

### ✅ DEPOIS (ENTIDADE RICA)

```java
@Entity
public class Ambulancia {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotBlank
    @Pattern(regexp = "[A-Z]{3}-[0-9]{4}")
    private String placa;
    
    @Enumerated(EnumType.STRING)
    private AmbulanciaStatus status = AmbulanciaStatus.DISPONIVEL;
    
    @ManyToOne(fetch = FetchType.LAZY)
    private Motorista motorista;
    
    // ✅ Métodos de negócio
    public boolean isDisponivel() {
        return this.status == AmbulanciaStatus.DISPONIVEL;
    }
    
    public void alocarMotorista(Motorista motorista) {
        if (motorista == null) {
            throw new IllegalArgumentException("Motorista não pode ser nulo");
        }
        if (!this.isDisponivel()) {
            throw new IllegalStateException("Ambulância não está disponível");
        }
        this.motorista = motorista;
        this.status = AmbulanciaStatus.EM_USO;
    }
    
    public void marcarComoDisponivel() {
        this.status = AmbulanciaStatus.DISPONIVEL;
        this.motorista = null;
    }
    
    public void marcarComoManutencao() {
        this.status = AmbulanciaStatus.MANUTENCAO;
        this.motorista = null; // Remove motorista quando em manutenção
    }
}
```

**Uso no service:**
```java
// ✅ Lógica de negócio encapsulada
ambulancia.alocarMotorista(motorista);
```

**Por que mudar?**
- Lógica de negócio na entidade (DDD)
- Validações no próprio modelo
- Código mais expressivo
- Menos duplicação

---

## 📚 Resumo das Transformações

| Aspecto | Antes ❌ | Depois ✅ | Ganho |
|---------|----------|-----------|-------|
| Password | NoOp (texto plano) | BCrypt | 🔐 Segurança |
| JWT Secret | Hardcoded | Externalizado | 🔐 Segurança |
| Auth | PermitAll | Role-based | 🔐 Segurança |
| Arquitetura | Controller faz tudo | Controller→Service→Repository | 🏗️ SOLID |
| Entidades | Expostas diretamente | DTOs | 🛡️ Proteção |
| Validação | Nenhuma | Bean Validation | ✅ Qualidade |
| Tipos | Strings | Enums | 🎯 Type Safety |
| Relacionamentos | Manual (Long id) | JPA (@ManyToOne) | ⚡ Performance |
| Exceções | RuntimeException | Custom + Handler | 🎨 UX |
| Entidades | Anêmicas | Ricas | 💎 DDD |

---

**Próximos passos:** Consulte o `MIGRATION_GUIDE.md` para implementação passo a passo.
