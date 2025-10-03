# build stage
FROM python:3.12 AS builder
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
WORKDIR /app
COPY pyproject.toml ./
RUN uv sync --no-install-project --no-editable
COPY cc_simple_server/ ./cc_simple_server/

# final stage
FROM python:3.12-slim
WORKDIR /app
COPY --from=builder /app/.venv /app/.venv
COPY cc_simple_server/ ./cc_simple_server/
COPY --from=builder /app/tests ./tests
RUN mkdir /app/data
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser
ENV PATH="/app/.venv/bin:$PATH"
EXPOSE 8000
CMD ["uvicorn", "cc_simple_server.server:app", "--host", "0.0.0.0", "--port", "8000"]
