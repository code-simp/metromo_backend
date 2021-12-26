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
amt = 90
cardNo = 'MTROCRD26122021-0002'

cur.callproc('recharge',(amt,cardNo[:16],cardNo[16:]))

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

trans1 = cur.fetchall() #stored in form of tuples
for i in trans1:
    print(list(i))

cur.close()

# Python function to retrieve all the items in transactions table

cur.execute('select * from transactions')
trans2 = cur.fetchall()
for i in trans2:
    print(i)

# closing the cursor
cur.close()


# closing the connection
con.close()
