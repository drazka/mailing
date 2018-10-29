from flask import Flask, render_template, request, json
from flaskext.mysql import MySQL
#from werkzeug import generate_password_hash, check_password_hash
from werkzeug.security import generate_password_hash

app = Flask(__name__)
mysql = MySQL()

#MySQL configuration
app.config['MYSQL_DATABASE_USER'] = 'root'
app.config['MYSQL_DATABASE_PASSWORD'] = 'Kilimandzaro'
app.config["MYSQL_DATABASE_DB"] = 'BucketList'
app.config["MYSQL_DATABASE_HOST"] = 'localhost'
mysql.init_app(app)

@app.route("/")
def main():
    return render_template('index.html')


@app.route("/showSignUp")
def showSignUp():
    return render_template('signup.html')


@app.route('/signUp', methods=['POST', 'GET'])
def signUp():
    #conn = mysql.connect()
    #cursor = conn.cursor()
    #read the posted values from UI
    try:
        _name = request.form['inputName']
        _email = request.form['inputEmail']
        _password = request.form['inputPassword']

        #validate the received values
        if _name and _email and _password:

            #if ok then
            conn = mysql.connect()
            cursor = conn.cursor()

            _hashed_password = generate_password_hash(_password)
            cursor.callproc('sp_createUser',(_name,_email,_hashed_password))
            data = cursor.fetchall()

            print(data)
            print(_password)
            print(_email)
            print(_name)
            print(_hashed_password)


            if len(data) is 0:
                conn.commit()
                return json.dumps({'message':'User created successfully'})
            else:
                return json.dump({'error':str(data[0])})
        else:
            return json.dumps({'html':'<span>Enter the required fields </span>'})

    except Exception as e:
        return json.dumps({'error':str(e)})
    finally:
        cursor.close()
        conn.close()



if __name__ == "__main__":
    app.run()