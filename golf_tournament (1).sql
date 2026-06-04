DROP DATABASE IF EXISTS golf_tournament;
CREATE DATABASE golf_tournament;
USE golf_tournament;

-- ============================================================
--  TABLE DEFINITIONS
-- ============================================================

CREATE TABLE Player (
    ssn     CHAR(13)    NOT NULL,
    nam     VARCHAR(20),
    PRIMARY KEY (ssn)
) ENGINE=InnoDB;

CREATE TABLE Ball (
    sig     VARCHAR(20) NOT NULL,
    nr      VARCHAR(20),
    brand   VARCHAR(20),
    ssn     CHAR(13),
    PRIMARY KEY (sig),
    FOREIGN KEY (ssn) REFERENCES Player(ssn)
) ENGINE=InnoDB;

CREATE TABLE Caddy (
    ssn      CHAR(13)     NOT NULL,
    favtips  VARCHAR(200),
    nam      VARCHAR(20),
    PRIMARY KEY (ssn)
) ENGINE=InnoDB;

CREATE TABLE Competition (
    nam  VARCHAR(50) NOT NULL,
    dat  CHAR(5),
    PRIMARY KEY (nam)
) ENGINE=InnoDB;

CREATE TABLE Referee (
    ssn     CHAR(13)    NOT NULL,
    salary  INT,
    nam     VARCHAR(20),
    PRIMARY KEY (ssn)
) ENGINE=InnoDB;

-- Links referees to the competitions they oversee (many-to-many)
CREATE TABLE Responsible (
    comp_nam  VARCHAR(50) NOT NULL,
    ref_ssn   CHAR(13)    NOT NULL,
    PRIMARY KEY (comp_nam, ref_ssn),
    FOREIGN KEY (comp_nam) REFERENCES Competition(nam),
    FOREIGN KEY (ref_ssn)  REFERENCES Referee(ssn)
) ENGINE=InnoDB;

CREATE TABLE PlayingTime (
    start_time  VARCHAR(20) NOT NULL,
    result      VARCHAR(20),
    player_ssn  CHAR(13)    NOT NULL,
    comp_nam    VARCHAR(50) NOT NULL,
    PRIMARY KEY (start_time, player_ssn, comp_nam),
    FOREIGN KEY (player_ssn) REFERENCES Player(ssn),
    FOREIGN KEY (comp_nam)   REFERENCES Competition(nam)
) ENGINE=InnoDB;

CREATE TABLE GolfBag (
    brand       VARCHAR(20) NOT NULL,
    bagtype     VARCHAR(20),
    player_ssn  CHAR(13)    NOT NULL,
    caddy_ssn   CHAR(13),
    PRIMARY KEY (brand, player_ssn),
    FOREIGN KEY (player_ssn) REFERENCES Player(ssn),
    FOREIGN KEY (caddy_ssn)  REFERENCES Caddy(ssn)
) ENGINE=InnoDB;

-- Weak entity: identity depends on the parent GolfBag
CREATE TABLE Club (
    nam         VARCHAR(20)  NOT NULL,
    clubcomment VARCHAR(100),
    bagbrand    VARCHAR(20)  NOT NULL,
    player_ssn  CHAR(13)     NOT NULL,
    PRIMARY KEY (nam, bagbrand, player_ssn),
    FOREIGN KEY (bagbrand, player_ssn) REFERENCES GolfBag(brand, player_ssn)
) ENGINE=InnoDB;

-- ============================================================
--  INDEXES
--  MySQL does not auto-index foreign key columns on the
--  referencing side, so these help JOIN and lookup performance.
-- ============================================================

CREATE INDEX idx_ball_player       ON Ball(ssn);
CREATE INDEX idx_playingtime_player ON PlayingTime(player_ssn);
CREATE INDEX idx_playingtime_comp   ON PlayingTime(comp_nam);
CREATE INDEX idx_golfbag_caddy      ON GolfBag(caddy_ssn);
CREATE INDEX idx_responsible_ref    ON Responsible(ref_ssn);

-- ============================================================
--  DATA INSERTIONS
-- ============================================================

-- 1. Competition
INSERT INTO Competition (nam, dat) VALUES ('Sigges summer competition', '10/7');

-- 2. Referees assigned to Sigges
INSERT INTO Referee (ssn, nam, salary) VALUES ('790129-4344', 'Simon',  11000);
INSERT INTO Referee (ssn, nam, salary) VALUES ('790129-4444', 'Sven',   12000);
INSERT INTO Referee (ssn, nam, salary) VALUES ('790612-1212', 'Eva',    11000);
INSERT INTO Responsible (comp_nam, ref_ssn) VALUES ('Sigges summer competition', '790129-4344');
INSERT INTO Responsible (comp_nam, ref_ssn) VALUES ('Sigges summer competition', '790129-4444');
INSERT INTO Responsible (comp_nam, ref_ssn) VALUES ('Sigges summer competition', '790612-1212');

-- 3. Bosse starts at 10:35 with a Nike ball
INSERT INTO Player     (ssn, nam)                      VALUES ('560123-6666', 'Bosse');
INSERT INTO Ball       (sig, nr, brand, ssn)           VALUES ('Red Comet', '9', 'Nike', '560123-6666');
INSERT INTO PlayingTime(start_time, result, player_ssn, comp_nam)
    VALUES ('10:35', '52', '560123-6666', 'Sigges summer competition');

-- 4. Jeff with a Nike Tour bag and caddy Dean
INSERT INTO Player  (ssn, nam)                        VALUES ('730909-1111', 'Jeff');
INSERT INTO Caddy   (ssn, favtips, nam)               VALUES ('96392765-1111', 'Use your arms', 'Dean');
INSERT INTO GolfBag (brand, bagtype, player_ssn, caddy_ssn)
    VALUES ('Nike', 'Tour', '730909-1111', '96392765-1111');

-- 5. Driver club belonging to Jeff
INSERT INTO Club (nam, clubcomment, bagbrand, player_ssn)
    VALUES ('Driver', 'Straight and Short', 'Nike', '730909-1111');

-- 6. Sune with Adidas Travel bag and caddy Anna
INSERT INTO Caddy   (ssn, favtips, nam)               VALUES ('14567289-8888', 'Tie your shoes tighter', 'Anna');
INSERT INTO Player  (ssn, nam)                        VALUES ('670808-2222', 'Sune');
INSERT INTO GolfBag (brand, bagtype, player_ssn, caddy_ssn)
    VALUES ('Adidas', 'Travel', '670808-2222', '14567289-8888');

-- 7. Sune tees off at 13:10 with a Titleist ball, scores 72
INSERT INTO Ball       (sig, nr, brand, ssn)          VALUES ('Heart', '3', 'Titleist', '670808-2222');
INSERT INTO PlayingTime(start_time, result, player_ssn, comp_nam)
    VALUES ('13:10', '72', '670808-2222', 'Sigges summer competition');

-- 8. Henry with XSports Sporty bag, caddy Petra, and a Driver club
INSERT INTO Player  (ssn, nam)                        VALUES ('29364910-2222', 'Henry');
INSERT INTO Caddy   (ssn, favtips, nam)               VALUES ('29182938-5555', 'Swing Calmly', 'Petra');
INSERT INTO GolfBag (brand, bagtype, player_ssn, caddy_ssn)
    VALUES ('XSports', 'Sporty', '29364910-2222', '29182938-5555');
INSERT INTO Club (nam, clubcomment, bagbrand, player_ssn)
    VALUES ('Driver', 'Longest and Crooked on the tour', 'XSports', '29364910-2222');

-- 9. Benny plays at 15:30 — disqualified after ball ruled unplayable by Henrik
INSERT INTO Player     (ssn, nam)                     VALUES ('790101-4343', 'Benny');
INSERT INTO Ball       (sig, nr, brand, ssn)          VALUES ('Three Dots', '5', 'GBrandX', '790101-4343');
INSERT INTO Referee    (ssn, nam, salary)              VALUES ('770202-3333', 'Henrik', 10000);
INSERT INTO PlayingTime(start_time, result, player_ssn, comp_nam)
    VALUES ('15:30', 'Disqualified', '790101-4343', 'Sigges summer competition');
INSERT INTO Responsible (comp_nam, ref_ssn)           VALUES ('Sigges summer competition', '770202-3333');

-- 10. Stina plays at 12:05 — disqualified by Jens for a modified Nike ball
INSERT INTO Player  (ssn, nam)                        VALUES ('39287152-6666', 'Stina');
INSERT INTO Caddy   (ssn, favtips, nam)               VALUES ('29463729-9999', 'Swing wide and hard', 'Robbie');
INSERT INTO GolfBag (brand, bagtype, player_ssn, caddy_ssn)
    VALUES ('Nike', 'Travel', '39287152-6666', '29463729-9999');
INSERT INTO Club (nam, clubcomment, bagbrand, player_ssn)
    VALUES ('OlDriver', 'Secure Bettan', 'Nike', '39287152-6666');
INSERT INTO Referee    (ssn, nam, salary)              VALUES ('48273645-4444', 'Jens', 11000);
INSERT INTO Responsible (comp_nam, ref_ssn)            VALUES ('Sigges summer competition', '48273645-4444');
INSERT INTO PlayingTime (start_time, result, player_ssn, comp_nam)
    VALUES ('12:05', 'disqualified', '39287152-6666', 'Sigges summer competition');
INSERT INTO Ball (sig, nr, brand, ssn)                 VALUES ('Zesty', '14', 'Nike', '39287152-6666');

-- ============================================================
--  QUERY OPERATIONS
-- ============================================================

-- Q1: Name of referee with SSN 790129-4444
SELECT nam
FROM   Referee
WHERE  ssn = '790129-4444';

-- Q2: Signature of the ball played by player 560123-6666
SELECT sig
FROM   Ball
WHERE  ssn = '560123-6666';

-- Q3: Add a caddy and bag for Bosse, then retrieve his bag type
INSERT INTO Caddy   (ssn, favtips, nam)
    VALUES ('48320302-5555', 'Stay well fed', 'Georgie');
INSERT INTO GolfBag (brand, bagtype, player_ssn, caddy_ssn)
    VALUES ('Titleist', 'Chunker', '560123-6666', '48320302-5555');

SELECT bagtype
FROM   GolfBag
WHERE  player_ssn = '560123-6666';

-- Q4: Names of players who own a Titleist ball
SELECT Player.nam
FROM   Ball, Player
WHERE  Ball.brand   = 'Titleist'
AND    Ball.ssn     = Player.ssn;

-- Q5: Results from sessions where the player used a Nike ball
SELECT PlayingTime.result
FROM   PlayingTime, Ball
WHERE  Ball.brand        = 'Nike'
AND    Ball.ssn          = PlayingTime.player_ssn;

-- Q6: SSNs of all players named Henry (second Henry added to demonstrate duplicate names)
INSERT INTO Player (ssn, nam) VALUES ('790101-4347', 'Henry');

SELECT ssn
FROM   Player
WHERE  nam = 'Henry';

-- Q7: SSNs of referees not assigned to any competition
INSERT INTO Referee (ssn, nam, salary) VALUES ('770204-4444', 'Lay-Zi', 13000);

SELECT ssn
FROM   Referee
WHERE  ssn NOT IN (SELECT ref_ssn FROM Responsible);

-- Q8: Tip given to player 660808-5555, who scored 72 in the Ryder Cup
INSERT INTO Competition (nam, dat)                        VALUES ('Ryder Cup', '10/8');
INSERT INTO Player      (ssn, nam)                        VALUES ('660808-5555', 'Victor');
INSERT INTO Caddy       (ssn, favtips, nam)               VALUES ('29473729-9999', 'Sybau', 'John Pork');
INSERT INTO GolfBag     (brand, bagtype, player_ssn, caddy_ssn)
    VALUES ('Nike', 'Chunky', '660808-5555', '29473729-9999');
INSERT INTO PlayingTime (start_time, result, player_ssn, comp_nam)
    VALUES ('12:05', '72', '660808-5555', 'Ryder Cup');

SELECT Caddy.favtips
FROM   Caddy, GolfBag, PlayingTime
WHERE  Caddy.ssn           = GolfBag.caddy_ssn
AND    GolfBag.player_ssn  = '660808-5555'
AND    PlayingTime.player_ssn = '660808-5555'
AND    PlayingTime.result  = '72';

-- Q9: Names of players who have at least one registered playing time
SELECT Player.nam
FROM   Player, PlayingTime
WHERE  Player.ssn = PlayingTime.player_ssn;

-- Q10: Referees who are responsible for exactly two competitions
INSERT INTO Responsible (comp_nam, ref_ssn) VALUES ('Ryder Cup', '790129-4344');

SELECT Referee.nam
FROM   Referee, Responsible
WHERE  Referee.ssn       = Responsible.ref_ssn
GROUP  BY Responsible.ref_ssn
HAVING COUNT(Responsible.ref_ssn) = 2;

-- Q11: All golf bags sorted by brand in descending (Z-A) order
SELECT brand, bagtype, player_ssn, caddy_ssn
FROM   GolfBag
ORDER  BY brand DESC;

-- Q12: Average score across all completed sessions (non-numeric results are ignored by CAST)
SELECT AVG(CAST(result AS UNSIGNED)) AS average_score
FROM   PlayingTime;

-- Q13: Average score per competition
SELECT comp_nam,
       AVG(CAST(result AS UNSIGNED)) AS average_score
FROM   PlayingTime
GROUP  BY comp_nam;

-- Q14: All clubs whose name starts with the letter J
INSERT INTO Player  (ssn, nam)          VALUES ('29369210-2233', 'Ellie');
INSERT INTO Caddy   (ssn, favtips, nam) VALUES ('29181938-5555', 'Stay Calm', 'Levi');
INSERT INTO GolfBag (brand, bagtype, player_ssn, caddy_ssn)
    VALUES ('XSportsElite', 'Lightweight', '29369210-2233', '29181938-5555');
INSERT INTO Club (nam, clubcomment, bagbrand, player_ssn)
    VALUES ('Jamison', 'Little bit Wonky', 'XSportsElite', '29369210-2233');

INSERT INTO Player  (ssn, nam)          VALUES ('29479210-2222', 'Joel');
INSERT INTO Caddy   (ssn, favtips, nam) VALUES ('29120538-5555', 'Lock in', 'Zoe');
INSERT INTO GolfBag (brand, bagtype, player_ssn, caddy_ssn)
    VALUES ('Adidas', 'Heavy', '29479210-2222', '29120538-5555');
INSERT INTO Club (nam, clubcomment, bagbrand, player_ssn)
    VALUES ('Jayeson', 'Little bit sticky', 'Adidas', '29479210-2222');

SELECT *
FROM   Club
WHERE  nam RLIKE '^J';

-- Q15: Player with the best (lowest) score in the Masters competition
INSERT INTO Competition (nam, dat)  VALUES ('Masters', '11/7');
INSERT INTO Player (ssn, nam)       VALUES ('111111-1111', 'Alice');
INSERT INTO Player (ssn, nam)       VALUES ('222222-2222', 'Bob');
INSERT INTO PlayingTime (start_time, result, player_ssn, comp_nam)
    VALUES ('09:00', '58', '111111-1111', 'Masters');
INSERT INTO PlayingTime (start_time, result, player_ssn, comp_nam)
    VALUES ('09:30', '68', '222222-2222', 'Masters');

SELECT Player.nam
FROM   Player, PlayingTime, Competition
WHERE  Player.ssn            = PlayingTime.player_ssn
AND    PlayingTime.comp_nam  = Competition.nam
AND    Competition.nam       = 'Masters'
ORDER  BY CAST(PlayingTime.result AS UNSIGNED) ASC
LIMIT  1;

-- Q16: Players who did not complete their session (result is not a plain number)
SELECT Player.nam
FROM   Player, PlayingTime
WHERE  Player.ssn        = PlayingTime.player_ssn
AND    PlayingTime.result NOT REGEXP '^[0-9]+$';

-- Q17: Competitions scheduled between July 10 and July 17
SELECT *
FROM   Competition
WHERE  SUBSTRING_INDEX(dat, '/', 1) + 0 BETWEEN 10 AND 17
AND    SUBSTRING_INDEX(dat, '/', -1) = '7';

-- Q18: Increase salary by 3% for referees currently earning between 10,000 and 12,000
SET SQL_SAFE_UPDATES = 0;

UPDATE Referee
SET    salary = salary * 1.03
WHERE  salary BETWEEN 10000 AND 12000;

SET SQL_SAFE_UPDATES = 1;

-- Q19: Insert caddy Jeppe, then remove him
INSERT INTO Caddy (ssn, favtips, nam) VALUES ('96392965-1111', 'Stop Staring', 'Jeppe');
SELECT * FROM Caddy;

SET SQL_SAFE_UPDATES = 0;
DELETE FROM Caddy WHERE nam = 'Jeppe' AND favtips = 'Stop Staring';
SET SQL_SAFE_UPDATES = 1;

-- Q20: Remove the Titleist golf bag belonging to player 560123-6666
SELECT * FROM GolfBag WHERE player_ssn = '560123-6666';

SET SQL_SAFE_UPDATES = 0;
DELETE FROM GolfBag WHERE brand = 'Titleist' AND player_ssn = '560123-6666';
SET SQL_SAFE_UPDATES = 1;

-- ============================================================
--  VIEWS
-- ============================================================

-- Competition leaderboard: ranked by average numeric score,
-- disqualified and non-numeric results are excluded from the average.
CREATE VIEW vw_leaderboard AS
SELECT
    pt.comp_nam                              AS competition,
    p.nam                                    AS player,
    pt.result                                AS result,
    CASE
        WHEN pt.result REGEXP '^[0-9]+$' THEN 'Completed'
        ELSE 'Did not finish'
    END                                      AS status
FROM PlayingTime pt
JOIN Player p ON p.ssn = pt.player_ssn
ORDER BY
    competition,
    CAST(NULLIF(pt.result REGEXP '^[0-9]+$', 0) AS UNSIGNED),
    CAST(pt.result AS UNSIGNED);

-- Full player equipment overview: all players with their bag,
-- clubs, and assigned caddy (LEFT JOIN keeps players with no bag).
CREATE VIEW vw_player_equipment AS
SELECT
    p.ssn                   AS player_ssn,
    p.nam                   AS player,
    gb.brand                AS bag_brand,
    gb.bagtype              AS bag_type,
    c.nam                   AS caddy,
    c.favtips               AS caddy_tip,
    cl.nam                  AS club,
    cl.clubcomment          AS club_notes
FROM Player p
LEFT JOIN GolfBag gb  ON gb.player_ssn = p.ssn
LEFT JOIN Caddy   c   ON c.ssn         = gb.caddy_ssn
LEFT JOIN Club    cl  ON cl.player_ssn = p.ssn
                     AND cl.bagbrand   = gb.brand;

-- Referee workload: how many competitions each referee oversees.
CREATE VIEW vw_referee_workload AS
SELECT
    r.ssn,
    r.nam               AS referee,
    r.salary,
    COUNT(rs.comp_nam)  AS competitions_assigned
FROM Referee r
LEFT JOIN Responsible rs ON rs.ref_ssn = r.ssn
GROUP BY r.ssn, r.nam, r.salary;

-- Competition summary: total entries, finishers, and DNFs per event.
CREATE VIEW vw_competition_summary AS
SELECT
    comp_nam                                            AS competition,
    COUNT(*)                                            AS total_entries,
    SUM(result REGEXP '^[0-9]+$')                      AS completed,
    SUM(result NOT REGEXP '^[0-9]+$')                  AS did_not_finish,
    ROUND(AVG(CAST(
        CASE WHEN result REGEXP '^[0-9]+$'
             THEN result END
    AS UNSIGNED)), 2)                                  AS avg_score
FROM PlayingTime
GROUP BY comp_nam;

-- ============================================================
--  STORED PROCEDURE
-- ============================================================

-- Returns the full competition history for a given player:
-- every competition they entered, their result, start time,
-- and the caddy who carried their bag that day.
DELIMITER $$

CREATE PROCEDURE GetPlayerHistory(IN p_ssn CHAR(13))
BEGIN
    SELECT
        pt.comp_nam         AS competition,
        pt.start_time       AS tee_time,
        pt.result           AS result,
        CASE
            WHEN pt.result REGEXP '^[0-9]+$' THEN 'Completed'
            ELSE 'Did not finish'
        END                 AS status,
        c.nam               AS caddy,
        c.favtips           AS caddy_tip
    FROM PlayingTime pt
    LEFT JOIN GolfBag gb ON gb.player_ssn = pt.player_ssn
    LEFT JOIN Caddy   c  ON c.ssn         = gb.caddy_ssn
    WHERE pt.player_ssn = p_ssn
    ORDER BY pt.comp_nam, pt.start_time;
END$$

DELIMITER ;

-- Example call:
-- CALL GetPlayerHistory('560123-6666');

-- ============================================================
--  TRIGGER
-- ============================================================

-- Prevents a player from being registered twice in the same
-- competition (same player_ssn + comp_nam combination).
-- A duplicate start time alone would already violate the PK,
-- but two different start times for the same player in the same
-- event would slip through without this check.
DELIMITER $$

CREATE TRIGGER trg_no_duplicate_entry
BEFORE INSERT ON PlayingTime
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM   PlayingTime
        WHERE  player_ssn = NEW.player_ssn
        AND    comp_nam   = NEW.comp_nam
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Player is already registered in this competition.';
    END IF;
END$$

DELIMITER ;


