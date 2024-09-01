USE gamedb;

DROP TABLE IF EXISTS tblClickTarget;
CREATE TABLE tblClickTarget(
   UserName varchar(50) PRIMARY KEY,
   `Password` varchar(50) NOT NULL default '123',
   Attempts INT DEFAULT 0,
   LOCKED_OUT BOOL DEFAULT FALSE
);

DROP PROCEDURE IF EXISTS Login;

DELIMITER $$
CREATE PROCEDURE Login(IN pUserName VARCHAR(50), IN pPassword VARCHAR(50))
COMMENT 'Check login'
BEGIN
    DECLARE numAttempts INT DEFAULT 0;
    
    -- Check if the username and password are valid
    IF EXISTS (
        SELECT * FROM tblClickTarget
        WHERE UserName = pUserName AND `Password` = pPassword
    ) THEN
        UPDATE tblClickTarget 
        SET Attempts = 0
        WHERE UserName = pUserName;
        SELECT 'Logged In' AS Message;
    
    ELSE
        IF EXISTS (
            SELECT * FROM tblClickTarget WHERE UserName = pUserName
        ) THEN
            SELECT Attempts INTO numAttempts
            FROM tblClickTarget
            WHERE UserName = pUserName;
            SET numAttempts = numAttempts + 1;
            
            IF numAttempts > 5 THEN
                -- If attempts > 5, set lockout to true
                UPDATE tblClickTarget 
                SET LOCKED_OUT = TRUE
                WHERE UserName = pUserName;
                SELECT 'Locked Out' AS Message;
            ELSE
                UPDATE tblClickTarget
                SET Attempts = numAttempts
                WHERE UserName = pUserName;
                SELECT 'Invalid user name and password' AS Message;
            END IF;
        ELSE
            SELECT 'Invalid user name and password' AS Message;
        END IF;
    END IF;
END $$
DELIMITER ;


SELECT UserName, Attempts 
FROM tblClickTarget;


DROP PROCEDURE IF EXISTS AddUserName;
DELIMITER $$
CREATE PROCEDURE AddUserName(IN pUserName VARCHAR(50))
BEGIN
  IF EXISTS (SELECT * 
     FROM tblClickTarget
     WHERE Username = pUserName) THEN
  BEGIN
     SELECT 'This name already exists!' AS Message;
  END;
  ELSE 
     INSERT INTO tblClickTarget(UserName)
     VALUE (pUserName); -- Need to check the X,Y location
     SELECT 'You have successfully registered into the game - Lets play!' AS Message;
  END IF;
  
END $$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS GetAllPlayers;
CREATE PROCEDURE GetAllPlayers()
BEGIN
	SELECT UserName
    FROM tblClickTarget ;
END$$
DELIMITER $$
