package k0s

import (
	"piper.octohelm.tech/wd"
	"piper.octohelm.tech/exec"
)

#Restart: {
	$dep?: _

	cwd: wd.#WorkDir

	_stop: exec.#Run & {
		if $dep != _|_ {
			"$dep": $dep
		}

		"cwd": cwd
		"cmd": """
			k0s stop
			"""
		"with": {
			failfast: false
		}
	}

	_start: exec.#Run & {
		"$dep": _stop.$ok

		"cwd": cwd
		"cmd": """
			k0s start
			"""
		"with": {
			failfast: false
		}
	}

	$ok: _start.$ok
}
