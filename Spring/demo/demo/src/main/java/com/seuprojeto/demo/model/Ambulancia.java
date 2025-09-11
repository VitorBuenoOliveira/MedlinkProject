package com.seuprojeto.demo.model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

import jakarta.persistence.Column;

@Entity
public class Ambulancia {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String placa;
    private String modelo;
    private Integer capacidade;
    private String status; // disponivel, em_uso, manutencao

    @Column(name = "motorista_id")
    private Long motoristaId;

    private Double latitude;
    private Double longitude;

    // Constructors
    public Ambulancia() {}

    public Ambulancia(String placa, String modelo, Integer capacidade, String status, Long motoristaId, Double latitude, Double longitude) {
        this.placa = placa;
        this.modelo = modelo;
        this.capacidade = capacidade;
        this.status = status;
        this.motoristaId = motoristaId;
        this.latitude = latitude;
        this.longitude = longitude;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getPlaca() { return placa; }
    public void setPlaca(String placa) { this.placa = placa; }

    public String getModelo() { return modelo; }
    public void setModelo(String modelo) { this.modelo = modelo; }

    public Integer getCapacidade() { return capacidade; }
    public void setCapacidade(Integer capacidade) { this.capacidade = capacidade; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Long getMotoristaId() { return motoristaId; }
    public void setMotoristaId(Long motoristaId) { this.motoristaId = motoristaId; }

    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }

    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }
}
