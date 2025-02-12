#!/bin/bash
echo $$ > /tmp/troca_dev.pid
cleanup() {
    echo "Ctrl+C detected. Cleaning up..."
    pkill -P $$
    rm -f /tmp/troca_dev.pid
    exit 0
}
watchkill() {
    inotifywait -e modify $(find . -name '*.go') && {
        # Find and kill all troca processes
        pkill -f "go run.*troca" || true
        pkill troca || true
    }
}
trap cleanup SIGINT SIGTERM
(watchkill) &

while true; do
    export TERM=xterm-256color
    go run -ldflags="-X main.APIURL=localhost:8080" ./cmd/troca -d
    sleep 1  # Prevent CPU spinning if go run fails
done
