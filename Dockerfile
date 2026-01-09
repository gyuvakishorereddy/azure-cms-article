# Use official Python runtime as base image
FROM python:3.11-slim

# Set working directory in container
WORKDIR /app

# Install system dependencies required for pyodbc and SQL Server
RUN apt-get update && apt-get install -y \
    curl \
    apt-transport-https \
    gnupg \
    unixodbc-dev \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY . .

# Create directories for logs and instance data
RUN mkdir -p logs instance

# Expose the port the app runs on
EXPOSE 5555

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV SERVER_HOST=0.0.0.0
ENV SERVER_PORT=5555

# Run the application using gunicorn for production
CMD ["gunicorn", "--bind", "0.0.0.0:5555", "--workers", "4", "--timeout", "120", "application:app"]
