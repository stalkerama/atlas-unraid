# Atlas for Unraid

Unraid packaging for [Eraxty/Atlas](https://github.com/Eraxty/Atlas), a
self-hosted Usenet indexer with a Newznab-compatible API.

This repository does **not** fork or modify the Atlas application source.
GitHub Actions builds upstream tag `v5.1.1` with a small Unraid startup
wrapper and publishes it to `ghcr.io/stalkerama/atlas-unraid:latest` and
`ghcr.io/stalkerama/atlas-unraid:v5.1.1`.

The scheduled workflow checks the pinned release every six hours. Builds also
carry an upstream commit tag. Moving to a newer release requires updating
`UPSTREAM_REF` in the workflow and checking the config patch against that tag.

## Unraid installation

Use unraid/atlas.xml as the template. Configure appdata at
/mnt/user/appdata/atlas, map the host port of your choice to container port
9090 (default host port: 9192), and enter your NNTP credentials.

Atlas does not provide a browser dashboard. The Unraid WebUI link opens its
Newznab capabilities endpoint as a health check.

The startup wrapper creates /mnt/user/appdata/atlas/config.json on first run.
It preserves the Atlas API key and synchronizes the Unraid NNTP settings into
that file on later starts.

### Existing Unraid installations

Unraid saves an installed container's settings in its own `my-Atlas` user
template. Updating this repository's `Atlas` XML does not replace that saved
template. Recreating from `my-Atlas` keeps the existing appdata mapping and
loads settings from `config.json`. In Unraid's Docker page, open Atlas **Edit**,
switch to **Advanced View**, and verify that Appdata maps
`/mnt/user/appdata/atlas` to `/app/data` (read/write), and the port maps host
`9192` to container `9090` (TCP). Keep the `/mnt/user/appdata/atlas` directory:
removing it deletes the configuration, database, and API key.

Check the running container's actual mounts and port on the Unraid terminal:

```sh
docker inspect Atlas --format '{{range .Mounts}}{{println .Source "->" .Destination}}{{end}}{{json .NetworkSettings.Ports}}'
ls -la /mnt/user/appdata/atlas
```

The inspect output must include `/mnt/user/appdata/atlas -> /app/data` and
`9090/tcp` mapped to host port `9192`. `config.json` must appear in that host
directory after startup. If it appears only inside the container, the appdata
mount is missing or points somewhere else. Atlas's **Change config** screen
asks for values again instead of pre-filling saved values; this alone does not
mean the file was erased. Check `config.json` on the host, and keep its password
and API key private.

Add Atlas to Prowlarr as a Generic Newznab indexer:

- URL: http://UNRAID-IP:9192
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
