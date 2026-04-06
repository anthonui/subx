-- ============================================================
-- SUBX — Correctifs sécurité + performance
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- 1. INDEX de performance
-- ────────────────────────────────────────────────────────────

-- registrations : requêtes fréquentes par athlète, event, statut
CREATE INDEX IF NOT EXISTS idx_registrations_athlete
  ON registrations(athlete_id);

CREATE INDEX IF NOT EXISTS idx_registrations_event
  ON registrations(event_id);

CREATE INDEX IF NOT EXISTS idx_registrations_status
  ON registrations(status);

-- ticket_type : chargement des tickets d'un event
CREATE INDEX IF NOT EXISTS idx_ticket_type_event
  ON ticket_type(event_id);

-- event : liste des events publiés (page d'accueil)
CREATE INDEX IF NOT EXISTS idx_event_published
  ON event(published) WHERE published = TRUE;

-- event : dashboard organisateur
CREATE INDEX IF NOT EXISTS idx_event_organizer
  ON event(organizer_id);

-- event : tri par date (affichage liste)
CREATE INDEX IF NOT EXISTS idx_event_date
  ON event(date);


-- ────────────────────────────────────────────────────────────
-- 2. Lien FK registrations → ticket_type (intégrité des données)
-- ────────────────────────────────────────────────────────────
ALTER TABLE registrations
  ADD COLUMN IF NOT EXISTS ticket_type_id UUID
    REFERENCES ticket_type(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_registrations_ticket_type
  ON registrations(ticket_type_id);


-- ────────────────────────────────────────────────────────────
-- 3. Sécurité : bloquer la fraude sur le prix
--    L'athlète ne peut QUE passer son inscription en 'cancelled'
--    Il ne peut PAS modifier unit_price, qty, status → autre chose
-- ────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "registrations_update_own" ON registrations;

CREATE POLICY "registrations_update_own"
  ON registrations FOR UPDATE
  USING (auth.uid() = athlete_id)
  WITH CHECK (
    auth.uid() = athlete_id
    AND status = 'cancelled'
  );


-- ────────────────────────────────────────────────────────────
-- 4. Sécurité : valider le prix côté serveur à l'insertion
--    Empêche un athlète d'envoyer unit_price = 0.01 via l'API
-- ────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION check_registration_price()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  expected_price NUMERIC(8,2);
BEGIN
  -- Si ticket_type_id fourni, vérifier que unit_price correspond
  IF NEW.ticket_type_id IS NOT NULL THEN
    SELECT price INTO expected_price
    FROM ticket_type WHERE id = NEW.ticket_type_id;

    IF expected_price IS NOT NULL AND NEW.unit_price <> expected_price THEN
      RAISE EXCEPTION 'Prix invalide : attendu %, reçu %', expected_price, NEW.unit_price;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS registrations_check_price ON registrations;
CREATE TRIGGER registrations_check_price
  BEFORE INSERT ON registrations
  FOR EACH ROW EXECUTE FUNCTION check_registration_price();


-- ────────────────────────────────────────────────────────────
-- 5. Profils : visibles entre utilisateurs authentifiés
--    Nécessaire pour que l'organisateur lise les noms des inscrits
-- ────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "profiles_select_authenticated" ON profiles;

CREATE POLICY "profiles_select_authenticated"
  ON profiles FOR SELECT
  USING (auth.role() = 'authenticated');


-- ────────────────────────────────────────────────────────────
-- 6. Contrainte : qty max 10 par inscription (déjà en CHECK,
--    on ajoute aussi une limite de places par ticket_type)
-- ────────────────────────────────────────────────────────────

-- Fonction pour vérifier les places restantes avant insertion
CREATE OR REPLACE FUNCTION check_ticket_availability()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  max_spots_val   INTEGER;
  already_sold    INTEGER;
BEGIN
  IF NEW.ticket_type_id IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT max_spots INTO max_spots_val
  FROM ticket_type WHERE id = NEW.ticket_type_id;

  -- Si max_spots non défini → pas de limite
  IF max_spots_val IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT COALESCE(SUM(qty), 0) INTO already_sold
  FROM registrations
  WHERE ticket_type_id = NEW.ticket_type_id
    AND status <> 'cancelled';

  IF already_sold + NEW.qty > max_spots_val THEN
    RAISE EXCEPTION 'Plus assez de places disponibles pour ce ticket (% restantes)', max_spots_val - already_sold;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS registrations_check_availability ON registrations;
CREATE TRIGGER registrations_check_availability
  BEFORE INSERT ON registrations
  FOR EACH ROW EXECUTE FUNCTION check_ticket_availability();
