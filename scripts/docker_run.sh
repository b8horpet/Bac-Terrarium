#!/bin/bash

run=$1
if [ ! -f $run ]; then
	run="$(dirname "$0")/$run"
	if [ ! -f $run ]; then
		run="$run.sh"
	fi
fi
bakf="$HOME/.config/itch/butler_cred"
if [[ "$OSTYPE" == "darvin"* ]]; then
	bakf="$HOME/Library/Application Support/itch/butler_creds"
fi
if [ ! -f "$bakf" ]; then
	bakf="/dev/null"
fi
docker run -e BUTLER_API_KEY=$(cat "$bakf") --mount "type=bind,src=.,dst=/project" -w /project barichello/godot-ci:4.4.1 $run
