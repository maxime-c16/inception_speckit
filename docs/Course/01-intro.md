# Lesson 01 — Introduction to Containers and Docker

Objectives
- Understand what containers are and how they differ from virtual machines
- Learn about images, containers, and the Docker workflow
- Run a simple container and inspect its filesystem

Key concepts
- Container: a lightweight, portable runtime instance with isolated file system and process namespace.
- Image: an immutable layered filesystem built from a Dockerfile.
- Registry: a storage for images (Docker Hub, private registries).

Hands-on: run a container

```bash
# List running containers (none):
docker ps -a

# Run an interactive Alpine container
docker run --rm -it alpine:latest sh
# inside container: echo hello > /hello.txt; cat /hello.txt; exit

# Inspect image layers
docker image inspect alpine:latest --format '{{json .RootFS}}' | jq
```

Course pointer: in this repository the `extra` service is a small Alpine container (`srcs/extra/Dockerfile`). Open it and compare:

```bash
sed -n '1,200p' srcs/extra/Dockerfile
```
