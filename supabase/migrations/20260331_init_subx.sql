-- ============================================================
-- SUBX — Migration complète
-- À coller dans : Supabase Dashboard > SQL Editor > New Query
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- 1. TYPES ÉNUMÉRÉS
-- ────────────────────────────────────────────────────────────

-- Type de course (3 catégories + autre)
DO $$ BEGIN
  CREATE TYPE race_type_enum AS ENUM ('hybride', 'fonctionnel', 'obstacle', 'autre');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Niveaux
DO $$ BEGIN
  CREATE TYPE level_enum AS ENUM ('debutant', 'intermediaire', 'expert', 'elite');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Formats de course
DO $$ BEGIN
  CREATE TYPE format_enum AS ENUM ('solo', 'duo', 'equipe', 'relais');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Rôle utilisateur
DO $$ BEGIN
  CREATE TYPE user_role_enum AS ENUM ('athlete', 'organizer');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;


-- ────────────────────────────────────────────────────────────
-- 2. TABLE : profiles
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS profiles (
  id                  UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name           TEXT,
  email               TEXT,
  avatar_url          TEXT,
  city                TEXT,
  role                user_role_enum DEFAULT 'athlete',
  is_organizer        BOOLEAN DEFAULT FALSE,
  org_name            TEXT,
  org_website         TEXT,
  phone               TEXT,
  preferred_discipline TEXT,
  events_count        TEXT,                        -- onboarding : nb d'événements organisés
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- Créer un profil automatiquement à l'inscription
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO profiles (id, full_name, email)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    NEW.email
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();


-- ────────────────────────────────────────────────────────────
-- 3. TABLE : organizers
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS organizers (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  org_name    TEXT NOT NULL,
  website     TEXT,
  phone       TEXT,
  description TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id)
);


-- ────────────────────────────────────────────────────────────
-- 4. TABLE : event
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS event (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organizer_id      UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  organizer_name    TEXT,

  -- Infos générales
  name              TEXT NOT NULL,
  race_type         race_type_enum NOT NULL,          -- hybride | fonctionnel | obstacle | autre
  level             level_enum[]   DEFAULT '{}',      -- tableau de niveaux
  description       TEXT,

  -- Dates
  date              DATE,
  date_end          DATE,

  -- Lieu
  city              TEXT NOT NULL,
  address           TEXT,
  venue             TEXT,

  -- Détails techniques
  distance_km       NUMERIC(6,2),
  elevation_m       INTEGER,
  max_participants  INTEGER,
  website           TEXT,

  -- Formats & tarifs
  formats           TEXT[]   DEFAULT '{}',
  prices            JSONB    DEFAULT '{}',
  price_from        NUMERIC(8,2),

  -- Média
  image_url         TEXT,

  -- Statut
  published         BOOLEAN DEFAULT FALSE,
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

-- Mise à jour automatique de updated_at
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$;

DROP TRIGGER IF EXISTS event_updated_at ON event;
CREATE TRIGGER event_updated_at
  BEFORE UPDATE ON event
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();


-- ────────────────────────────────────────────────────────────
-- 5. ROW LEVEL SECURITY (RLS)
-- ────────────────────────────────────────────────────────────

-- profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "profiles_select_own"  ON profiles;
DROP POLICY IF EXISTS "profiles_update_own"  ON profiles;
CREATE POLICY "profiles_select_own"  ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "profiles_update_own"  ON profiles FOR UPDATE USING (auth.uid() = id);

-- organizers
ALTER TABLE organizers ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "organizers_select_own"  ON organizers;
DROP POLICY IF EXISTS "organizers_update_own"  ON organizers;
DROP POLICY IF EXISTS "organizers_insert_own"  ON organizers;
CREATE POLICY "organizers_select_own"  ON organizers FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "organizers_update_own"  ON organizers FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "organizers_insert_own"  ON organizers FOR INSERT WITH CHECK (auth.uid() = user_id);

-- event
ALTER TABLE event ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "event_select_published"  ON event;
DROP POLICY IF EXISTS "event_select_own"        ON event;
DROP POLICY IF EXISTS "event_insert_own"        ON event;
DROP POLICY IF EXISTS "event_update_own"        ON event;
DROP POLICY IF EXISTS "event_delete_own"        ON event;
-- Tout le monde voit les événements publiés
CREATE POLICY "event_select_published"  ON event FOR SELECT USING (published = TRUE OR auth.uid() = organizer_id);
-- L'organisateur gère ses propres événements
CREATE POLICY "event_insert_own"        ON event FOR INSERT WITH CHECK (auth.uid() = organizer_id);
CREATE POLICY "event_update_own"        ON event FOR UPDATE USING (auth.uid() = organizer_id);
CREATE POLICY "event_delete_own"        ON event FOR DELETE USING (auth.uid() = organizer_id);


-- ────────────────────────────────────────────────────────────
-- 6. STORAGE BUCKET : covers (images d'événements)
-- ────────────────────────────────────────────────────────────
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('covers', 'covers', TRUE, 5242880, ARRAY['image/jpeg','image/png','image/webp'])
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "covers_public_read"    ON storage.objects;
DROP POLICY IF EXISTS "covers_auth_upload"    ON storage.objects;
DROP POLICY IF EXISTS "covers_owner_delete"   ON storage.objects;

CREATE POLICY "covers_public_read"   ON storage.objects FOR SELECT USING (bucket_id = 'covers');
CREATE POLICY "covers_auth_upload"   ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'covers' AND auth.role() = 'authenticated');
CREATE POLICY "covers_owner_delete"  ON storage.objects FOR DELETE USING (bucket_id = 'covers' AND auth.uid()::text = (storage.foldername(name))[1]);
