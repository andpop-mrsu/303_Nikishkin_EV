#!/bin/bash
chcp 65001
cd ../Task02
python3 make_db_init.py
sqlite3 movies_rating.db < db_init.sql
rm db_init.sql

echo "1.Составить список фильмов, имеющих хотя бы одну оценку. Список фильмов отсортировать по году выпуска и по названиям. В списке оставить первые 10 фильмов."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT DISTINCT movies.id id, title, year, genres FROM movies JOIN ratings WHERE movies.id = ratings.movie_id ORDER BY year, title LIMIT 10;"
echo " "

echo "2. Вывести список всех пользователей, фамилии (не имена!) которых начинаются на букву 'A'. Полученный список отсортировать по дате регистрации. В списке оставить первых 5 пользователей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT * FROM users WHERE name LIKE '% A%' ORDER BY register_date LIMIT 5;"

echo "3.Написать запрос, возвращающий информацию о рейтингах в более читаемом формате: имя и фамилия эксперта, название фильма, год выпуска, оценка и дата оценки в формате ГГГГ-ММ-ДД. Отсортировать данные по имени эксперта, затем названию фильма и оценке. В списке оставить первые 50 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT users.name, movies.title, movies.year, ratings.rating, date(ratings.timestamp, 'unixepoch') rating_date FROM movies JOIN ratings ON movies.id = ratings.movie_id JOIN users ON users.id = ratings.user_id ORDER BY users.name, movies.title, ratings.rating LIMIT 50"

echo "4.Вывести список фильмов с указанием тегов, которые были им присвоены пользователями. Сортировать по году выпуска, затем по названию фильма, затем по тегу. В списке оставить первые 40 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT movies.title, tags.tag FROM movies JOIN tags ON movies.id = tags.movie_id LIMIT 40"

echo "5.Вывести список самых свежих фильмов. В список должны войти все фильмы последнего года выпуска, имеющиеся в базе данных. Запрос должен быть универсальным, не зависящим от исходных данных (нужный год выпуска должен определяться в запросе, а не жестко задаваться)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT * FROM movies WHERE movies.year = (SELECT MAX(movies.year) FROM movies)"

echo "6.Найти все комедии, выпущенные после 2000 года, которые понравились мужчинам (оценка не ниже 4.5). Для каждого фильма в этом списке вывести название, год выпуска и количество таких оценок. Результат отсортировать по году выпуска и названию фильма."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT movies.title, movies.year, COUNT(*) rating_count FROM movies JOIN ratings ON movies.id = ratings.movie_id JOIN users ON ratings.user_id = users.id WHERE users.gender = 'male' AND movies.year >= 2000 AND ratings.rating >= 4.5 GROUP BY movies.id ORDER BY movies.year, movies.title"

echo "7.Провести анализ занятий (профессий) пользователей - вывести количество пользователей для каждого рода занятий. Найти самую распространенную и самую редкую профессию посетитетей сайта."
echo --------------------------------------------------
echo "7.1.Вывести количество пользователей для каждого рода занятий"
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT users.occupation, COUNT(*) occupation_count FROM users GROUP BY users.occupation"
echo "7.2.Самая распространенная проффессия"
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT users.occupation, COUNT(*) occupation_count FROM users GROUP BY users.occupation ORDER BY occupation_count DESC LIMIT 1"
echo "7.3.Самая нераспространенная проффессия"
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT users.occupation, COUNT(*) occupation_count FROM users GROUP BY users.occupation ORDER BY occupation_count ASC LIMIT 1"


rm movies_rating.db