#!/bin/bash
chcp 65001
cd ../Task02
python3 make_db_init.py
sqlite3 movies_rating.db < db_init.sql
rm db_init.sql

echo "1.Найти все пары пользователей, оценивших один и тот же фильм. Устранить дубликаты, проверить отсутствие пар с самим собой. Для каждой пары должны быть указаны имена пользователей и название фильма, который они ценили."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT users1.name, users2.name, movies.title FROM ratings ratings1, ratings ratings2, users users1, users users2, movies WHERE ratings1.movie_id=ratings2.movie_id AND ratings1.user_id < ratings2.user_id AND ratings1.movie_id=movies.id AND users1.id=ratings1.user_id AND users2.id=ratings2.user_id GROUP BY ratings1.user_id, ratings2.user_id"
echo " "

echo "2. Найти 10 самых свежих оценок от разных пользователей, вывести названия фильмов, имена пользователей, оценку, дату отзыва в формате ГГГГ-ММ-ДД."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT movies.title, users.name, ratings.rating, MAX(DATE(ratings.timestamp, 'unixepoch')) rating_date FROM movies JOIN ratings ON movies.id = ratings.movie_id JOIN users ON ratings.user_id = users.id GROUP BY users.name ORDER BY ratings.timestamp DESC LIMIT 10"

echo "3.Вывести в одном списке все фильмы с максимальным средним рейтингом и все фильмы с минимальным средним рейтингом. Общий список отсортировать по году выпуска и названию фильма. В зависимости от рейтинга в колонке "Рекомендуем" для фильмов должно быть написано "Да" или "Нет"."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH movrat AS (SELECT movies.title title, AVG(ratings.rating) rating, movies.year year FROM movies JOIN ratings ON movies.id = ratings.movie_id GROUP BY movies.id) SELECT movrat.title, movrat.rating, movrat.year, 'Да' recomendation FROM movrat WHERE movrat.rating = (SELECT MAX(movrat.rating) FROM movrat) UNION ALL SELECT movrat.title, movrat.rating, movrat.year, 'Нет' recomendation FROM movrat WHERE movrat.rating = (SELECT MIN(movrat.rating) FROM movrat) ORDER BY movrat.title, movrat.year"

echo "4.Вычислить количество оценок и среднюю оценку, которую дали фильмам пользователи-женщины в период с 2010 по 2012 год."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT AVG(ratings.rating) avg_rating, COUNT(*) count_rating FROM ratings JOIN users ON ratings.user_id = users.id WHERE DATE(ratings.timestamp, 'unixepoch') >= '2010-00-00' AND DATE(ratings.timestamp, 'unixepoch') < '2013-00-00' AND users.gender = 'female'"

echo "5.Составить список фильмов с указанием их средней оценки и места в рейтинге по средней оценке. Полученный список отсортировать по году выпуска и названиям фильмов. В списке оставить первые 20 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH movrat AS (SELECT movies.title title, AVG(ratings.rating) rating, movies.year year FROM movies JOIN ratings ON movies.id = ratings.movie_id GROUP BY movies.id) SELECT movrat.title, movrat.rating, movrat.year, ROW_NUMBER() OVER(ORDER BY movrat.rating DESC) place FROM movrat ORDER BY movrat.year, movrat.title LIMIT 10"

echo "6.Вывести список из 10 последних зарегистрированных пользователей в формате "Фамилия Имя|Дата регистрации" (сначала фамилия, потом имя)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT SUBSTR(users.name, INSTR(users.name, ' ') + 1, 123) || ' ' || SUBSTR(users.name, 0, INSTR(users.name, ' ')) || ' | ' || users.register_date user FROM users ORDER BY users.register_date DESC LIMIT 10"

echo "7.С помощью рекурсивного CTE составить таблицу умножения для чисел от 1 до 10"
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE mult_tab(x, y) AS (SELECT 1 AS x, 1 AS y UNION SELECT x + y / 10 AS x, y % 10 + 1 AS y FROM mult_tab WHERE x <= 10 AND x + y != 20) SELECT mult_tab.x || 'x' || mult_tab.y || ' = ' || (mult_tab.x * mult_tab.y) AS result FROM mult_tab"

echo "8. С помощью рекурсивного CTE выделить все жанры фильмов, имеющиеся в таблице movies (каждый жанр в отдельной строке)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE find_genres(res, genres) AS (SELECT '' AS res, movies.genres as genres FROM movies UNION ALL SELECT IIF(INSTR(genres, '|') != 0, SUBSTR(genres, 0, INSTR(genres, '|')), genres) AS res, IIF(INSTR(genres, '|') != 0, SUBSTR(genres, INSTR(genres, '|') + 1, 555), '') AS genres FROM find_genres WHERE genres != '') SELECT DISTINCT res as genre from find_genres WHERE genre != '' AND genre != '(no genres listed)'"

rm movies_rating.db