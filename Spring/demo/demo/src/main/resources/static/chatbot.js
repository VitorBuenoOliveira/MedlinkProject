// MedLink Assistant Chatbot
class MedLinkBot {
    constructor() {
        this.isOpen = false;
        this.currentPage = this.detectCurrentPage();
        this.init();
    }

    detectCurrentPage() {
        const path = window.location.pathname;
        const page = path.split('/').pop() || 'home.html';
        return page.replace('.html', '');
    }

    init() {
        this.createBotUI();
        this.attachEventListeners();
    }

    createBotUI() {
        const botHTML = `
            <!-- Chatbot Button -->
            <div id="chatbot-button" class="chatbot-button">
                <i class="fas fa-robot"></i>
                <span class="chatbot-badge">?</span>
            </div>

            <!-- Chatbot Window -->
            <div id="chatbot-window" class="chatbot-window">
                <div class="chatbot-header">
                    <div class="chatbot-header-content">
                        <i class="fas fa-robot"></i>
                        <span>Assistente MedLink</span>
                    </div>
                    <button id="chatbot-close" class="chatbot-close">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
                
                <div class="chatbot-body">
                    <div class="chatbot-welcome">
                        <div class="bot-avatar">
                            <i class="fas fa-robot"></i>
                        </div>
                        <h3>Olá! 👋</h3>
                        <p>Sou o assistente virtual do MedLink. Como posso ajudar você hoje?</p>
                    </div>

                    <div class="chatbot-options">
                        <button class="chat-option" data-action="pages">
                            <i class="fas fa-sitemap"></i>
                            <span>Ver Todas as Páginas</span>
                        </button>
                        <button class="chat-option" data-action="current">
                            <i class="fas fa-info-circle"></i>
                            <span>Sobre Esta Página</span>
                        </button>
                        <button class="chat-option" data-action="help">
                            <i class="fas fa-question-circle"></i>
                            <span>Preciso de Ajuda</span>
                        </button>
                        <button class="chat-option" data-action="shortcuts">
                            <i class="fas fa-bolt"></i>
                            <span>Atalhos Rápidos</span>
                        </button>
                    </div>

                    <div id="chatbot-content" class="chatbot-content"></div>
                </div>
            </div>
        `;

        document.body.insertAdjacentHTML('beforeend', botHTML);
    }

    attachEventListeners() {
        const button = document.getElementById('chatbot-button');
        const closeBtn = document.getElementById('chatbot-close');
        const window = document.getElementById('chatbot-window');

        button.addEventListener('click', () => this.toggleChat());
        closeBtn.addEventListener('click', () => this.toggleChat());

        // Option buttons
        document.querySelectorAll('.chat-option').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const action = e.currentTarget.dataset.action;
                this.handleAction(action);
            });
        });
    }

    toggleChat() {
        this.isOpen = !this.isOpen;
        const window = document.getElementById('chatbot-window');
        const button = document.getElementById('chatbot-button');
        
        if (this.isOpen) {
            window.classList.add('active');
            button.classList.add('active');
        } else {
            window.classList.remove('active');
            button.classList.remove('active');
        }
    }

    handleAction(action) {
        const content = document.getElementById('chatbot-content');
        
        switch(action) {
            case 'pages':
                content.innerHTML = this.getPagesContent();
                break;
            case 'current':
                content.innerHTML = this.getCurrentPageInfo();
                break;
            case 'help':
                content.innerHTML = this.getHelpContent();
                break;
            case 'shortcuts':
                content.innerHTML = this.getShortcutsContent();
                break;
        }

        content.style.display = 'block';
        content.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }

    getPagesContent() {
        const pages = [
            { name: 'Home', icon: 'fa-home', url: 'home.html', desc: 'Página inicial com visão geral do sistema' },
            { name: 'Dashboard', icon: 'fa-chart-line', url: 'dashboard.html', desc: 'Painel de controle com estatísticas e gráficos em tempo real' },
            { name: 'Clientes', icon: 'fa-users', url: 'client_management.html', desc: 'Gerenciar cadastro e solicitações de transporte de pacientes' },
            { name: 'Motoristas', icon: 'fa-id-card', url: 'motorista_registration.html', desc: 'Cadastrar e gerenciar motoristas de ambulâncias' },
            { name: 'Ambulâncias', icon: 'fa-ambulance', url: 'ambulancia_registration.html', desc: 'Registrar e gerenciar frota de ambulâncias' },
            { name: 'Hospitais', icon: 'fa-hospital', url: 'hospital_registration.html', desc: 'Cadastrar hospitais e clínicas parceiras' },
            { name: 'Usuários', icon: 'fa-user-cog', url: 'usuario_registration.html', desc: 'Gerenciar usuários do sistema' },
            { name: 'Gestão de Ambulâncias', icon: 'fa-clipboard-list', url: 'ambulancia_management.html', desc: 'Visualizar e editar todas as ambulâncias cadastradas' },
            { name: 'Vincular Motorista', icon: 'fa-link', url: 'ambulancia_motorista.html', desc: 'Associar motoristas às ambulâncias' },
            { name: 'Geolocalização', icon: 'fa-map-marked-alt', url: 'geolocation.html', desc: 'Ver ambulâncias próximas em tempo real no mapa' },
            { name: 'Mapa Geral', icon: 'fa-map', url: 'map.html', desc: 'Visualização geral de todas as ambulâncias' },
            { name: 'Relatórios', icon: 'fa-file-chart-line', url: 'reports.html', desc: 'Estatísticas e relatórios analíticos do sistema' },
            { name: 'Agendamento', icon: 'fa-calendar-alt', url: 'scheduling.html', desc: 'Agendar e visualizar transportes programados' },
            { name: 'Rastreamento Cliente', icon: 'fa-location-arrow', url: 'cliente_track.html', desc: 'Acompanhar ambulância em tempo real (visão do cliente)' },
            { name: 'Painel Motorista', icon: 'fa-route', url: 'motorista_track.html', desc: 'Painel de navegação para motoristas' },
            { name: 'Configurações', icon: 'fa-cog', url: 'settings.html', desc: 'Personalizar tema, acessibilidade e preferências' },
            { name: 'Sobre', icon: 'fa-info-circle', url: 'about.html', desc: 'Informações sobre o sistema MedLink' }
        ];

        let html = '<div class="chat-response"><h4><i class="fas fa-sitemap"></i> Todas as Páginas</h4><div class="pages-list">';
        
        pages.forEach(page => {
            const isActive = this.currentPage === page.url.replace('.html', '');
            html += `
                <a href="${page.url}" class="page-item ${isActive ? 'active' : ''}">
                    <div class="page-icon"><i class="fas ${page.icon}"></i></div>
                    <div class="page-info">
                        <strong>${page.name}</strong>
                        <p>${page.desc}</p>
                    </div>
                </a>
            `;
        });

        html += '</div></div>';
        return html;
    }

    getCurrentPageInfo() {
        const pageInfo = {
            'home': {
                title: 'Página Inicial',
                icon: 'fa-home',
                description: 'Esta é a página inicial do MedLink. Aqui você encontra cards de acesso rápido para todas as funcionalidades principais do sistema.',
                features: ['Visão geral do sistema', 'Acesso rápido às funcionalidades', 'Cards animados com ícones']
            },
            'dashboard': {
                title: 'Dashboard',
                icon: 'fa-chart-line',
                description: 'Painel de controle analítico com estatísticas em tempo real do sistema MedLink.',
                features: ['6 KPIs animados', '3 gráficos interativos', 'Dados atualizados automaticamente', 'Indicadores de tendência']
            },
            'client_management': {
                title: 'Gerenciamento de Clientes',
                icon: 'fa-users',
                description: 'Cadastre e gerencie clientes que solicitam transporte de ambulância.',
                features: ['Cadastro de novos clientes', 'Lista de todos os clientes', 'Editar informações', 'Visualizar status']
            },
            'geolocation': {
                title: 'Geolocalização',
                icon: 'fa-map-marked-alt',
                description: 'Visualize ambulâncias próximas à sua localização em tempo real no mapa.',
                features: ['Mapa interativo', 'Ambulâncias cadastradas no banco', 'Cálculo automático de distância', 'Tempo estimado de chegada', 'Solicitar ambulância']
            },
            'motorista_track': {
                title: 'Painel do Motorista',
                icon: 'fa-route',
                description: 'Painel de navegação completo para motoristas de ambulância.',
                features: ['Mapa com rota completa', 'Informações do paciente', 'Estatísticas em tempo real', 'Integração com Google Maps']
            },
            'cliente_track': {
                title: 'Rastreamento Cliente',
                icon: 'fa-location-arrow',
                description: 'Acompanhe a ambulância chegando em tempo real.',
                features: ['Posição da ambulância', 'Tempo estimado', 'Informações do motorista', 'Botões de contato']
            },
            'settings': {
                title: 'Configurações',
                icon: 'fa-cog',
                description: 'Personalize sua experiência no sistema MedLink.',
                features: ['Tema escuro/claro', 'Modo de alto contraste', 'Texto grande', 'Notificações visuais', 'Seletor de idioma']
            }
        };

        const info = pageInfo[this.currentPage] || {
            title: 'Página do Sistema',
            icon: 'fa-file',
            description: 'Esta página faz parte do sistema MedLink.',
            features: ['Navegue pelo menu lateral para acessar outras páginas']
        };

        let html = `
            <div class="chat-response">
                <h4><i class="fas ${info.icon}"></i> ${info.title}</h4>
                <p>${info.description}</p>
                <h5>Recursos:</h5>
                <ul>
                    ${info.features.map(f => `<li>${f}</li>`).join('')}
                </ul>
            </div>
        `;

        return html;
    }

    getHelpContent() {
        return `
            <div class="chat-response">
                <h4><i class="fas fa-question-circle"></i> Como Usar o Sistema</h4>
                <div class="help-sections">
                    <div class="help-item">
                        <h5><i class="fas fa-mouse-pointer"></i> Navegação</h5>
                        <p>Use a barra lateral (sidebar) para navegar entre as páginas. Clique no ícone de menu para expandir/recolher.</p>
                    </div>
                    <div class="help-item">
                        <h5><i class="fas fa-database"></i> Dados</h5>
                        <p>O sistema está conectado ao PostgreSQL. Inicie o banco de dados para ver dados reais.</p>
                    </div>
                    <div class="help-item">
                        <h5><i class="fas fa-map"></i> Mapas</h5>
                        <p>Para usar os mapas, adicione sua chave do Google Maps API nas páginas de rastreamento.</p>
                    </div>
                    <div class="help-item">
                        <h5><i class="fas fa-palette"></i> Temas</h5>
                        <p>Acesse Configurações para alternar entre tema claro/escuro e ajustar acessibilidade.</p>
                    </div>
                </div>
            </div>
        `;
    }

    getShortcutsContent() {
        const shortcuts = [
            { name: 'Dashboard', icon: 'fa-chart-line', url: 'dashboard.html', desc: 'Estatísticas gerais' },
            { name: 'Nova Ambulância', icon: 'fa-plus-circle', url: 'ambulancia_registration.html', desc: 'Cadastrar ambulância' },
            { name: 'Novo Motorista', icon: 'fa-user-plus', url: 'motorista_registration.html', desc: 'Cadastrar motorista' },
            { name: 'Ver no Mapa', icon: 'fa-map-marked-alt', url: 'geolocation.html', desc: 'Ambulâncias próximas' },
            { name: 'Relatórios', icon: 'fa-file-chart-line', url: 'reports.html', desc: 'Ver estatísticas' },
            { name: 'Configurações', icon: 'fa-cog', url: 'settings.html', desc: 'Personalizar sistema' }
        ];

        let html = '<div class="chat-response"><h4><i class="fas fa-bolt"></i> Atalhos Rápidos</h4><div class="shortcuts-grid">';
        
        shortcuts.forEach(shortcut => {
            html += `
                <a href="${shortcut.url}" class="shortcut-item">
                    <i class="fas ${shortcut.icon}"></i>
                    <strong>${shortcut.name}</strong>
                    <span>${shortcut.desc}</span>
                </a>
            `;
        });

        html += '</div></div>';
        return html;
    }
}

// Initialize chatbot when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    // Only initialize on pages with sidebar (not login)
    if (!window.location.pathname.includes('login.html')) {
        new MedLinkBot();
    }
});
