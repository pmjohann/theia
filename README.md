# Opinionated Theia online IDE

## Key features

- Based on Ubuntu LTS (focal)
- Runs as separate underprivileged user
- Sudo granted so ```sudo apt install package``` works in terminals
- Persistent storage for repositories at ```/repos```
- Pre-installable apt packages via ```INSTALL``` ENV var (e.g. ```INSTALL=nano```)
- Pre-configurable working environment via mounted ```/preconf.sh```

## How to run

```sh
docker run --rm -it -p 3000:3000 -v /path/to/repos:/repos pmjohann/theia
```

## How to run (pre-install packages)

```sh
docker run --rm -it -e INSTALL=nano -p 3000:3000 -v /path/to/repos:/repos pmjohann/theia
```

## How to run (pre-configure script)

```sh
docker run --rm -it -v /path/to/script.sh:/preconf.sh -p 3000:3000 -v /path/to/repos:/repos pmjohann/theia
```
