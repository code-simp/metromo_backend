FROM python:3.9-rc-buster

WORKDIR /code

ENV FLASK_APP app.py
ENV FLASK_RUN_HOST 0.0.0.0

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000
CMD [ "flask", "run" ]