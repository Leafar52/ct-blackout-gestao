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

create unique index if not exists idx_academias_codigo_convite_upper
  on public.academias (upper(codigo_convite));

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
drop policy if exists "usuarios veem a propria academia" on public.usuarios;
create policy "usuarios veem a propria academia" on public.usuarios
  for select using (id = auth.uid() or academia_id = public.usuario_academia_id());

drop policy if exists "academia por membro" on public.academias;
create policy "academia por membro" on public.academias
  for select using (id = public.usuario_academia_id());

create or replace function public.receber_cadastro_publico(p_codigo text, p_cadastro jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_academia public.academias%rowtype;
  v_aluno_id uuid;
  v_modalidade text;
  v_modalidade_id uuid;
  v_nascimento date;
  v_lgpd date;
  v_resp jsonb;
begin
  select *
    into v_academia
    from public.academias
   where upper(codigo_convite) = upper(regexp_replace(coalesce(p_codigo, ''), '[^A-Za-z0-9]', '', 'g'))
   limit 1;

  if v_academia.id is null then
    raise exception 'codigo_convite_invalido' using errcode = '22023';
  end if;

  if nullif(trim(coalesce(p_cadastro->>'nome', '')), '') is null then
    raise exception 'nome_obrigatorio' using errcode = '22023';
  end if;

  if nullif(trim(coalesce(p_cadastro->>'email', '')), '') is null then
    raise exception 'email_obrigatorio' using errcode = '22023';
  end if;

  if coalesce(p_cadastro->>'nascimento', '') ~ '^\d{4}-\d{2}-\d{2}$' then
    v_nascimento := (p_cadastro->>'nascimento')::date;
  end if;

  if coalesce(p_cadastro->>'lgpd', '') ~ '^\d{4}-\d{2}-\d{2}$' then
    v_lgpd := (p_cadastro->>'lgpd')::date;
  else
    v_lgpd := current_date;
  end if;

  insert into public.alunos (
    academia_id,
    nome,
    nascimento,
    telefone,
    email,
    status,
    faixa,
    novo,
    lgpd_aceite
  ) values (
    v_academia.id,
    trim(p_cadastro->>'nome'),
    v_nascimento,
    nullif(trim(coalesce(p_cadastro->>'telefone', '')), ''),
    lower(nullif(trim(coalesce(p_cadastro->>'email', '')), '')),
    'ativo',
    coalesce(nullif(trim(p_cadastro->>'faixa'), ''), 'branca'),
    true,
    v_lgpd
  )
  returning id into v_aluno_id;

  for v_modalidade in
    select value from jsonb_array_elements_text(coalesce(p_cadastro->'modalidades', '[]'::jsonb))
  loop
    select id
      into v_modalidade_id
      from public.modalidades
     where academia_id = v_academia.id
       and lower(nome) = lower(v_modalidade)
     limit 1;

    if v_modalidade_id is null then
      insert into public.modalidades (academia_id, nome, sistema, cor)
      values (
        v_academia.id,
        v_modalidade,
        case when v_modalidade ilike '%jiu%' or v_modalidade ilike '%no-gi%' then 'bjj' else 'nenhum' end,
        '#8C8C8C'
      )
      returning id into v_modalidade_id;
    end if;

    insert into public.aluno_modalidades (aluno_id, modalidade_id, nivel)
    values (v_aluno_id, v_modalidade_id, p_cadastro->>'faixa')
    on conflict do nothing;
  end loop;

  v_resp := p_cadastro->'resp';
  if v_resp is not null and jsonb_typeof(v_resp) = 'object' and nullif(trim(coalesce(v_resp->>'nome', '')), '') is not null then
    insert into public.responsaveis (aluno_id, nome, parentesco, telefone)
    values (
      v_aluno_id,
      trim(v_resp->>'nome'),
      nullif(trim(coalesce(v_resp->>'parentesco', '')), ''),
      nullif(trim(coalesce(v_resp->>'telefone', '')), '')
    );
  end if;

  return jsonb_build_object('ok', true, 'aluno_id', v_aluno_id);
end;
$$;

grant execute on function public.receber_cadastro_publico(text, jsonb) to anon, authenticated;

insert into public.academias (id, nome, codigo_convite, whatsapp)
select '00000000-0000-0000-0000-000000000001', 'Blackout Jiu-Jitsu', 'BLKOUT', '5511961167426'
where not exists (
  select 1 from public.academias where upper(codigo_convite) = 'BLKOUT'
);

update public.academias
   set nome = 'Blackout Jiu-Jitsu',
       whatsapp = '5511961167426'
 where upper(codigo_convite) = 'BLKOUT';

insert into public.modalidades (academia_id, nome, sistema, cor)
select a.id, m.nome, m.sistema, m.cor
from public.academias a
cross join (
  values
    ('Jiu-Jitsu', 'bjj', '#FFFFFF'),
    ('No-Gi', 'bjj', '#E3161B'),
    ('Muay Thai', 'nenhum', '#8C8C8C'),
    ('Funcional', 'nenhum', '#FFD166')
) as m(nome, sistema, cor)
where upper(a.codigo_convite) = 'BLKOUT'
  and not exists (
    select 1
      from public.modalidades x
     where x.academia_id = a.id
       and lower(x.nome) = lower(m.nome)
  );

-- As demais tabelas devem receber politicas por academia na integracao do cliente,
-- depois de confirmar o modelo de permissoes do dono/professor/recepcao.
