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

import com.seuprojeto.demo.model.Hospital;
import com.seuprojeto.demo.repository.HospitalRepository;

@RestController
@RequestMapping("/hospitais")
public class HospitalController {

    private final HospitalRepository repository;

    public HospitalController(HospitalRepository repository) {
        this.repository = repository;
    }

    @GetMapping
    public List<Hospital> listar() {
        return repository.findAll();
    }

    @PostMapping
    public Hospital salvar(@RequestBody Hospital hospital) {
        return repository.save(hospital);
    }

    @GetMapping("/{id}")
    public Hospital buscarPorId(@PathVariable Long id) {
        return repository.findById(id).orElseThrow(() -> new RuntimeException("Hospital não encontrado"));
    }

    @PutMapping("/{id}")
    public Hospital atualizar(@PathVariable Long id, @RequestBody Hospital hospitalAtualizado) {
        return repository.findById(id).map(hospital -> {
            hospital.setNome(hospitalAtualizado.getNome());
            hospital.setEndereco(hospitalAtualizado.getEndereco());
            hospital.setEspecialidades(hospitalAtualizado.getEspecialidades());
            return repository.save(hospital);
        }).orElseThrow(() -> new RuntimeException("Hospital não encontrado"));
    }

    @DeleteMapping("/{id}")
    public void excluir(@PathVariable Long id) {
        repository.deleteById(id);
    }
}
