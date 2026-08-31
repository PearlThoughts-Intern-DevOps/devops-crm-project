# ------------------------------------------------------------
# Twenty CRM Docker Image
# ------------------------------------------------------------

FROM twentycrm/twenty:latest

# Application port
EXPOSE 2020

# Environment configuration
ENV NODE_PORT=2020
ENV SERVER_URL=http://localhost:2020
ENV STORAGE_TYPE=local
ENV IS_BILLING_ENABLED=false
ENV APPLICATION_LOG_DRIVER=CONSOLE

# Keep the official Twenty entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]