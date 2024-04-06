package k0s

import (
	"encoding/yaml"

	"piper.octohelm.tech/wd"
	"piper.octohelm.tech/exec"
	"piper.octohelm.tech/client"
)

#Status: {
	$dep?: _

	cwd: wd.#WorkDir

	_status: exec.#Run & {
		if $dep != _|_ {
			"$dep": $dep
		}

		"cwd": cwd
		"cmd": """
			k0s status
			"""
		"with": {
			failfast: false
			stdout:   false
		}
	}

	_ret: client.#Wait & {
		$ok: _status.$ok

		status: yaml.Unmarshal(_status.stdout)
	}

	$ok:    _ret.$ok
	status: _ret.status
}
