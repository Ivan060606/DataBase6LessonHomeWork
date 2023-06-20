-- 1.Создайте таблицу users_old, аналогичную таблице users. Создайте процедуру, с помощью которой можно переместить
-- любого (одного) пользователя из таблицы users в таблицу users_old. (использование транзакции с выбором commit или
-- rollback – обязательно).

USE 4lessdbhw;

DROP TABLE IF EXISTS users_old;
CREATE TABLE users_old (
	id SERIAL PRIMARY KEY, -- SERIAL = BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
    firstname VARCHAR(50),
    lastname VARCHAR(50) COMMENT 'Фамилия',
    email VARCHAR(120) UNIQUE
);

SELECT * FROM users_old;

DROP PROCEDURE IF EXISTS move_it;
DELIMITER //
CREATE PROCEDURE move_it (
	idt INT
)
BEGIN
	START TRANSACTION;
	SELECT * FROM users
    WHERE id = idt;
	INSERT INTO users_old (SELECT * FROM users WHERE id = idt);
    DELETE FROM `users` WHERE `id` = idt LIMIT 1;
    	
	COMMIT;
END //
DELIMITER ;

call move_it(3);

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
  
