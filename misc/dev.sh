#!/bin/bash
echo $$ > /tmp/troca_dev.pid
cleanup() {
    echo "Ctrl+C detected. Cleaning up..."
    pkill -P $$
    rm -f /tmp/troca_dev.pid
    exit 0
}
watchkill() {
    while true; do
    inotifywait -e modify $(find ./app -name '*.go') || {
        pkill -x troca || true
    }
    done
}
trap cleanup SIGINT SIGTERM
(watchkill) &

while true; do
    export TERM=xterm-256color
    go run -ldflags="-X main.APIURL=localhost:8080" ./cmd/troca --debug
done
