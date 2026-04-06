-- ============================================================
-- SUBX — Table registrations (inscriptions / tickets achetés)
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- Fonction set_updated_at (créée ici si pas encore existante)
-- ────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$;

-- ────────────────────────────────────────────────────────────
-- Statut de l'inscription
-- ────────────────────────────────────────────────────────────
DO $$ BEGIN
  CREATE TYPE registration_status_enum AS ENUM ('pending', 'confirmed', 'cancelled');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ────────────────────────────────────────────────────────────
-- TABLE : registrations
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS registrations (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  athlete_id    UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  event_id      UUID NOT NULL REFERENCES event(id)    ON DELETE CASCADE,

  -- Ticket choisi
  ticket_id     TEXT NOT NULL,       -- ex: "solo", "duo_expert", "default"
  ticket_name   TEXT NOT NULL,       -- ex: "Solo", "Duo"
  ticket_format TEXT,                -- ex: "solo", "duo"
  ticket_levels TEXT[] DEFAULT '{}', -- ex: ["expert"]
  qty           INTEGER NOT NULL DEFAULT 1 CHECK (qty >= 1 AND qty <= 10),

  -- Tarif
  unit_price    NUMERIC(8,2) NOT NULL,
  total_price   NUMERIC(8,2) GENERATED ALWAYS AS (qty * unit_price) STORED,

  -- Statut & paiement
  status        registration_status_enum DEFAULT 'pending',
  payment_ref   TEXT,                -- référence paiement futur (Stripe, etc.)

  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- Mise à jour automatique de updated_at
DROP TRIGGER IF EXISTS registrations_updated_at ON registrations;
CREATE TRIGGER registrations_updated_at
  BEFORE UPDATE ON registrations
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ────────────────────────────────────────────────────────────
-- ROW LEVEL SECURITY
-- ────────────────────────────────────────────────────────────
ALTER TABLE registrations ENABLE ROW LEVEL SECURITY;

-- L'athlète voit uniquement ses propres inscriptions
DROP POLICY IF EXISTS "registrations_select_own" ON registrations;
CREATE POLICY "registrations_select_own"
  ON registrations FOR SELECT
  USING (auth.uid() = athlete_id);

-- L'athlète peut créer ses propres inscriptions
DROP POLICY IF EXISTS "registrations_insert_own" ON registrations;
CREATE POLICY "registrations_insert_own"
  ON registrations FOR INSERT
  WITH CHECK (auth.uid() = athlete_id);

-- L'athlète peut annuler (update status) ses propres inscriptions
DROP POLICY IF EXISTS "registrations_update_own" ON registrations;
CREATE POLICY "registrations_update_own"
  ON registrations FOR UPDATE
  USING (auth.uid() = athlete_id);

-- L'organisateur voit les inscriptions de ses événements
DROP POLICY IF EXISTS "registrations_select_organizer" ON registrations;
CREATE POLICY "registrations_select_organizer"
  ON registrations FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM event e
      WHERE e.id = registrations.event_id
        AND e.organizer_id = auth.uid()
    )
  );
