-- ============================================================================
-- WARNER BROS. BOX OFFICE DATABASE — CREATE TABLES SCRIPT


-- ============================================================================

-- VARCHAR(n) vs STRING: our ERD uses the general type "STRING". PostgreSQL
-- does not have that type, so we picked a real type for each column.
-- VARCHAR(n) sets a max length that fits the real content (see the
-- comments below on each column). TEXT is only used for text with no
-- clear max length (like a full review).

-- ATTRIBUTION: change "-- Author: <name>" to the real name of the student
-- who wrote or changed that part (the syllabus asks for this).



-- ============================================================================
-- STEP 1: TABLES WITH NO FOREIGN KEYS
-- Make these first, because other tables (like MOVIE and the award
-- tables) will point to them.
-- ============================================================================
-- Author: <name>

CREATE TABLE director (
    director_id     SERIAL PRIMARY KEY,          -- auto-number ID: names are
                                                   -- not always unique (two
                                                   -- directors can share a name)
    director_name   VARCHAR(255) NOT NULL         -- 255 is enough space for a
                                                   -- full name, but shorter than TEXT
);

CREATE TABLE actor (
    actor_id        SERIAL PRIMARY KEY,
    actor_name      VARCHAR(255) NOT NULL         -- same reason as director_name
);

CREATE TABLE genre (
    genre_id        SERIAL PRIMARY KEY,
    genre           VARCHAR(100) UNIQUE NOT NULL  -- 100 is enough for a genre
                                                   -- name (e.g. "Science Fiction").
                                                   -- UNIQUE stops the same genre
                                                   -- being added twice
);


-- ============================================================================
-- STEP 2: MOVIE — the main table that most other tables link to
-- ============================================================================
-- Author: <name>

CREATE TABLE movie (
    movie_id        SERIAL PRIMARY KEY,
    url             VARCHAR(500),                 -- URLs can be long (extra
                                                    -- text after the address),
                                                    -- so this gets more space
    title           VARCHAR(255) NOT NULL,         -- movie titles are almost
                                                    -- never longer than 255 chars
    studio          VARCHAR(255),
    rating          VARCHAR(20),                   -- rating codes are short
                                                    -- (e.g. "PG-13", "R")
    runtime_meta    INT,                           -- minutes, so a whole number
    runtime_sales   INT,
    metascore       FLOAT,
    userscore       FLOAT,
    rel_date        DATE                           -- only need the date, not a time
);


-- ============================================================================
-- STEP 3: AWARD TABLES
-- Each row is one nomination or award, linked to a movie, director, or
-- actor. We use three separate tables instead of one shared table, so we
-- do not end up with empty (NULL) columns for entities that do not apply.
-- We only store the nominee's name once, in name_nominee. not again in
-- a separate director_name/actor_name column, since that would just
-- duplicate the name already reachable through the foreign key.
-- ============================================================================
-- Author: <name>

CREATE TABLE award_movie (
    award_id        SERIAL PRIMARY KEY,
    movie_id        INT NOT NULL,
    year_ceremony   INT,
    ceremony        VARCHAR(255),                  -- name of the event, e.g.
                                                    -- "95th Academy Awards"
    category        VARCHAR(255),                  -- e.g. "Best Picture"
    name_nominee    VARCHAR(255),                  -- name of the person or
                                                    -- entity nominated (removed
                                                    -- the separate director_name
                                                    -- column -- it duplicated
                                                    -- this field)
    film            VARCHAR(255),
    winner          BOOLEAN,
    FOREIGN KEY (movie_id) REFERENCES movie (movie_id)
);

CREATE TABLE award_director (
    award_id        SERIAL PRIMARY KEY,
    director_id     INT NOT NULL,
    movie_id        INT NOT NULL,
    year_ceremony   INT,
    ceremony        VARCHAR(255),
    category        VARCHAR(255),
    name_nominee    VARCHAR(255),                  -- removed the separate
                                                    -- director_name column --
                                                    -- director_id already links
                                                    -- to the name in "director",
                                                    -- and this field also had it
    film            VARCHAR(255),
    winner          BOOLEAN,
    FOREIGN KEY (director_id) REFERENCES director (director_id),
    FOREIGN KEY (movie_id) REFERENCES movie (movie_id)
);

CREATE TABLE award_actor (
    award_id        SERIAL PRIMARY KEY,
    actor_id        INT NOT NULL,
    movie_id        INT NOT NULL,
    year_ceremony   INT,
    ceremony        VARCHAR(255),
    category        VARCHAR(255),
    name_nominee    VARCHAR(255),                  -- removed the separate
                                                    -- actor_name column --
                                                    -- actor_id already links to
                                                    -- the name in "actor", and
                                                    -- this field also had it
    film            VARCHAR(255),
    winner          BOOLEAN,
    FOREIGN KEY (actor_id) REFERENCES actor (actor_id),
    FOREIGN KEY (movie_id) REFERENCES movie (movie_id)
);


-- ============================================================================
-- STEP 4: JUNCTION TABLE MOVIE <-> ACTOR
-- The real relationship: one movie has many actors, and one actor plays
-- in many movies (this is many-to-many). We split this into two simpler
-- 1:N links using this junction table, exactly like the ERD shows:
-- movie (1) -> actor_connect (N), and actor (1) -> actor_connect (N).
-- ============================================================================
-- Author: <name>

CREATE TABLE actor_connect (
    movie_id    INT NOT NULL,
    actor_id    INT NOT NULL,
    PRIMARY KEY (movie_id, actor_id),
    FOREIGN KEY (movie_id) REFERENCES movie (movie_id),
    FOREIGN KEY (actor_id) REFERENCES actor (actor_id)
);


-- ============================================================================
-- STEP 5: REVIEW TABLES
-- We keep consumer and expert reviews in two separate tables on purpose.
-- Consumer reviews have extra columns (thumbs_up, total_thumbs) that
-- expert reviews do not have. This way we avoid empty (NULL) columns for
-- expert reviews.
-- ============================================================================
-- Author: <name>

CREATE TABLE consumer_review (
    review_id       SERIAL PRIMARY KEY,
    movie_id        INT NOT NULL,
    url             VARCHAR(500),
    review_score    FLOAT,
    pos_emotion_pct FLOAT,
    neg_emotion_pct FLOAT,
    thumbs_up       INT,
    total_thumbs    INT,
    FOREIGN KEY (movie_id) REFERENCES movie (movie_id)
);

CREATE TABLE expert_review (
    expert_review_id SERIAL PRIMARY KEY,
    movie_id         INT NOT NULL,
    url              VARCHAR(500),
    review_score     FLOAT,
    pos_emotion_pct  FLOAT,
    neg_emotion_pct  FLOAT,
    FOREIGN KEY (movie_id) REFERENCES movie (movie_id)
);


-- ============================================================================
-- STEP 6: SALES + JUNCTION TABLE MOVIE <-> SALES
-- NOTE (talk about this with your group for the report): normally a
-- simple movie_id foreign key on sales would be enough, like we did for
-- the reviews above, because one sales record usually belongs to one
-- movie. A junction table only makes sense if you expect one sales
-- record to link to more than one movie, or if you want extra
-- flexibility for later.
-- ============================================================================
-- Author: <name>

CREATE TABLE sales (
    sales_id                  SERIAL PRIMARY KEY,
    production_budget         FLOAT,
    international_box_office  FLOAT,
    domestic_box_office       FLOAT,
    opening_weekend           FLOAT,
    theatre_count             INT,
    avg_run_per_theatre       FLOAT,
    creative_type             VARCHAR(100)         -- e.g. "Live Action",
                                                    -- "Animation" -- short,
                                                    -- fixed categories
);

CREATE TABLE movie_sales (
    movie_id    INT NOT NULL,
    sales_id    INT NOT NULL,
    PRIMARY KEY (movie_id, sales_id),
    FOREIGN KEY (movie_id) REFERENCES movie (movie_id),
    FOREIGN KEY (sales_id) REFERENCES sales (sales_id)
);


-- ============================================================================
-- STEP 7: JUNCTION TABLE MOVIE <-> GENRE
-- The real relationship: one movie can have many genres (e.g. action AND
-- comedy), and one genre covers many movies (this is many-to-many). We
-- split this into two simpler 1:N links, matching the ERD: movie (1) ->
-- movie_genre (N), and genre (1) -> movie_genre (N).
-- ============================================================================
-- Author: <name>

CREATE TABLE movie_genre (
    movie_id    INT NOT NULL,
    genre_id    INT NOT NULL,
    PRIMARY KEY (movie_id, genre_id),
    FOREIGN KEY (movie_id) REFERENCES movie (movie_id),
    FOREIGN KEY (genre_id) REFERENCES genre (genre_id)
);


-- ============================================================================
-- END OF SCRIPT
--  now have we have 13 tables named.
-- director, actor, genre, movie, award_movie, award_director, award_actor,
-- actor_connect, consumer_review, expert_review, sales, movie_sales,
-- movie_genre
-- ============================================================================