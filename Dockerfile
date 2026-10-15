FROM ghcr.io/dhis2-chap/chapkit-py-cli:latest
WORKDIR /work
COPY pyproject.toml ./
RUN uv pip install --python /app/.venv/bin/python -r pyproject.toml
COPY . .
