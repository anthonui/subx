-- ============================================================
-- SUBX — Tickets uniques par événement (fictif mais cohérent)
-- ============================================================

DELETE FROM ticket_type;

INSERT INTO ticket_type (event_id, format, level, price, max_spots) VALUES

-- ── HYROX Toulon (premium, gros event, Solo + Double Mixte) ──
('0add4429-d43a-47fe-8d5a-3a729f9609a9', 'Solo Homme',   'debutant',      69.00, 120),
('0add4429-d43a-47fe-8d5a-3a729f9609a9', 'Solo Homme',   'intermediaire', 89.00,  80),
('0add4429-d43a-47fe-8d5a-3a729f9609a9', 'Solo Homme',   'expert',       109.00,  40),
('0add4429-d43a-47fe-8d5a-3a729f9609a9', 'Solo Femme',   'debutant',      69.00, 120),
('0add4429-d43a-47fe-8d5a-3a729f9609a9', 'Solo Femme',   'intermediaire', 89.00,  80),
('0add4429-d43a-47fe-8d5a-3a729f9609a9', 'Solo Femme',   'expert',       109.00,  40),
('0add4429-d43a-47fe-8d5a-3a729f9609a9', 'Double Mixte', 'debutant',     129.00,  60),
('0add4429-d43a-47fe-8d5a-3a729f9609a9', 'Double Mixte', 'intermediaire',159.00,  40),
('0add4429-d43a-47fe-8d5a-3a729f9609a9', 'Double Mixte', 'expert',       189.00,  20),

-- ── LYONRACE Lyon (mid-range, tous niveaux, Solo + Relais) ──
('ef4e1826-251b-4798-9e0d-2eac14e92c37', 'Solo Homme',   'debutant',      49.00, 150),
('ef4e1826-251b-4798-9e0d-2eac14e92c37', 'Solo Homme',   'intermediaire', 65.00, 100),
('ef4e1826-251b-4798-9e0d-2eac14e92c37', 'Solo Homme',   'expert',        79.00,  50),
('ef4e1826-251b-4798-9e0d-2eac14e92c37', 'Solo Femme',   'debutant',      49.00, 150),
('ef4e1826-251b-4798-9e0d-2eac14e92c37', 'Solo Femme',   'intermediaire', 65.00, 100),
('ef4e1826-251b-4798-9e0d-2eac14e92c37', 'Solo Femme',   'expert',        79.00,  50),
('ef4e1826-251b-4798-9e0d-2eac14e92c37', 'Relais',       'debutant',      99.00,  40),
('ef4e1826-251b-4798-9e0d-2eac14e92c37', 'Relais',       'intermediaire',129.00,  30),
('ef4e1826-251b-4798-9e0d-2eac14e92c37', 'Relais',       'expert',       159.00,  15),

-- ── SPARTFIT Bordeaux (accessible, Solo + Double Hommes/Femme) ──
('f170470b-6d45-4139-a3a9-85bc5976705a', 'Solo Homme',    'debutant',      39.00, 200),
('f170470b-6d45-4139-a3a9-85bc5976705a', 'Solo Homme',    'intermediaire', 55.00, 120),
('f170470b-6d45-4139-a3a9-85bc5976705a', 'Solo Femme',    'debutant',      39.00, 200),
('f170470b-6d45-4139-a3a9-85bc5976705a', 'Solo Femme',    'intermediaire', 55.00, 120),
('f170470b-6d45-4139-a3a9-85bc5976705a', 'Double Hommes', 'debutant',      75.00,  80),
('f170470b-6d45-4139-a3a9-85bc5976705a', 'Double Hommes', 'intermediaire', 95.00,  50),
('f170470b-6d45-4139-a3a9-85bc5976705a', 'Double Femme',  'debutant',      75.00,  80),
('f170470b-6d45-4139-a3a9-85bc5976705a', 'Double Femme',  'intermediaire', 95.00,  50),

-- ── X-RACE Nantes (obstacle, élite inclus, Solo + Double Mixte + Relais) ──
('451d7775-1ddc-4347-9bb1-3ab29e6e7302', 'Solo Homme',   'intermediaire', 59.00, 100),
('451d7775-1ddc-4347-9bb1-3ab29e6e7302', 'Solo Homme',   'expert',        75.00,  60),
('451d7775-1ddc-4347-9bb1-3ab29e6e7302', 'Solo Homme',   'elite',         95.00,  25),
('451d7775-1ddc-4347-9bb1-3ab29e6e7302', 'Solo Femme',   'intermediaire', 59.00, 100),
('451d7775-1ddc-4347-9bb1-3ab29e6e7302', 'Solo Femme',   'expert',        75.00,  60),
('451d7775-1ddc-4347-9bb1-3ab29e6e7302', 'Solo Femme',   'elite',         95.00,  25),
('451d7775-1ddc-4347-9bb1-3ab29e6e7302', 'Double Mixte', 'intermediaire',115.00,  40),
('451d7775-1ddc-4347-9bb1-3ab29e6e7302', 'Double Mixte', 'expert',       139.00,  25),
('451d7775-1ddc-4347-9bb1-3ab29e6e7302', 'Relais',       'expert',       149.00,  20),

-- ── SUMMERWOD Ajaccio (été, tarif unique, débutant friendly, Solo + Double Mixte) ──
('8f24bc61-c925-4f3e-9a2e-b71c5515fbe9', 'Solo Homme',   'debutant',      45.00, 180),
('8f24bc61-c925-4f3e-9a2e-b71c5515fbe9', 'Solo Homme',   'intermediaire', 59.00, 100),
('8f24bc61-c925-4f3e-9a2e-b71c5515fbe9', 'Solo Femme',   'debutant',      45.00, 180),
('8f24bc61-c925-4f3e-9a2e-b71c5515fbe9', 'Solo Femme',   'intermediaire', 59.00, 100),
('8f24bc61-c925-4f3e-9a2e-b71c5515fbe9', 'Double Mixte', 'debutant',      85.00,  60),
('8f24bc61-c925-4f3e-9a2e-b71c5515fbe9', 'Double Mixte', 'intermediaire',109.00,  40),

-- ── MARSEILLE RACE (complet, tous formats, tous niveaux) ──
('ce26b8b3-0284-46e8-a2d1-bcc705fb6948', 'Solo Homme',    'debutant',      55.00, 150),
('ce26b8b3-0284-46e8-a2d1-bcc705fb6948', 'Solo Homme',    'intermediaire', 72.00, 100),
('ce26b8b3-0284-46e8-a2d1-bcc705fb6948', 'Solo Homme',    'expert',        89.00,  50),
('ce26b8b3-0284-46e8-a2d1-bcc705fb6948', 'Solo Femme',    'debutant',      55.00, 150),
('ce26b8b3-0284-46e8-a2d1-bcc705fb6948', 'Solo Femme',    'intermediaire', 72.00, 100),
('ce26b8b3-0284-46e8-a2d1-bcc705fb6948', 'Solo Femme',    'expert',        89.00,  50),
('ce26b8b3-0284-46e8-a2d1-bcc705fb6948', 'Double Hommes', 'intermediaire',119.00,  40),
('ce26b8b3-0284-46e8-a2d1-bcc705fb6948', 'Double Hommes', 'expert',       145.00,  25),
('ce26b8b3-0284-46e8-a2d1-bcc705fb6948', 'Double Femme',  'intermediaire',119.00,  40),
('ce26b8b3-0284-46e8-a2d1-bcc705fb6948', 'Double Femme',  'expert',       145.00,  25),
('ce26b8b3-0284-46e8-a2d1-bcc705fb6948', 'Double Mixte',  'intermediaire',119.00,  50),
('ce26b8b3-0284-46e8-a2d1-bcc705fb6948', 'Double Mixte',  'expert',       145.00,  30),
('ce26b8b3-0284-46e8-a2d1-bcc705fb6948', 'Relais',        'expert',       169.00,  20),

-- ── HYBRID CROSS Paris (premium, élite, Solo + Double + Relais) ──
('4d5d1890-65cf-4123-9e7d-f7fbdb5ae9fc', 'Solo Homme',   'intermediaire',  79.00,  80),
('4d5d1890-65cf-4123-9e7d-f7fbdb5ae9fc', 'Solo Homme',   'expert',         99.00,  50),
('4d5d1890-65cf-4123-9e7d-f7fbdb5ae9fc', 'Solo Homme',   'elite',         129.00,  20),
('4d5d1890-65cf-4123-9e7d-f7fbdb5ae9fc', 'Solo Femme',   'intermediaire',  79.00,  80),
('4d5d1890-65cf-4123-9e7d-f7fbdb5ae9fc', 'Solo Femme',   'expert',         99.00,  50),
('4d5d1890-65cf-4123-9e7d-f7fbdb5ae9fc', 'Solo Femme',   'elite',         129.00,  20),
('4d5d1890-65cf-4123-9e7d-f7fbdb5ae9fc', 'Double Mixte', 'expert',        179.00,  30),
('4d5d1890-65cf-4123-9e7d-f7fbdb5ae9fc', 'Double Mixte', 'elite',         219.00,  15),
('4d5d1890-65cf-4123-9e7d-f7fbdb5ae9fc', 'Relais',       'expert',        189.00,  20),
('4d5d1890-65cf-4123-9e7d-f7fbdb5ae9fc', 'Relais',       'elite',         239.00,  10),

-- ── ROXDAY Toulon (fin d'année, accessible, Solo + Relais) ──
('e479dea5-4997-4ec9-a8fe-b3d934e1b6a0', 'Solo Homme',   'debutant',      42.00, 200),
('e479dea5-4997-4ec9-a8fe-b3d934e1b6a0', 'Solo Homme',   'intermediaire', 58.00, 120),
('e479dea5-4997-4ec9-a8fe-b3d934e1b6a0', 'Solo Homme',   'expert',        72.00,  60),
('e479dea5-4997-4ec9-a8fe-b3d934e1b6a0', 'Solo Femme',   'debutant',      42.00, 200),
('e479dea5-4997-4ec9-a8fe-b3d934e1b6a0', 'Solo Femme',   'intermediaire', 58.00, 120),
('e479dea5-4997-4ec9-a8fe-b3d934e1b6a0', 'Solo Femme',   'expert',        72.00,  60),
('e479dea5-4997-4ec9-a8fe-b3d934e1b6a0', 'Relais',       'debutant',      89.00,  50),
('e479dea5-4997-4ec9-a8fe-b3d934e1b6a0', 'Relais',       'intermediaire',115.00,  35);

-- Mettre à jour price_from par event (prix du ticket le moins cher)
UPDATE event SET price_from = sub.min_price
FROM (
  SELECT event_id, MIN(price) AS min_price FROM ticket_type GROUP BY event_id
) sub
WHERE event.id = sub.event_id;

-- Vérification
SELECT e.name, tt.format, tt.level, tt.price, tt.max_spots
FROM ticket_type tt
JOIN event e ON e.id = tt.event_id
ORDER BY e.date, tt.format, tt.level;
