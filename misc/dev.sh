#!/bin/bash
echo $$ > /tmp/troca_dev.pid
cleanup() {
    echo "Ctrl+C detected. Cleaning up..."
    pkill -TERM -x inotifywait
    pkill -TERM -x troca
    pkill -P $$
    rm -f /tmp/troca_dev.pid
    exit 0
}
trap cleanup SIGINT SIGTERM
start_troca(){
    export TERM=xterm-256color
    echo "starting troca"
    go run -ldflags="-X main.APIURL=localhost:8080" ./cmd/troca --debug
}

start_tracker(){
    inotifywait -r -m -e modify ./app --include '\.go$' | while read -r event; do
        echo "Detected modification: $event"
        pkill -9 -x troca || true
        sleep 0.2
    done
}

(start_tracker)&
while :;do start_troca; sleep 1; done
