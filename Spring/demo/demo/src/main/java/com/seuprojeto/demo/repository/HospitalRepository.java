package com.seuprojeto.demo.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.seuprojeto.demo.model.Hospital;

@Repository
public interface HospitalRepository extends JpaRepository<Hospital, Long> {
}
