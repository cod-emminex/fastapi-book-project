FROM python:3.9-slim

# Install nginx
RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /fastapi-book-project

# Copy requirements first to leverage Docker cache
COPY requirements.txt .
RUN pip install --break-system-packages --no-cache-dir -r requirements.txt

# Copy all project files
COPY . .

# Remove default nginx configuration
RUN rm /etc/nginx/nginx.conf

# Copy nginx configuration
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf

# Create start script with proper format
RUN echo '#!/bin/sh\n\ncd /fastapi-book-project && uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4 &\n\nsleep 5\n\nnginx -t && nginx -g "daemon off;"\n' > /start.sh && \
    chmod +x /start.sh

# Expose port 80
EXPOSE 80

CMD ["/start.sh"]
