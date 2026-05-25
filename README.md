# LABDAMD - Sistema de Agendamento de Quadras e Árbitros

## Apresentação e motivação
Plataforma distribuída para simplificar o agendamento de quadras esportivas e a contratação de árbitros. O objetivo é reduzir a fragmentação na organização de eventos esportivos amadores, conectando organizadores e prestadores em um único ecossistema. A comunicação é orientada a eventos (EDA), com notificações assíncronas via mensageria.

## Perfis de usuário
- **Cliente (Organizador da partida):** busca quadras, seleciona horários e solicita arbitragem.
- **Prestador (Dono da quadra / Árbitro):** recebe solicitações, gerencia agenda e aceita ou recusa demandas.

## Principais funcionalidades
- Criação de agendamentos com local, data e necessidade de arbitragem.
- Publicação de eventos no middleware para notificações em tempo real.
- Atualização de status da reserva (ex.: pendente -> confirmado) com retorno ao cliente.
- Persistência e consulta do histórico de agendamentos.

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