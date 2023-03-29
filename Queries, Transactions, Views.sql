-- Author: Vybhav Vydula
-- Date: 5/15/2022

-- Two Example Views

-- This view shows all tracks and the respective albums they are on.

CREATE VIEW Album_Tracks AS
SELECT ALBUMS.Title As Album, TRACKS.Title As Track_Title
FROM ALBUMS, TRACKS, ALBUM_CONTAINS
WHERE ALBUMS.Album_ID = ALBUM_CONTAINS.Album_ID AND
TRACKS.Track_ID = ALBUM_CONTAINS.Track_ID
ORDER BY ALBUMS.Title

-- This view shows all audiobook titles and their respective authors.

CREATE VIEW BooksByAuthor AS
SELECT First_Name, Last_Name, Title AS Audiobook
FROM AUTHORS, AUDIOBOOKS
WHERE AUDIOBOOKS.Author_ID = AUTHORS.Author_ID
ORDER BY AUDIOBOOKS.Title


-- Three Example Transactions

/*The transaction below will activate the movie order with a Collection_ID of 10.
The way our database runs requires the user to know a specific collection ID to 
activate it. Upon activation, the item’s arrival attribute will be changed to “T” 
for true and it will add the movie to the Movies table. This transaction would prove 
useful as we do not want to activate an order without adding it to the library.*/

BEGIN TRANSACTION ACTIVATE_ORDER
UPDATE ORDERS
SET Arrived = 'T'
WHERE Collection_ID = 10;
IF error THEN GO TO UNDO; END IF;
INSERT INTO MOVIES (Movie_ID, Num_Of_Copies, Year, Length, Content_Rating, Genre, Director, Title, Type, Collection_ID)
VALUES (600, 3, 1997, 161, 'PG-13', 'Sci-Fi', 'Christopher Nolan', 'Rebellion 2', 'Movie', 10);
IF error THEN GO TO UND0; END IF;
COMMIT;
GO TO FINISH;
UNDO: ROLLBACK;
FINISH:
END TRANSACTION;

/*The following transaction would be used to cancel any fees from a specific patron with Card_ID = 11
and deactivate their account. These items would go together as oftentimes patrons may never pay their
fees and will let their accounts be terminated, or they do pay their fees but broke the rules of the
library and will not be allowed to checkout new items. After canceling their fees and deactivating 
the account, the transaction returns a new list of fees grouped by card number so that an employee 
can see which other patrons owe fees.*/

BEGIN TRANSACTION Cancel_Fees
SELECT SUM(Amount)
FROM FEES
WHERE Card_ID = 11
GROUP BY Card_ID;
IF error THEN GO TO UNDO; END IF;
UPDATE FEES
SET Amount = 0
WHERE Card_ID = 11;
IF error THEN GO TO UND0; END IF;
UPDATE PATRON
SET AD_Status = "D"
WHERE Card_ID = 11;
IF error THEN GO TO UND0; END IF;
SELECT Card_ID, SUM(Amount)
FROM FEES
GROUP BY Card_ID;
	IF error THEN GO TO UND0; END IF;
COMMIT;
GO TO FINISH;
UNDO: ROLLBACK;
FINISH:
END TRANSACTION;


/*The following transaction inserts a new movie into the database and includes the actors 
who act in it, assuming they are already in the database. This serves well as a transaction
 since we normally would never enter a single movie alone. A similar transaction which could 
 be had is inserting new actors into the database as well at the same time. */

BEGIN TRANSACTION Cancel_Fees
INSERT INTO MOVIES (Movie_ID, Num_Of_Copies, Year, Length, Content_Rating, Genre, Director, Title, Type, Collection_ID)
VALUES (601, 2, 2022, 168, 'PG-13', 'Documentary', 'Stephen Spielberg', 'Ouroboros', 'Movie', 601);
IF error THEN GO TO UND0; END IF;
INSERT INTO ACTOR_ACTS_IN (Actor_ID, Movie_ID)
VALUES (2,15);
IF error THEN GO TO UND0; END IF;
INSERT INTO ACTOR_ACTS_IN (Actor_ID, Movie_ID)
VALUES (4,15);
IF error THEN GO TO UND0; END IF;
INSERT INTO ACTOR_ACTS_IN (Actor_ID, Movie_ID)
VALUES (11,15);
IF error THEN GO TO UND0; END IF;
INSERT INTO ACTOR_ACTS_IN (Actor_ID, Movie_ID)
VALUES (19,15);
IF error THEN GO TO UND0; END IF;
COMMIT;
GO TO FINISH;
UNDO: ROLLBACK;
FINISH:
END TRANSACTION;

-- Sample Queries

--a: Find the titles of all tracks by ARTIST(Bruno Mars) released before YEAR(2015)

SELECT t.Title
FROM ARTISTS AS a, TRACKS AS t, ALBUM_CONTAINS as AC, ALBUMS as AL
WHERE a.First_Name = "Bruno"
AND a.Last_Name = "Mars"
AND AC.Track_ID = t.Track_ID
AND AC.Album_ID = AL.Album_ID
AND a.Artist_ID = AL.Artist_ID
AND T.Year < 2015;

--b: Give all the movies and their date of their checkout from a single patron (you choose how to designate the patron)

SELECT M.Title, C.Check_Out_Date
FROM MOVIES AS M, CHECKOUT_INSTANCE AS C, PATRON AS P
WHERE M.Collection_ID = C.Collection_ID
AND P.Card_ID = 15;

--c: List all the albums and their unique identifiers with less than 2 copies held by the library.

SELECT Title
FROM Albums
WHERE Num_Of_Copies < 2;

--d: Give all the patrons who checked out a movie by ACTOR(Paul Rudd) and the movies they checked out.

SELECT P.First_name, P.Last_name, M.Title
FROM PATRON AS P, MOVIES AS M, ACTORS AS A, ACTOR_ACTS_IN AS AAI, CHECKOUT_INSTANCE as C
WHERE A.First_Name = "Paul"
AND A.Last_Name = "Rudd"
AND A.Actor_ID = AAI.Actor_ID
AND AAI.Movie_ID = M.Movie_ID
GROUP BY P.First_name;

--e: Find the total number of albums checked out by a single patron (you choose how to designate the patron)

SELECT COUNT(*)
FROM (SELECT Card_ID
    FROM CHECKOUT_INSTANCE AS C, ALBUMS AS A
    WHERE C.Collection_ID = A.Collection_ID)
WHERE Card_ID = 9;

--f: Find the patron who has checked out the most videos and the total number of videos they have checked out.

SELECT Card_ID, COUNT(M.Title) AS count
FROM PATRON, MOVIES AS M, CHECKOUT_INSTANCE as C
WHERE C.Collection_ID = M.Collection_ID
GROUP BY PATRON.Card_ID
ORDER BY count DESC
LIMIT 1;


-- Checkpoint 4 Question 4 - Extra Queries
--a: Find all actor names in movie titled "Spider-Man: No Way Home".

SELECT First_Name, Last_Name
FROM ACTORS, MOVIES, ACTOR_ACTS_IN
WHERE ACTOR_ACTS_IN.Actor_ID = ACTORS.Actor_ID
AND ACTOR_ACTS_IN.Movie_ID = MOVIES.Movie_ID
AND MOVIES.Title = 'Spider-Man: No Way Home';

--b: Average how many chapters are in a Will Smith Audiobook.

SELECT AVG(Chapters)
FROM AUDIOBOOKS, AUTHORS
WHERE AUDIOBOOKS.Author_ID = AUTHORS.Author_ID
AND AUTHORS.First_Name = 'Will'
AND AUTHORS.Last_Name = 'Smith'
GROUP BY AUDIOBOOKS.Author_ID;

--c: Get emails of all users at Library Branch 'Columbus Library'.

SELECT Email
FROM LIBRARY_BRANCH, PATRON
WHERE LIBRARY_BRANCH.Library_ID = PATRON.Library_ID
AND LIBRARY_BRANCH.Library_Name = 'Columbus Library';

-- Checkpoint 5 Question 4 - Advanced Queries
--a: Provide a list of patron names, along with the total combined running time of all the movies they have checked out.

SELECT First_Name, Last_Name, SUM(Length) AS Run_Time
FROM PATRON, MOVIES, CHECKOUT_INSTANCE
WHERE CHECKOUT_INSTANCE.Card_ID = PATRON.Card_ID
AND CHECKOUT_INSTANCE.Collection_ID = MOVIES.Collection_ID
GROUP BY First_Name;

--b: Provide a list of patron names and email addresses for patrons who have checked out more albums than the average patron.

SELECT First_Name, Last_Name, Email
FROM (SELECT avg(num) as avg
   FROM (SELECT P.First_Name, P.Last_Name,P.Email, Count(*) AS num
       FROM PATRON as P, ALBUMS, CHECKOUT_INSTANCE
       WHERE CHECKOUT_INSTANCE.Card_ID = P.Card_ID
       AND CHECKOUT_INSTANCE.Collection_ID = ALBUMS.Collection_ID
       GROUP BY First_Name)), (SELECT P.First_Name, P.Last_Name,P.Email, Count(*) AS num
           FROM PATRON as P, ALBUMS, CHECKOUT_INSTANCE
           WHERE CHECKOUT_INSTANCE.Card_ID = P.Card_ID
           AND CHECKOUT_INSTANCE.Collection_ID = ALBUMS.Collection_ID
           GROUP BY First_Name)
WHERE num > avg;

--c: Provide a list of the movies in the database and associated total copies lent to patrons, sorted from the movie that has been lent the most to the movies that has been lent the least.

SELECT Title, Count(*) num_lends
FROM MOVIES, CHECKOUT_INSTANCE
WHERE MOVIES.Collection_ID = CHECKOUT_INSTANCE.Collection_ID
GROUP BY Title
ORDER BY num_lends DESC;

--d: Provide a list of the albums in the database and associated totals for copies checked out to customers, sorted from the ones that have been checked out the highest amount to the ones checked out the lowest.

SELECT Title, Count(*) num_lends
FROM ALBUMS, CHECKOUT_INSTANCE
WHERE ALBUMS.Collection_ID = CHECKOUT_INSTANCE.Collection_ID
GROUP BY Title
ORDER BY num_lends DESC;

--e: Find the most popular actor in the database (i.e. the one who has had the most lent movies)

SELECT First_Name, Last_Name
FROM ACTORS, ACTOR_ACTS_IN, MOVIES, CHECKOUT_INSTANCE
WHERE ACTORS.Actor_ID = ACTOR_ACTS_IN.Actor_ID 
AND ACTOR_ACTS_IN.Movie_ID = MOVIES.Movie_ID 
AND MOVIES.Collection_ID = CHECKOUT_INSTANCE.Collection_ID
GROUP BY First_Name
ORDER BY Count(Title) DESC
LIMIT 1;

--f: Find the most listened to artist in the database (use the running time of the album and number of times the album has been lent out to calculate)

SELECT ARTISTS.First_Name, ARTISTS.Last_Name
FROM ALBUMS, CHECKOUT_INSTANCE, TRACKS, ALBUM_CONTAINS, ARTISTS
WHERE ALBUMS.Collection_ID = CHECKOUT_INSTANCE.Collection_ID
AND ALBUM_CONTAINS.Album_ID = ALBUMS.Album_ID
AND ALBUM_CONTAINS.Track_ID = TRACKS.Track_ID
AND ARTISTS.Artist_ID = ALBUMS.Artist_ID
GROUP BY ALBUMS.Title
ORDER BY SUM(TRACKS.Length) DESC
LIMIT 1;

--g: Provide a list of customer information for patrons who have checked out anything by the most watched actors in the database.

SELECT First_Name, Last_Name, Email
FROM PATRON, CHECKOUT_INSTANCE, MOVIES, ACTOR_ACTS_IN
WHERE CHECKOUT_INSTANCE.Collection_ID = MOVIES.Collection_ID
AND PATRON.Card_ID = CHECKOUT_INSTANCE.Card_ID
AND ACTOR_ACTS_IN.Movie_ID = MOVIES.Movie_ID
AND ACTOR_ACTS_IN.Actor_ID IN (SELECT ACTORS.Actor_ID
   FROM ACTORS, ACTOR_ACTS_IN, MOVIES, CHECKOUT_INSTANCE
   WHERE ACTORS.Actor_ID = ACTOR_ACTS_IN.Actor_ID
   AND ACTOR_ACTS_IN.Movie_ID = MOVIES.Movie_ID
   AND MOVIES.Collection_ID = CHECKOUT_INSTANCE.Collection_ID
   GROUP BY ACTORS.Actor_ID
   ORDER BY Count(Title) DESC
   LIMIT 5)
GROUP BY Email;

--h: Provide a list of artists who authored the albums checked out by customers who have checked out more albums than the average customer.

SELECT ARTISTS.First_Name, ARTISTS.Last_Name
FROM ALBUMS, CHECKOUT_INSTANCE, ARTISTS
WHERE CHECKOUT_INSTANCE.Card_ID IN (SELECT Card_ID
   FROM (SELECT avg(num) as avg
      FROM (SELECT P.First_Name, P.Last_Name,P.Email, Count(*) AS num
          FROM PATRON as P, ALBUMS, CHECKOUT_INSTANCE
          WHERE CHECKOUT_INSTANCE.Card_ID = P.Card_ID
          AND CHECKOUT_INSTANCE.Collection_ID = ALBUMS.Collection_ID
          GROUP BY First_Name)), (SELECT P.First_Name, P.Last_Name,P.Email, P.Card_ID, Count(*) AS num
              FROM PATRON as P, ALBUMS, CHECKOUT_INSTANCE
              WHERE CHECKOUT_INSTANCE.Card_ID = P.Card_ID
              AND CHECKOUT_INSTANCE.Collection_ID = ALBUMS.Collection_ID
              GROUP BY First_Name)
  WHERE num > avg)
AND CHECKOUT_INSTANCE.Collection_ID = ALBUMS.Collection_ID
AND ARTISTS.Artist_ID = ALBUMS.Artist_ID
GROUP BY Title;