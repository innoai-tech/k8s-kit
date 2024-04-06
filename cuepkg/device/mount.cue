package device

import (
	"piper.octohelm.tech/client"
	"piper.octohelm.tech/wd"
	"piper.octohelm.tech/exec"
)

#Mount: {
	cwd!:        wd.#WorkDir
	device!:     #Device
	mountPoint!: string

	_mounted: exec.#Run & {
		"cwd": cwd
		"cmd": "mount | grep \(device.path)"
		"with": {
			failfast: false
			stdout:   true
		}
	}

	_mount: exec.#Run & {
		$dep: client.#Skip & {
			when: _mounted.$ok
		}

		"cwd": cwd
		"cmd": [
			"mkdir -p \(mountPoint);",
			"mount \(device.path) \(mountPoint);",
		]
	}

	$ok: _mounted.$ok | _mount.$ok
}
