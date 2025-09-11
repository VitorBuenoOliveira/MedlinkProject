package com.seuprojeto.demo.controllers;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.seuprojeto.demo.model.Usuario;
import com.seuprojeto.demo.repository.UsuarioRepository;
import com.seuprojeto.demo.util.JwtUtil;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public AuthController(AuthenticationManager authenticationManager,
                         UsuarioRepository usuarioRepository,
                         PasswordEncoder passwordEncoder,
                         JwtUtil jwtUtil) {
        this.authenticationManager = authenticationManager;
        this.usuarioRepository = usuarioRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> loginRequest) {
        String email = loginRequest.get("email");
        String senha = loginRequest.get("senha");

        try {
            System.out.println("Tentando autenticar usuário: " + email);
            Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(email, senha)
            );
            System.out.println("Autenticação bem-sucedida para: " + email);

            UserDetails userDetails = (UserDetails) authentication.getPrincipal();
            String token = jwtUtil.generateToken(userDetails);

            return ResponseEntity.ok(Map.of("token", token, "role", userDetails.getAuthorities().toString()));
        } catch (Exception e) {
            System.err.println("Falha na autenticação para: " + email + " - " + e.getMessage());
            return ResponseEntity.status(401).body("Credenciais inválidas");
        }
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody Usuario usuario) {
        if (usuarioRepository.findByEmail(usuario.getEmail()).isPresent()) {
            return ResponseEntity.badRequest().body("Email já cadastrado");
        }

        usuario.setSenha(passwordEncoder.encode(usuario.getSenha()));
        Usuario savedUser = usuarioRepository.save(usuario);

        return ResponseEntity.ok(savedUser);
    }
}
