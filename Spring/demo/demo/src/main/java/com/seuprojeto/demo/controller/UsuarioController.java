package com.seuprojeto.demo.controller;

import com.seuprojeto.demo.model.Usuario;
import com.seuprojeto.demo.repository.UsuarioRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.Optional;

@RestController
@RequestMapping("/usuarios")
public class UsuarioController {

    private final UsuarioRepository repository;
    private final PasswordEncoder passwordEncoder;

    public UsuarioController(UsuarioRepository repository, PasswordEncoder passwordEncoder) {
        this.repository = repository;
        this.passwordEncoder = passwordEncoder;
    }

    @GetMapping
    public List<Usuario> listar() {
        return repository.findAll();
    }

    @PostMapping
    public ResponseEntity<?> salvar(@RequestBody Usuario usuario) {
        if (repository.findByEmail(usuario.getEmail()).isPresent()) {
            return ResponseEntity.badRequest().body("Email já cadastrado");
        }
        usuario.setSenha(passwordEncoder.encode(usuario.getSenha()));
        Usuario saved = repository.save(usuario);
        return ResponseEntity.ok(saved);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Usuario> buscarPorId(@PathVariable Long id) {
        Optional<Usuario> usuario = repository.findById(id);
        return usuario.map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Usuario> atualizar(@PathVariable Long id, @RequestBody Usuario usuarioAtualizado) {
        return repository.findById(id).map(usuario -> {
            usuario.setNome(usuarioAtualizado.getNome());
            usuario.setEmail(usuarioAtualizado.getEmail());
            if (usuarioAtualizado.getSenha() != null && !usuarioAtualizado.getSenha().isEmpty()) {
                usuario.setSenha(passwordEncoder.encode(usuarioAtualizado.getSenha()));
            }
            usuario.setRole(usuarioAtualizado.getRole());
            return ResponseEntity.ok(repository.save(usuario));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> excluir(@PathVariable Long id) {
        if (repository.existsById(id)) {
            repository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    @GetMapping("/quantidade")
    public Map<String, Long> quantidadeUsuarios() {
        long total = repository.count();
        Map<String, Long> mapa = new HashMap<>();
        mapa.put("Total de Usuários", total);
        return mapa;
    }

    @GetMapping("/role/{role}")
    public List<Usuario> listarPorRole(@PathVariable String role) {
        return repository.findAll().stream()
            .filter(u -> role.equals(u.getRole()))
            .toList();
    }
}
