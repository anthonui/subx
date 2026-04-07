-- ============================================================
-- SUBX — Backfill ticket_type depuis les anciens événements
--
-- Pour chaque event sans ticket_type, génère des lignes
-- à partir des champs legacy : formats[], level[], prices JSONB
--
-- À coller dans : Supabase Dashboard > SQL Editor > New Query
-- ============================================================

INSERT INTO ticket_type (event_id, format, level, price, max_spots)

-- ── CAS 1 : event a des formats ET des niveaux ──────────────
-- → 1 ticket par combinaison (format × niveau)
SELECT
  e.id                                                      AS event_id,
  fmt                                                       AS format,
  lvl                                                       AS level,
  COALESCE(
    (e.prices ->> lower(fmt))::NUMERIC,
    (e.prices ->> fmt)::NUMERIC,
    (e.prices ->> (upper(left(fmt,1)) || lower(substring(fmt,2))))::NUMERIC,
    e.price_from,
    0
  )                                                         AS price,
  NULL                                                      AS max_spots
FROM event e
CROSS JOIN UNNEST(e.formats)       AS fmt
CROSS JOIN UNNEST(e.level::TEXT[]) AS lvl
WHERE
  NOT EXISTS (SELECT 1 FROM ticket_type tt WHERE tt.event_id = e.id)
  AND array_length(e.formats, 1) > 0
  AND array_length(e.level,   1) > 0

UNION ALL

-- ── CAS 2 : event a des formats mais AUCUN niveau ───────────
-- → 1 ticket par format, niveau = NULL
SELECT
  e.id                                                      AS event_id,
  fmt                                                       AS format,
  NULL                                                      AS level,
  COALESCE(
    (e.prices ->> lower(fmt))::NUMERIC,
    (e.prices ->> fmt)::NUMERIC,
    (e.prices ->> (upper(left(fmt,1)) || lower(substring(fmt,2))))::NUMERIC,
    e.price_from,
    0
  )                                                         AS price,
  NULL                                                      AS max_spots
FROM event e
CROSS JOIN UNNEST(e.formats) AS fmt
WHERE
  NOT EXISTS (SELECT 1 FROM ticket_type tt WHERE tt.event_id = e.id)
  AND array_length(e.formats, 1) > 0
  AND (array_length(e.level, 1) IS NULL OR array_length(e.level, 1) = 0)

UNION ALL

-- ── CAS 3 : event sans format ni niveau ─────────────────────
-- → 1 ticket générique "Inscription Standard"
SELECT
  e.id                                AS event_id,
  NULL                                AS format,
  NULL                                AS level,
  COALESCE(e.price_from, 0)           AS price,
  e.max_participants                  AS max_spots
FROM event e
WHERE
  NOT EXISTS (SELECT 1 FROM ticket_type tt WHERE tt.event_id = e.id)
  AND (array_length(e.formats, 1) IS NULL OR array_length(e.formats, 1) = 0);


-- ── Vérification : affiche les tickets créés ────────────────
SELECT
  e.name        AS event_name,
  tt.format,
  tt.level,
  tt.price,
  tt.max_spots
FROM ticket_type tt
JOIN event e ON e.id = tt.event_id
ORDER BY e.name, tt.format, tt.level;
