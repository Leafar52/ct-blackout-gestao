-- Blackout Gestao - schema inicial Supabase
-- Rode este arquivo no SQL Editor do Supabase antes da integracao do app.

create extension if not exists "pgcrypto";

create table if not exists public.academias (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  codigo_convite text not null,
  whatsapp text,
  pix text,
  suporte text,
  created_at timestamptz not null default now()
);

create table if not exists public.usuarios (
  id uuid primary key references auth.users(id) on delete cascade,
  academia_id uuid not null references public.academias(id) on delete cascade,
  nome text not null,
  papel text not null check (papel in ('dono','professor','recepcao')),
  created_at timestamptz not null default now()
);

create table if not exists public.unidades (
  id uuid primary key default gen_random_uuid(),
  academia_id uuid not null references public.academias(id) on delete cascade,
  nome text not null,
  endereco text,
  created_at timestamptz not null default now()
);

create table if not exists public.modalidades (
  id uuid primary key default gen_random_uuid(),
  academia_id uuid not null references public.academias(id) on delete cascade,
  nome text not null,
  sistema text not null check (sistema in ('bjj','nivel','nenhum')),
  cor text not null default '#8C8C8C',
  created_at timestamptz not null default now()
);

create table if not exists public.planos (
  id uuid primary key default gen_random_uuid(),
  academia_id uuid not null references public.academias(id) on delete cascade,
  nome text not null,
  valor numeric(10,2) not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.professores (
  id uuid primary key default gen_random_uuid(),
  academia_id uuid not null references public.academias(id) on delete cascade,
  unidade_id uuid references public.unidades(id) on delete set null,
  nome text not null,
  telefone text,
  faixa text,
  graus integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.alunos (
  id uuid primary key default gen_random_uuid(),
  academia_id uuid not null references public.academias(id) on delete cascade,
  unidade_id uuid references public.unidades(id) on delete set null,
  plano_id uuid references public.planos(id) on delete set null,
  nome text not null,
  nascimento date,
  telefone text,
  email text,
  status text not null default 'ativo' check (status in ('ativo','inativo')),
  faixa text default 'branca',
  graus integer not null default 0,
  ultima_graduacao date,
  inicio date not null default current_date,
  vencimento integer not null default 10,
  emergencia_nome text,
  emergencia_tel text,
  kimono text,
  obs text,
  novo boolean not null default false,
  lgpd_aceite date,
  created_at timestamptz not null default now()
);

create table if not exists public.aluno_modalidades (
  aluno_id uuid not null references public.alunos(id) on delete cascade,
  modalidade_id uuid not null references public.modalidades(id) on delete cascade,
  nivel text,
  primary key (aluno_id, modalidade_id)
);

create table if not exists public.responsaveis (
  id uuid primary key default gen_random_uuid(),
  aluno_id uuid not null references public.alunos(id) on delete cascade,
  nome text not null,
  parentesco text,
  telefone text,
  email text,
  cpf text,
  autorizados_busca text,
  imagem_autorizada boolean,
  created_at timestamptz not null default now()
);

create table if not exists public.anamneses (
  aluno_id uuid primary key references public.alunos(id) on delete cascade,
  data date,
  liberacao boolean,
  sangue text,
  plano_saude text,
  alergias text,
  medicamentos text,
  lesoes text,
  obs text,
  flags jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.aulas (
  id uuid primary key default gen_random_uuid(),
  academia_id uuid not null references public.academias(id) on delete cascade,
  unidade_id uuid references public.unidades(id) on delete set null,
  professor_id uuid references public.professores(id) on delete set null,
  modalidade_id uuid references public.modalidades(id) on delete set null,
  nome text not null,
  publico text not null default 'adulto',
  hora time not null,
  dias integer[] not null default '{}',
  created_at timestamptz not null default now()
);

create table if not exists public.presencas (
  id uuid primary key default gen_random_uuid(),
  aluno_id uuid not null references public.alunos(id) on delete cascade,
  aula_id uuid references public.aulas(id) on delete set null,
  data date not null,
  origem text not null default 'manual',
  created_at timestamptz not null default now(),
  unique (aluno_id, aula_id, data)
);

create table if not exists public.mensalidades (
  id uuid primary key default gen_random_uuid(),
  aluno_id uuid not null references public.alunos(id) on delete cascade,
  competencia text not null,
  valor numeric(10,2) not null,
  vencimento date not null,
  pago boolean not null default false,
  data_pagamento date,
  metodo text,
  created_at timestamptz not null default now()
);

create table if not exists public.despesas (
  id uuid primary key default gen_random_uuid(),
  academia_id uuid not null references public.academias(id) on delete cascade,
  unidade_id uuid references public.unidades(id) on delete set null,
  descricao text not null,
  categoria text,
  valor numeric(10,2) not null,
  data date not null,
  created_at timestamptz not null default now()
);

create table if not exists public.graduacoes (
  id uuid primary key default gen_random_uuid(),
  aluno_id uuid not null references public.alunos(id) on delete cascade,
  data date not null,
  de jsonb not null,
  para jsonb not null,
  obs text,
  created_at timestamptz not null default now()
);

create table if not exists public.eventos_graduacao (
  id uuid primary key default gen_random_uuid(),
  academia_id uuid not null references public.academias(id) on delete cascade,
  unidade_id uuid references public.unidades(id) on delete set null,
  titulo text not null,
  data date not null,
  hora time,
  realizado boolean not null default false,
  alunos uuid[] not null default '{}',
  created_at timestamptz not null default now()
);

create table if not exists public.mensagens (
  id uuid primary key default gen_random_uuid(),
  academia_id uuid not null references public.academias(id) on delete cascade,
  aluno_id uuid references public.alunos(id) on delete set null,
  tipo text not null,
  texto text not null,
  data date not null default current_date,
  hora time not null default current_time,
  created_at timestamptz not null default now()
);

create index if not exists idx_alunos_academia on public.alunos(academia_id);
create index if not exists idx_presencas_aluno_data on public.presencas(aluno_id, data);
create index if not exists idx_mensalidades_aluno_competencia on public.mensalidades(aluno_id, competencia);
create index if not exists idx_despesas_academia_data on public.despesas(academia_id, data);

alter table public.academias enable row level security;
alter table public.usuarios enable row level security;
alter table public.unidades enable row level security;
alter table public.modalidades enable row level security;
alter table public.planos enable row level security;
alter table public.professores enable row level security;
alter table public.alunos enable row level security;
alter table public.aluno_modalidades enable row level security;
alter table public.responsaveis enable row level security;
alter table public.anamneses enable row level security;
alter table public.aulas enable row level security;
alter table public.presencas enable row level security;
alter table public.mensalidades enable row level security;
alter table public.despesas enable row level security;
alter table public.graduacoes enable row level security;
alter table public.eventos_graduacao enable row level security;
alter table public.mensagens enable row level security;

create or replace function public.usuario_academia_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select academia_id from public.usuarios where id = auth.uid()
$$;

-- Politicas base. Ajuste permissoes finas por papel na etapa de integracao.
create policy "usuarios veem a propria academia" on public.usuarios
  for select using (id = auth.uid() or academia_id = public.usuario_academia_id());

create policy "academia por membro" on public.academias
  for select using (id = public.usuario_academia_id());

-- As demais tabelas devem receber politicas por academia na integracao do cliente,
-- depois de confirmar o modelo de permissoes do dono/professor/recepcao.
