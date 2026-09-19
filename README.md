# Blackout Gestao

Sistema de gestão da Blackout Jiu-Jitsu, em um único arquivo `index.html`.

Versao atual: `v1.1`, pronta para publicacao estatica em Vercel e preparada para a proxima etapa com Supabase.

## Módulos

- Painel com indicadores e infográficos
- Alunos: cadastro completo, dados de saúde e emergência, filtros e WhatsApp
- Horários e presença: grade semanal por modalidade e chamada com um toque
- Graduação: requisitos por faixa, lista de aptos e histórico
- Financeiro: planos, mensalidades, recebimentos, inadimplência, despesas e relatório
- Central de mensagens: fila diária de cobrança, falta e aniversário, envio para grupos, modelos e histórico
- Cobrança automática: régua de lembrete, vencimento e atraso
- Autoatendimento: check-in do aluno na recepção, com situação e chave Pix
- Unidades e modalidades: várias unidades, esportes e professores
- Anamnese interna e cadastro de responsáveis para menores
- Datas de graduação com previsão por aluno
- Ajuda com respostas rápidas
- Visão do aluno: progresso para mostrar ao aluno
- Kimonos: simulador de tamanho integrado ao cadastro

## Convite e cadastro de alunos

- `cadastro.html`: página pública de cadastro, sem nenhum dado da academia.
- `academia.json`: código de convite, nome, WhatsApp e modalidades. A página de cadastro usa este arquivo para conferir o código.
- `vercel.json`: cria o endereço curto `/join?codigo=XXXXXX`.
- `PRODUCTION_CHECKLIST.md`: checklist antes de publicar.
- `supabase/schema.sql`: schema inicial, seed da academia e funcao de cadastro publico.
- `supabase/config.js`: URL e chave publicavel do Supabase usadas pelo cadastro publico.

O aluno abre `seusite.vercel.app/join?codigo=BLKOUT` (ou digita o código), preenche os dados e o cadastro e gravado no Supabase. O WhatsApp continua abrindo como confirmacao e plano B.

Sempre que mudar o código, o WhatsApp ou as modalidades, baixe um novo `academia.json` em Alunos > Convite e substitua no repositório.

## Publicacao no GitHub e Vercel

1. Publique o conteudo desta pasta `v1` em um repositorio GitHub.
2. Na Vercel, importe o repositorio como projeto estatico.
3. Use `/` para o painel e `/join?codigo=BLKOUT` para o cadastro publico.
4. Depois do deploy, preencha em Configuracoes o endereco final da Vercel.
5. Atualize `academia.json` com o WhatsApp real da academia antes de convidar alunos.

## Supabase

O arquivo `supabase/schema.sql` deve ser rodado no SQL Editor do Supabase. Ele cria a base inicial para:

- usuarios por papel: dono, professor e recepcao;
- alunos, responsaveis, anamnese e modalidades;
- aulas, presencas, graduacoes e eventos;
- mensalidades, pagamentos, despesas e mensagens.
- funcao `receber_cadastro_publico`, chamada pela pagina `cadastro.html`.

Depois de rodar o SQL e publicar o site, novos cadastros publicos entram direto na tabela `alunos` com `novo = true`.

O painel principal ainda usa `localStorage`. A proxima etapa tecnica e trocar a camada de dados do `index.html` por Supabase Auth e banco para dono, professores e recepcao acessarem os mesmos dados.

## Importante

Enquanto o painel principal estiver em `localStorage`, dados editados dentro do painel ficam no navegador de cada aparelho. Use Configurações > Exportar backup com frequência ate a migracao completa.
