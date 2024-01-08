from flask import Flask, render_template
from sqlalchemy import create_engine
from sqlalchemy import text
from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField, IntegerField, SelectField, widgets, BooleanField

app = Flask(__name__, template_folder='templates')
app.config["SECRET_KEY"] = "super tajny klic"

class MujWTFFormular(FlaskForm):
    search = StringField("search")

@app.route("/", methods = ["GET", "POST"])
@app.route("/home", methods = ["GET", "POST"])
@app.route("/index", methods = ["GET", "POST"])
def index():
    engine = create_engine("mysql+mysqlconnector://root:@localhost/systemsdb")

    connection = engine.connect()

    form = MujWTFFormular()
    if form.validate_on_submit():
        search = form.search.data

        if search == '':
            query = text("SELECT s.name AS system_name, st.name AS station_name, GROUP_CONCAT(se.name) AS all_services, p.name AS planet_name, st.maxPadSize_id, a.name AS allegiance_name FROM systems s RIGHT JOIN stations st ON s.id = st.system_id LEFT JOIN station_service ss ON s.id = ss.station_id LEFT JOIN services se ON ss.service_id = se.id LEFT JOIN planets p ON st.planet_id = p.id JOIN allegiances a ON st.allegiance_id = a.id GROUP BY st.id")
        else:
            query = text("""
                SELECT s.name AS system_name, st.name AS station_name, GROUP_CONCAT(se.name) AS all_services, 
                    p.name AS planet_name, st.maxPadSize_id, a.name AS allegiance_name  
                FROM systems s  
                RIGHT JOIN stations st ON s.id = st.system_id  
                LEFT JOIN station_service ss ON s.id = ss.station_id  
                LEFT JOIN services se ON ss.service_id = se.id  
                LEFT JOIN planets p ON st.planet_id = p.id  
                JOIN allegiances a ON st.allegiance_id = a.id  
                WHERE MATCH(s.name) AGAINST(:search_term IN BOOLEAN MODE) 
                    OR MATCH(st.name) AGAINST(:search_term IN BOOLEAN MODE) 
                    OR MATCH(se.name) AGAINST(:search_term IN BOOLEAN MODE) 
                    OR MATCH(p.name) AGAINST(:search_term IN BOOLEAN MODE) 
                    OR MATCH(a.name) AGAINST(:search_term IN BOOLEAN MODE)
                GROUP BY st.id 
                LOCK IN SHARE MODE;
            """)
            query = query.bindparams(search_term=search)

        result = connection.execute(query)
        return render_template("index.html", form=form, stations=result)

    query = text("SELECT * FROM planets")
    result = connection.execute(query)
    return render_template("index.html", form=form, planets=result)

if __name__ == "__main__":
    app.run(debug=True)