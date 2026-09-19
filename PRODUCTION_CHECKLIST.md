# Checklist de publicacao

Use este checklist antes de colocar a Blackout Gestao em uso real.

## Antes do GitHub

- Definir o WhatsApp real da academia em `academia.json`.
- Abrir `/sistema` e ir em Configuracoes para conferir nome da academia, chave Pix, codigo de convite e PIN do autoatendimento.
- Se houver dados reais no navegador, exportar backup em Configuracoes.
- Decidir se o app publicado vai iniciar com demonstracao ou se a academia vai usar Configuracoes > Apagar tudo e comecar do zero no primeiro acesso.

## Vercel

- Publicar a pasta `v1` como projeto estatico.
- Conferir se `/` abre o site publico.
- Conferir se `/sistema` abre o painel.
- Conferir se `/join?codigo=BLKOUT` abre a pagina publica de cadastro.
- Atualizar o campo "Endereco do site" em Configuracoes com a URL final da Vercel.

## Cadastro publico

- `academia.json` precisa ter `whatsapp` com DDD, de preferencia somente numeros.
- Sempre que mudar codigo, modalidades ou WhatsApp, substituir `academia.json` no repositorio e redeployar.

## Supabase

- Criar um projeto Supabase.
- Conferir se `supabase/config.js` tem a URL e a publishable key corretas.
- Abrir Supabase > SQL Editor > New query.
- Copiar todo o conteudo de `supabase/schema.sql`, colar e rodar.
- Testar `/join?codigo=BLKOUT` com um cadastro ficticio.
- Verificar se o aluno apareceu em Table Editor > `alunos` com `novo = true`.
- Ativar Auth antes de migrar o painel principal para varios usuarios.
- Implementar a camada de dados remota do `sistema.html` antes de usar em varios aparelhos ao mesmo tempo.

## Aviso operacional

Enquanto o app estiver na versao localStorage, os dados ficam em cada navegador. Para operacao com dono, professores e recepcao em aparelhos diferentes, a etapa Supabase e obrigatoria.
