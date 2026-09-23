# Atlas for Unraid

Unraid packaging for [Eraxty/Atlas](https://github.com/Eraxty/Atlas), a
self-hosted Usenet indexer with a Newznab-compatible API.

This repository does **not** fork or modify the Atlas application source.
GitHub Actions builds the exact upstream commit with a small Unraid startup
wrapper and publishes it to ghcr.io/stalkerama/atlas-unraid:latest.

The scheduled workflow checks upstream every six hours. Each upstream commit is
published once as both latest and an immutable upstream-commit tag.

## Unraid installation

Use unraid/atlas.xml as the template. Configure appdata at
/mnt/user/appdata/atlas, map the host port of your choice to container port
9090, and enter your NNTP credentials.

Atlas does not provide a browser dashboard. The Unraid WebUI link opens its
Newznab capabilities endpoint as a health check.

The startup wrapper creates /mnt/user/appdata/atlas/config.json on first run.
It preserves the Atlas API key and synchronizes the Unraid NNTP settings into
that file on later starts.

Add Atlas to Prowlarr as a Generic Newznab indexer:

- URL: http://UNRAID-IP:9090
- API path: /api
- API key: the api_key value from config.json
- Category: Other (7000)

## AI search with Ollama

Atlas AI search requires a separate Ollama server and currently hardcodes the
model qwen3:4b. Pull that model in Ollama, then set OLLAMA_HOST in the Atlas
template to the reachable Ollama API URL, for example:

http://UNRAID-IP:11434

Do not use localhost when Ollama runs in another container; localhost inside
Atlas refers to the Atlas container itself.

## SABnzbd

Set ATLAS_SAB_HOST to the SABnzbd container name when both containers share a
custom Docker network. With ordinary bridge networking, use the Unraid server
IP. The default SABnzbd port is 8080. Map the SABnzbd appdata directory to
/root/.sabnzbd in Atlas; upstream Atlas reads the SABnzbd API key from the
sabnzbd.ini file rather than from an environment variable.

## Unraid wrapper

The packaging wrapper only handles container configuration:

- creates and updates the persistent Atlas config file;
- generates the Atlas API key once and preserves it;
- preserves the API key when settings are changed from the Atlas menu;
- binds the Newznab API to 0.0.0.0:9090; and
- then starts the unmodified upstream application.

## Upstream and licensing

Atlas is developed by Eraxty. Application issues belong in the upstream
repository. This repository only contains the build workflow and Unraid
template. Atlas is licensed under GPL-3.0; the upstream source and license are
embedded in every image.
