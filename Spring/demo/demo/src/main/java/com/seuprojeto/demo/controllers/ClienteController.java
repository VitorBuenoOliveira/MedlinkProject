package com.seuprojeto.demo.controllers;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.seuprojeto.demo.model.Cliente;
import com.seuprojeto.demo.repository.ClienteRepository;

@RestController
@RequestMapping("/clientes")
public class ClienteController {

    private final ClienteRepository clienteRepository;

    public ClienteController(ClienteRepository clienteRepository) {
        this.clienteRepository = clienteRepository;
    }

    @GetMapping
    public List<Cliente> getAllClientes() {
        return clienteRepository.findAll();
    }

    /** Quantidade de pacientes por tipo de atendimento (usado no gráfico da tela de clientes). */
    @GetMapping("/estatisticas")
    public Map<String, Long> estatisticas() {
        Map<String, Long> porTipo = new LinkedHashMap<>();
        clienteRepository.findAll().forEach(c ->
                porTipo.merge(c.getTipo() == null || c.getTipo().isBlank() ? "Sem tipo" : c.getTipo(), 1L, Long::sum));
        return porTipo;
    }

    @GetMapping("/{id}")
    public ResponseEntity<Cliente> getClienteById(@PathVariable Long id) {
        Optional<Cliente> cliente = clienteRepository.findById(id);
        return cliente.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Cliente> createCliente(@RequestBody Cliente cliente) {
        if (cliente.getNome() == null || cliente.getNome().isBlank()) {
            return ResponseEntity.badRequest().build();
        }
        Cliente savedCliente = clienteRepository.save(cliente);
        return ResponseEntity.ok(savedCliente);
    }

    /** Marca o paciente como atendido/embarcado (usado pelas telas de agenda e do motorista). */
    @PutMapping("/{id}/atender")
    public ResponseEntity<Cliente> atender(@PathVariable Long id) {
        return clienteRepository.findById(id).map(c -> {
            c.setAtendido(true);
            return ResponseEntity.ok(clienteRepository.save(c));
        }).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Cliente> updateCliente(@PathVariable Long id, @RequestBody Cliente clienteDetails) {
        Optional<Cliente> optionalCliente = clienteRepository.findById(id);
        if (!optionalCliente.isPresent()) {
            return ResponseEntity.notFound().build();
        }
        Cliente cliente = optionalCliente.get();
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

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCliente(@PathVariable Long id) {
        if (!clienteRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        clienteRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
