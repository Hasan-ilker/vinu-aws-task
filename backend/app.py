from flask import Flask
import os, mysql.connector

app = Flask(__name__)

def db_alive():
    try:
        cnx = mysql.connector.connect(
            host=os.getenv("DB_HOST","db"),
            user=os.getenv("DB_USER","appuser"),
            password=os.getenv("DB_PASS","apppass"),
            database=os.getenv("DB_NAME","appdb"),
            port=int(os.getenv("DB_PORT","3306")),
            connection_timeout=2
        )
        cnx.close()
        return True
    except:
        return False

@app.get("/hello")
def hello():
    return "Hello from BE! DB: %s" % ("OK" if db_alive() else "FAILED")
