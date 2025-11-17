// Sidebar HTML Generator and Functions
function createSidebar(activePage = '') {
    return `
    <!-- Mobile Toggle Button -->
    <button class="sidebar-toggle" onclick="toggleSidebar()">
        <i class="fas fa-bars"></i>
    </button>
    
    <!-- Sidebar Overlay for Mobile -->
    <div class="sidebar-overlay" onclick="toggleSidebar()"></div>
    
    <!-- Sidebar -->
    <aside class="sidebar" id="sidebar">
        <!-- Sidebar Header -->
        <div class="sidebar-header">
            <img src="medilink_logo.png" alt="MediLink Logo" class="logo" />
            <h3>MediLink System</h3>
        </div>
        
        <!-- User Profile -->
        <div class="user-profile">
            <div class="user-avatar">
                <i class="fas fa-user"></i>
            </div>
            <div class="user-info">
                <h4>Admin User</h4>
                <p>admin@medilink.com</p>
            </div>
        </div>
        
        <!-- Navigation Menu -->
        <nav class="sidebar-nav">
            <div class="nav-section">
                <div class="nav-section-title">Menu Principal</div>
                <a href="/dashboard.html" ${activePage === 'dashboard' ? 'class="active"' : ''}>
                    <i class="fas fa-home"></i>
                    <span>Dashboard</span>
                </a>
                <a href="/client_management.html" ${activePage === 'client_management' ? 'class="active"' : ''}>
                    <i class="fas fa-users"></i>
                    <span>Clientes</span>
                </a>
                <a href="/motorista_registration.html" ${activePage === 'motorista_registration' ? 'class="active"' : ''}>
                    <i class="fas fa-user-tie"></i>
                    <span>Motoristas</span>
                </a>
                <a href="/ambulancia_registration.html" ${activePage === 'ambulancia_registration' ? 'class="active"' : ''}>
                    <i class="fas fa-ambulance"></i>
                    <span>Ambulâncias</span>
                </a>
                <a href="/hospital_registration.html" ${activePage === 'hospital_registration' ? 'class="active"' : ''}>
                    <i class="fas fa-hospital"></i>
                    <span>Hospitais</span>
                </a>
                <a href="/usuario_registration.html" ${activePage === 'usuario_registration' ? 'class="active"' : ''}>
                    <i class="fas fa-user-plus"></i>
                    <span>Usuários</span>
                </a>
            </div>
            
            <div class="nav-section">
                <div class="nav-section-title">Operações</div>
                <a href="/scheduling.html" ${activePage === 'scheduling' ? 'class="active"' : ''}>
                    <i class="fas fa-calendar-alt"></i>
                    <span>Agendamento</span>
                </a>
                <a href="/cliente_track.html" ${activePage === 'cliente_track' ? 'class="active"' : ''}>
                    <i class="fas fa-map-marked-alt"></i>
                    <span>Rastreamento Cliente</span>
                </a>
                <a href="/motorista_track.html" ${activePage === 'motorista_track' ? 'class="active"' : ''}>
                    <i class="fas fa-route"></i>
                    <span>Painel Motorista</span>
                </a>
            </div>
            
            <div class="nav-section">
                <div class="nav-section-title">Mapas & Análises</div>
                <a href="/geolocation.html" ${activePage === 'geolocation' ? 'class="active"' : ''}>
                    <i class="fas fa-map-marker-alt"></i>
                    <span>Geolocalização</span>
                </a>
                <a href="/map.html" ${activePage === 'map' ? 'class="active"' : ''}>
                    <i class="fas fa-map"></i>
                    <span>Mapa Próximo</span>
                </a>
                <a href="/reports.html" ${activePage === 'reports' ? 'class="active"' : ''}>
                    <i class="fas fa-chart-bar"></i>
                    <span>Relatórios</span>
                </a>
                <a href="/grafico.html" ${activePage === 'grafico' ? 'class="active"' : ''}>
                    <i class="fas fa-chart-line"></i>
                    <span>Gráficos</span>
                </a>
            </div>
            
            <div class="nav-section">
                <div class="nav-section-title">Gerenciamento</div>
                <a href="/ambulancia_management.html" ${activePage === 'ambulancia_management' ? 'class="active"' : ''}>
                    <i class="fas fa-cogs"></i>
                    <span>Gestão Ambulâncias</span>
                </a>
                <a href="/ambulancia_motorista.html" ${activePage === 'ambulancia_motorista' ? 'class="active"' : ''}>
                    <i class="fas fa-link"></i>
                    <span>Vincular Motorista</span>
                </a>
            </div>
        </nav>
        
        <!-- Sidebar Footer -->
        <div class="sidebar-footer">
            <a href="/login.html">
                <i class="fas fa-sign-out-alt"></i>
                <span>Sair</span>
            </a>
        </div>
    </aside>
    `;
}

// Sidebar toggle for mobile and desktop collapse
function toggleSidebar() {
    const sidebar = document.getElementById('sidebar');
    const body = document.body;
    const overlay = document.querySelector('.sidebar-overlay');
    
    // Mobile behavior
    if (window.innerWidth <= 768) {
        sidebar.classList.toggle('active');
        if (overlay) overlay.classList.toggle('active');
    } 
    // Desktop collapse behavior
    else {
        sidebar.classList.toggle('collapsed');
        body.classList.toggle('sidebar-collapsed');
    }
}

// Set active menu item based on current page
window.addEventListener('DOMContentLoaded', () => {
    const currentPage = window.location.pathname;
    const menuLinks = document.querySelectorAll('.sidebar-nav a');
    
    menuLinks.forEach(link => {
        if (link.getAttribute('href') === currentPage) {
            link.classList.add('active');
        } else {
            link.classList.remove('active');
        }
    });
    
    // Handle window resize
    window.addEventListener('resize', () => {
        const sidebar = document.getElementById('sidebar');
        const body = document.body;
        
        if (window.innerWidth > 768) {
            sidebar.classList.remove('active');
            const overlay = document.querySelector('.sidebar-overlay');
            if (overlay) overlay.classList.remove('active');
        } else {
            sidebar.classList.remove('collapsed');
            body.classList.remove('sidebar-collapsed');
        }
    });
});

// Export functions for use in pages
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { createSidebar, toggleSidebar, initializeSidebar };
}
