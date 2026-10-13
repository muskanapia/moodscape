-- MoodScape Database Schema
-- A Mood-Based Movie Review Platform
-- Database Design for CSE370 (Database Systems)

-- ============================================
-- 1. USER & ROLES TABLES (3NF Normalized)
-- ============================================

-- Base User table (1NF: atomic values, no repeating groups)
CREATE TABLE Users (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    JoinDate DATE NOT NULL,
    IsActive BOOLEAN DEFAULT TRUE
);

-- Admin table (2NF: no partial dependency on PK)
-- UserID is both PK and FK to Users
CREATE TABLE Admin (
    UserID INT PRIMARY KEY,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

-- NormalUser table (2NF: no partial dependency on PK)
-- UserID is both PK and FK to Users
CREATE TABLE NormalUser (
    UserID INT PRIMARY KEY,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

-- ============================================
-- 2. MOVIE & RELATED TABLES
-- ============================================

-- Genre lookup table (3NF: no transitive dependencies)
CREATE TABLE Genre (
    GenreID INT PRIMARY KEY AUTO_INCREMENT,
    GenreName VARCHAR(50) NOT NULL UNIQUE
);

-- Movie table (3NF: all non-key attributes depend only on PK)
CREATE TABLE Movie (
    MovieID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    Summary TEXT,
    ReleaseYear INT NOT NULL,
    GenreID INT NOT NULL,
    FOREIGN KEY (GenreID) REFERENCES Genre(GenreID) ON DELETE RESTRICT
);

-- ============================================
-- 3. REVIEW & RATING TABLES
-- ============================================

-- Review table (3NF: no transitive dependencies)
CREATE TABLE Review (
    ReviewID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    MovieID INT NOT NULL,
    ReviewText TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    FOREIGN KEY (MovieID) REFERENCES Movie(MovieID) ON DELETE CASCADE,
    UNIQUE KEY unique_user_movie_review (UserID, MovieID)
);

-- Rating table (3NF: no transitive dependencies)
-- Composite PK ensures one rating per user per movie
CREATE TABLE Rating (
    UserID INT NOT NULL,
    MovieID INT NOT NULL,
    NumRating INT NOT NULL CHECK (NumRating >= 1 AND NumRating <= 10),
    PRIMARY KEY (UserID, MovieID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    FOREIGN KEY (MovieID) REFERENCES Movie(MovieID) ON DELETE CASCADE
);

-- ============================================
-- 4. MOOD SYSTEM TABLES
-- ============================================

-- Mood lookup table (3NF: no transitive dependencies)
CREATE TABLE MoodCategory (
    MoodID INT PRIMARY KEY AUTO_INCREMENT,
    MoodName VARCHAR(50) NOT NULL UNIQUE,
    MoodDescription VARCHAR(255)
);

-- UserMood junction table (3NF: resolves many-to-many)
-- Multiple users can assign multiple moods to multiple movies
CREATE TABLE UserMood (
    UserID INT NOT NULL,
    MovieID INT NOT NULL,
    MoodID INT NOT NULL,
    PRIMARY KEY (UserID, MovieID, MoodID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    FOREIGN KEY (MovieID) REFERENCES Movie(MovieID) ON DELETE CASCADE,
    FOREIGN KEY (MoodID) REFERENCES MoodCategory(MoodID) ON DELETE RESTRICT
);

-- ============================================
-- 5. REQUEST SYSTEM
-- ============================================

-- Request table for user requests (3NF: no transitive dependencies)
CREATE TABLE Request (
    RequestID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    RequestType VARCHAR(50) NOT NULL,  -- 'ADD_MOVIE', 'EDIT_MOVIE', etc.
    RequestData TEXT,  -- JSON or structured text
    Status VARCHAR(20) DEFAULT 'PENDING',  -- 'PENDING', 'APPROVED', 'REJECTED'
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

-- ============================================
-- 6. INDEXES FOR PERFORMANCE
-- ============================================

CREATE INDEX idx_movie_genre ON Movie(GenreID);
CREATE INDEX idx_movie_year ON Movie(ReleaseYear);
CREATE INDEX idx_review_movie ON Review(MovieID);
CREATE INDEX idx_review_user ON Review(UserID);
CREATE INDEX idx_rating_movie ON Rating(MovieID);
CREATE INDEX idx_usermood_movie ON UserMood(MovieID);
CREATE INDEX idx_usermood_user ON UserMood(UserID);
CREATE INDEX idx_request_user ON Request(UserID);
CREATE INDEX idx_request_status ON Request(Status);