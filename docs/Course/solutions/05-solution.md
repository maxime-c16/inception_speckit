# Solutions for Lesson 05 — Security and next steps

Exercise — Convert a password to a docker secret (local test)

This is a conceptual exercise (we will not commit real secrets). Example steps for local testing:

1. Create a file for the secret (local-only):

```bash
echo "example_redis_pw" > /tmp/redis_password.txt
```

2. Use docker swarm or Compose v2+ secrets (local dev):

```bash
docker secret create redis_password /tmp/redis_password.txt || true
```

3. In `docker-compose.yml`, reference the secret under `services.redis.secrets:` and pass the secret filename into the container.

Note: For local dev we often use `.env` and instruct users to create their own `.env` from `.env.example` (don't commit real passwords).

Recommendations (answers):

- Use an external secret manager for production (Vault, AWS Secrets Manager).
- Use Let's Encrypt for real certificates; for automation, integrate `certbot` or an ACME sidecar.
- Run containers as non-root and make mounts read-only when possible.
