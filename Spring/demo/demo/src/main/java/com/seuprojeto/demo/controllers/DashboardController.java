package com.seuprojeto.demo.controllers;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.seuprojeto.demo.model.Ambulancia;
import com.seuprojeto.demo.model.Cliente;
import com.seuprojeto.demo.repository.AmbulanciaRepository;
import com.seuprojeto.demo.repository.ClienteRepository;
import com.seuprojeto.demo.repository.HospitalRepository;
import com.seuprojeto.demo.repository.MotoristaRepository;

/** Indicadores do dashboard, calculados a partir do banco. */
@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    private final ClienteRepository clienteRepository;
    private final AmbulanciaRepository ambulanciaRepository;
    private final MotoristaRepository motoristaRepository;
    private final HospitalRepository hospitalRepository;

    public DashboardController(ClienteRepository clienteRepository, AmbulanciaRepository ambulanciaRepository,
                               MotoristaRepository motoristaRepository, HospitalRepository hospitalRepository) {
        this.clienteRepository = clienteRepository;
        this.ambulanciaRepository = ambulanciaRepository;
        this.motoristaRepository = motoristaRepository;
        this.hospitalRepository = hospitalRepository;
    }

    @GetMapping("/stats")
    public Map<String, Object> stats() {
        LocalDate hoje = LocalDate.now();
        List<Cliente> todos = clienteRepository.findAll();
        List<Cliente> doDia = todos.stream().filter(c -> hoje.equals(c.getDataAtendimento())).toList();
        List<Ambulancia> frota = ambulanciaRepository.findAll();

        long emUso = frota.stream().filter(a -> "em_uso".equals(a.getStatus())).count();
        long disponiveis = frota.stream().filter(a -> "disponivel".equals(a.getStatus())).count();
        long manutencao = frota.stream().filter(a -> "manutencao".equals(a.getStatus())).count();
        long operacionais = frota.size() - manutencao;
        long atendidos = doDia.stream().filter(Cliente::isAtendido).count();

        Map<String, Object> out = new LinkedHashMap<>();
        out.put("data", hoje.toString());
        out.put("pacientesHoje", doDia.size());
        out.put("embarcados", atendidos);
        out.put("pendentes", doDia.size() - atendidos);
        out.put("pacientesCadastrados", todos.size());
        out.put("motoristas", motoristaRepository.count());
        out.put("hospitais", hospitalRepository.count());
        out.put("veiculos", frota.size());
        out.put("veiculosEmOperacao", emUso);
        out.put("ocupacaoFrotaPct", operacionais == 0 ? 0 : Math.round(100.0 * emUso / operacionais));

        Map<String, Long> status = new LinkedHashMap<>();
        status.put("Em rota", emUso);
        status.put("Disponível", disponiveis);
        status.put("Manutenção", manutencao);
        out.put("frotaPorStatus", status);

        out.put("porTratamento", contar(doDia, c -> vazio(c.getTipo(), "Outros")));
        out.put("porGrupo", contar(doDia, c -> rotuloGrupo(c.getGrupoVulneravel())));
        out.put("porDestino", contar(doDia, c -> vazio(c.getDestino(), "Sem destino")));
        out.put("porBairro", contar(doDia, c -> vazio(c.getBairro(), "Sem bairro")));

        // saídas por hora (a hora vem de "HH:mm" do horário da van)
        Map<String, Long> porHora = doDia.stream()
                .filter(c -> c.getHorarioVan() != null && c.getHorarioVan().length() >= 2)
                .collect(Collectors.groupingBy(c -> c.getHorarioVan().substring(0, 2) + "h",
                        java.util.TreeMap::new, Collectors.counting()));
        out.put("saidasPorHora", porHora);
        return out;
    }

    private static List<Map<String, Object>> contar(List<Cliente> clientes, Function<Cliente, String> chave) {
        return clientes.stream().collect(Collectors.groupingBy(chave, Collectors.counting()))
                .entrySet().stream()
                .sorted(Map.Entry.<String, Long>comparingByValue(Comparator.reverseOrder()).thenComparing(Map.Entry.comparingByKey()))
                .map(e -> {
                    Map<String, Object> item = new LinkedHashMap<>();
                    item.put("rotulo", e.getKey());
                    item.put("total", e.getValue());
                    return item;
                })
                .collect(Collectors.toCollection(ArrayList::new));
    }

    private static String vazio(String valor, String padrao) {
        return valor == null || valor.isBlank() ? padrao : valor;
    }

    private static String rotuloGrupo(String grupo) {
        if (grupo == null || grupo.isBlank() || "nenhum".equals(grupo)) return "Sem condição especial";
        return switch (grupo) {
            case "cadeirante" -> "Cadeirante";
            case "maca" -> "Maca";
            case "crianca" -> "Criança";
            case "idoso" -> "Idoso";
            default -> grupo;
        };
    }
}
