ARG APP_NAME=troca_api
FROM busybox
WORKDIR /app
COPY ./bin/${APP_NAME} /app/${APP_NAME}
CMD ["/app/troca_api"]
