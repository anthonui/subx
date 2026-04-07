-- ============================================================
-- SUBX — Reset tickets avec 3 formats × 3 niveaux × prix variés
-- Cible : tous les events qui n'ont qu'un ticket "Inscription Standard"
--
-- ⚠️ AJUSTE LES PRIX avant de lancer !
-- ============================================================

-- Étape 1 : Supprimer les tickets génériques existants
DELETE FROM ticket_type
WHERE event_id IN (
  SELECT event_id
  FROM ticket_type
  GROUP BY event_id
  HAVING COUNT(*) = 1
     AND MIN(format) IS NULL  -- ticket "Inscription Standard" = format NULL
);

-- Étape 2 : Insérer 9 tickets (3 formats × 3 niveaux) pour chaque event concerné
INSERT INTO ticket_type (event_id, format, level, price, max_spots)
SELECT e.id, combo.format, combo.level, combo.price, combo.max_spots
FROM event e
CROSS JOIN (VALUES
  --   format     niveau          prix   places
  ('solo',    'debutant',        49.00,  100),
  ('solo',    'intermediaire',   59.00,  80),
  ('solo',    'expert',          69.00,  50),
  ('duo',     'debutant',        89.00,  60),
  ('duo',     'intermediaire',  109.00,  50),
  ('duo',     'expert',         129.00,  30),
  ('equipe',  'debutant',       149.00,  40),
  ('equipe',  'intermediaire',  179.00,  30),
  ('equipe',  'expert',         199.00,  20)
) AS combo(format, level, price, max_spots)
WHERE NOT EXISTS (
  SELECT 1 FROM ticket_type tt WHERE tt.event_id = e.id
);

-- Étape 3 : Mettre à jour price_from sur les events modifiés
UPDATE event
SET price_from = 49.00
WHERE NOT EXISTS (
  SELECT 1 FROM ticket_type tt
  WHERE tt.event_id = event.id
    AND tt.format IS NULL
);

-- ── Vérification finale ──────────────────────────────────────
SELECT
  e.name        AS evenement,
  tt.format,
  tt.level,
  tt.price      AS prix,
  tt.max_spots  AS places
FROM ticket_type tt
JOIN event e ON e.id = tt.event_id
ORDER BY e.name, tt.format, tt.level;
