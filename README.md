# Atlas for Unraid

Unraid packaging for [Eraxty/Atlas](https://github.com/Eraxty/Atlas), a
self-hosted Usenet indexer with a Newznab-compatible API.

This repository does **not** fork, copy, or modify the Atlas application.
GitHub Actions builds the upstream project's own Dockerfile directly from the
exact upstream commit and publishes it to ghcr.io/stalkerama/atlas-unraid:latest.

The scheduled workflow checks upstream every six hours. Each upstream commit is
published once as both latest and an immutable upstream-commit tag.

## Unraid installation

Use unraid/atlas.xml as the template. Configure appdata at
/mnt/user/appdata/atlas, API port 9090, and your NNTP credentials.

Atlas does not provide a browser dashboard. The Unraid WebUI link opens its
Newznab capabilities endpoint as a health check.

The API key is generated on first run and saved in
/mnt/user/appdata/atlas/config.json.

Add Atlas to Prowlarr as a Generic Newznab indexer:

- URL: http://UNRAID-IP:9090
- API path: /api
- API key: the api_key value from config.json
- Category: Other (7000)

## SABnzbd

Set ATLAS_SAB_HOST to the SABnzbd container name when both containers share a
custom Docker network. With ordinary bridge networking, use the Unraid server
IP. The default SABnzbd port is 8080.

## Upstream and licensing

Atlas is developed by Eraxty. Application issues belong in the upstream
repository. This repository only contains the build workflow and Unraid
template. Atlas is licensed under GPL-3.0; the upstream source and license are
embedded in every image.

