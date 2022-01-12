from dotenv import load_dotenv
load_dotenv()

import os
SECRET_KEY = os.getenv("HOST")

from flask import Flask,jsonify
import json
from flask.wrappers import Request
from flask_restful import Resource, Api, reqparse
import psycopg2 

# Connecting the DB
con = psycopg2.connect(
    # port = "5431",
    host = SECRET_KEY,
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
            balance = cur.fetchall()
            return jsonify(balance)
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
        cur.execute("select trans.trans_id_1, trans.trans_id_2, trans.card_id_1, trans.card_id_2, tcost.trans_cost, trans.trans_source, trans.trans_destination from transactions trans, transaction_cost tcost where concat(trans.card_id_1,trans.card_id_2) = '%s' and trans.trans_id_1 = tcost.trans_id_1 and trans.trans_id_2 = tcost.trans_id_2 order by trans.trans_id_2 desc;" %(cardNo))
        history = cur.fetchall()
        return jsonify(history)

# function to retrieve all tuples of transaction table

class History_all(Resource):
    def get(self):
        cur.execute('select trans.trans_id_1, trans.trans_id_2, trans.card_id_1, trans.card_id_2, tcost.trans_cost, trans.trans_source, trans.trans_destination  from transactions trans, transaction_cost tcost where trans.trans_id_1 = tcost.trans_id_1 and trans.trans_id_2 = tcost.trans_id_2 order by trans.trans_id_2 desc')
        historyAll = cur.fetchall()
        return jsonify(historyAll)

# function to travel and update the changes to DB

class Travel(Resource):
    def get(self,cardNo,source,dest):
        cur.callproc('ret_bal', (cardNo[:16],cardNo[16:]))
        bal = cur.fetchall()
        bal = json.dumps(str(bal))
        bal = json.loads(bal)
        bal = float(bal[11:-5])
        if bal < 50:
            return [['-1']]
        cur.callproc('travel',(cardNo[:16],cardNo[16:],source,dest))
        amount = cur.fetchall()
        amount = json.dumps(str(amount))
        amount = json.loads(amount)
        # print(amount[11:-5])
        amount = float(amount[11:-5])
        cur.callproc('update_balance',(amount,cardNo[:16],cardNo[16:],source,dest))
        balance = cur.fetchall()
        # balance = json.dumps(str(balance))
        # balance = json.loads(balance)
        balance = jsonify(balance)
        return balance

class Report_Month(Resource):
    def get(self):
        cur.execute('select trans.trans_id_1, trans.trans_id_2, trans.card_id_1, trans.card_id_2, tcost.trans_cost, trans.trans_source, trans.trans_destination  from transactions trans, transaction_cost tcost where trans.trans_id_1 = tcost.trans_id_1 and trans.trans_id_2 = tcost.trans_id_2 order by trans.trans_id_2 desc')
        historyAll = cur.fetchall()
        # print(historyAll)
        
        #code to return month_basis
        temp = set()
        result = []
        for i in historyAll:
            if i[0][7:9] in temp:
                continue
            else:
                temp.add(i[0][7:9])
                result.append(i)
        return jsonify(result)

class Report_Analysis(Resource):
    def get(self, monthYear):
        cur.execute('select trans.trans_id_1, trans.trans_id_2, trans.card_id_1, trans.card_id_2, tcost.trans_cost, trans.trans_source, trans.trans_destination  from transactions trans, transaction_cost tcost where trans.trans_id_1 = tcost.trans_id_1 and trans.trans_id_2 = tcost.trans_id_2 order by trans.trans_id_2 desc')
        historyAll = cur.fetchall()

        #code to send the montly_report 
        total = 0.00
        temp = []
        result = dict()
        for i in historyAll:
            if i[0][7:13] == monthYear:
                temp.append(i)
                total += float(i[4])
            else:
                continue
        result = {
            'revenue' : total,
            'data' : temp
        }
        return jsonify(result)


api.add_resource(AddCard,'/add_card')
api.add_resource(History, '/history/<string:cardNoTemp>')
api.add_resource(History_all, '/history_all')
api.add_resource(Recharge,'/recharge_card/<string:cardNo>/<int:amount>')
api.add_resource(Travel,'/travel/<string:cardNo>/<string:source>/<string:dest>')
api.add_resource(Report_Month,'/report_month')
api.add_resource(Report_Analysis,'/report_analysis/<string:monthYear>')



if __name__ == '__main__':
    app.run(debug=True)

# cur.close()