FROM alpine:latest
RUN apk add --no-cache bash netcat-openbsd iputils
WORKDIR /app
COPY start.sh .
CMD ["/app/start.sh"]
