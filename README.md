# backup

Provides basic scaffolding to perform local backup, to storj, using restic and rclone.

## requirements

- gnu make
```sh
$ make -v
GNU Make 4.4.1
Built for x86_64-apple-darwin22.3.0
Copyright (C) 1988-2023 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

```

## setup

1\. Copy `config.env.dist` to `config.env`
```sh
$ cp config.env.dist config.env
$ cat config.env.dist 
name=ssdd
backup=$(HOME)/Develop:$(HOME)/Documents

export ACCESS_KEY_ID=$(ACCESS_KEY_ID)
export SECRET_ACCESS_KEY=$(SECRET_ACCESS_KEY)
export RESTIC_PASSWORD=$(RESTIC_PASSWORD)
```

You may replace makefile secret `$(PLACEHOLDERS)` or leave as is and inject secrets when running backup.

Exported values should be capitalized and are overridable at runtime. All other values should be lowercased and immutable outside of config.

2\. Add distribution and architecture specific `restic` and `rclone` binaries, to `assets`, if needed. 

3\. Initialize restic repository using `make` workflow
```sh
$ make
: ## distclean
rm -rf dist
: ## dist
mkdir -p dist dist/bin
...
check snapshots, trees and blobs
[0:00]          0 snapshots
no errors were found
```

## usage

Run backup using `make` workflow
```sh
$ make
...
```
```sh
$ make backup
...
```

## troubleshoot

Unlock canceled/failed backups
```sh
$ make unlock
: ## unlock
cd dist
restic unlock \
  -o rclone.program=$(command -v rclone) \
  -r rclone:storj:fubar
repository d09af0fc opened (version 2, compression level auto)
```

