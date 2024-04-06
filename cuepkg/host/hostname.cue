package host

import (
	"piper.octohelm.tech/wd"
	"piper.octohelm.tech/exec"
	"piper.octohelm.tech/client"
)

#SetHostname: {
	cwd!:      wd.#WorkDir
	hostname!: string

	_do: exec.#Run & {
		"cwd": cwd
		"cmd": "hostnamectl set-hostname \(hostname)"
		"with": failfast: true
	}

	output: client.#Wait & {
		"hostname": hostname

		"$ok": _do.$ok
	}
}
