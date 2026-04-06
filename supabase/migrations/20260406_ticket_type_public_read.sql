-- ============================================================
-- SUBX — ticket_type : création si absente + lecture publique
-- ============================================================

-- Créer la table si elle n'existe pas encore
CREATE TABLE IF NOT EXISTS ticket_type (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id   UUID NOT NULL REFERENCES event(id) ON DELETE CASCADE,
  format     TEXT NOT NULL,
  level      TEXT,
  price      NUMERIC(8,2) NOT NULL DEFAULT 0,
  max_spots  INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Activer RLS
ALTER TABLE ticket_type ENABLE ROW LEVEL SECURITY;

-- Lecture publique (tout le monde peut voir les tickets d'un event publié)
DROP POLICY IF EXISTS "ticket_type_public_read" ON ticket_type;
CREATE POLICY "ticket_type_public_read"
  ON ticket_type FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM event e
      WHERE e.id = ticket_type.event_id
        AND e.published = TRUE
    )
  );

-- L'organisateur peut tout gérer sur ses propres events
DROP POLICY IF EXISTS "ticket_type_organizer_all" ON ticket_type;
CREATE POLICY "ticket_type_organizer_all"
  ON ticket_type FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM event e
      WHERE e.id = ticket_type.event_id
        AND e.organizer_id = auth.uid()
    )
  );
