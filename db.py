import psycopg2 

# connect to DB
con = psycopg2.connect(
    host = 'Tarun-MacBook-Air.local',
    database = 'metromo',
    user = 'postgres',
    password = '1234')


# creating cursor
cur = con.cursor()

# query section
cur.execute('select * from stations')

rows = cur.fetchall()

# closing the cursor
cur.close()

for i in rows:
    print(i)


# closing the connection
con.close()
