-- Function to insert sample data for the last 30 days
INSERT INTO steps (id, steps, date, times, distance, calories)
VALUES
  -- Today
  ('1', 8432, date('now'), 12, 5.6, 325.4),
  
  -- Yesterday
  ('2', 9123, date('now', '-1 day'), 15, 6.1, 352.8),
  
  -- 2 days ago
  ('3', 7845, date('now', '-2 day'), 10, 5.2, 302.5),
  
  -- 3 days ago
  ('4', 10234, date('now', '-3 day'), 18, 6.8, 394.6),
  
  -- 4 days ago
  ('5', 6543, date('now', '-4 day'), 8, 4.4, 252.1),
  
  -- 5 days ago
  ('6', 8765, date('now', '-5 day'), 14, 5.8, 337.9),
  
  -- 6 days ago
  ('7', 9876, date('now', '-6 day'), 16, 6.6, 380.4),
  
  -- Last week
  ('8', 7654, date('now', '-7 day'), 11, 5.1, 295.2),
  ('9', 8234, date('now', '-8 day'), 13, 5.5, 317.3),
  ('10', 9432, date('now', '-9 day'), 15, 6.3, 363.5),
  
  -- Two weeks ago
  ('11', 7123, date('now', '-10 day'), 10, 4.7, 274.6),
  ('12', 8543, date('now', '-11 day'), 14, 5.7, 329.2),
  ('13', 9234, date('now', '-12 day'), 16, 6.2, 355.8),
  ('14', 7845, date('now', '-13 day'), 12, 5.2, 302.5),
  
  -- Three weeks ago
  ('15', 8765, date('now', '-14 day'), 15, 5.8, 337.9),
  ('16', 9123, date('now', '-15 day'), 17, 6.1, 352.8),
  ('17', 7432, date('now', '-16 day'), 11, 4.9, 286.4),
  
  -- Four weeks ago
  ('18', 8654, date('now', '-17 day'), 14, 5.8, 333.7),
  ('19', 9876, date('now', '-18 day'), 18, 6.6, 380.4),
  ('20', 7543, date('now', '-19 day'), 12, 5.0, 290.8),
  
  -- Remaining days
  ('21', 8234, date('now', '-20 day'), 13, 5.5, 317.3),
  ('22', 9432, date('now', '-21 day'), 16, 6.3, 363.5),
  ('23', 7654, date('now', '-22 day'), 11, 5.1, 295.2),
  ('24', 8765, date('now', '-23 day'), 15, 5.8, 337.9),
  ('25', 9123, date('now', '-24 day'), 17, 6.1, 352.8),
  ('26', 7432, date('now', '-25 day'), 11, 4.9, 286.4),
  ('27', 8543, date('now', '-26 day'), 14, 5.7, 329.2),
  ('28', 9876, date('now', '-27 day'), 18, 6.6, 380.4),
  ('29', 7123, date('now', '-28 day'), 10, 4.7, 274.6),
  ('30', 8432, date('now', '-29 day'), 13, 5.6, 325.4);