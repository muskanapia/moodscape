-- MoodScape Analytics Queries
-- Complex SQL queries for mood-based movie analytics
-- Academic Project for CSE370 (Database Systems)

-- ============================================
-- 1. AVERAGE RATING PER MOVIE
-- ============================================
-- Calculates the average numerical rating for each movie
-- Uses aggregate function AVG with GROUP BY
SELECT 
    m.MovieID,
    m.Name AS MovieName,
    m.ReleaseYear,
    g.GenreName,
    AVG(r.NumRating) AS AverageRating,
    COUNT(r.NumRating) AS TotalRatings
FROM Movie m
JOIN Genre g ON m.GenreID = g.GenreID
LEFT JOIN Rating r ON m.MovieID = r.MovieID
GROUP BY m.MovieID, m.Name, m.ReleaseYear, g.GenreName
ORDER BY AverageRating DESC;

-- ============================================
-- 2. MOOD PERCENTAGE CALCULATION
-- ============================================
-- Calculates the percentage distribution of moods for each movie
-- Uses window functions and CTE for complex analytics
WITH MovieMoodCounts AS (
    SELECT 
        m.MovieID,
        m.Name AS MovieName,
        mc.MoodName,
        COUNT(*) AS MoodCount
    FROM Movie m
    JOIN UserMood um ON m.MovieID = um.MovieID
    JOIN MoodCategory mc ON um.MoodID = mc.MoodID
    GROUP BY m.MovieID, m.Name, mc.MoodName
),
MovieTotalMoods AS (
    SELECT 
        MovieID,
        SUM(MoodCount) AS TotalMoods
    FROM MovieMoodCounts
    GROUP BY MovieID
)
SELECT 
    mmc.MovieID,
    mmc.MovieName,
    mmc.MoodName,
    mmc.MoodCount,
    mtm.TotalMoods,
    ROUND((mmc.MoodCount * 100.0 / mtm.TotalMoods), 2) AS MoodPercentage
FROM MovieMoodCounts mmc
JOIN MovieTotalMoods mtm ON mmc.MovieID = mtm.MovieID
ORDER BY mmc.MovieID, MoodPercentage DESC;

-- ============================================
-- 3. USER'S MOST COMMON MOOD
-- ============================================
-- Finds the most frequently used mood tag by each user
-- Uses window function ROW_NUMBER() for ranking
WITH UserMoodCounts AS (
    SELECT 
        u.UserID,
        u.Name AS UserName,
        mc.MoodName,
        COUNT(*) AS MoodUsageCount
    FROM Users u
    JOIN UserMood um ON u.UserID = um.UserID
    JOIN MoodCategory mc ON um.MoodID = mc.MoodID
    GROUP BY u.UserID, u.Name, mc.MoodName
),
RankedUserMoods AS (
    SELECT 
        UserID,
        UserName,
        MoodName,
        MoodUsageCount,
        ROW_NUMBER() OVER (PARTITION BY UserID ORDER BY MoodUsageCount DESC) AS Rank
    FROM UserMoodCounts
)
SELECT 
    UserID,
    UserName,
    MoodName AS MostCommonMood,
    MoodUsageCount AS UsageCount
FROM RankedUserMoods
WHERE Rank = 1
ORDER BY UserID;

-- ============================================
-- 4. MOVIES FILTERED BY MOOD
-- ============================================
-- Finds all movies that have been tagged with a specific mood
-- Uses parameterized query pattern for application integration
SELECT 
    m.MovieID,
    m.Name AS MovieName,
    m.Summary,
    m.ReleaseYear,
    g.GenreName,
    AVG(r.NumRating) AS AverageRating,
    COUNT(DISTINCT um.UserID) AS UsersWithThisMood
FROM Movie m
JOIN Genre g ON m.GenreID = g.GenreID
LEFT JOIN Rating r ON m.MovieID = r.MovieID
JOIN UserMood um ON m.MovieID = um.MovieID
JOIN MoodCategory mc ON um.MoodID = mc.MoodID
WHERE mc.MoodName = 'Inspired'  -- Change this parameter to filter by different moods
GROUP BY m.MovieID, m.Name, m.Summary, m.ReleaseYear, g.GenreName
ORDER BY AverageRating DESC;

-- ============================================
-- 5. DOMINANT MOOD PER MOVIE
-- ============================================
-- Finds the most frequently assigned mood for each movie
WITH MovieMoodCounts AS (
    SELECT 
        m.MovieID,
        m.Name AS MovieName,
        mc.MoodName,
        COUNT(*) AS MoodCount
    FROM Movie m
    JOIN UserMood um ON m.MovieID = um.MovieID
    JOIN MoodCategory mc ON um.MoodID = mc.MoodID
    GROUP BY m.MovieID, m.Name, mc.MoodName
),
DominantMoods AS (
    SELECT 
        MovieID,
        MovieName,
        MoodName,
        MoodCount,
        ROW_NUMBER() OVER (PARTITION BY MovieID ORDER BY MoodCount DESC) AS Rank
    FROM MovieMoodCounts
)
SELECT 
    MovieID,
    MovieName,
    MoodName AS DominantMood,
    MoodCount AS DominantMoodCount
FROM DominantMoods
WHERE Rank = 1
ORDER BY MovieID;

-- ============================================
-- 6. USER PROFILE ANALYTICS
-- ============================================
-- Comprehensive user profile data including review statistics
SELECT 
    u.UserID,
    u.Name AS UserName,
    u.Email,
    u.JoinDate,
    COUNT(DISTINCT r.MovieID) AS MoviesReviewed,
    COUNT(DISTINCT rv.ReviewID) AS ReviewsWritten,
    AVG(r2.NumRating) AS AverageRatingGiven,
    COUNT(DISTINCT um.MoodID) AS DifferentMoodsUsed,
    GROUP_CONCAT(DISTINCT mc.MoodName ORDER BY mc.MoodName SEPARATOR ', ') AS MoodsUsed
FROM Users u
LEFT JOIN Rating r ON u.UserID = r.UserID
LEFT JOIN Review rv ON u.UserID = rv.UserID
LEFT JOIN Rating r2 ON u.UserID = r2.UserID
LEFT JOIN UserMood um ON u.UserID = um.UserID
LEFT JOIN MoodCategory mc ON um.MoodID = mc.MoodID
GROUP BY u.UserID, u.Name, u.Email, u.JoinDate
ORDER BY u.UserID;

-- ============================================
-- 7. TOP MOVIES BY MOOD COMPOSITION
-- ============================================
-- Finds movies with the most diverse mood profiles
SELECT 
    m.MovieID,
    m.Name AS MovieName,
    COUNT(DISTINCT mc.MoodName) AS UniqueMoods,
    COUNT(*) AS TotalMoodAssignments,
    AVG(r.NumRating) AS AverageRating
FROM Movie m
JOIN UserMood um ON m.MovieID = um.MovieID
JOIN MoodCategory mc ON um.MoodID = mc.MoodID
LEFT JOIN Rating r ON m.MovieID = r.MovieID
GROUP BY m.MovieID, m.Name
HAVING COUNT(DISTINCT mc.MoodName) >= 2
ORDER BY UniqueMoods DESC, AverageRating DESC;

-- ============================================
-- 8. MOOD CORRELATION WITH RATINGS
-- ============================================
-- Analyzes if certain moods correlate with higher/lower ratings
SELECT 
    mc.MoodName,
    COUNT(*) AS TimesUsed,
    AVG(r.NumRating) AS AverageRatingWithMood,
    MIN(r.NumRating) AS MinRating,
    MAX(r.NumRating) AS MaxRating
FROM UserMood um
JOIN MoodCategory mc ON um.MoodID = mc.MoodID
JOIN Rating r ON um.UserID = r.UserID AND um.MovieID = r.MovieID
GROUP BY mc.MoodName
ORDER BY AverageRatingWithMood DESC;

-- ============================================
-- 9. MOVIE RECOMMENDATIONS BY MOOD SIMILARITY
-- ============================================
-- Finds movies with similar mood profiles to a given movie
WITH TargetMovieMoods AS (
    SELECT DISTINCT MoodID
    FROM UserMood
    WHERE MovieID = 1  -- Change this to target different movie
),
SimilarMovies AS (
    SELECT 
        um.MovieID,
        m.Name AS MovieName,
        COUNT(*) AS SharedMoods,
        AVG(r.NumRating) AS AverageRating
    FROM UserMood um
    JOIN TargetMovieMoods tmm ON um.MoodID = tmm.MoodID
    JOIN Movie m ON um.MovieID = m.MovieID
    LEFT JOIN Rating r ON um.MovieID = r.MovieID
    WHERE um.MovieID != 1  -- Exclude the target movie
    GROUP BY um.MovieID, m.Name
)
SELECT 
    MovieID,
    MovieName,
    SharedMoods,
    AverageRating
FROM SimilarMovies
WHERE SharedMoods >= 1
ORDER BY SharedMoods DESC, AverageRating DESC
LIMIT 5;