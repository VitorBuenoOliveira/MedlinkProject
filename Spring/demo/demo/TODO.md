# TODO List for Patient Transportation Management System

## 1. Database and Models
- [x] Create Motorista entity with fields: id, nome, carteiraHabilitacao, telefone, regiaoAtuacao
- [x] Create Ambulancia entity with fields: id, placa, modelo, capacidade, status (disponivel, em_uso, manutencao)
- [x] Create Hospital entity with fields: id, nome, endereco, especialidades
- [x] Update Cliente entity to include ODS-related fields (e.g., prioridadeSaude for ODS 3, inovacao for ODS 9, etc.)
- [x] Create SQL scripts for database schema (create tables, relationships)

## 2. Authentication and Security
- [ ] Temporarily disabled role-based access control to allow open access for testing

## 3. Backend Controllers and Endpoints
- [ ] Create AgendaController for generating and managing daily agendas
- [x] Add endpoints in ClienteController: query by date, cancel request, confirm transport
- [ ] Create RelatorioController for statistical reports (trips, patients, absences)
- [x] Add /clientes/estatisticas endpoint for dashboard chart
- [ ] Implement PDF generation for agenda export

## 4. Business Logic
- [ ] Implement agenda generation logic (distribute patients to drivers based on region/time)
- [ ] Add validation for required fields and business rules
- [ ] Implement error handling for scenarios like no available drivers

## 5. Frontend Updates
- [ ] Update dashboard.html to include new forms (e.g., for agenda, reports)
- [ ] Add authentication UI
- [ ] Integrate new endpoints for stats and agenda

## 6. Testing and Validation
- [ ] Add unit tests for new entities and controllers
- [ ] Test database connections and queries
- [ ] Validate ODS implementation

## 7. Deployment and Documentation
- [ ] Prepare for cloud deployment (update DB config)
- [ ] Document API endpoints
- [ ] Final integration testing
- 
# TODO List for Implementing Combined Ambulancia-Motorista Endpoint

- [ ] Update Ambulancia.java model to add motoristaId (Long), latitude (Double), longitude (Double)
- [ ] Update schema.sql to add motorista_id, latitude, longitude columns to ambulancia table
- [ ] Create AmbulanciaMotoristaDTO.java for combined response data
- [ ] Update AmbulanciaController.java to add /combined endpoint returning list of DTOs
- [ ] Update geolocation.html to fetch data from /ambulancias/combined endpoint instead of hardcoded data
- [ ] Test the endpoint and HTML functionality