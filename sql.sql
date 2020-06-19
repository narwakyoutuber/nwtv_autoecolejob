

INSERT INTO `addon_account` (name, label, shared) VALUES
  ('society_driving','Auto Ecole',1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
  ('society_driving','Auto Ecole',1)
;

INSERT INTO `jobs` (name, label) VALUES
  ('driving','Auto Ecole')
;

INSERT INTO `jobs` (name, label) VALUES
  ('offdriving','Auto Ecole')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
  ('driving',0,'motorinstr','Moniteur moto',689,'{}','{}'),
  ('driving',1,'carinstr','Moniteur voiture',785,'{}','{}'),
  ('driving',2,'truckinstr','Moniteur camion',874,'{}','{}'),
  ('driving',3,'examiner','Examinateur',954,'{}','{}'),
  ('driving',4,'boss','Patron',1045,'{}','{}')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
  ('offdriving',0,'motorinstr','Conges',380,'{}','{}'),
  ('offdriving',1,'carinstr','Conges',450,'{}','{}'),
  ('offdriving',2,'truckinstr','Conges',530,'{}','{}'),
  ('offdriving',3,'examiner','Conges',650,'{}','{}'),
  ('offdriving',4,'boss','Conges',720,'{}','{}')
;