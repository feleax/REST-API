FROM python:3.12-slim

WORKDIR /flask

COPY . .

RUN  \
  pip install --upgrade pip  && \
  pip install -r requirements.txt --no-cache-dir  && \
  :

EXPOSE 5000

CMD ["python", "server.py"]