-- ============================================================
-- SUBX — Reset complet des ticket_type avec les bons formats
-- Formats : Solo Homme, Solo Femme, Double Hommes,
--           Double Femme, Double Mixte, Relais
-- ============================================================

-- Supprimer tous les anciens tickets (anciens formats erronés)
DELETE FROM ticket_type;

-- Insérer 6 formats × 3 niveaux = 18 tickets par événement
INSERT INTO ticket_type (event_id, format, level, price, max_spots)
SELECT e.id, combo.format, combo.level, combo.price, combo.max_spots
FROM event e
CROSS JOIN (VALUES
  --   format              niveau           prix   places
  ('Solo Homme',    'debutant',        49.00,  100),
  ('Solo Homme',    'intermediaire',   59.00,   80),
  ('Solo Homme',    'expert',          69.00,   50),
  ('Solo Femme',    'debutant',        49.00,  100),
  ('Solo Femme',    'intermediaire',   59.00,   80),
  ('Solo Femme',    'expert',          69.00,   50),
  ('Double Hommes', 'debutant',        89.00,   60),
  ('Double Hommes', 'intermediaire',  109.00,   50),
  ('Double Hommes', 'expert',         129.00,   30),
  ('Double Femme',  'debutant',        89.00,   60),
  ('Double Femme',  'intermediaire',  109.00,   50),
  ('Double Femme',  'expert',         129.00,   30),
  ('Double Mixte',  'debutant',        89.00,   60),
  ('Double Mixte',  'intermediaire',  109.00,   50),
  ('Double Mixte',  'expert',         129.00,   30),
  ('Relais',        'debutant',       149.00,   40),
  ('Relais',        'intermediaire',  179.00,   30),
  ('Relais',        'expert',         199.00,   20)
) AS combo(format, level, price, max_spots);

-- Mettre à jour price_from sur tous les events
UPDATE event SET price_from = 49.00;

-- Vérification
SELECT e.name AS evenement, tt.format, tt.level, tt.price
FROM ticket_type tt
JOIN event e ON e.id = tt.event_id
ORDER BY e.name, tt.format, tt.level;
