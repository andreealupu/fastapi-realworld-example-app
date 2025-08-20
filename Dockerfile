FROM python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install Poetry
RUN pip install --upgrade pip setuptools wheel \
    && pip install poetry==1.8.3

# Set Poetry to create venv in project
RUN poetry config virtualenvs.in-project true

# Create working directory
WORKDIR /app

# Copy only dependency files first for caching
COPY pyproject.toml poetry.lock ./

# Install dependencies (no dev deps)
RUN poetry install --no-dev --no-root

# Copy the rest of the app
COPY . .

# Expose port
EXPOSE 8000

# Command to run the app
CMD ["poetry", "run", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

