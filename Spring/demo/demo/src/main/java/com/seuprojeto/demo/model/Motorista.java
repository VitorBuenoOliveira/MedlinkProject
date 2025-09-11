package com.seuprojeto.demo.model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

@Entity
public class Motorista {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nome;
    private String carteiraHabilitacao;
    private String telefone;
    private String regiaoAtuacao;

    // Constructors
    public Motorista() {}

    public Motorista(String nome, String carteiraHabilitacao, String telefone, String regiaoAtuacao) {
        this.nome = nome;
        this.carteiraHabilitacao = carteiraHabilitacao;
        this.telefone = telefone;
        this.regiaoAtuacao = regiaoAtuacao;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }

    public String getCarteiraHabilitacao() { return carteiraHabilitacao; }
    public void setCarteiraHabilitacao(String carteiraHabilitacao) { this.carteiraHabilitacao = carteiraHabilitacao; }

    public String getTelefone() { return telefone; }
    public void setTelefone(String telefone) { this.telefone = telefone; }

    public String getRegiaoAtuacao() { return regiaoAtuacao; }
    public void setRegiaoAtuacao(String regiaoAtuacao) { this.regiaoAtuacao = regiaoAtuacao; }
}
