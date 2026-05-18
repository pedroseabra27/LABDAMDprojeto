# LABDAMD - Sistema de Agendamento de Quadras e Arbitros

## Apresentacao e motivacao
Plataforma distribuida para simplificar o agendamento de quadras esportivas e a contratacao de arbitros. O objetivo e reduzir a fragmentacao na organizacao de eventos esportivos amadores, conectando organizadores e prestadores em um unico ecossistema. A comunicacao e orientada a eventos (EDA), com notificacoes assincronas via mensageria.

## Perfis de usuario
- **Cliente (Organizador da partida):** busca quadras, seleciona horarios e solicita arbitragem.
- **Prestador (Dono da quadra / Arbitro):** recebe solicitacoes, gerencia agenda e aceita ou recusa demandas.

## Principais funcionalidades
- Criacao de agendamentos com local, data e necessidade de arbitragem.
- Publicacao de eventos no middleware para notificacoes em tempo real.
- Atualizacao de status da reserva (ex.: pendente -> confirmado) com retorno ao cliente.
- Persistencia e consulta do historico de agendamentos.

## Tecnologias
- **Backend:** Node.js, Express e TypeScript.
- **Banco de dados:** PostgreSQL com Drizzle ORM.
- **Mensageria:** Redis Pub/Sub.
- **Mobile:** Flutter (clientes e prestadores).

## Estrutura do projeto
```
backend/
  docker-compose.yml
  drizzle.config.ts
  package.json
  postman_collection.json
  tsconfig.json
  drizzle/
  src/
    app.ts
    server.ts
    db/
    redis/
    routes/
```