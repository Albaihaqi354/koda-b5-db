-- Register
INSERT INTO users (email, password, first_name, last_name, phone_number, role)
VALUES ('albian@gmail.com', 'Albian@gmail.com', 'Albi', 'Bian', '087727726316', 'user')
RETURNING id, email, first_name, last_name, phone_number, loyalty_points, role, created_at;

-- Login
SELECT 
    id, 
    email, 
    password, 
    first_name, 
    last_name, 
    phone_number, 
    profile_image, 
    loyalty_points, 
    role,
    created_at
FROM users
WHERE email = 'albian@gmail.com';

-- Get Upcoming Movies
SELECT 
    m.id,
    m.title,
    m.synopsis,
    m.duration,
    m.release_date,
    d.name AS director,
    STRING_AGG(DISTINCT a.name, ', ') AS "cast",
    m.poster_url,
    m.backdrop_url,
    m.popularity_score,
    STRING_AGG(DISTINCT g.name, ', ') AS genre_name
FROM movies m
LEFT JOIN directors d ON m.director_id = d.id
LEFT JOIN movie_casts mc ON m.id = mc.movie_id
LEFT JOIN actors a ON mc.actor_id = a.id
LEFT JOIN movie_genres mg ON m.id = mg.movie_id
LEFT JOIN genres g ON mg.genre_id = g.id
WHERE m.is_upcoming = true OR m.release_date > CURRENT_DATE
GROUP BY m.id, d.name
ORDER BY m.release_date ASC;

-- Get Popular Movies
SELECT 
    m.id,
    m.title,
    m.synopsis,
    m.duration,
    m.release_date,
    d.name AS director,
    STRING_AGG(DISTINCT a.name, ', ') AS "cast",
    m.poster_url,
    m.backdrop_url,
    m.popularity_score,
    STRING_AGG(DISTINCT g.name, ', ') AS genre_name
FROM movies m
LEFT JOIN directors d ON m.director_id = d.id
LEFT JOIN movie_casts mc ON m.id = mc.movie_id
LEFT JOIN actors a ON mc.actor_id = a.id
LEFT JOIN movie_genres mg ON m.id = mg.movie_id
LEFT JOIN genres g ON mg.genre_id = g.id
GROUP BY m.id, d.name
ORDER BY m.popularity_score DESC;

-- Get Movies with Pagination
SELECT 
    m.id,
    m.title,
    m.synopsis,
    m.duration,
    m.release_date,
    d.name AS director,
    STRING_AGG(DISTINCT a.name, ', ') AS "cast",
    m.poster_url,
    m.backdrop_url,
    m.popularity_score,
    STRING_AGG(DISTINCT g.name, ', ') AS genre_name
FROM movies m
LEFT JOIN directors d ON m.director_id = d.id
LEFT JOIN movie_casts mc ON m.id = mc.movie_id
LEFT JOIN actors a ON mc.actor_id = a.id
LEFT JOIN movie_genres mg ON m.id = mg.movie_id
LEFT JOIN genres g ON mg.genre_id = g.id
GROUP BY m.id, d.name
ORDER BY m.release_date DESC
LIMIT 12 OFFSET 0;

-- Filter Movie by Name and Genre with Pagination
SELECT 
    m.id,
    m.title,
    m.synopsis,
    m.duration,
    m.release_date,
    d.name AS director,
    STRING_AGG(DISTINCT a.name, ', ') AS "cast",
    m.poster_url,
    m.backdrop_url,
    m.popularity_score,
    STRING_AGG(DISTINCT g.name, ', ') AS genre_name
FROM movies m
LEFT JOIN directors d ON m.director_id = d.id
LEFT JOIN movie_casts mc ON m.id = mc.movie_id
LEFT JOIN actors a ON mc.actor_id = a.id
LEFT JOIN movie_genres mg ON m.id = mg.movie_id
LEFT JOIN genres g ON mg.genre_id = g.id
WHERE 
    ('Spider' IS NULL OR m.title ILIKE '%' || 'Spider' || '%') AND
    (1::INTEGER IS NULL OR m.id IN (
        SELECT movie_id FROM movie_genres WHERE genre_id = 1
    ))
GROUP BY m.id, d.name
ORDER BY m.release_date DESC
LIMIT 12 OFFSET 0;

-- Get Schedules
SELECT 
    s.id,
    s.show_date,
    s.show_time,
    s.price,
    c.id AS cinema_id,
    c.name AS cinema_name,
    c.logo_url AS cinema_logo,
    c.location AS cinema_location,
    ci.name AS cinema_city
FROM schedules s
INNER JOIN cinemas c ON s.cinema_id = c.id
INNER JOIN cities ci ON c.city_id = ci.id
WHERE s.movie_id = 1
    AND ('2026-02-01'::DATE IS NULL OR s.show_date = '2026-02-01')
    AND ('Jakarta'::VARCHAR IS NULL OR ci.name = 'Jakarta')
ORDER BY s.show_date, s.show_time;

-- Get Seat Sold/Available
SELECT 
    se.id AS seat_id,
    se.row_letter,
    se.seat_number,
    se.seat_type,
    CASE 
        WHEN od.id IS NOT NULL THEN 'sold'
        ELSE 'available'
    END AS status
FROM schedules sch
INNER JOIN cinemas c ON sch.cinema_id = c.id
INNER JOIN seats se ON se.cinema_id = c.id
LEFT JOIN orders o ON o.schedule_id = sch.id AND o.payment_status = 'paid'
LEFT JOIN order_details od ON od.order_id = o.id AND od.seat_id = se.id
WHERE sch.id = 1
ORDER BY se.row_letter, se.seat_number;

-- Get Movie Detail
SELECT 
    m.id,
    m.title,
    m.synopsis,
    m.duration,
    m.release_date,
    d.name AS director,
    STRING_AGG(DISTINCT a.name, ', ') AS "cast",
    m.poster_url,
    m.backdrop_url,
    m.is_upcoming,
    m.popularity_score,
    STRING_AGG(DISTINCT g.name, ', ') AS genre_name
FROM movies m
LEFT JOIN directors d ON m.director_id = d.id
LEFT JOIN movie_casts mc ON m.id = mc.movie_id
LEFT JOIN actors a ON mc.actor_id = a.id
LEFT JOIN movie_genres mg ON m.id = mg.movie_id
LEFT JOIN genres g ON mg.genre_id = g.id
WHERE m.id = 1
GROUP BY m.id, d.name;

-- Create Order
INSERT INTO orders (user_id, schedule_id, total_price, payment_status, booking_code)
VALUES (2, 1, 50000, 'pending', RANDOM())
RETURNING id, booking_code, created_at;

-- Get Profile
SELECT 
    id, 
    email, 
    first_name, 
    last_name, 
    phone_number, 
    profile_image, 
    loyalty_points, 
    role,
    created_at
FROM users
WHERE id = 2;

-- Get History
SELECT 
    o.id AS order_id,
    o.booking_code,
    o.total_price,
    o.payment_status,
    o.created_at AS order_date,
    m.id AS movie_id,
    m.title AS movie_title,
    m.poster_url AS movie_poster,
    c.name AS cinema_name,
    c.logo_url AS cinema_logo,
    s.show_date,
    s.show_time,
    COUNT(od.id) AS ticket_count
FROM orders o
INNER JOIN schedules s ON o.schedule_id = s.id
INNER JOIN movies m ON s.movie_id = m.id
INNER JOIN cinemas c ON s.cinema_id = c.id
LEFT JOIN order_details od ON od.order_id = o.id
WHERE o.user_id = 2
GROUP BY o.id, m.id, c.id, s.id
ORDER BY o.created_at DESC
LIMIT 10 OFFSET 0;

-- Edit Profile
UPDATE users
SET 
    first_name = COALESCE('Bianqi', first_name),
    last_name = COALESCE('Albaihaqi', last_name),
    phone_number = COALESCE('081233334444', phone_number),
    profile_image = COALESCE('profile.jpg', profile_image)
WHERE id = 2
RETURNING id, email, first_name, last_name, phone_number, profile_image, loyalty_points;

-- Get All Movie (Admin)
SELECT 
    m.id,
    m.title,
    m.synopsis,
    m.duration,
    m.release_date,
    d.name AS director,
    STRING_AGG(DISTINCT a.name, ', ') AS "cast",
    m.poster_url,
    m.backdrop_url,
    m.is_upcoming,
    m.popularity_score,
    m.created_at,
    m.updated_at,
    STRING_AGG(DISTINCT g.name, ', ') AS genre_name,
    COUNT(DISTINCT s.id) AS schedule_count
FROM movies m
LEFT JOIN directors d ON m.director_id = d.id
LEFT JOIN movie_casts mc ON m.id = mc.movie_id
LEFT JOIN actors a ON mc.actor_id = a.id
LEFT JOIN movie_genres mg ON m.id = mg.movie_id
LEFT JOIN genres g ON mg.genre_id = g.id
LEFT JOIN schedules s ON s.movie_id = m.id
GROUP BY m.id, d.name
ORDER BY m.created_at DESC
LIMIT 10 OFFSET 0;

-- Delete Movie (Admin)
DELETE FROM movies
WHERE id = 5
RETURNING id, title;

-- Edit Movie (Admin)
UPDATE movies
SET 
    title = COALESCE('Hallo', title),
    synopsis = COALESCE(NULL, synopsis),
    duration = COALESCE(130, duration),
    release_date = COALESCE(NULL, release_date),
    director_id = COALESCE(1, director_id),
    poster_url = COALESCE(NULL, poster_url),
    backdrop_url = COALESCE(NULL, backdrop_url),
    is_upcoming = COALESCE(NULL, is_upcoming),
    popularity_score = COALESCE(NULL, popularity_score)
WHERE id = 1
RETURNING id, title, synopsis, duration, release_date, director_id, poster_url, backdrop_url, is_upcoming, popularity_score;