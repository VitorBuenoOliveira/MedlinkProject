package com.seuprojeto.demo.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.seuprojeto.demo.model.Motorista;

@Repository
public interface MotoristaRepository extends JpaRepository<Motorista, Long> {
}
