package com.seuprojeto.demo.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "chamados")
public class Chamado {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "cliente_id")
    private Cliente cliente;

    @ManyToOne
    @JoinColumn(name = "motorista_id")
    private Motorista motorista;

    @ManyToOne
    @JoinColumn(name = "ambulancia_id")
    private Ambulancia ambulancia;

    @Enumerated(EnumType.STRING)
    private StatusChamado status;

    private Double latitudeCliente;
    private Double longitudeCliente;

    private Double latitudeAmbulancia;
    private Double longitudeAmbulancia;

    private LocalDateTime dataCriacao;
    private LocalDateTime dataAceitacao;
    private LocalDateTime dataConclusao;

    private String prioridade;
    private String descricao;

    public enum StatusChamado {
        PENDENTE,
        ACEITO,
        A_CAMINHO,
        CONCLUIDO,
        CANCELADO
    }

    // Construtores
    public Chamado() {}

    public Chamado(Cliente cliente, Double latitudeCliente, Double longitudeCliente, String prioridade, String descricao) {
        this.cliente = cliente;
        this.latitudeCliente = latitudeCliente;
        this.longitudeCliente = longitudeCliente;
        this.prioridade = prioridade;
        this.descricao = descricao;
        this.status = StatusChamado.PENDENTE;
        this.dataCriacao = LocalDateTime.now();
    }

    // Getters e Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Cliente getCliente() {
        return cliente;
    }

    public void setCliente(Cliente cliente) {
        this.cliente = cliente;
    }

    public Motorista getMotorista() {
        return motorista;
    }

    public void setMotorista(Motorista motorista) {
        this.motorista = motorista;
    }

    public Ambulancia getAmbulancia() {
        return ambulancia;
    }

    public void setAmbulancia(Ambulancia ambulancia) {
        this.ambulancia = ambulancia;
    }

    public StatusChamado getStatus() {
        return status;
    }

    public void setStatus(StatusChamado status) {
        this.status = status;
    }

    public Double getLatitudeCliente() {
        return latitudeCliente;
    }

    public void setLatitudeCliente(Double latitudeCliente) {
        this.latitudeCliente = latitudeCliente;
    }

    public Double getLongitudeCliente() {
        return longitudeCliente;
    }

    public void setLongitudeCliente(Double longitudeCliente) {
        this.longitudeCliente = longitudeCliente;
    }

    public Double getLatitudeAmbulancia() {
        return latitudeAmbulancia;
    }

    public void setLatitudeAmbulancia(Double latitudeAmbulancia) {
        this.latitudeAmbulancia = latitudeAmbulancia;
    }

    public Double getLongitudeAmbulancia() {
        return longitudeAmbulancia;
    }

    public void setLongitudeAmbulancia(Double longitudeAmbulancia) {
        this.longitudeAmbulancia = longitudeAmbulancia;
    }

    public LocalDateTime getDataCriacao() {
        return dataCriacao;
    }

    public void setDataCriacao(LocalDateTime dataCriacao) {
        this.dataCriacao = dataCriacao;
    }

    public LocalDateTime getDataAceitacao() {
        return dataAceitacao;
    }

    public void setDataAceitacao(LocalDateTime dataAceitacao) {
        this.dataAceitacao = dataAceitacao;
    }

    public LocalDateTime getDataConclusao() {
        return dataConclusao;
    }

    public void setDataConclusao(LocalDateTime dataConclusao) {
        this.dataConclusao = dataConclusao;
    }

    public String getPrioridade() {
        return prioridade;
    }

    public void setPrioridade(String prioridade) {
        this.prioridade = prioridade;
    }

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }
}
