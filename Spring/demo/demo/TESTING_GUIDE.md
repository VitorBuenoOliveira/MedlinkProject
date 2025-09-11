# Guia de Teste para Sistema de Gestão de Transporte de Pacientes

## Como criar um usuário para teste

### Usando Postman ou Curl

Faça uma requisição POST para o endpoint `/usuarios` com o seguinte JSON no corpo:

```json
{
  "nome": "Teste Usuario",
  "email": "teste@exemplo.com",
  "senha": "senha123",
  "role": "Admin"
}
```

Exemplo Curl:

```bash
curl -X POST http://localhost:8080/usuarios \
-H "Content-Type: application/json" \
-d '{"nome":"Teste Usuario","email":"teste@exemplo.com","senha":"senha123","role":"Admin"}'
```

### Verificar se o usuário foi criado

Faça uma requisição GET para `/usuarios` para listar todos os usuários e verificar se o novo usuário aparece.

---

## Testar login e autenticação (em desenvolvimento)

- Atualmente, o sistema não possui autenticação implementada.
- Futuramente, será implementado Spring Security com JWT para autenticação e controle de acesso.

---

## Testar outros endpoints

- Consulte o guia anterior para testar clientes, motoristas, ambulâncias e hospitais.
