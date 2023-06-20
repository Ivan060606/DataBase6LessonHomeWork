-- 2.Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток.
-- С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу
-- "Добрый день", с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".

DELIMITER //

CREATE FUNCTION hello ()
RETURNS TINYTEXT NOT DETERMINISTIC
BEGIN
DECLARE hour INT;
SET hour = HOUR(NOW());
CASE
	WHEN hour BETWEEN 0 AND 5 THEN RETURN "Доброй ночи";
	WHEN hour BETWEEN 6 AND 11 THEN RETURN "Доброе утро";
	WHEN hour BETWEEN 12 AND 17 THEN RETURN "Добрый день";
	WHEN hour BETWEEN 18 AND 23 THEN RETURN "Добрый вечер";
END CASE;
END//

SELECT NOW(), hello()//

-- 3.(по желанию)* Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users,
-- communities и messages в таблицу logs помещается время и дата создания записи, название таблицы, идентификатор
-- первичного ключа.

DROP TABLE IF EXISTS logs;

CREATE TABLE logs (
  append_dt DATETIME DEFAULT CURRENT_TIMESTAMP,
  append_tn VARCHAR (255),
  pk_id INT UNSIGNED NOT NULL,
  ) ENGINE ARCHIVE;

DROP PROCEDURE IF EXISTS append_logs;
DELIMITER //
CREATE PROCEDURE append_logs (
  dt DATETIME,
  tn VARCHAR (255),
  id INT
)
BEGIN
	INSERT INTO logs (append_dt, append_tn, pk_id) VALUES (dt, tn, id);
END //
delimiter ;

DROP TRIGGER IF EXISTS log_appending_from_users;
delimiter //
CREATE TRIGGER log_appending_from_users
AFTER INSERT ON users
FOR EACH ROW
BEGIN
	CALL append_logs(NEW.dt, 'users', NEW.id);
END //
delimiter ;

DROP TRIGGER IF EXISTS log_appending_from_communities;
delimiter //
CREATE TRIGGER log_appending_from_communities
AFTER INSERT ON communities
FOR EACH ROW
BEGIN
	CALL append_logs(NEW.dt, 'communities', NEW.id);
END //
delimiter ;

DROP TRIGGER IF EXISTS log_appending_from_messages;
delimiter //
CREATE TRIGGER log_appending_from_messages
AFTER INSERT ON messages
FOR EACH ROW
BEGIN
	CALL append_logs(NEW.dt, 'messages', NEW.id);
END //
delimiter ;
  
