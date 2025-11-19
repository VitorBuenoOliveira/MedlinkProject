package com.seuprojeto.demo.controllers;

import com.seuprojeto.demo.model.Chamado;
import com.seuprojeto.demo.model.Cliente;
import com.seuprojeto.demo.model.Motorista;
import com.seuprojeto.demo.repository.ChamadoRepository;
import com.seuprojeto.demo.repository.ClienteRepository;
import com.seuprojeto.demo.repository.MotoristaRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/chamados")
@CrossOrigin(origins = "*")
public class ChamadoController {

    private final ChamadoRepository chamadoRepository;
    private final ClienteRepository clienteRepository;
    private final MotoristaRepository motoristaRepository;

    public ChamadoController(ChamadoRepository chamadoRepository,
                           ClienteRepository clienteRepository,
                           MotoristaRepository motoristaRepository) {
        this.chamadoRepository = chamadoRepository;
        this.clienteRepository = clienteRepository;
        this.motoristaRepository = motoristaRepository;
    }

    @PostMapping("/emergencia")
    public ResponseEntity<Chamado> criarChamadoEmergencia(@RequestBody ChamadoRequest request) {
        Optional<Cliente> clienteOpt = clienteRepository.findById(request.getClienteId());
        if (!clienteOpt.isPresent()) {
            return ResponseEntity.badRequest().build();
        }

        Chamado chamado = new Chamado(
            clienteOpt.get(),
            request.getLatitude(),
            request.getLongitude(),
            request.getPrioridade(),
            request.getDescricao()
        );

        Chamado savedChamado = chamadoRepository.save(chamado);
        return ResponseEntity.ok(savedChamado);
    }

    @GetMapping("/pendentes")
    public List<Chamado> getChamadosPendentes() {
        return chamadoRepository.findByStatus(Chamado.StatusChamado.PENDENTE);
    }

    @PutMapping("/{id}/aceitar")
    public ResponseEntity<Chamado> aceitarChamado(@PathVariable Long id, @RequestParam Long motoristaId) {
        Optional<Chamado> chamadoOpt = chamadoRepository.findById(id);
        Optional<Motorista> motoristaOpt = motoristaRepository.findById(motoristaId);

        if (!chamadoOpt.isPresent() || !motoristaOpt.isPresent()) {
            return ResponseEntity.notFound().build();
        }

        Chamado chamado = chamadoOpt.get();
        if (chamado.getStatus() != Chamado.StatusChamado.PENDENTE) {
            return ResponseEntity.badRequest().build();
        }

        chamado.setMotorista(motoristaOpt.get());
        chamado.setStatus(Chamado.StatusChamado.ACEITO);
        chamado.setDataAceitacao(LocalDateTime.now());

        Chamado updatedChamado = chamadoRepository.save(chamado);
        return ResponseEntity.ok(updatedChamado);
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<Chamado> atualizarStatus(@PathVariable Long id, @RequestParam Chamado.StatusChamado status) {
        Optional<Chamado> chamadoOpt = chamadoRepository.findById(id);
        if (!chamadoOpt.isPresent()) {
            return ResponseEntity.notFound().build();
        }

        Chamado chamado = chamadoOpt.get();
        chamado.setStatus(status);

        if (status == Chamado.StatusChamado.CONCLUIDO) {
            chamado.setDataConclusao(LocalDateTime.now());
        }

        Chamado updatedChamado = chamadoRepository.save(chamado);
        return ResponseEntity.ok(updatedChamado);
    }

    @PutMapping("/{id}/localizacao-ambulancia")
    public ResponseEntity<Chamado> atualizarLocalizacaoAmbulancia(@PathVariable Long id,
                                                                 @RequestParam Double latitude,
                                                                 @RequestParam Double longitude) {
        Optional<Chamado> chamadoOpt = chamadoRepository.findById(id);
        if (!chamadoOpt.isPresent()) {
            return ResponseEntity.notFound().build();
        }

        Chamado chamado = chamadoOpt.get();
        chamado.setLatitudeAmbulancia(latitude);
        chamado.setLongitudeAmbulancia(longitude);

        Chamado updatedChamado = chamadoRepository.save(chamado);
        return ResponseEntity.ok(updatedChamado);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Chamado> getChamadoById(@PathVariable Long id) {
        Optional<Chamado> chamado = chamadoRepository.findById(id);
        return chamado.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping("/motorista/{motoristaId}/ativo")
    public ResponseEntity<Chamado> getChamadoAtivoMotorista(@PathVariable Long motoristaId) {
        List<Chamado> chamadosAtivos = chamadoRepository.findActiveCallsByMotorista(motoristaId);
        if (chamadosAtivos.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(chamadosAtivos.get(0));
    }

    public static class ChamadoRequest {
        private Long clienteId;
        private Double latitude;
        private Double longitude;
        private String prioridade;
        private String descricao;

        // Getters e Setters
        public Long getClienteId() { return clienteId; }
        public void setClienteId(Long clienteId) { this.clienteId = clienteId; }

        public Double getLatitude() { return latitude; }
        public void setLatitude(Double latitude) { this.latitude = latitude; }

        public Double getLongitude() { return longitude; }
        public void setLongitude(Double longitude) { this.longitude = longitude; }

        public String getPrioridade() { return prioridade; }
        public void setPrioridade(String prioridade) { this.prioridade = prioridade; }

        public String getDescricao() { return descricao; }
        public void setDescricao(String descricao) { this.descricao = descricao; }
    }
}
