# Documentação dos Eventos — Sistema de Agendamento de Quadras e Árbitros

## Topologia

- **MOM utilizado:** Redis Pub/Sub
- **Padrão:** Publish/Subscribe — o produtor publica em um canal; o consumidor escuta esse canal de forma independente e assíncrona.
- **Payload:** JSON stringificado.

---

## Tabela de Eventos

| Evento | Produtor | Consumidor | Payload JSON | Canal Redis |
|---|---|---|---|---|
| `agendamento.criado` | `bookingService` — disparado pelo endpoint `POST /bookings` | Subscriber Redis (registra no log do terminal) | `{ "agendamentoId": 1, "quadraId": 1, "clienteId": 10, "prestadorId": 5, "horarioInicio": "2026-05-02T19:00:00.000Z", "status": "solicitado" }` | `agendamento.criado` |
| `agendamento.status_alterado` | `bookingService` — disparado pelo endpoint `PATCH /bookings/:id/status` | Subscriber Redis (registra no log do terminal) | `{ "agendamentoId": 1, "status": "confirmado" }` | `agendamento.status_alterado` |
| `agendamento.deletado` | `bookingService` — disparado pelo endpoint `DELETE /bookings/:id` | Subscriber Redis (registra no log do terminal) | `{ "agendamentoId": 1, "status": "deletado" }` | `agendamento.deletado` |

---

## Detalhamento dos Eventos

### 1. `agendamento.criado`

**Quando ocorre:** ao criar um novo agendamento via `POST /bookings`.

**Produtor:** `bookingService.createBooking()` — após inserção no banco de dados, publica o evento antes de retornar a resposta ao cliente.

**Consumidor:** Subscriber Redis inicializado em `server.ts` via `initRedisSubscriber()`. Registra a mensagem no log do terminal.

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

---

### 2. `agendamento.status_alterado`

**Quando ocorre:** ao atualizar o status de um agendamento via `PATCH /bookings/:id/status`.

**Produtor:** `bookingService.updateBookingStatus()` — após atualização no banco de dados.

**Consumidor:** Subscriber Redis. Registra a mudança de status no log do terminal.

**Payload:**
```json
{
  "agendamentoId": 1,
  "status": "confirmado"
}
```

> Valores possíveis de `status`: `"solicitado"`, `"confirmado"`, `"recusado"`, `"concluido"`.

---

### 3. `agendamento.deletado`

**Quando ocorre:** ao deletar um agendamento via `DELETE /bookings/:id`.

**Produtor:** `bookingService.deleteBookingById()` — após remoção do banco de dados.

**Consumidor:** Subscriber Redis. Registra a deleção no log do terminal.

**Payload:**
```json
{
  "agendamentoId": 1,
  "status": "deletado"
}
```

---

## Fluxo Assíncrono

```
[Cliente HTTP]
     |
     | POST /bookings  (chamada REST síncrona)
     v
[bookingController]
     |
     v
[bookingService]  ──── INSERT no PostgreSQL
     |
     | publishEvent("agendamento.criado", payload)
     v
[Redis Pub/Sub — canal: agendamento.criado]
     |
     | (assíncrono — sem chamada REST)
     v
[Subscriber Redis]  ──── console.log("[event] agendamento.criado", payload)
```

O consumidor (Subscriber) processa a mensagem **independentemente** da requisição HTTP — ele não é chamado diretamente pelo produtor, apenas recebe a mensagem via canal Redis.
