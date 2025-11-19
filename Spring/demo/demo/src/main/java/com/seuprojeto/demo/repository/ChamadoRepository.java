package com.seuprojeto.demo.repository;

import com.seuprojeto.demo.model.Chamado;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChamadoRepository extends JpaRepository<Chamado, Long> {

    List<Chamado> findByStatus(Chamado.StatusChamado status);

    @Query("SELECT c FROM Chamado c WHERE c.motorista.id = :motoristaId AND c.status IN ('ACEITO', 'A_CAMINHO')")
    List<Chamado> findActiveCallsByMotorista(@Param("motoristaId") Long motoristaId);

    @Query("SELECT c FROM Chamado c WHERE c.cliente.id = :clienteId AND c.status IN ('PENDENTE', 'ACEITO', 'A_CAMINHO') ORDER BY c.dataCriacao DESC")
    List<Chamado> findActiveCallsByCliente(@Param("clienteId") Long clienteId);

    List<Chamado> findByClienteIdOrderByDataCriacaoDesc(Long clienteId);
}
