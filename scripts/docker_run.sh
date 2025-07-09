#!/bin/bash

run=$1
if [ ! -f $run ]; then
	run="$(dirname "$0")/$run"
	if [ ! -f $run ]; then
		run="$run.sh"
	fi
fi
docker run -e "BUTLER_API_KEY=$(cat ~/.config/itch/butler_creds)" --mount "type=bind,src=.,dst=/project" -w /project barichello/godot-ci:4.4.1 $run
