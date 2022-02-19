from configparser import ConfigParser
import firebirdsql
import os

#read ini file of database params
def config(filename='config_db.ini', section='firebird'):
    # create parser
    parser = ConfigParser()
    # read params
    parser.read(filename)

    # read sections
    db = {}
    if parser.has_section(section):
        params = parser.items(section)
        for param in params:
            db[param[0]] = param[1]
    else:
        raise Exception('Section {0} not found in the {1} file'.format(section, filename))

    return db

def DBConnect():
    try:
        print('Conectando ao banco de dados Firebird...')
        conn = firebirdsql.connect(database=config()["database"],                             
                               user=config()["user"],
                               password=config()["password"],
                               charset=config()["charset"])
        cur = conn.cursor()
        print('Conectado')
    except Exception as err:
        print(err)