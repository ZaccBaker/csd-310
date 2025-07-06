
#Method to show films
def show_films(cursor, title):
    
    query = """
    SELECT film_name AS Name, film_director AS Director, genre_name AS Genre, studio_name AS 'Studio Name'
    FROM film
    INNER JOIN genre ON film.genre_id=genre.genre_id
    INNER JOIN studio ON film.studio_id=studio.studio_id
    ORDER BY film_id
    """

    cursor.execute(query)
    film_data = cursor.fetchall()

    print('\n -- {} -- '.format(title))

    for film in film_data:
        print('Film Name: {}\nDirector: {}\nGenre Name ID: {}\nStudio Name: {}\n'.format(film[0], film[1], film[2], film[3]))
    

"""Specific functionality methods: insert, update"""
#Insert film specific method
def insert_film(cursor, title):

    title += ' AFTER INSERT'

    query = """
    INSERT INTO film(film_name, film_releaseDate, film_runtime, film_director, studio_id, genre_id) 
    VALUES('Planet of the Apes', '2001', '120', 'Tim Burton', 
    (SELECT studio_id FROM studio WHERE studio_name = '20th Century Fox'),
    (SELECT genre_id FROM genre WHERE genre_name = 'SciFi') );
    """

    cursor.execute(query)

    show_films(cursor, title)

#Update film specific method
def update_film(cursor, title):

    title += ' AFTER UPDATE- Changed Alien to Horror'

    query = """
    UPDATE film
    SET genre_id = (SELECT genre_id FROM genre WHERE genre_name = 'Horror')
    WHERE film_name = 'Alien'
    AND genre_id = (SELECT genre_id FROM genre WHERE genre_name = 'SciFi')
    """
    cursor.execute(query)

    show_films(cursor, title)

#Delete film specific method
def delete_film(cursor, title):

    title += ' AFTER DELETE'

    query = """
    DELETE FROM film
    WHERE film_name = 'Gladiator'
    """
    cursor.execute(query)

    show_films(cursor, title)


"""Control method for flow of assignment
    Connects queries to main"""
#Control method
def control(db):
    cursor = db.cursor()

    TITLE = 'DISPLAYING FILMS'

    show_films(cursor, TITLE) #First section: displaying
    insert_film(cursor, TITLE) #Second section: inserting
    update_film(cursor, TITLE) #Third section: updating
    delete_film(cursor, TITLE) #Fourth section: deleting