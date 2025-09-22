# Lesson 02 — Dockerfile anatomy and best practices (expanded)

Objectives
- Learn Dockerfile instructions and image layering
- Apply best practices for small, secure images
- Understand multi-stage builds and caching

Dockerfile instructions (quick reference)
- `FROM` — base image (pin versions in production)
- `LABEL` — metadata
- `RUN` — executed at build time (creates layers)
- `COPY` / `ADD` — copy files into the image
- `WORKDIR` — set working directory
- `ENV` — set environment variables
- `USER` — switch to a less privileged user
- `EXPOSE` — document ports
- `CMD` / `ENTRYPOINT` — runtime command

Example: the repository `srcs/nginx/Dockerfile`

```bash
sed -n '1,240p' srcs/nginx/Dockerfile
```

Best practices explained

- Pin base images: `alpine:3.18` or `wordpress:php8.2-fpm-alpine` instead of `latest`.
- Minimize layers: combine `RUN` commands with `&&` and cleanup caches in the same layer.
- Use `.dockerignore` to avoid copying unnecessary files (node_modules, .git, tmp, etc.).
- Use `--no-cache` flags where package managers support them to avoid leaking caches into layers.
- Avoid running as root where possible; create and switch to a non-root `USER`.
- Set explicit file/directory permissions at build time if the entrypoint needs them.

Multi-stage build example

```Dockerfile
FROM golang:1.20-alpine AS builder
WORKDIR /src
COPY . .
RUN go build -o /out/app ./cmd/app

FROM alpine:3.18
COPY --from=builder /out/app /usr/local/bin/app
USER nobody
ENTRYPOINT ["/usr/local/bin/app"]
```

Exercises

- Exercise 1 — Build a small web image

  Create `demos/hello-node` with a `Dockerfile` based on `node:20-alpine`, a small `server.js` that serves "Hello", and build/run it. Aim for minimal layers.

- Exercise 2 — Optimize a slow Dockerfile

  Given a project with `requirements.txt` and `app.py`, write a Dockerfile that caches dependencies so that subsequent builds are fast when only application code changes.

What to expect

- After optimizing, builds that only change application code will reuse the cached dependency layer.
- The image will run as a non-root user where possible and be smaller if using Alpine-based or multi-stage builds.

---

Solution: see `DOCS/Course/solutions/02-solution.md` for worked answers and example Dockerfiles.
