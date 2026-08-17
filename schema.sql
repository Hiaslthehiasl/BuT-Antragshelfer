-- BuT-Antragshelfer - Supabase Schema
-- TSV 1862 Friedberg e.V.

create type case_status as enum (
  'eingereicht',
  'in_pruefung',
  'bei_behoerde',
  'bewilligt',
  'abgelehnt',
  'kein_anspruch'
);

create type erz_beziehung as enum (
  'mutter', 'vater', 'sorgeberechtigt', 'vormund', 'sonstige'
);

create type leistungsart as enum (
  'buergergeld', 'sozialhilfe', 'wohngeld', 'kinderzuschlag', 'asylblg'
);

create type beitrag_rhythmus as enum (
  'monat', 'quartal', 'halbjahr', 'jahr'
);

create table members (
  id uuid primary key default gen_random_uuid(),
  kind_vorname text not null,
  kind_nachname text not null,
  kind_geburtsdatum date not null,
  erz_name text not null,
  erz_geburtsdatum date not null,
  erz_beziehung erz_beziehung not null,
  adresse_strasse text not null,
  adresse_plz text not null,
  adresse_ort text not null,
  kontakt_email text not null,
  kontakt_telefon text not null,
  sprache text not null default 'de',
  created_at timestamptz not null default now()
);

create table cases (
  id uuid primary key default gen_random_uuid(),
  member_id uuid not null references members(id) on delete cascade,
  leistungsarten leistungsart[] not null,
  akt_beschreibung text not null,
  zeitraum_von date not null,
  zeitraum_bis date not null,
  beitrag_betrag numeric(10,2) not null,
  beitrag_rhythmus beitrag_rhythmus not null,
  faellig_am text not null,
  status case_status not null default 'eingereicht',
  behoerde text, -- 'aichach_friedberg' | 'augsburg', wird aus PLZ/Ort abgeleitet
  bescheid_dokument_url text, -- Link auf SharePoint-Ablage
  ausgefuelltes_pdf_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table payments (
  id uuid primary key default gen_random_uuid(),
  case_id uuid not null references cases(id) on delete cascade,
  faelligkeit date not null,
  betrag numeric(10,2) not null,
  bezahlt boolean not null default false,
  sepa_mandat_vorhanden boolean not null default false,
  created_at timestamptz not null default now()
);

create index idx_cases_member on cases(member_id);
create index idx_cases_status on cases(status);
create index idx_payments_case on payments(case_id);
