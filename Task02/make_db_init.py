# from asyncio.windows_events import NULL
import csv




with open('db_init.sql', 'w') as sql_file:
    sql_file.write("CREATE TABLE IF NOT EXISTS movies (\n" +
                "    id INT PRIMARY KEY,\n" +
                "    title varchar(255),\n" +
                "    year INT,\n" +
                "    genres varchar(255)\n" +
                ");\n" +
                "\n" +
                "CREATE TABLE IF NOT EXISTS ratings (\n" +
                "    id INT PRIMARY KEY,\n" +
                "    user_id INT,\n" +
                "    movie_id INT,\n" +
                "    rating REAL,\n" +
                "    timestamp INT\n" +
                ");\n" +
                "\n" +
                "CREATE TABLE IF NOT EXISTS tags (\n" +
                "    id INT PRIMARY KEY,\n" +
                "    user_id INT,\n" +
                "    movie_id INT,\n" +
                "    tag varchar(255),\n" +
                "    timestamp INT\n" +
                ");\n" +
                "\n" +
                "CREATE TABLE IF NOT EXISTS users (\n" +
                "    id INT PRIMARY KEY,\n" +
                "    name varchar(255),\n" +
                "    email varchar(255),\n" +
                "    gender varchar(255),\n" +
                "    register_date DATE,\n" +
                "    occupation varchar(255)\n" +
                ");\n")


    sql_file.write('INSERT OR IGNORE INTO movies VALUES\n')
    k = 0
    with open('movies.csv', 'r') as csv_file:
        reader = list(csv.reader(csv_file))
        for row in reader:
            id = row[0]
            k = k + 1
            if (id == 'movieId'):
                continue
            while len(row[1]) > 0 and row[1][-1] == ' ':
                row[1] = row[1][0:-2]
            title = row[1][0:-7]
            title = title.replace('\"', '')
            try:
                year = int(row[1][-5:-1])
            except:
                year = 'NULL'
            genres = row[2]
            st = f'({id}, "{title}", {year}, "{genres}")'
            if k != len(reader):
                st = st + ','
                st = st + '\n'
            sql_file.write(st)

    sql_file.write(';\n')
    sql_file.write('INSERT OR IGNORE INTO ratings VALUES\n')
    k = 0
    with open('ratings.csv', 'r') as csv_file:
        reader = list(csv.reader(csv_file))

        for row in reader:
            k = k + 1
            user_id, movie_id, rating, timestamp = row
            if user_id == 'userId':
                continue
            st = f'({k}, {user_id}, {movie_id}, {rating}, {timestamp})'
            if k != len(reader):
                st = st + ','
                st = st + '\n'
            sql_file.write(st)

    sql_file.write(';\n')
    k = 0
    sql_file.write('INSERT OR IGNORE INTO tags VALUES\n')
    with open('tags.csv', 'r') as csv_file:
        reader = list(csv.reader(csv_file))

        for row in reader:
            userId, movieId, tag, timestamp = row
            k = k + 1
            if userId == 'userId':
                continue
            tag = tag.replace('\"', '')
            st = f'({k}, {userId}, {movieId}, \"{tag}\", {timestamp})'
            if k != len(reader):
                st = st + ',\n'
            sql_file.write(st)

    sql_file.write(';\n')
    
    sql_file.write('INSERT OR IGNORE INTO users VALUES\n')
    k = 0
    with open('users.txt', 'r') as txt_file:
        rows = list(txt_file.readlines())
        for row in rows:
            k = k + 1
            id, name, email, gender, register_date, occupation = row.split('|')
            name = name.replace('\"', '')
            email = email.replace('\"', '')
            gender = gender.replace('\"', '')
            occupation = occupation.replace('\"', '')
            st = f'({id}, \"{name}\", \"{email}\", \"{gender}\", {register_date}, \"{occupation}\")'
            if k != len(rows):
                st = st + ',\n'
            sql_file.write(st)

    sql_file.write(';\n')
