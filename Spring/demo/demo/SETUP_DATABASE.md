# Configuração do Banco de Dados PostgreSQL

## Pré-requisitos
- PostgreSQL instalado e rodando no seu computador
- Acesso ao terminal/psql

## Passos para Configurar o Banco

### 1. Criar o Banco de Dados
Abra o terminal e execute os seguintes comandos:

```sql
-- Conectar ao PostgreSQL como superusuário (geralmente 'postgres')
psql -U postgres

-- Criar o banco de dados
CREATE DATABASE ambulancia;

-- Criar o usuário da aplicação
CREATE USER ambulancia_user WITH PASSWORD '1234567';

-- Dar permissões ao usuário no banco
GRANT ALL PRIVILEGES ON DATABASE ambulancia TO ambulancia_user;

-- Sair do psql
\q
```

### 2. Verificar a Configuração
Para verificar se tudo está funcionando:

```sql
-- Conectar com o usuário da aplicação
psql -U ambulancia_user -d ambulancia

-- Se conectar com sucesso, o banco está configurado corretamente
-- Sair
\q
```

## Configuração Alternativa (se você preferir usar pgAdmin)

1. Abra o pgAdmin
2. Clique com botão direito em "Databases" > "Create" > "Database"
3. Nome: `ambulancia`
4. Owner: `postgres` (ou seu usuário admin)
5. Clique em "Save"

6. Criar usuário:
   - Vá em "Login/Group Roles"
   - Clique com botão direito > "Create" > "Login/Group Role"
   - Name: `ambulancia_user`
   - Password: `1234567`
   - Privileges: Marque "Can login?" e "Create databases?"

7. Dar permissões:
   - Clique com botão direito no banco `ambulancia`
   - "Properties" > "Security" > "Add" o usuário `ambulancia_user` com privilégios

## O que Acontece Quando Você Roda a Aplicação

Quando você executar `mvn spring-boot:run`, o Spring Boot irá:

1. Conectar ao banco `ambulancia` com o usuário `ambulancia_user`
2. Criar automaticamente as tabelas:
   - `cliente`
   - `usuario`
   - `motorista`
   - `ambulancia`
   - `hospital`

## Verificar se as Tabelas Foram Criadas

Após rodar a aplicação pela primeira vez:

```sql
-- Conectar ao banco
psql -U ambulancia_user -d ambulancia

-- Listar tabelas
\dt

-- Você deve ver as tabelas criadas automaticamente
```

## Problemas Comuns

### Erro: "FATAL: password authentication failed for user 'ambulancia_user'"
- Verifique se a senha está correta: `1234567`
- Certifique-se de que o PostgreSQL está aceitando conexões locais

### Erro: "FATAL: database 'ambulancia' does not exist"
- Crie o banco de dados seguindo os passos acima

### Erro: "Connection refused"
- Verifique se o PostgreSQL está rodando: `sudo systemctl status postgresql` (Linux) ou verifique os serviços no Windows

## Configurações no application.properties

O arquivo `src/main/resources/application.properties` já está configurado com:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/ambulancia
spring.datasource.username=ambulancia_user
spring.datasource.password=1234567
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.hibernate.ddl-auto=update
```

Não é necessário alterar nada neste arquivo.

## Teste Final

Após configurar tudo:

1. Rode a aplicação: `mvn spring-boot:run`
2. Abra o navegador: `http://localhost:8080/dashboard.html`
3. Teste criar um cliente através da interface web
4. Verifique no banco se os dados foram salvos

Se tudo funcionar, sua configuração está correta! 🎉
