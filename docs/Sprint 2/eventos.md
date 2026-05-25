# Eventos do sistema

Este documento descreve os eventos publicados no MOM (Redis Pub/Sub) e seus payloads.

## Topologia Redis Pub/Sub
- Cada evento é publicado em um canal com o mesmo nome do evento.
- O payload e JSON stringificado.
- O backend atua como publisher e subscriber (logs no terminal).

## Fluxo assincrono (resumo)
1. Um endpoint altera o estado do agendamento (criar, atualizar status, deletar).
2. O service publica o evento no Redis.
3. O subscriber recebe e registra no log.

## Endpoints x eventos

| Endpoint | Evento publicado |
| --- | --- |
| POST /bookings | agendamento.criado |
| PATCH /bookings/:id/status | agendamento.status_alterado |
| DELETE /bookings/:id | agendamento.deletado |

## 1) agendamento.criado

**Quando ocorre:** ao criar um novo agendamento.

**Payload:**
```json
{
  "agendamentoId": 1,
  "quadraId": 1,
  "clienteId": 10,
  "prestadorId": 5,
  "horarioInicio": "2026-05-02T19:00:00.000Z",
  "status": "solicitado"
}
```

## 2) agendamento.status_alterado

**Quando ocorre:** ao atualizar o status de um agendamento.

**Payload:**
```json
{
  "agendamentoId": 1,
  "status": "confirmado"
}
```

## 3) agendamento.deletado

**Quando ocorre:** ao deletar um agendamento.

**Payload:**
```json
{
  "agendamentoId": 1,
  "status": "deletado"
}
```

## Observacoes
- Endpoints de leitura (listar, buscar por id) não publicam eventos.
- Evidências de logs estão em [docs/Sprint 2/sprint2.md](docs/Sprint%202/sprint2.md).
