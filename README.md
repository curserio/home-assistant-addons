# Curserio Home Assistant Add-ons

Custom Home Assistant add-ons for personal infrastructure.

## Add-ons

### SSH Tunnel & Forwarding

Autossh-based SSH tunnel add-on, derived from
[ThomDietrich/home-assistant-addons](https://github.com/ThomDietrich/home-assistant-addons).

Current local changes:

- Generic upstream-style defaults for fresh installs.
- First-class `local_dynamic_forward` support for SSH dynamic SOCKS tunnels.
- Explicit `authorized_key_permitopen` support for restricted SSH keys.

## Install

Add this repository in Home Assistant:

```text
Settings -> Add-ons -> Add-on Store -> ... -> Repositories
```

Repository URL:

```text
https://github.com/curserio/home-assistant-addons
```
