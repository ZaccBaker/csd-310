""" import statements """
import mysql.connector # to connect
from mysql.connector import errorcode

import dotenv # to use .env file
from dotenv import dotenv_values


#using our .env file
secrets = dotenv_values(".env")

""" database config object """
config = {
    "user": secrets["USER"],
    "password": secrets["PASSWORD"],
    "host": secrets["HOST"],
    "database": secrets["DATABASE"],
    "raise_on_warnings": True #not in .env file
}

try:
    """ try/catch block for handling potential MySQL database errors """ 

    db = mysql.connector.connect(**config) # connect to the movies database 

    cursor = db.cursor()

    #First query
    query = """
    SELECT *
    FROM studio
    """
    
    cursor.execute(query)

    result = cursor.fetchall()

    print("\n-- DISPLAYING Studio RECORDS --")
    
    for text in result:
    
        print(f'\nStudio ID: {text[0]}'
              f'\nStudio Name: {text[1]}')
        

    #Second query
    query = """
    SELECT *
    FROM genre
    """

    cursor.execute(query)

    result = cursor.fetchall()

    print("\n-- DISPLAYING Genre RECORDS --")
    
    for text in result:

        print(f'\nGenre ID: {text[0]}'
              f'\nGenre Name: {text[1]}')
        

    #Third query
    query = """
    SELECT film_name, SUM(film_runtime) as run_time
    FROM film
    GROUP BY film_name
    HAVING SUM(film_runtime) < 120;
    """

    cursor.execute(query)

    result = cursor.fetchall()

    print("\n-- DISPLAYING Short Film RECORDS --")
    
    for text in result:

        print(f'\nFilm Name: {text[0]}'
              f'\nRuntime: {text[1]}')
        

    #Fourth query
    query = """
    SELECT film_name, film_director
    FROM film
    ORDER BY film_director ASC, film_name DESC;
    """

    cursor.execute(query)

    result = cursor.fetchall()

    print("\n-- DISPLAYING Director RECORDS in Order --")
    
    for text in result:

        print(f'\nFilm Name: {text[0]}'
              f'\nDirector: {text[1]}')


except mysql.connector.Error as err:
    """ on error code """

    if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
        print("  The supplied username or password are invalid")

    elif err.errno == errorcode.ER_BAD_DB_ERROR:
        print("  The specified database does not exist")

    else:
        print(err)

finally:
    """ close the connection to MySQL """

    db.close()