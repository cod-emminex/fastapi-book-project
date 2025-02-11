# Stage 1: Python/FastAPI
FROM python:3.9-slim as fastapi

WORKDIR /fastapi-book-project

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Stage 2: Nginx
FROM nginx:alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx config
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf

# Copy FastAPI app from previous stage
COPY --from=fastapi /fastapi-book-project /fastapi-book-project

# Install Python and dependencies in Nginx image
RUN apk add --no-cache python3 py3-pip \
    && pip3 install --break-system-packages --no-cache-dir -r /fastapi-book-project/requirements.txt

# Expose port 80
EXPOSE 80

# Start Nginx and FastAPI
COPY docker/start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
