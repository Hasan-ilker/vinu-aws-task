FROM python:3.12-slim
WORKDIR /app
RUN pip install flask mysql-connector-python gunicorn
COPY app.py .
CMD ["gunicorn", "-b", "0.0.0.0:4000", "app:app"]
