package com.seuprojeto.demo.model;

import java.time.LocalDate;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

@Entity
public class Cliente {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String cartao;
    private String tipo;
    private String horarioVan;
    private LocalDate dataNascimento;
    private LocalDate dataAtendimento; // Data do atendimento/serviço
    private String nome;
    private String endereco;
    private String bairro;
    private String telefone;
    private String destino;
    private String horarioAtendimento;
    private Integer vagas;
    private String tratamento;

    // Campos do acompanhante
    private String cartaoAcompanhante;
    private String nomeAcompanhante;
    private LocalDate dataNascimentoAcompanhante;

    // Status atendimento
    private boolean atendido = false;

    // ODS 3 - Boa Saude e Bem-Estar
    private String prioridadeSaude; // e.g., "alta", "media", "baixa"

    // ODS 9 - Industria, Inovacao e Infraestrutura
    private String inovacao; // e.g., "tecnologia_assistiva", "monitoramento_remoto"

    // ODS 10 - Reducao das Desigualdades
    private String grupoVulneravel; // e.g., "idoso", "deficiente", "baixa_renda"

    // ODS 11 - Cidades e Comunidades Sustentaveis
    private String transporteSustentavel; // e.g., "veiculo_eletrico", "otimizacao_rotas"

    // ====================
    // Getters e Setters
    // ====================

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getCartao() { return cartao; }
    public void setCartao(String cartao) { this.cartao = cartao; }

    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }

    public String getHorarioVan() { return horarioVan; }
    public void setHorarioVan(String horarioVan) { this.horarioVan = horarioVan; }

    public LocalDate getDataNascimento() { return dataNascimento; }
    public void setDataNascimento(LocalDate dataNascimento) { this.dataNascimento = dataNascimento; }

    public LocalDate getDataAtendimento() { return dataAtendimento; }
    public void setDataAtendimento(LocalDate dataAtendimento) { this.dataAtendimento = dataAtendimento; }

    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }

    public String getEndereco() { return endereco; }
    public void setEndereco(String endereco) { this.endereco = endereco; }

    public String getBairro() { return bairro; }
    public void setBairro(String bairro) { this.bairro = bairro; }

    public String getTelefone() { return telefone; }
    public void setTelefone(String telefone) { this.telefone = telefone; }

    public String getDestino() { return destino; }
    public void setDestino(String destino) { this.destino = destino; }

    public String getHorarioAtendimento() { return horarioAtendimento; }
    public void setHorarioAtendimento(String horarioAtendimento) { this.horarioAtendimento = horarioAtendimento; }

    public Integer getVagas() { return vagas; }
    public void setVagas(Integer vagas) { this.vagas = vagas; }

    public String getTratamento() { return tratamento; }
    public void setTratamento(String tratamento) { this.tratamento = tratamento; }

    public String getCartaoAcompanhante() { return cartaoAcompanhante; }
    public void setCartaoAcompanhante(String cartaoAcompanhante) { this.cartaoAcompanhante = cartaoAcompanhante; }

    public String getNomeAcompanhante() { return nomeAcompanhante; }
    public void setNomeAcompanhante(String nomeAcompanhante) { this.nomeAcompanhante = nomeAcompanhante; }

    public LocalDate getDataNascimentoAcompanhante() { return dataNascimentoAcompanhante; }
    public void setDataNascimentoAcompanhante(LocalDate dataNascimentoAcompanhante) { this.dataNascimentoAcompanhante = dataNascimentoAcompanhante; }

    public boolean isAtendido() { return atendido; }
    public void setAtendido(boolean atendido) { this.atendido = atendido; }

    public String getPrioridadeSaude() { return prioridadeSaude; }
    public void setPrioridadeSaude(String prioridadeSaude) { this.prioridadeSaude = prioridadeSaude; }

    public String getInovacao() { return inovacao; }
    public void setInovacao(String inovacao) { this.inovacao = inovacao; }

    public String getGrupoVulneravel() { return grupoVulneravel; }
    public void setGrupoVulneravel(String grupoVulneravel) { this.grupoVulneravel = grupoVulneravel; }

    public String getTransporteSustentavel() { return transporteSustentavel; }
    public void setTransporteSustentavel(String transporteSustentavel) { this.transporteSustentavel = transporteSustentavel; }
}
