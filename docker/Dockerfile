FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN grep -v "SABnzbd" requirements.txt > requirements.container.txt \
    && pip install --no-cache-dir -r requirements.container.txt

COPY . .
RUN chmod 0755 /app/unraid-entrypoint.sh

ENV ATLAS_HOME=/app/data
ENV PYTHONUNBUFFERED=1

VOLUME ["/app/data", "/root/.sabnzbd"]
EXPOSE 9090

ENTRYPOINT ["/app/unraid-entrypoint.sh"]

