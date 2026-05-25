# Relatório de Integração - Sprint 2 (MOM)

## Ferramenta escolhida
Foi adotado o Redis Pub/Sub como MOM por simplicidade operacional e por atender ao escopo do projeto acadêmico. O objetivo da Sprint 2 é evidenciar a comunicação assíncrona entre publicador e consumidor, o que é atendido pelo modelo de canais do Redis.

## Padrao arquitetural
**Publish/Subscribe.** A API publica eventos em canais com o mesmo nome do evento. O subscriber escuta esses canais e registra os eventos no log, demonstrando o processamento assíncrono. O produtor não conhece o consumidor.

## Eventos implementados
Os eventos e seus payloads estão descritos em [docs/eventos.md](docs/eventos.md). Nesta Sprint, foram usados:
- `agendamento.criado`
- `agendamento.status_alterado`
- `agendamento.deletado`

## Fluxo assincrono (resumo)
1. Um endpoint altera o estado do agendamento.
2. O service publica o evento no Redis.
3. O subscriber recebe e registra o evento no terminal.

## Evidencias (logs/prints)
- Criação de agendamento: [docs/Sprint 2/evidencias/agendamentoCriado.png](docs/Sprint%202/evidencias/agendamentoCriado.png)
- Atualização de status (confirmado): [docs/Sprint 2/evidencias/agendamentoConfirmado.png](docs/Sprint%202/evidencias/agendamentoConfirmado.png)
- Deleção de agendamento: [docs/Sprint 2/evidencias/agendamentoDeletado.png](docs/Sprint%202/evidencias/agendamentoDeletado.png)
- Atualização de status (recusado, extra): [docs/Sprint 2/evidencias/agendamentoRecusado.png](docs/Sprint%202/evidencias/agendamentoRecusado.png)

## Limites e proximos passos
- O Redis Pub/Sub é fire-and-forget: não há persistência nem retry automático.
- Para evoluir, pode-se adotar uma fila persistente (ex.: RabbitMQ) ou um outbox pattern.