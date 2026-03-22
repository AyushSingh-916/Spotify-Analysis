-- ============================================================
-- Music Streaming Analysis — SQL Queries
-- Database: PostgreSQL / MySQL / SQLite
-- Table: spotify_tracks
-- ============================================================

-- ── TABLE SETUP (if importing CSV into SQL) ────────────────
CREATE TABLE IF NOT EXISTS spotify_tracks (
    track_id               VARCHAR(50),
    artists                TEXT,
    album_name             TEXT,
    track_name             TEXT,
    popularity             INT,
    duration_ms            INT,
    explicit               BOOLEAN,
    danceability           FLOAT,
    energy                 FLOAT,
    loudness               FLOAT,
    speechiness            FLOAT,
    acousticness           FLOAT,
    instrumentalness       FLOAT,
    liveness               FLOAT,
    valence                FLOAT,
    tempo                  FLOAT,
    track_genre            VARCHAR(100),
    track_album_release_date DATE
);


-- ============================================================
-- SECTION 1: BASIC OVERVIEW
-- ============================================================

-- 1.1 Total tracks, artists and genres
SELECT
    COUNT(*)                          AS total_tracks,
    COUNT(DISTINCT artists)           AS unique_artists,
    COUNT(DISTINCT track_genre)       AS unique_genres,
    ROUND(AVG(popularity), 2)         AS avg_popularity,
    ROUND(AVG(duration_ms)/60000.0, 2) AS avg_duration_min
FROM spotify_tracks;


-- 1.2 Check for nulls
SELECT
    SUM(CASE WHEN track_name   IS NULL THEN 1 ELSE 0 END) AS null_track,
    SUM(CASE WHEN artists      IS NULL THEN 1 ELSE 0 END) AS null_artists,
    SUM(CASE WHEN popularity   IS NULL THEN 1 ELSE 0 END) AS null_popularity,
    SUM(CASE WHEN track_genre  IS NULL THEN 1 ELSE 0 END) AS null_genre
FROM spotify_tracks;


-- ============================================================
-- SECTION 2: ARTIST ANALYSIS
-- ============================================================

-- 2.1 Top 10 artists by average popularity
SELECT
    artists,
    COUNT(*)                     AS total_tracks,
    ROUND(AVG(popularity), 2)    AS avg_popularity,
    MAX(popularity)              AS max_popularity
FROM spotify_tracks
GROUP BY artists
HAVING COUNT(*) >= 5                   -- at least 5 tracks for fairness
ORDER BY avg_popularity DESC
LIMIT 10;


-- 2.2 Most prolific artists (most tracks)
SELECT
    artists,
    COUNT(*)  AS total_tracks,
    ROUND(AVG(popularity), 2) AS avg_popularity
FROM spotify_tracks
GROUP BY artists
ORDER BY total_tracks DESC
LIMIT 10;


-- 2.3 Artists with highest peak popularity (max score)
SELECT
    artists,
    track_name,
    popularity
FROM spotify_tracks
WHERE popularity = (
    SELECT MAX(s2.popularity)
    FROM spotify_tracks s2
    WHERE s2.artists = spotify_tracks.artists
)
ORDER BY popularity DESC
LIMIT 15;


-- ============================================================
-- SECTION 3: GENRE ANALYSIS
-- ============================================================

-- 3.1 Top genres by average popularity
SELECT
    track_genre,
    COUNT(*)                        AS track_count,
    ROUND(AVG(popularity), 2)       AS avg_popularity,
    ROUND(AVG(danceability), 3)     AS avg_danceability,
    ROUND(AVG(energy), 3)           AS avg_energy,
    ROUND(AVG(valence), 3)          AS avg_valence
FROM spotify_tracks
GROUP BY track_genre
ORDER BY avg_popularity DESC
LIMIT 10;


-- 3.2 Genre with highest average danceability
SELECT
    track_genre,
    ROUND(AVG(danceability), 3) AS avg_danceability
FROM spotify_tracks
GROUP BY track_genre
ORDER BY avg_danceability DESC
LIMIT 10;


-- 3.3 Genre distribution (market share)
SELECT
    track_genre,
    COUNT(*) AS track_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS pct_share
FROM spotify_tracks
GROUP BY track_genre
ORDER BY track_count DESC
LIMIT 15;


-- ============================================================
-- SECTION 4: AUDIO FEATURE ANALYSIS
-- ============================================================

-- 4.1 Average audio features across all tracks
SELECT
    ROUND(AVG(danceability), 3)      AS avg_danceability,
    ROUND(AVG(energy), 3)            AS avg_energy,
    ROUND(AVG(valence), 3)           AS avg_valence,
    ROUND(AVG(acousticness), 3)      AS avg_acousticness,
    ROUND(AVG(instrumentalness), 3)  AS avg_instrumentalness,
    ROUND(AVG(tempo), 1)             AS avg_tempo_bpm,
    ROUND(AVG(loudness), 2)          AS avg_loudness_db
FROM spotify_tracks;


-- 4.2 Audio features for HIGH popularity tracks vs LOW
SELECT
    CASE
        WHEN popularity >= 70 THEN 'High (70+)'
        WHEN popularity >= 40 THEN 'Medium (40-69)'
        ELSE 'Low (<40)'
    END AS popularity_bucket,
    COUNT(*)                         AS tracks,
    ROUND(AVG(danceability), 3)      AS avg_danceability,
    ROUND(AVG(energy), 3)            AS avg_energy,
    ROUND(AVG(valence), 3)           AS avg_valence,
    ROUND(AVG(tempo), 1)             AS avg_tempo,
    ROUND(AVG(duration_ms)/60000.0, 2) AS avg_duration_min
FROM spotify_tracks
GROUP BY popularity_bucket
ORDER BY avg_danceability DESC;


-- 4.3 Explicit vs Non-Explicit comparison
SELECT
    explicit,
    COUNT(*)                      AS total_tracks,
    ROUND(AVG(popularity), 2)     AS avg_popularity,
    ROUND(AVG(danceability), 3)   AS avg_danceability,
    ROUND(AVG(energy), 3)         AS avg_energy
FROM spotify_tracks
GROUP BY explicit;


-- ============================================================
-- SECTION 5: TIME TREND ANALYSIS
-- ============================================================

-- 5.1 Average song duration by decade
SELECT
    FLOOR(EXTRACT(YEAR FROM track_album_release_date) / 10) * 10 AS decade,
    COUNT(*)                              AS track_count,
    ROUND(AVG(duration_ms)/60000.0, 2)   AS avg_duration_min,
    ROUND(AVG(popularity), 2)            AS avg_popularity
FROM spotify_tracks
WHERE track_album_release_date IS NOT NULL
GROUP BY decade
ORDER BY decade;


-- 5.2 Year-over-year trend in energy and danceability
SELECT
    EXTRACT(YEAR FROM track_album_release_date) AS release_year,
    COUNT(*)                          AS tracks,
    ROUND(AVG(energy), 3)            AS avg_energy,
    ROUND(AVG(danceability), 3)      AS avg_danceability,
    ROUND(AVG(valence), 3)           AS avg_valence
FROM spotify_tracks
WHERE EXTRACT(YEAR FROM track_album_release_date) BETWEEN 1960 AND 2023
GROUP BY release_year
ORDER BY release_year;


-- 5.3 Top 5 tracks per year (window function)
SELECT *
FROM (
    SELECT
        EXTRACT(YEAR FROM track_album_release_date) AS release_year,
        track_name,
        artists,
        popularity,
        RANK() OVER (
            PARTITION BY EXTRACT(YEAR FROM track_album_release_date)
            ORDER BY popularity DESC
        ) AS rank_in_year
    FROM spotify_tracks
    WHERE EXTRACT(YEAR FROM track_album_release_date) BETWEEN 2010 AND 2023
) ranked
WHERE rank_in_year <= 5
ORDER BY release_year DESC, rank_in_year;


-- ============================================================
-- SECTION 6: ADVANCED QUERIES
-- ============================================================

-- 6.1 Most popular track per genre (window function)
SELECT genre, track_name, artists, popularity
FROM (
    SELECT
        track_genre AS genre,
        track_name,
        artists,
        popularity,
        ROW_NUMBER() OVER (PARTITION BY track_genre ORDER BY popularity DESC) AS rn
    FROM spotify_tracks
) t
WHERE rn = 1
ORDER BY popularity DESC;


-- 6.2 Artists who dominate multiple genres
SELECT
    artists,
    COUNT(DISTINCT track_genre)  AS genre_count,
    STRING_AGG(DISTINCT track_genre, ', ') AS genres    -- use GROUP_CONCAT for MySQL
FROM spotify_tracks
GROUP BY artists
HAVING COUNT(DISTINCT track_genre) >= 3
ORDER BY genre_count DESC
LIMIT 10;


-- 6.3 Rolling average popularity (3-year window)
SELECT
    release_year,
    avg_popularity,
    ROUND(AVG(avg_popularity) OVER (
        ORDER BY release_year
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS rolling_avg_3yr
FROM (
    SELECT
        EXTRACT(YEAR FROM track_album_release_date) AS release_year,
        ROUND(AVG(popularity), 2) AS avg_popularity
    FROM spotify_tracks
    GROUP BY release_year
) yearly
ORDER BY release_year;


-- 6.4 Classify tracks by mood quadrant
--     High Energy + High Valence = "Euphoric"
--     High Energy + Low Valence  = "Aggressive"
--     Low Energy  + High Valence = "Peaceful"
--     Low Energy  + Low Valence  = "Melancholic"
SELECT
    mood,
    COUNT(*)                   AS track_count,
    ROUND(AVG(popularity), 2)  AS avg_popularity
FROM (
    SELECT
        track_name,
        popularity,
        CASE
            WHEN energy >= 0.5 AND valence >= 0.5 THEN 'Euphoric'
            WHEN energy >= 0.5 AND valence < 0.5  THEN 'Aggressive'
            WHEN energy < 0.5  AND valence >= 0.5 THEN 'Peaceful'
            ELSE 'Melancholic'
        END AS mood
    FROM spotify_tracks
) mood_data
GROUP BY mood
ORDER BY avg_popularity DESC;
