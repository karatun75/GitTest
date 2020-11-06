#!/bin/sh

let loop=0
while true; do
	if [[ $loop%300 -eq 0 ]]; then
		weather=$(curl wttr.in?format=1)
		let loop=0
	fi
	xsetroot -name " $weather | $(date '+%b %d %a') | $(date '+%H:%M') "
	let loop=$loop+1
	sleep 1
done