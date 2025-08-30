FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNVUFFERED=1

WORKDIR /code

RUN apt-get update && apt-get install -y libmagic1 \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip
RUN pip install poetry
RUN poetry config virtualenvs.create false
ADD pyproject.toml .
RUN poetry install --no-root --no-interaction --no-ansi

EXPOSE 8000

COPY . .

CMD [ "python", "main.py" ]