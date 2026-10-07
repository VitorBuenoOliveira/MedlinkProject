// Menu lateral do MedLink (gerado em JS e injetado em cada página)
const MENU = [
    { titulo: 'Visão geral', itens: [
        ['dashboard', '/dashboard.html', 'fa-chart-pie', 'Dashboard'],
    ]},
    { titulo: 'Operação', itens: [
        ['scheduling', '/scheduling.html', 'fa-calendar-check', 'Agendamento'],
        ['map', '/map.html', 'fa-map-location-dot', 'Mapa da frota'],
        ['cliente_track', '/cliente_track.html', 'fa-location-crosshairs', 'Rastreio do paciente'],
        ['motorista_track', '/motorista_track.html', 'fa-route', 'Painel do motorista'],
    ]},
    { titulo: 'Cadastros', itens: [
        ['client_management', '/client_management.html', 'fa-users', 'Pacientes'],
        ['ambulancia_registration', '/ambulancia_registration.html', 'fa-van-shuttle', 'Veículos'],
        ['motorista_registration', '/motorista_registration.html', 'fa-id-card', 'Motoristas'],
        ['hospital_registration', '/hospital_registration.html', 'fa-hospital', 'Destinos (hospitais)'],
        ['ambulancia_motorista', '/ambulancia_motorista.html', 'fa-link', 'Vincular motorista'],
        ['ambulancia_management', '/ambulancia_management.html', 'fa-screwdriver-wrench', 'Gestão da frota'],
        ['usuario_registration', '/usuario_registration.html', 'fa-user-plus', 'Usuários'],
    ]},
    { titulo: 'Análises', itens: [
        ['reports', '/reports.html', 'fa-chart-column', 'Relatórios'],
        ['grafico', '/grafico.html', 'fa-chart-line', 'Gráficos'],
    ]},
];

function createSidebar(activePage = '') {
    const link = ([id, href, icone, rotulo]) =>
        `<a href="${href}" ${activePage === id ? 'class="active"' : ''}><i class="fas ${icone}"></i><span>${rotulo}</span></a>`;
    const secoes = MENU.map(s =>
        `<div class="nav-section"><div class="nav-section-title">${s.titulo}</div>${s.itens.map(link).join('')}</div>`).join('');
    return `
    <div class="sidebar-overlay" onclick="toggleSidebar()"></div>
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <svg class="ml-pulse" width="34" height="34" viewBox="0 0 34 34" fill="none" aria-hidden="true">
                <rect width="34" height="34" rx="9" fill="#3FA3E8"/>
                <path d="M5 18h7l3-8 4 15 3-7h7" stroke="#071A30" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            <div class="ml-logo"><b>Med</b>Link</div>
        </div>
        <nav class="sidebar-nav">${secoes}</nav>
        <div class="sidebar-footer">
            <a href="/settings.html" ${activePage === 'settings' ? 'class="active"' : ''}><i class="fas fa-gear"></i><span>Configurações</span></a>
            <a href="/about.html" ${activePage === 'about' ? 'class="active"' : ''}><i class="fas fa-circle-info"></i><span>Sobre</span></a>
            <a href="/login.html"><i class="fas fa-right-from-bracket"></i><span>Sair</span></a>
        </div>
    </aside>`;
}

function toggleSidebar() {
    const sidebar = document.getElementById('sidebar');
    const overlay = document.querySelector('.sidebar-overlay');
    if (window.innerWidth <= 768) {
        sidebar.classList.toggle('active');
        if (overlay) overlay.classList.toggle('active');
    } else {
        sidebar.classList.toggle('collapsed');
        document.body.classList.toggle('sidebar-collapsed');
    }
}

window.addEventListener('DOMContentLoaded', () => {
    // fecha o menu no celular ao escolher uma página
    document.querySelectorAll('.sidebar-nav a').forEach(a => a.addEventListener('click', () => {
        if (window.innerWidth <= 768) toggleSidebar();
    }));
    window.addEventListener('resize', () => {
        const sidebar = document.getElementById('sidebar');
        if (!sidebar) return;
        if (window.innerWidth > 768) {
            sidebar.classList.remove('active');
            const overlay = document.querySelector('.sidebar-overlay');
            if (overlay) overlay.classList.remove('active');
        } else {
            sidebar.classList.remove('collapsed');
            document.body.classList.remove('sidebar-collapsed');
        }
    });
});
