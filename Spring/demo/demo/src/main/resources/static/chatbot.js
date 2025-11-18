// MedLink Chatbot Assistant
(function() {
    'use strict';

    // Page descriptions
    const pageInfo = {
        'home.html': {
            title: '🏠 Home',
            description: 'Página inicial do sistema com visão geral de todas as funcionalidades.',
            details: 'Aqui você encontra cards de acesso rápido para todas as áreas do sistema.'
        },
        'dashboard.html': {
            title: '📊 Dashboard',
            description: 'Dashboard profissional com métricas e análises em tempo real.',
            details: 'Visualize KPIs, gráficos de atendimentos, status de ambulâncias e chamados por região.'
        },
        'client_management.html': {
            title: '👥 Clientes',
            description: 'Gerenciamento de solicitações de transporte de pacientes.',
            details: 'Cadastre clientes, gerencie solicitações e acompanhe o status dos atendimentos.'
        },
        'motorista_registration.html': {
            title: '🚗 Motoristas',
            description: 'Cadastro e gerenciamento de motoristas de ambulância.',
            details: 'Registre motoristas, atualize informações e gerencie a equipe de condutores.'
        },
        'ambulancia_registration.html': {
            title: '🚑 Ambulâncias',
            description: 'Gerenciamento da frota de veículos de emergência.',
            details: 'Cadastre ambulâncias, monitore status e gerencie a manutenção da frota.'
        },
        'hospital_registration.html': {
            title: '🏥 Hospitais',
            description: 'Cadastro de hospitais e clínicas de destino.',
            details: 'Registre hospitais parceiros e seus endereços para rotas de transporte.'
        },
        'usuario_registration.html': {
            title: '👤 Usuários',
            description: 'Gerenciamento de usuários do sistema.',
            details: 'Crie contas de usuário, defina permissões e gerencie acessos.'
        },
        'scheduling.html': {
            title: '📅 Agendamento',
            description: 'Criação e visualização de agendas de transporte.',
            details: 'Agende transportes, visualize calendário e gerencie compromissos.'
        },
        'geolocation.html': {
            title: '🗺️ Geolocalização',
            description: 'Visualize ambulâncias próximas em tempo real no mapa.',
            details: 'Veja ambulâncias disponíveis perto de você com distância e tempo estimado.'
        },
        'reports.html': {
            title: '📈 Relatórios',
            description: 'Estatísticas e relatórios analíticos do sistema.',
            details: 'Gere relatórios, visualize gráficos e analise dados operacionais.'
        },
        'cliente_track.html': {
            title: '📍 Rastreamento Cliente',
            description: 'Acompanhe a ambulância chegando em tempo real.',
            details: 'Veja a localização da ambulância, tempo estimado e dados do motorista.'
        },
        'motorista_track.html': {
            title: '🧭 Painel do Motorista',
            description: 'Navegação GPS para motoristas de ambulância.',
            details: 'Rota completa, informações do paciente e controles de navegação.'
        },
        'settings.html': {
            title: '⚙️ Configurações',
            description: 'Personalize tema, acessibilidade e preferências.',
            details: 'Tema escuro/claro, alto contraste, texto grande, notificações visuais.'
        },
        'about.html': {
            title: 'ℹ️ Sobre',
            description: 'Informações sobre o sistema MedLink.',
            details: 'Conheça mais sobre o sistema, equipe e tecnologias utilizadas.'
        }
    };

    // Create chatbot HTML
    function createChatbot() {
        const chatbotHTML = `
            <div id="medlink-chatbot">
                <div id="chatbot-button" class="chatbot-button">
                    <i class="fas fa-robot"></i>
                </div>
                
                <div id="chatbot-window" class="chatbot-window">
                    <div class="chatbot-header">
                        <div class="chatbot-title">
                            <i class="fas fa-robot"></i>
                            <span>MedLink Assistente</span>
                        </div>
                        <button id="chatbot-close" class="chatbot-close-btn">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                    
                    <div class="chatbot-body">
                        <div class="chatbot-message bot-message">
                            <p>Olá! 👋 Sou o assistente do MedLink.</p>
                            <p>Posso ajudar você a navegar pelo sistema. Selecione uma página abaixo:</p>
                        </div>
                        
                        <div class="chatbot-pages">
                            ${Object.keys(pageInfo).map(page => `
                                <div class="chatbot-page-card" data-page="${page}">
                                    <div class="page-card-title">${pageInfo[page].title}</div>
                                    <div class="page-card-desc">${pageInfo[page].description}</div>
                                </div>
                            `).join('')}
                        </div>
                    </div>
                </div>
            </div>
        `;
        
        document.body.insertAdjacentHTML('beforeend', chatbotHTML);
    }

    // Initialize chatbot
    function initChatbot() {
        const button = document.getElementById('chatbot-button');
        const window = document.getElementById('chatbot-window');
        const closeBtn = document.getElementById('chatbot-close');
        const pageCards = document.querySelectorAll('.chatbot-page-card');

        // Toggle chatbot window
        button.addEventListener('click', () => {
            window.classList.toggle('active');
            button.classList.toggle('active');
        });

        // Close chatbot
        closeBtn.addEventListener('click', () => {
            window.classList.remove('active');
            button.classList.remove('active');
        });

        // Handle page card clicks
        pageCards.forEach(card => {
            card.addEventListener('click', () => {
                const page = card.dataset.page;
                const info = pageInfo[page];
                
                // Show details
                const chatbotBody = document.querySelector('.chatbot-body');
                chatbotBody.innerHTML = `
                    <div class="chatbot-message bot-message">
                        <h3>${info.title}</h3>
                        <p><strong>${info.description}</strong></p>
                        <p>${info.details}</p>
                        <button class="chatbot-navigate-btn" data-page="${page}">
                            <i class="fas fa-arrow-right"></i> Ir para esta página
                        </button>
                        <button class="chatbot-back-btn">
                            <i class="fas fa-arrow-left"></i> Voltar
                        </button>
                    </div>
                `;

                // Handle navigation
                const navigateBtn = chatbotBody.querySelector('.chatbot-navigate-btn');
                const backBtn = chatbotBody.querySelector('.chatbot-back-btn');

                navigateBtn.addEventListener('click', () => {
                    window.location.href = page;
                });

                backBtn.addEventListener('click', () => {
                    location.reload();
                });
            });
        });

        // Close on outside click
        document.addEventListener('click', (e) => {
            if (!e.target.closest('#medlink-chatbot')) {
                window.classList.remove('active');
                button.classList.remove('active');
            }
        });
    }

    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => {
            createChatbot();
            initChatbot();
        });
    } else {
        createChatbot();
        initChatbot();
    }
})();
