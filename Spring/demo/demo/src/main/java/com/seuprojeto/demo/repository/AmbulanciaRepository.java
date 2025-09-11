package com.seuprojeto.demo.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.seuprojeto.demo.model.Ambulancia;

@Repository
public interface AmbulanciaRepository extends JpaRepository<Ambulancia, Long> {
}
