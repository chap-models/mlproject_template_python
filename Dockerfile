FROM ghcr.io/dhis2-chap/chapkit-py-cli:latest
WORKDIR /work
COPY pyproject.toml ./
RUN uv pip install --python /app/.venv/bin/python -r pyproject.toml
COPY . .

# The commit the image is built from, reported by the service. The publish workflow sets it.
ARG GIT_REVISION=""
ENV GIT_REVISION=${GIT_REVISION}
