package com.seuprojeto.demo.model;

public class AmbulanciaMotoristaDTO {

    private Long ambulanciaId;
    private String placa;
    private String modelo;
    private Integer capacidade;
    private String status;
    private Double latitude;
    private Double longitude;
    private Long motoristaId;
    private String motoristaNome;
    private String motoristaTelefone;

    // Constructors
    public AmbulanciaMotoristaDTO() {}

    public AmbulanciaMotoristaDTO(Long ambulanciaId, String placa, String modelo, Integer capacidade, String status,
                                  Double latitude, Double longitude, Long motoristaId, String motoristaNome, String motoristaTelefone) {
        this.ambulanciaId = ambulanciaId;
        this.placa = placa;
        this.modelo = modelo;
        this.capacidade = capacidade;
        this.status = status;
        this.latitude = latitude;
        this.longitude = longitude;
        this.motoristaId = motoristaId;
        this.motoristaNome = motoristaNome;
        this.motoristaTelefone = motoristaTelefone;
    }

    // Getters and Setters
    public Long getAmbulanciaId() { return ambulanciaId; }
    public void setAmbulanciaId(Long ambulanciaId) { this.ambulanciaId = ambulanciaId; }

    public String getPlaca() { return placa; }
    public void setPlaca(String placa) { this.placa = placa; }

    public String getModelo() { return modelo; }
    public void setModelo(String modelo) { this.modelo = modelo; }

    public Integer getCapacidade() { return capacidade; }
    public void setCapacidade(Integer capacidade) { this.capacidade = capacidade; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }

    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }

    public Long getMotoristaId() { return motoristaId; }
    public void setMotoristaId(Long motoristaId) { this.motoristaId = motoristaId; }

    public String getMotoristaNome() { return motoristaNome; }
    public void setMotoristaNome(String motoristaNome) { this.motoristaNome = motoristaNome; }

    public String getMotoristaTelefone() { return motoristaTelefone; }
    public void setMotoristaTelefone(String motoristaTelefone) { this.motoristaTelefone = motoristaTelefone; }
}
