# Solutions for Lesson 01 — Intro

Exercise 1 — Inspect namespaces

Answer (summary):

- `ps aux` inside the container shows only the processes started in that container (fewer entries than the host).
- `ip addr` typically shows a single `lo` and one `eth0` with an IP from Docker's bridge network (e.g., 172.18.x.x). The host has many interfaces (en0, wifi, etc.).

Commands used (example):

```bash
docker run -d --name writer -v /tmp/inception-demo:/data alpine:latest sh -c "while true; do date > /data/now.txt; sleep 2; done"
docker exec -it writer sh -c "ip addr; ps aux"
docker rm -f writer
```

Exercise 2 — Tiny image

Dockerfile (demos/hello/Dockerfile):

```Dockerfile
FROM alpine:3.18
CMD ["/bin/sh", "-c", "echo Hello from image; sleep 1"]
```

Build & run commands:

```bash
docker build -t demo-hello demos/hello
docker run --rm demo-hello
```

Expected output:

```
Hello from image
```
