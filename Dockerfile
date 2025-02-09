FROM busybox
WORKDIR /app
COPY ./bin/troca_api /app/troca_api
CMD ["/app/troca_api"]
