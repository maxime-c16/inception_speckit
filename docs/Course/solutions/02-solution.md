# Solutions for Lesson 02 — Dockerfile

Exercise 1 — Small reproducible image

Dockerfile (demos/python-small/Dockerfile):

```Dockerfile
FROM python:3.12-alpine
WORKDIR /app
RUN pip install --no-cache-dir requests
COPY app.py ./
CMD ["python", "app.py"]
```

app.py:

```py
print('ok')
```

Build and run:

```bash
docker build -t demo-py-small demos/python-small
docker run --rm demo-py-small
```

The image size should be smaller than Debian-based Python images; check with `docker image ls`.

Exercise 2 — Fix the Dockerfile

Problem: copying the entire context before installing dependencies prevents Docker from using layer cache for the `pip install` step when only code changes.

Fixed Dockerfile:

```Dockerfile
FROM python:3.12-alpine
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . /app
CMD ["python", "app.py"]
```

Add `.dockerignore` to exclude tests and local artifacts:

```
venv
*.pyc
tests/
.tox
```

This orders steps so that dependency installation is cached when only application code changes.
