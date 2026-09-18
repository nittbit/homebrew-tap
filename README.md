# nittbit Homebrew Tap

Homebrew formulae for [UniCam Hub](https://unicam.app).

## Install

```sh
brew tap nittbit/tap
brew install unicam-hub
```

Start the hub daemon as a background service:

```sh
brew services start unicam-hub
```

Then use the CLI:

```sh
unicam status
```

## Formulae

| Formula | Description |
|---|---|
| `unicam-hub` | UniCam Hub daemon and `unicam` CLI (stable channel) |

Formulae in this tap are updated automatically by the UniCam Hub release
pipeline on every stable release. Artifacts are downloaded from
[nittbit/unicam-releases](https://github.com/nittbit/unicam-releases/releases).
