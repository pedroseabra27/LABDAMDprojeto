# Relatório Técnico Final — Sprint 4
**Projeto:** Sistema de Agendamento de Quadras Esportivas (LDAMD)  
**Disciplina:** Laboratório de Desenvolvimento de Aplicações Móveis e Distribuídas  

---

## 1. Introdução e Objetivo

O presente relatório detalha a implementação e arquitetura final do Sistema de Agendamento de Quadras Esportivas. O objetivo principal desta entrega (Sprint 4) foi o fechamento do fluxo do sistema de ponta a ponta, introduzindo o aplicativo do Prestador de Serviços e implementando a comunicação assíncrona orientada a eventos para garantir que todos os nós do sistema mantenham seus estados atualizados em tempo real, sem a necessidade de intervenção manual ou técnicas de requisição contínua (*polling*).

Através da adoção de tecnologias modernas e da Arquitetura Orientada a Eventos (EDA - *Event-Driven Architecture*), o projeto garante alta reatividade, escalabilidade e uma excelente experiência de usuário.

---

## 2. Arquitetura do Sistema

A arquitetura do sistema foi projetada seguindo o modelo Cliente-Servidor com comunicação bidirecional em tempo real. O sistema é composto por três grandes nós:

1.  **Frontend Cliente (Flutter):** Aplicativo móvel utilizado pelos clientes finais para visualizar quadras disponíveis e solicitar agendamentos.
2.  **Frontend Prestador (Flutter):** Aplicativo móvel utilizado pelos donos das quadras para receber notificações de novas solicitações e aceitar, recusar ou concluir agendamentos.
3.  **Backend (Node.js/Express):** Servidor central que atua como o cérebro da operação. Ele gerencia o banco de dados (PostgreSQL) e atua como o Message-Oriented Middleware (MOM) através da tecnologia WebSockets (Socket.IO).

### 2.1. Arquitetura Orientada a Eventos (EDA)
Em vez de depender exclusivamente do modelo Request-Response padrão (HTTP REST), onde o cliente precisa perguntar ao servidor repetidamente "Há alguma novidade?", a arquitetura adota o padrão **Push**. Quando um evento significativo ocorre no sistema (ex: "Novo Agendamento Solicitado" ou "Agendamento Confirmado"), o Backend ativamente propaga (faz o *push*) desse evento para os nós interessados.

Isso elimina o overhead de rede causado por *polling*, reduz o uso de bateria nos dispositivos móveis e garante sincronia instantânea entre o Cliente e o Prestador.

---

## 3. Decisões Tecnológicas e Stack (Tech Stack)

### 3.1. Frontend Mobile (Flutter & Provider)
Optamos pelo **Flutter** para ambos os aplicativos (Cliente e Prestador) devido à sua capacidade de compilar nativamente para iOS e Android a partir de um único código-fonte (`Dart`). 
*   **Reuso de Código:** Criamos um módulo local chamado `shared_core` que contém todos os modelos de dados (Booking, Court) e serviços (ApiService, SocketService). Ambos os aplicativos importam este núcleo, reduzindo drasticamente a duplicação de código e facilitando a manutenção.
*   **Gerência de Estado (`Provider`):** Utilizamos o pacote `Provider` para a reatividade da interface. Quando um evento WebSocket chega, o Provider é atualizado em background e notifica a UI (via `notifyListeners()`), que se redesenha imediatamente apenas nos componentes necessários.

### 3.2. Backend (Node.js & TypeScript)
O **Node.js** com **TypeScript** foi escolhido devido ao seu modelo assíncrono (Event Loop), que é perfeitamente adequado para lidar com múltiplas conexões concorrentes de WebSockets sem bloquear a thread principal.
*   **Drizzle ORM:** Em vez de mapeadores objeto-relacionais pesados, optamos pelo Drizzle ORM. Ele é leve, "Type-Safe" e permite um controle rígido sobre as consultas ao banco de dados PostgreSQL.

### 3.3. Mensageria e WebSockets (Socket.IO vs Polling/RabbitMQ)
O requisito da disciplina permitia a utilização de Polling, MOM (como RabbitMQ) ou WebSockets.
*   **Por que não Polling?** O *Polling* faria os apps enviarem requisições HTTP a cada X segundos. Isso consome processamento do servidor, banda de rede e bateria do celular.
*   **A Escolha do Socket.IO (WebSocket):** O Socket.IO atua como nosso middleware de mensageria (MOM) diretamente para os clientes mobile. Ele suporta "Salas" (*Rooms*), o que nos permitiu criar um design elegante de Publish-Subscribe (Pub/Sub):
    *   Ao fazer login, o cliente entra na sala `cliente_{ID}`.
    *   Ao fazer login, o prestador entra na sala `prestador_{ID}`.
    *   Ao criar um agendamento, o backend emite um evento `new_booking` apenas para a sala do dono da quadra afetada.

---

## 4. Fluxo de Execução Ponta a Ponta

Para ilustrar o funcionamento integrado do sistema, apresentamos o ciclo de vida completo de um agendamento:

### Passo 1: Solicitação (Cliente)
1.  O cliente visualiza uma quadra e clica em agendar.
2.  O aplicativo do cliente faz um `POST /bookings` para a API REST do Backend.
3.  O Backend valida os dados, identifica qual prestador é dono daquela quadra, insere o registro no PostgreSQL com status `"solicitado"`.

### Passo 2: Notificação Assíncrona (Backend -> Prestador)
1.  Imediatamente após a inserção, dentro do próprio fluxo do serviço, o Backend dispara o evento:
    `io.to(prestador_{id}).emit('new_booking', novoAgendamento)`
2.  O aplicativo do Prestador, que estava ouvindo esse socket em background, recebe o JSON do novo agendamento.
3.  O estado local é atualizado e o novo card surge na tela de "Solicitações Pendentes" do Prestador instantaneamente, sem que ele precise tocar na tela.

### Passo 3: Decisão do Prestador (Prestador -> Backend)
1.  O prestador visualiza a solicitação e clica no botão "Aceitar".
2.  O aplicativo do prestador faz um `PATCH /bookings/{id}/status` informando o status `"confirmado"`.
3.  O Backend atualiza o status no banco de dados.

### Passo 4: Retorno ao Cliente (Backend -> Cliente)
1.  Após salvar o novo status, o Backend descobre a quem pertence aquele agendamento e dispara o evento de retorno:
    `io.to(cliente_{id}).emit('booking_updated', agendamentoAtualizado)`
2.  O aplicativo do Cliente escuta o evento, atualiza o status visual do card de laranja (Solicitado) para verde (Confirmado).
3.  O fluxo está concluído e as partes estão sincronizadas.

---

## 5. Estrutura e Organização do Código

O projeto adotou as melhores práticas de separação de responsabilidades (Clean Architecture e Monorepo Pattern):

*   **`backend/src/`**: Contém Controllers (validação HTTP), Services (regras de negócio e queries Drizzle), e Routes (rotas Express).
*   **`shared_core/lib/`**: Onde os contratos vivem. O `ApiService.dart` e o `SocketService.dart` isolam a complexidade das requisições HTTP e da gerência de conexões WebSocket, oferecendo métodos limpos para a camada de apresentação.
*   **`frontend_cliente/` & `frontend_prestador/`**: Contêm puramente lógica de interface (UI) e o Provider. As telas não conhecem a API, apenas chamam os métodos do Provider, mantendo o código testável e fácil de manter.

## 6. Conclusão

A Sprint 4 entregou com sucesso um sistema distribuído altamente responsivo. A eliminação do acoplamento temporal através do uso de WebSockets comprovou que a aplicação prática de uma Arquitetura Orientada a Eventos traz benefícios claros para a experiência do usuário, emulando perfeitamente aplicativos modernos do mercado (como Uber ou iFood). A base de código modular (shared_core) também permite uma expansão sustentável para funcionalidades futuras.
