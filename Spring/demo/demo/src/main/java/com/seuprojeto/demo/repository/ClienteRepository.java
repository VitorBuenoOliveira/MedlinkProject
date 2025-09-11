package com.seuprojeto.demo.repository;

import com.seuprojeto.demo.model.Cliente;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface ClienteRepository extends JpaRepository<Cliente, Long> {

    List<Cliente> findByDataAtendimento(LocalDate dataAtendimento);

}
