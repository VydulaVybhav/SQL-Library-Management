-- File generated with SQLiteStudio v3.4.3 on Wed Mar 29 11:31:21 2023
--
-- Text encoding used: UTF-8
--
PRAGMA foreign_keys = off;
BEGIN TRANSACTION;

-- Table: ACTOR_ACTS_IN
CREATE TABLE IF NOT EXISTS ACTOR_ACTS_IN (
    Actor_ID INT NOT NULL,
    Movie_ID INT NOT NULL,
    PRIMARY KEY (
        Actor_ID,
        Movie_ID
    ),
    FOREIGN KEY (
        Actor_ID
    )
    REFERENCES ACTORS (Actor_ID),
    FOREIGN KEY (
        Movie_ID
    )
    REFERENCES MOVIES (Movie_ID) 
);


-- Table: ACTORS
CREATE TABLE IF NOT EXISTS ACTORS (
    Actor_ID      INT          NOT NULL,
    First_Name    VARCHAR (20) NOT NULL,
    Last_Name     VARCHAR (20),
    Bio           VARCHAR (50),
    Role_Type     VARCHAR (20),
    Collection_ID INT          NOT NULL,
    PRIMARY KEY (
        Actor_ID
    )
);


-- Table: ALBUM_CONTAINS
CREATE TABLE IF NOT EXISTS ALBUM_CONTAINS (
    Album_ID INT NOT NULL,
    Track_ID INT NOT NULL,
    PRIMARY KEY (
        Album_ID,
        Track_ID
    ),
    FOREIGN KEY (
        Album_ID
    )
    REFERENCES ALBUMS (Album_ID),
    FOREIGN KEY (
        Track_ID
    )
    REFERENCES TRACKS (Track_ID) 
);


-- Table: ALBUMS
CREATE TABLE IF NOT EXISTS ALBUMS (
    Album_ID      INT          NOT NULL,
    Title         VARCHAR (30) NOT NULL,
    Num_Of_Copies INT          NOT NULL,
    Type          VARCHAR (10),
    Artist_ID     INT          NOT NULL,
    Collection_ID INT          NOT NULL,
    PRIMARY KEY (
        Album_ID
    ),
    FOREIGN KEY (
        Artist_ID
    )
    REFERENCES ARTISTS (Artist_ID) 
);


-- Table: ARTISTS
CREATE TABLE IF NOT EXISTS ARTISTS (
    Artist_ID     INT          NOT NULL,
    First_Name    VARCHAR (20) NOT NULL,
    Last_Name     VARCHAR (20),
    Bio           VARCHAR (50),
    Type          VARCHAR (10),
    Collection_ID INT          NOT NULL,
    PRIMARY KEY (
        Artist_ID
    )
);


-- Table: AUDIOBOOKS
CREATE TABLE IF NOT EXISTS AUDIOBOOKS (
    Audiobook_ID  INT          NOT NULL,
    Num_Of_Copies INT          NOT NULL,
    Chapters      INT,
    Length        TIME,
    Title         VARCHAR (30) NOT NULL,
    Year          INT,
    Genre         VARCHAR (10),
    Type          VARCHAR (10),
    Collection_ID INT          NOT NULL,
    Author_ID     INT          NOT NULL,
    PRIMARY KEY (
        Audiobook_ID
    ),
    FOREIGN KEY (
        Author_ID
    )
    REFERENCES AUTHORS (Author_ID) 
);


-- Table: AUTHORS
CREATE TABLE IF NOT EXISTS AUTHORS (
    Author_ID     INT          NOT NULL,
    First_Name    VARCHAR (20) NOT NULL,
    Last_Name     VARCHAR (20),
    Bio           VARCHAR (50),
    Collection_ID INT          NOT NULL,
    PRIMARY KEY (
        Author_ID
    )
);


-- Table: CHECKOUT_INSTANCE
CREATE TABLE IF NOT EXISTS CHECKOUT_INSTANCE (
    Card_ID        INT  NOT NULL,
    Check_Out_Date DATE NOT NULL,
    Due_Date       DATE NOT NULL,
    Collection_ID  INT  NOT NULL,
    FOREIGN KEY (
        Card_ID
    )
    REFERENCES PATRON (Card_ID) 
);


-- Table: EMPLOYEE
CREATE TABLE IF NOT EXISTS EMPLOYEE (
    Employee_ID INT          NOT NULL,
    First_Name  VARCHAR (15),
    Last_Name   VARCHAR (20),
    Address     VARCHAR (30),
    Email       VARCHAR (30),
    Library_ID  INT          REFERENCES LIBRARY_BRANCH (Library_ID),
    PRIMARY KEY (
        Employee_ID
    )
);


-- Table: FEES
CREATE TABLE IF NOT EXISTS FEES (
    Card_ID INT            NOT NULL,
    Amount  DECIMAL (3, 2),
    FOREIGN KEY (
        Card_ID
    )
    REFERENCES PATRON (Card_ID) 
);


-- Table: LIBRARY_BRANCH
CREATE TABLE IF NOT EXISTS LIBRARY_BRANCH (
    Library_ID   INT          NOT NULL,
    Library_Name VARCHAR (30) NOT NULL,
    PRIMARY KEY (
        Library_ID
    )
);


-- Table: MOVIES
CREATE TABLE IF NOT EXISTS MOVIES (
    Movie_ID       INT          NOT NULL,
    Num_Of_Copies  INT          NOT NULL,
    Year           INT,
    Length         TIME,
    Content_Rating VARCHAR (5),
    Genre          VARCHAR (10),
    Director       VARCHAR (30),
    Title          VARCHAR (30) NOT NULL,
    Type           VARCHAR (10),
    Collection_ID  INT          NOT NULL,
    PRIMARY KEY (
        Movie_ID
    )
);


-- Table: ORDERED
CREATE TABLE IF NOT EXISTS ORDERED (
    Media_Type    VARCHAR (10),
    EDOA          DATE,
    Num_Of_Copies INT            NOT NULL,
    Price         DECIMAL (3, 2) NOT NULL,
    Collection_ID INT            NOT NULL,
    Arrived       BOOLEAN,
    Order_ID      INT            PRIMARY KEY
);


-- Table: PATRON
CREATE TABLE IF NOT EXISTS PATRON (
    AD_Status  CHAR         NOT NULL,
    Card_ID    INT          NOT NULL,
    First_Name VARCHAR (15),
    Last_Name  VARCHAR (20),
    Address    VARCHAR (30),
    Email      VARCHAR (30),
    Library_ID INT          REFERENCES LIBRARY_BRANCH (Library_ID),
    PRIMARY KEY (
        Card_ID
    )
);


-- Table: RETURNED_INSTANCE
CREATE TABLE IF NOT EXISTS RETURNED_INSTANCE (
    Card_ID     INT     NOT NULL,
    Return_Date DATE    NOT NULL,
    On_Time     BOOLEAN,
    FOREIGN KEY (
        Card_ID
    )
    REFERENCES PATRON (Card_ID) 
);


-- Table: TRACKS
CREATE TABLE IF NOT EXISTS TRACKS (
    Track_ID      INT          NOT NULL,
    Title         VARCHAR (20) NOT NULL,
    Length        TIME         NOT NULL,
    Genre         VARCHAR (10),
    Year          INT,
    Collection_ID INT          NOT NULL,
    PRIMARY KEY (
        Track_ID
    )
);


-- Index: myIndex3
CREATE UNIQUE INDEX IF NOT EXISTS myIndex3 ON ALBUM_CONTAINS (
    Album_ID,
    Track_ID
);
