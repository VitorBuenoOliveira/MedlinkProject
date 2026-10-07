// Utilidades de mapa do MedLink (Leaflet + OpenStreetMap, sem chave de API)
const CENTRO = [-22.858, -47.220]; // Hortolândia/SP

const STATUS = {
    em_uso: { cls: 'rota', rotulo: 'Em rota' },
    disponivel: { cls: 'livre', rotulo: 'Disponível' },
    manutencao: { cls: 'manut', rotulo: 'Manutenção' },
};
const statusDe = (s) => STATUS[s] || { cls: 'livre', rotulo: s || '-' };

// Posições aproximadas dos bairros (demonstração; o cadastro de pacientes ainda não guarda coordenadas)
const BAIRROS = {
    'Jardim Amanda': [-22.8475, -47.2090], 'Jardim Santa Amélia': [-22.8690, -47.2290],
    'Vila Real': [-22.8610, -47.2010], 'Jardim Nova Europa': [-22.8400, -47.2300],
    'Parque Orestes Ongaro': [-22.8760, -47.2150], 'Jardim Santa Clara': [-22.8520, -47.2400],
    'Centro': [-22.8585, -47.2205],
};
function posicaoPaciente(c) {
    const base = BAIRROS[c.bairro] || CENTRO;
    const j = ((c.id || 1) * 37 % 100) / 100; // espalha pacientes do mesmo bairro, de forma estável
    return [base[0] + (j - 0.5) * 0.006, base[1] + (((c.id || 1) * 53 % 100) / 100 - 0.5) * 0.006];
}

function criarMapa(id, zoom = 13) {
    const mapa = L.map(id, { zoomControl: true }).setView(CENTRO, zoom);
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
    }).addTo(mapa);
    return mapa;
}
function pino(classe, iconeFa, texto) {
    return L.divIcon({ className: '', iconSize: [34, 34], iconAnchor: [17, 17], popupAnchor: [0, -18],
        html: '<div class="ml-pin ' + classe + '">' + (texto ? texto : '<i class="fas ' + iconeFa + '"></i>') + '</div>' });
}
function distKm(a, b) {
    const R = 6371, rad = (x) => x * Math.PI / 180;
    const dLat = rad(b[0] - a[0]), dLng = rad(b[1] - a[1]);
    const h = Math.sin(dLat / 2) ** 2 + Math.cos(rad(a[0])) * Math.cos(rad(b[0])) * Math.sin(dLng / 2) ** 2;
    return 2 * R * Math.asin(Math.sqrt(h));
}
const escapar = (t) => String(t == null ? '' : t).replace(/[&<>"]/g, (ch) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[ch]));
const hoje = () => new Date().toISOString().slice(0, 10);
