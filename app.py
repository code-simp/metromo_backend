from flask import Flask,jsonify
from flask_restful import Resource, Api
import psycopg2 

# Connecting the DB
con = psycopg2.connect(
    host = 'Tarun-MacBook-Air.local',
    database = 'metromo',
    user = 'postgres',
    password = '1234')

# cursor and queries
cur = con.cursor()

# cur.execute('select * from card')
# try1 = cur.fetchall()
# for i in try1:
#     print(i)

app = Flask(__name__)
api = Api(app)




class HelloWorld(Resource):
    def get(self):
        return { 'hello' : 'world'}

class fetch_card(Resource):
    def get(self):
        cur.execute('select * from card')
        try1 = cur.fetchall()
        for i in try1:
            print(i)
        return jsonify(try1)
        

api.add_resource(HelloWorld,'/')
api.add_resource(fetch_card,'/fc')


if __name__ == '__main__':
    app.run(debug=True)

cur.close()