# Lesson 05 — Security, secrets, and production readiness

Objectives
- Understand where secrets are used in this project and options to secure them
- Learn about Docker secrets, file permissions, and TLS handling
- Get an action list for production hardening

Secrets in this repo
- `.env` contains example passwords (do not commit real secrets to version control)
- TLS cert/key are stored under `srcs/nginx/conf/` for local testing

Production recommendations
- Use Docker secrets or an external secret manager (Vault, AWS Secrets Manager)
- Use a real CA-signed certificate (Let's Encrypt) for public sites
- Limit container capabilities and run processes as non-root users
- Use read-only mounts where possible and apply proper file permissions

Quick exercise: convert `REDIS_PASSWORD` from `.env` to a Docker secret and update `docker-compose.yml` (hint: `secrets:` top-level key and service-level `secrets:` list).
