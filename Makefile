.DEFAULT_GOAL := @goal

.ONESHELL:
.POSIX:
.PHONY: build test run

## env
include config.env

export PATH := ./bin:$(PATH)
export RCLONE_CONFIG := ./rclone.conf

## recipe
@goal: distclean dist init check

distclean:
	: ## $@
	rm -rf dist
clean: distclean
	: ## $@

dist:
	: ## $@
	mkdir -p $@ $@/bin $@/log

	# cp assets binaries to dist, if available
	cp -rf assets/rclone* $@/bin/rclone ||:
	cp -rf assets/restic* $@/bin/restic ||:

	<rclone.conf envsubst >$@/rclone.conf

init:
	: ## $@
	cd dist

	# sanity check access
	rclone -vv lsf storj:

	# pass rclone executable path to deal with
	# restic security "feature"
	restic init \
		-o rclone.program=$$(command -v rclone) \
		-r rclone:storj:$(name) \
	| tee log/init \
	||:

check:
	: ## $@
	cd dist
	restic check \
		-o rclone.program=$$(command -v rclone) \
		-r rclone:storj:$(name) \
		-vv

backup:
	: ## $@
	cd dist
	restic prune \
		-o rclone.program=$$(command -v rclone) \
		-r rclone:storj:$(name) \
	| tee log/prune.log

	printf "%s" "$(backup)" \
		| tr ":" " " \
		| xargs -r -- nohup time restic backup \
				-o rclone.program=$$(command -v rclone) \
				-r rclone:storj:$(name) \
				-vv \
		| tee log/backup.log & wait

unlock: dist
	: ## $@
	cd dist
	restic unlock \
		-o rclone.program=$$(command -v rclone) \
		-r rclone:storj:$(name)

summary: dist
	: ## $@
	cd dist
	restic stats \
		-o rclone.program=$$(command -v rclone) \
		-r rclone:storj:$(name)
