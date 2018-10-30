from flask import Flask, render_template, request, json, redirect, session
from flaskext.mysql import MySQL
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
mysql = MySQL()
app.secret_key = 'why would I tell you my secret key?'

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


@app.route('/showSignin')
def showSignin():
    if session.get('user'):
        return render_template('userHome.html')
    else:
        return render_template('signin.html')


@app.route('/userHome')
def userHome():
    if session.get('user'):
        return render_template('userHome.html')
    else:
        return render_template('error.html', error = 'Unauthorized Access')


@app.route('/logout')
def logout():
    session.pop('user', None)
    return redirect('/')



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



@app.route('/validateLogin', methods=['POST'])
def validateLogin():
    try:
        _username = request.form['inputEmail']
        _password = request.form['inputPassword']


        # if ok then
        conn = mysql.connect()
        cursor = conn.cursor()
        cursor.callproc('sp_validateLogin',(_username,))
        data = cursor.fetchall()

        if len(data)>0:
            if check_password_hash(str(data[0][3]), _password):
                session['user'] = data[0][0]
                return redirect('/userHome')
            else:
                return render_template('error.html', error = 'Wrong email address or password ')
        else:
            return render_template('error.html', error = 'Wrong email or password')

    except Exception as e:
        return render_template('error.html', error=str(e))
    finally:
        cursor.close()
        conn.close()




if __name__ == "__main__":
    app.run(debug=True)