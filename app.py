from flask import Flask,jsonify
from flask.wrappers import Request
from flask_restful import Resource, Api, reqparse
import psycopg2 

# Connecting the DB
con = psycopg2.connect(
    host = 'Tarun-MacBook-Air.local',
    database = 'metromo',
    user = 'postgres',
    password = '1234')

con.autocommit = True

# cursor and queries
cur = con.cursor()

app = Flask(__name__)
api = Api(app)


# function to add new card to DB

class AddCard(Resource):
    def get(self):
        cur.callproc('insert_to_card')
        new_card = cur.fetchall()
        return jsonify(new_card)


# function to recharge  MTROCRD26122021-0005

class Recharge(Resource):
    def get(self,cardNo,amount):
        if amount > 50:
            cur.callproc('recharge',(amount,cardNo[:16],cardNo[16:]))
            return True
        else:
            return False 

# function to retrieve all tuples of the card

class History(Resource):
    def get(self,cardNoTemp):
        cardNo = cardNoTemp[:16]
        for i in range(16,len(cardNoTemp)):
            if cardNoTemp[i] != '0':
                break
            else:
                continue
        print(cardNoTemp)
        cardNo += cardNoTemp[i:]
        print(cardNo)
        cur.execute("select * from transactions where concat(card_id_1,card_id_2) = '%s'" %(cardNo))
        history = cur.fetchall()
        return jsonify(history)

# function to retrieve all tuples of transaction table

class History_all(Resource):
    def get(self):
        cur.execute('select * from transactions')
        historyAll = cur.fetchall()
        return jsonify(historyAll)
        

api.add_resource(AddCard,'/add_card')
api.add_resource(History, '/history/<string:cardNoTemp>')
api.add_resource(History_all, '/history_all')
api.add_resource(Recharge,'/recharge_card/<string:cardNo>/<int:amount>')


if __name__ == '__main__':
    app.run(debug=True)

cur.close()