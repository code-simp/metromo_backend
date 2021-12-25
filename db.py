import psycopg2 

# connect to DB
con = psycopg2.connect(
    host = 'Tarun-MacBook-Air.local',
    database = 'metromo',
    user = 'postgres',
    password = '1234')

con.autocommit = True


# creating cursor
cur = con.cursor()

# *     query section       *

# Python function to insert new card
cur.callproc('insert_to_card')

# Python function to recharge
cur.callproc('recharge',(200,'MTROCRD26122021-',5))

# Python function to check all transactions of a card number
cardNoTemp = 'MTROCRD26122021-0002'
cardNo = cardNoTemp[:16]
for i in range(16,len(cardNoTemp)):
    if cardNoTemp[i] != '0':
        break
    else:
        continue

cardNo += cardNoTemp[i:]

cur.execute("select * from transactions where concat(card_id_1,card_id_2) = '%s'" %(cardNo))

rows = cur.fetchall() #stored in form of tuples
for i in rows:
    print(list(i))

# closing the cursor
cur.close()


# closing the connection
con.close()
