FROM python:3.6.0-alpine

WORKDIR /app
ADD . /app

COPY requirements.txt /app/requirements.txt

RUN pip install --upgrade pip && apk --no-cache --update add build-base && \
    pip install -r /app/requirements.txt && \
    apk del build-base

ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts

ENTRYPOINT ["python3", "post_app.py"]
