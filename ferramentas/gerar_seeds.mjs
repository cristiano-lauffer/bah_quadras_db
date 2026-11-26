// Gera os seeds de demonstração do banco a partir dos dados fixos do front.
// uso: node gerar_seeds.mjs <pasta bah_quadras_web/src> <pasta bah_quadras_db/99_inserts>
import { writeFileSync } from "node:fs";
import { pathToFileURL } from "node:url";
import { join } from "node:path";
const [src, out] = process.argv.slice(2);
const imp = (p) => import(pathToFileURL(join(src, p)).href);
const { quadras } = await imp("data/quadras.js");
const { avaliacoes } = await imp("data/avaliacoes.js");
const { reservas: reservasJoao } = await imp("data/reservas.js");
const { empresaDemo, quadrasEmpresa, agendaHoje } = await imp("data/empresa.js");

const q = (v) =>
  v === null || v === undefined
    ? "NULL"
    : typeof v === "number"
      ? String(v)
      : typeof v === "boolean"
        ? v ? "TRUE" : "FALSE"
        : `'${String(v).replace(/\\/g, "\\\\").replace(/'/g, "''")}'`;
const js = (v) => q(JSON.stringify(v));
const hoje = new Date();
hoje.setHours(12, 0, 0, 0);
const diasDe = (iso) => Math.round((new Date(`${iso}T12:00:00`) - hoje) / 86400000);
const dia = (d) => `CURDATE() + INTERVAL ${d} DAY`;
const hh = (h) => `${String(h).padStart(2, "0")}:00:00`;

const tipos = { "Futebol society": 1, "Beach tennis": 2, Futsal: 3, "Vôlei": 4, "Vôlei de quadra": 4, "Vôlei de areia": 5, Basquete: 6, "Tênis": 7, Padel: 8, Badminton: 9, "Esportes de areia": 10, "Futebol 7": 11, "Futebol 11": 12, Kart: 13 };
const pisos = { "Futebol society": "Grama sintética", "Futebol 7": "Grama sintética", "Futebol 11": "Grama sintética", Futsal: "Madeira", "Vôlei de quadra": "Madeira", Basquete: "Madeira", Badminton: "Emborrachado", "Tênis": "Saibro", "Beach tennis": "Areia", "Vôlei de areia": "Areia", "Esportes de areia": "Areia", Kart: "Asfalto" };

/* ---------- empresas e quadras ---------- */
const empresas = [];
const quadrasDb = [];
const slugParaId = {};
const separarRua = (e) => (e ?? "").split(" - ")[0];
const enderecoTexto = (rua, bairro, cidade) => `${rua} - ${bairro ? `${bairro}, ` : ""}${cidade}`;

// Arena Sport (empresa do painel de demonstração): perfil completo + 4 quadras
const { nome: _n, cnpj: _c, responsavel: _r, membroDesde: _m, ...perfilSport } = empresaDemo;
const end = empresaDemo.endereco;
empresas.push({
  id: 2, nome: "Arena Sport", cnpj: "12345678000190", telefone: "51987654321",
  endereco: `${end.rua}, ${end.numero} - ${end.bairro}, ${end.cidade}/${end.estado}`,
  perfil: { ...perfilSport, bairro: end.bairro, cidade: `${end.cidade}/${end.estado}` },
  criada: diasDe(empresaDemo.membroDesde),
});
let proxQuadra = 3;
const quadraEmpresaId = {};
for (const qe of quadrasEmpresa) {
  const pub = qe.publicaId ? quadras.find((x) => x.id === qe.publicaId) : null;
  const id = proxQuadra++;
  quadraEmpresaId[qe.id] = id;
  if (qe.publicaId) slugParaId[qe.publicaId] = id;
  const imgs = pub ? pub.imagens : [qe.imagem];
  quadrasDb.push({
    id, empresa: 2, tipo: tipos[qe.modalidade], nome: qe.nome,
    descricao: pub?.descricao ?? `${qe.nome} da Arena Sport, no centro de Viamão.`, preco: qe.preco, status: qe.status,
    piso: pisos[qe.modalidade], cobertura: qe.modalidade === "Futsal" ? "coberta" : "descoberta",
    capacidade: qe.modalidade === "Futebol society" ? 14 : qe.modalidade === "Futsal" ? 10 : 4,
    comodidades: pub?.estrutura ?? ["Vestiário", "Iluminação", "Estacionamento"], imagem: imgs[0], imagens: imgs.slice(1),
    destaque: Boolean(pub?.destaque), cobranca: "hora", minutos: null, mapa: null, grade: "sport",
  });
}

// Demais quadras de demonstração: uma empresa por espaço (a RGM Academy agrupa as três dela)
let proxEmpresa = 3;
const empresaPorNome = {};
for (const d of quadras) {
  if (d.id === "arena-sport") continue;
  const rgm = d.id.startsWith("rgm-academy");
  const nomeEmpresa = rgm ? "RGM Academy" : d.nome;
  let emp = empresaPorNome[nomeEmpresa];
  if (!emp) {
    emp = {
      id: proxEmpresa++, nome: nomeEmpresa, cnpj: null, telefone: null,
      endereco: enderecoTexto(separarRua(d.endereco), d.bairro, d.cidade),
      perfil: {
        descricao: rgm ? d.descricao.split(". ").slice(1).join(". ") : d.descricao,
        bairro: d.bairro, cidade: d.cidade, ...(d.mapa && { mapa: d.mapa }),
      },
      criada: -200,
    };
    empresaPorNome[nomeEmpresa] = emp;
    empresas.push(emp);
  }
  const id = proxQuadra++;
  slugParaId[d.id] = id;
  const kart = d.cobranca?.unidade === "bateria";
  quadrasDb.push({
    id, empresa: emp.id, tipo: tipos[d.modalidade], nome: d.nome, descricao: d.descricao,
    preco: d.preco, status: "ativa", piso: pisos[d.modalidade] ?? null,
    cobertura: /coberta|indoor|ginásio/i.test(`${d.descricao} ${d.nome}`) ? "coberta" : "descoberta",
    capacidade: null, comodidades: d.estrutura ?? [], imagem: d.imagens[0], imagens: d.imagens.slice(1),
    destaque: Boolean(d.destaque), cobranca: kart ? "bateria" : "hora", minutos: kart ? d.cobranca.minutos : null,
    mapa: d.mapa ?? null, grade: kart ? "kart" : "padrao",
  });
}

/* ---------- grades semanais ---------- */
const grades = {
  sport: Object.fromEntries(
    empresaDemo.horarios.map((h) => [h.dia, h.abre ? [Number(h.abre.slice(0, 2)), h.fecha === "00:00" ? 24 : Number(h.fecha.slice(0, 2))] : null])
  ),
  padrao: { 0: [9, 20], 1: [8, 23], 2: [8, 23], 3: [8, 23], 4: [8, 23], 5: [8, 23], 6: [8, 23] },
  kart: { 0: [10, 20], 1: [14, 22], 2: [14, 22], 3: [14, 22], 4: [14, 22], 5: [14, 23], 6: [10, 23] },
};
const horasAbertas = (qd, ds) => {
  const g = grades[qd.grade][ds];
  if (!g) return [];
  const r = [];
  for (let h = g[0]; h < g[1]; h++) r.push(h);
  return r;
};

/* ---------- reservas ---------- */
const solicitacoes = [];
let proxSol = 100;
const ocupado = new Set();
const livreEm = (qid, d, h, dur) => {
  for (let i = 0; i < dur; i++) if (ocupado.has(`${qid}|${d}|${h + i}`)) return false;
  return true;
};
function reservar(x) {
  if (x.status !== "cancelada") for (let i = 0; i < x.dur; i++) ocupado.add(`${x.qid}|${x.d}|${x.h + i}`);
  solicitacoes.push({ usuario: null, cliente: null, origem: "app", baterias: null, minutos: null, ...x, id: proxSol++ });
}
// Reservas do João (jogador de demonstração)
for (const r of reservasJoao) {
  const qid = slugParaId[r.quadraId];
  const qd = quadrasDb.find((x) => x.id === qid);
  const d = diasDe(r.data);
  reservar({
    qid, usuario: 2, d, h: Number(r.hora.slice(0, 2)), dur: r.duracao, valor: r.valor, preco: qd.preco, pagamento: "Pix",
    pago: d < 0 && r.status !== "cancelada", status: r.status === "cancelada" ? "cancelada" : "confirmada", criadaDias: Math.min(d, 0) - 5,
  });
}
// Agenda de hoje do painel da Arena Sport
for (const ag of agendaHoje) {
  const qid = quadraEmpresaId[ag.quadraId];
  const h = Number(ag.hora.slice(0, 2));
  if (!livreEm(qid, 0, h, ag.duracao)) continue;
  reservar({ qid, cliente: ag.cliente, d: 0, h, dur: ag.duracao, valor: ag.valor, preco: ag.valor / ag.duracao, pagamento: "Pix", pago: ag.pago, status: "confirmada", criadaDias: -2 });
}
// Movimento gerado (180 dias para trás e 14 para frente) nas quadras da Arena Sport e da Arena Central.
// Arena Central evita 14h-17h: os seeds 06/07 têm reservas ativas nesses horários.
const clientes = ["Lucas Ferreira", "Mariana Costa", "Rafael Martins", "Camila Souza", "Bruno Almeida", "Fernanda Lima", "Diego Santos", "Juliana Pereira", "Gustavo Ribeiro", "Aline Barbosa", "Pelada de Quinta", "Time Amigos do Bairro", "Thiago Oliveira", "Patrícia Rocha", "Leonardo Dias"];
let semente = 42;
const rnd = () => {
  semente = (semente * 16807) % 2147483647;
  return (semente - 1) / 2147483646;
};
const geradas = [
  { id: 3, preco: 80, horas: [8, 10, 14, 17, 18, 19, 20, 21] },
  { id: 4, preco: 90, horas: [8, 10, 14, 17, 18, 19, 20, 21] },
  { id: 5, preco: 70, horas: [8, 10, 14, 17, 18, 19, 20, 21] },
  { id: 1, preco: 120, horas: [9, 11, 17, 18, 19, 20] },
  { id: 2, preco: 80, horas: [9, 11, 17, 18, 19, 20] },
];
const formas = ["Pix", "Cartão", "Dinheiro"];
for (let d = -180; d <= 14; d++) {
  if (d === 0) continue;
  for (const g of geradas) {
    for (const h of g.horas) {
      if (rnd() >= (d > 0 ? 0.25 : 0.23)) continue;
      const dur = rnd() < 0.2 ? 2 : 1;
      const cancelada = rnd() < 0.07;
      const cliente = clientes[Math.floor(rnd() * clientes.length)];
      const pagamento = formas[Math.floor(rnd() * 3)];
      const pago = d < 0 ? !cancelada : rnd() < 0.65;
      const origem = rnd() < 0.75 ? "app" : "balcao";
      if (!livreEm(g.id, d, h, dur)) continue;
      reservar({ qid: g.id, cliente, d, h, dur, valor: g.preco * dur, preco: g.preco, pagamento, pago, status: cancelada ? "cancelada" : "confirmada", origem, criadaDias: Math.min(d, 0) - 3 });
    }
  }
}

/* ---------- respostas de exemplo da empresa ---------- */
const respostas = {
  1: ["Obrigado, Mariana! Ficamos muito felizes que a galera curtiu. Esperamos vocês no próximo jogo!", -2],
  3: ["Valeu pelo retorno, Rafael! Estamos ampliando o estacionamento e a obra termina no mês que vem.", -14],
  5: ["Bruno, pedimos desculpas pelo atraso. Agora deixamos 10 minutos de intervalo entre os jogos para isso não se repetir.", -38],
  6: ["Valeu, Fernanda! A iluminação nova foi pensada justamente para o jogo da noite.", -54],
  16: ["Boa ideia, Vinícius! Já estamos orçando um bebedouro na lateral do campo.", -19],
  19: ["Obrigado por avisar, Tatiane! Rede trocada e conferida toda semana agora.", -62],
  20: ["Que alegria fazer parte desse aniversário, Rodrigo! Parabéns ao craque.", -79],
  21: ["Obrigado, Natália! Cuidar bem do espaço é o nosso compromisso.", -103],
};

/* ---------- SQL ---------- */
const cab = (t) => `-- GERADO a partir dos dados de demonstração que ficavam no front (bah_quadras_web/src/data).\n-- ${t}\nSET NAMES utf8mb4;\n\n`;

let sql = cab("Empresas, quadras e grades de horários de demonstração.");
sql += "INSERT INTO empresas (id, nome, cnpj, telefone, endereco, perfil, created_at) VALUES\n" +
  empresas.map((e) => `    (${e.id}, ${q(e.nome)}, ${q(e.cnpj)}, ${q(e.telefone)}, ${q(e.endereco)}, ${js(e.perfil)}, NOW() - INTERVAL ${-e.criada} DAY)`).join(",\n") + ";\n\n";
sql += "-- SOMENTE DESENVOLVIMENTO: responsável da Arena Sport (painel de demonstração): contato@arenasport.com / empresa123\n";
sql += "INSERT INTO usuarios (id, nome, email, telefone, senha, papel, empresa_id) VALUES\n    (5, 'Ana Paula Mendes', 'contato@arenasport.com', '51987654321', '$2a$10$.PdgKDbD5DKHB5Dq7oJY5OLZnqa1dtn6QDbXR47I3j6.4/WCmwfQa', 'empresa', 2);\n\n";
sql += "UPDATE usuarios SET cidade = 'Porto Alegre/RS', esportes = '[\"Futebol society\", \"Beach tennis\"]' WHERE id = 2;\n\n";
sql += "INSERT INTO quadras (id, empresa_id, tipo_quadra_id, nome, descricao, valor_hora, status, piso, cobertura, capacidade, comodidades, imagem_url, imagens, destaque, cobranca, minutos_bateria, mapa) VALUES\n" +
  quadrasDb.map((x) => `    (${x.id}, ${x.empresa}, ${x.tipo}, ${q(x.nome)}, ${q(x.descricao)}, ${x.preco}, ${q(x.status)}, ${q(x.piso)}, ${q(x.cobertura)}, ${q(x.capacidade)}, ${js(x.comodidades)}, ${q(x.imagem)}, ${js(x.imagens)}, ${q(x.destaque)}, ${q(x.cobranca)}, ${q(x.minutos)}, ${q(x.mapa)})`).join(",\n") + ";\n\n";
const linhasGrade = [];
for (const x of quadrasDb) for (let ds = 0; ds < 7; ds++) for (const h of horasAbertas(x, ds)) linhasGrade.push(`(${x.id}, ${ds}, '${hh(h)}', '${hh(h + 1)}')`);
sql += "INSERT INTO horarios (quadra_id, dia_semana, hora_inicio, hora_fim) VALUES\n    " + linhasGrade.join(",\n    ") + ";\n";
writeFileSync(join(out, "10_demo_empresas_quadras.sql"), sql);

let r = cab("Reservas de demonstração: as do João (joao@arena.local) e o movimento das quadras da Arena Sport e da Arena Central.\n-- Datas relativas a CURDATE(): rodar o reset em outro dia mantém próximas reservas e histórico.");
r += "INSERT INTO solicitacoes_reserva (id, usuario_id, cliente_nome, quadra_id, status_id, data_reserva, hora_inicio, hora_fim, created_at) VALUES\n" +
  solicitacoes.map((x) => `    (${x.id}, ${q(x.usuario)}, ${q(x.cliente)}, ${x.qid}, ${x.status === "cancelada" ? 3 : 2}, ${dia(x.d)}, '${hh(x.h)}', '${hh(x.h + x.dur)}', NOW() + INTERVAL ${x.criadaDias} DAY)`).join(",\n") + ";\n\n";
r += "INSERT INTO reservas (solicitacao_id, status, preco_snapshot, valor_total, forma_pagamento, pago, origem, baterias, minutos_bateria, cancelada_em, data_confirmacao, created_at) VALUES\n" +
  solicitacoes.map((x) => `    (${x.id}, '${x.status === "cancelada" ? "CANCELADA" : "ATIVA"}', ${x.preco}, ${x.valor}, ${q(x.pagamento)}, ${q(x.pago)}, '${x.origem}', ${q(x.baterias)}, ${q(x.minutos)}, ${x.status === "cancelada" ? `NOW() + INTERVAL ${Math.min(x.d, 0) - 1} DAY` : "NULL"}, NOW() + INTERVAL ${x.criadaDias} DAY, NOW() + INTERVAL ${x.criadaDias} DAY)`).join(",\n") + ";\n";
writeFileSync(join(out, "11_demo_reservas.sql"), r);

let a = cab("Avaliações de demonstração (sem conta ligada: usuario_id NULL), respostas da Arena Sport e favoritas do João.");
a += "INSERT INTO avaliacoes (id, quadra_id, usuario_id, autor_nome, nota, aspectos, texto, util, resposta, resposta_em, created_at) VALUES\n" +
  avaliacoes.map((x) => {
    const rp = respostas[x.id];
    return `    (${x.id}, ${slugParaId[x.quadraId]}, NULL, ${q(x.nome)}, ${x.nota}, ${js(x.aspectos)}, ${q(x.texto)}, ${x.util ?? 0}, ${rp ? q(rp[0]) : "NULL"}, ${rp ? `NOW() + INTERVAL ${rp[1]} DAY` : "NULL"}, NOW() + INTERVAL ${diasDe(x.data)} DAY)`;
  }).join(",\n") + ";\n\n";
a += "INSERT INTO favoritos (usuario_id, quadra_id) VALUES\n" + ["arena-sport", "beach-arena", "play-sports"].map((sl) => `    (2, ${slugParaId[sl]})`).join(",\n") + ";\n";
writeFileSync(join(out, "12_demo_avaliacoes_favoritos.sql"), a);

console.log({
  empresas: empresas.length + 1, quadras: quadrasDb.length + 2, horarios: linhasGrade.length, reservas: solicitacoes.length,
  avaliacoes: avaliacoes.length, semQuadra: avaliacoes.filter((x) => !slugParaId[x.quadraId]).length, slugs: slugParaId,
});
