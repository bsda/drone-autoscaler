FROM golang as builder
#ADD .drone.sh /drone.sh
#RUN chmod +x /drone.sh
ADD . /
RUN chmod +x /.drone.sh
RUN /.drone.sh

FROM alpine:3.6 as alpine
RUN apk add -U --no-cache ca-certificates

FROM alpine:3.6 as production
EXPOSE 8080 80 443
VOLUME /data

ENV GODEBUG netdns=go
ENV XDG_CACHE_HOME /data
ENV DRONE_DATABASE_DRIVER sqlite3
ENV DRONE_DATABASE_DATASOURCE /data/database.sqlite?cache=shared&mode=rwc&_busy_timeout=9999999

COPY --from=alpine /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder go/release/linux/amd64/drone-autoscaler /bin/

ENTRYPOINT ["/bin/drone-autoscaler"]