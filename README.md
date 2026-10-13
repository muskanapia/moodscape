# MoodScape - A Mood-Based Movie Review Platform

## 📚 Academic Project for CSE370 (Database Systems)

**Project Title:** MoodScape – A Mood-Based Movie Review Platform  
**Course:** CSE370 - Database Systems  
**Focus:** SQL database design, normalization, relationships, and CRUD operations

---

## 🎯 Project Overview

MoodScape is a web application where users review movies based on emotions (moods) instead of only numerical ratings. The system demonstrates strong SQL usage including normalized schemas (3NF), foreign keys, many-to-many relationships, aggregate queries, CRUD operations, and role-based access control.

### Key Features
- **Mood-Based Reviews**: Users can tag movies with multiple mood tags (Happy, Emotional, Inspired, Tense, etc.)
- **Comprehensive Rating System**: 1-10 numerical ratings with written reviews
- **Advanced Search & Filter**: Search by title, genre, year, mood, or rating range
- **User Profiles**: Track review history, rating patterns, and mood preferences
- **Admin Panel**: Manage movies, users, and moderate content
- **Analytics**: Mood distribution charts and aggregate statistics

---

## 🛠 Technology Stack

**Frontend:** HTML + CSS (simple, clean, no frameworks)  
**Backend:** Python Flask  
**Database:** MySQL (normalized to 3NF)  
**Charts:** Chart.js for mood distribution visualization  
**Authentication:** Flask sessions with password hashing

---

## 📊 Database Design

### Normalization Overview (3NF)

The database schema follows Third Normal Form (3NF) principles:

1. **First Normal Form (1NF)**: All tables have atomic values, no repeating groups
2. **Second Normal Form (2NF)**: No partial dependencies on composite primary keys
3. **Third Normal Form (3NF)**: No transitive dependencies of non-key attributes

### Core Tables

#### 1. Users & Roles
```sql
Users(UserID PK, Name, Email, PasswordHash, JoinDate, IsActive)
Admin(UserID PK/FK)          -- Role specialization
NormalUser(UserID PK/FK)     -- Role specialization
```

#### 2. Movie & Genre
```sql
Genre(GenreID PK, GenreName)     -- Lookup table
Movie(MovieID PK, Name, Summary, ReleaseYear, GenreID FK)
```

#### 3. Review System
```sql
Review(ReviewID PK, UserID FK, MovieID FK, ReviewText, Time)
Rating(UserID PK/FK, MovieID PK/FK, NumRating)  -- Composite PK
```

#### 4. Mood System
```sql
MoodCategory(MoodID PK, MoodName, MoodDescription)  -- Lookup table
UserMood(UserID PK/FK, MovieID PK/FK, MoodID PK/FK)  -- Junction table
```

### Key Relationships

- **One-to-Many**: User → Reviews, Movie → Reviews, Genre → Movies
- **Many-to-Many**: Users ↔ Movies (through Rating/Review), Users ↔ Movies ↔ Moods (through UserMood)
- **Role Specialization**: Users → Admin/NormalUser (ISA relationship)

---

## 🚀 Installation & Setup

### Prerequisites
- Python 3.7+
- MySQL Server
- pip (Python package manager)

### Step 1: Database Setup

1. **Update Database Credentials** in `backend/app.py`:
   ```python
   DB_CONFIG = {
       'host': 'localhost',
       'database': 'moodscape_db',
       'user': 'root',
       'password': 'your_mysql_password',  # Change this
       'port': 3306
   }
   ```

2. **Run Database Setup**:
   ```bash
   cd database
   python setup.py
   ```
   Or manually execute `schema.sql` and `sample_data.sql` in MySQL.

### Step 2: Backend Setup

1. **Install Dependencies**:
   ```bash
   cd backend
   pip install flask mysql-connector-python werkzeug
   ```

2. **Run Flask Application**:
   ```bash
   python app.py
   ```

3. **Access Application**:
   - URL: `http://localhost:5000`
   - Admin Login: `admin@example.com` / `password`
   - User Login: `alice@example.com` / `password`

---

## 📁 Project Structure

```
moodscape/
├── backend/
│   └── app.py                 # Flask application with CRUD routes
├── database/
│   ├── schema.sql            # CREATE TABLE statements (3NF normalized)
│   ├── sample_data.sql       # Sample INSERT statements
│   ├── analytics_queries.sql # Complex SQL queries for analytics
│   └── setup.py              # Database setup script
├── templates/
│   ├── base.html             # Base template
│   ├── login.html            # User login
│   ├── register.html         # User registration
│   ├── search.html           # Search and filter movies
│   ├── profile.html          # User profile
│   ├── movies/
│   │   ├── list.html         # List all movies
│   │   ├── detail.html       # Movie details with reviews
│   │   ├── add.html          # Add movie (admin)
│   │   └── edit.html         # Edit movie (admin)
│   ├── reviews/
│   │   └── add.html          # Add/edit reviews
│   └── admin/
│       ├── dashboard.html    # Admin dashboard
│       ├── users.html        # Manage users
│       └── requests.html     # User requests
├── static/
│   ├── css/
│   │   └── style.css         # Simple, clean CSS
│   └── js/
│       └── main.js           # JavaScript utilities
└── README.md                 # This file
```

---

## 🔧 Core Functionality

### User Features

#### 1. View Movies
- **Route**: `/movies`
- **Query**: Lists all movies with average ratings using aggregate functions

#### 2. Movie Details
- **Route**: `/movies/<movie_id>`
- **Features**: Summary, average rating, mood distribution (pie chart), user reviews
- **API**: `/api/mood-distribution/<movie_id>` returns JSON mood data

#### 3. Add Review + Rating + Moods
- **Route**: `/movies/<movie_id>/review`
- **Database Operations**:
  - INSERT/UPDATE Rating (one per user per movie constraint)
  - INSERT/UPDATE Review
  - DELETE existing UserMood + INSERT new UserMood entries

#### 4. Edit/Delete Review
- **Route**: `/movies/<movie_id>/review` (GET shows existing review)
- **Database Operations**:
  - DELETE FROM Rating, Review, UserMood
  - CASCADE deletes maintain referential integrity

#### 5. Search & Filter
- **Route**: `/search`
- **Features**: Search by title, genre, year, mood, rating range
- **Query**: Dynamic SQL with JOINs across multiple tables

#### 6. User Profile
- **Route**: `/profile`
- **Features**: Review history, rating patterns, most used moods
- **Query**: Complex aggregation with GROUP BY and COUNT(DISTINCT)

### Admin Features

#### 1. Manage Movies
- **Routes**: `/movies/add`, `/movies/<id>/edit`, `/movies/<id>/delete`
- **Features**: Full CRUD operations with referential integrity

#### 2. Manage Users
- **Route**: `/admin/users`
- **Features**: View all users, ban/unban users
- **Query**: LEFT JOIN with role tables and aggregate statistics

#### 3. Moderate Reviews
- **Route**: `/admin/requests`
- **Features**: View and process user requests

---

## 📈 Complex SQL Queries

### 1. Average Rating Per Movie
```sql
SELECT m.MovieID, m.Name, AVG(r.NumRating) AS AverageRating
FROM Movie m
LEFT JOIN Rating r ON m.MovieID = r.MovieID
GROUP BY m.MovieID, m.Name
ORDER BY AverageRating DESC
```

### 2. Mood Percentage Calculation
```sql
WITH MovieMoodCounts AS (
    SELECT m.MovieID, mc.MoodName, COUNT(*) AS MoodCount
    FROM Movie m
    JOIN UserMood um ON m.MovieID = um.MovieID
    JOIN MoodCategory mc ON um.MoodID = mc.MoodID
    GROUP BY m.MovieID, mc.MoodName
)
SELECT MovieID, MoodName, 
       ROUND((MoodCount * 100.0 / SUM(MoodCount) OVER (PARTITION BY MovieID)), 2) AS MoodPercentage
FROM MovieMoodCounts
```

### 3. User's Most Common Mood
```sql
WITH UserMoodCounts AS (
    SELECT u.UserID, mc.MoodName, COUNT(*) AS MoodUsageCount,
           ROW_NUMBER() OVER (PARTITION BY u.UserID ORDER BY COUNT(*) DESC) AS Rank
    FROM Users u
    JOIN UserMood um ON u.UserID = um.UserID
    JOIN MoodCategory mc ON um.MoodID = mc.MoodID
    GROUP BY u.UserID, mc.MoodName
)
SELECT UserID, MoodName, MoodUsageCount
FROM UserMoodCounts
WHERE Rank = 1
```

### 4. Movies Filtered by Mood
```sql
SELECT m.MovieID, m.Name, AVG(r.NumRating) AS AverageRating
FROM Movie m
JOIN UserMood um ON m.MovieID = um.MovieID
JOIN MoodCategory mc ON um.MoodID = mc.MoodID
LEFT JOIN Rating r ON m.MovieID = r.MovieID
WHERE mc.MoodName = 'Inspired'
GROUP BY m.MovieID, m.Name
ORDER BY AverageRating DESC
```

---

## 🎨 Frontend Features

### Simple, Clean Design
- **CSS Framework**: Custom CSS (no frameworks as per requirements)
- **Responsive**: Mobile-friendly design
- **Color Scheme**: Professional blue/gray theme
- **Typography**: Clean sans-serif fonts

### Key UI Components
1. **Navigation Bar**: User authentication status, role-based menu items
2. **Movie Cards**: Grid layout with hover effects
3. **Rating Display**: Star ratings with average calculations
4. **Mood Visualization**: Interactive pie charts using Chart.js
5. **Forms**: Clean, accessible form designs with validation

---

## 🔐 Security Features

### Authentication & Authorization
- **Password Hashing**: Using Werkzeug's pbkdf2:sha256
- **Session Management**: Flask sessions for user state
- **Role-Based Access**: Admin vs Normal User permissions
- **Input Validation**: Server-side form validation

### Database Security
- **Parameterized Queries**: All queries use parameterized statements
- **SQL Injection Prevention**: Input sanitization and validation
- **Referential Integrity**: Foreign key constraints prevent data corruption

---

## 📊 Academic Justification

### Why This Design is Suitable for CSE370

1. **3NF Normalization**: Demonstrates proper database normalization
2. **Complex Relationships**: Many-to-many relationships via junction tables
3. **Aggregate Queries**: Advanced SQL with window functions and CTEs
4. **CRUD Operations**: Complete lifecycle management
5. **Role-Based Access**: Demonstrates database-level security
6. **Referential Integrity**: Foreign keys and CASCADE operations
7. **Performance Optimization**: Strategic indexes for query performance

### Database Concepts Demonstrated

- **Entity-Relationship Model**: Clear separation of entities
- **Normalization Theory**: 1NF, 2NF, 3NF compliance
- **SQL Mastery**: Complex queries, joins, subqueries, aggregates
- **Transaction Management**: ACID properties in CRUD operations
- **Database Security**: Authentication, authorization, input validation

---

## 🧪 Testing

### Sample Data Included
- **Users**: 6 users (1 admin, 5 normal users)
- **Movies**: 10 classic movies across various genres
- **Reviews**: Multiple reviews with ratings and mood tags
- **Moods**: 10 different mood categories

### Test Scenarios
1. **User Registration**: Create new accounts
2. **Login/Logout**: Session management
3. **Add Reviews**: Rating + mood tagging
4. **Search Movies**: Multi-criteria filtering
5. **Admin Operations**: CRUD on movies and users
6. **Mood Analytics**: Chart generation and statistics

---

## 📝 Future Enhancements

### Potential Improvements
1. **Recommendation Engine**: Movies based on mood similarity
2. **Social Features**: Follow users, share reviews
3. **Advanced Analytics**: Machine learning on mood patterns
4. **API Development**: RESTful API for mobile apps
5. **Performance Optimization**: Query optimization, caching
6. **Additional Visualizations**: More chart types and statistics

---

## 🎓 Conclusion

MoodScape demonstrates comprehensive database design principles and SQL mastery suitable for a CSE370 academic project. The emphasis on database handling over UI polish aligns with the course requirements, showcasing normalized schemas, complex queries, and proper relational database practices.

The project successfully implements all required features while maintaining clean, readable code suitable for academic evaluation.

---

## 📧 Support

For questions or issues related to this academic project, please refer to the documentation or consult with your CSE370 instructor.

**Good luck with your database systems course!** 🚀
