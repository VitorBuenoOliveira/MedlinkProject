package com.seuprojeto.demo.controllers;

import java.util.List;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.seuprojeto.demo.model.Motorista;
import com.seuprojeto.demo.repository.MotoristaRepository;

@RestController
@RequestMapping("/motoristas")
public class MotoristaController {

    private final MotoristaRepository repository;

    public MotoristaController(MotoristaRepository repository) {
        this.repository = repository;
    }

    @GetMapping
    public List<Motorista> listar() {
        return repository.findAll();
    }

    @PostMapping
    public Motorista salvar(@RequestBody Motorista motorista) {
        return repository.save(motorista);
    }

    @GetMapping("/{id}")
    public Motorista buscarPorId(@PathVariable Long id) {
        return repository.findById(id).orElseThrow(() -> new RuntimeException("Motorista não encontrado"));
    }

    @PutMapping("/{id}")
    public Motorista atualizar(@PathVariable Long id, @RequestBody Motorista motoristaAtualizado) {
        return repository.findById(id).map(motorista -> {
            motorista.setNome(motoristaAtualizado.getNome());
            motorista.setCarteiraHabilitacao(motoristaAtualizado.getCarteiraHabilitacao());
            motorista.setTelefone(motoristaAtualizado.getTelefone());
            motorista.setRegiaoAtuacao(motoristaAtualizado.getRegiaoAtuacao());
            return repository.save(motorista);
        }).orElseThrow(() -> new RuntimeException("Motorista não encontrado"));
    }

    @DeleteMapping("/{id}")
    public void excluir(@PathVariable Long id) {
        repository.deleteById(id);
    }
}
