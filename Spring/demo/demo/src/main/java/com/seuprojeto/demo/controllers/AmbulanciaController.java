package com.seuprojeto.demo.controllers;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.seuprojeto.demo.model.Ambulancia;
import com.seuprojeto.demo.model.AmbulanciaMotoristaDTO;
import com.seuprojeto.demo.model.Motorista;
import com.seuprojeto.demo.repository.AmbulanciaRepository;
import com.seuprojeto.demo.repository.MotoristaRepository;

@RestController
@RequestMapping("/ambulancias")
public class AmbulanciaController {

    private final AmbulanciaRepository ambulanciaRepository;
    private final MotoristaRepository motoristaRepository;

    public AmbulanciaController(AmbulanciaRepository ambulanciaRepository, MotoristaRepository motoristaRepository) {
        this.ambulanciaRepository = ambulanciaRepository;
        this.motoristaRepository = motoristaRepository;
    }

    @GetMapping
    public List<Ambulancia> listar() {
        return ambulanciaRepository.findAll();
    }

    @PostMapping
    public Ambulancia salvar(@RequestBody Ambulancia ambulancia) {
        return ambulanciaRepository.save(ambulancia);
    }

    @GetMapping("/{id}")
    public Ambulancia buscarPorId(@PathVariable Long id) {
        return ambulanciaRepository.findById(id).orElseThrow(() -> new RuntimeException("Ambulância não encontrada"));
    }

    @PutMapping("/{id}")
    public Ambulancia atualizar(@PathVariable Long id, @RequestBody Ambulancia ambulanciaAtualizada) {
        return ambulanciaRepository.findById(id).map(ambulancia -> {
            ambulancia.setPlaca(ambulanciaAtualizada.getPlaca());
            ambulancia.setModelo(ambulanciaAtualizada.getModelo());
            ambulancia.setCapacidade(ambulanciaAtualizada.getCapacidade());
            ambulancia.setStatus(ambulanciaAtualizada.getStatus());
            ambulancia.setMotoristaId(ambulanciaAtualizada.getMotoristaId());
            ambulancia.setLatitude(ambulanciaAtualizada.getLatitude());
            ambulancia.setLongitude(ambulanciaAtualizada.getLongitude());
            return ambulanciaRepository.save(ambulancia);
        }).orElseThrow(() -> new RuntimeException("Ambulância não encontrada"));
    }

    @DeleteMapping("/{id}")
    public void excluir(@PathVariable Long id) {
        ambulanciaRepository.deleteById(id);
    }

    @GetMapping("/combined")
    public List<AmbulanciaMotoristaDTO> listarCombined() {
        return ambulanciaRepository.findAll().stream().map(ambulancia -> {
            Motorista motorista = null;
            if (ambulancia.getMotoristaId() != null) {
                motorista = motoristaRepository.findById(ambulancia.getMotoristaId()).orElse(null);
            }
            return new AmbulanciaMotoristaDTO(
                ambulancia.getId(),
                ambulancia.getPlaca(),
                ambulancia.getModelo(),
                ambulancia.getCapacidade(),
                ambulancia.getStatus(),
                ambulancia.getLatitude(),
                ambulancia.getLongitude(),
                motorista != null ? motorista.getId() : null,
                motorista != null ? motorista.getNome() : null,
                motorista != null ? motorista.getTelefone() : null
            );
        }).collect(Collectors.toList());
    }
}
