# syntax=docker/dockerfile:1.7

FROM python:3.10-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
	PYTHONUNBUFFERED=1 \
	PIP_DISABLE_PIP_VERSION_CHECK=1 \
	VIRTUAL_ENV=/opt/venv \
	PATH="/opt/venv/bin:$PATH"

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
	build-essential \
	curl \
	libgomp1 \
	libpq-dev \
	&& rm -rf /var/lib/apt/lists/*

RUN python -m venv "$VIRTUAL_ENV"

COPY requirements.txt ./
RUN --mount=type=cache,target=/root/.cache/pip \
	pip install --upgrade pip setuptools wheel && \
	pip install torch==2.1.2+cpu --index-url https://download.pytorch.org/whl/cpu && \
	pip install -r requirements.txt

FROM python:3.10-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
	PYTHONUNBUFFERED=1 \
	PIP_NO_CACHE_DIR=1 \
	PIP_DISABLE_PIP_VERSION_CHECK=1 \
	VIRTUAL_ENV=/opt/venv \
	PATH="/opt/venv/bin:$PATH"

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
	curl \
	libgomp1 \
	libpq5 \
	&& rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/venv /opt/venv
COPY . .

EXPOSE 8000

CMD ["python", "run.py"]