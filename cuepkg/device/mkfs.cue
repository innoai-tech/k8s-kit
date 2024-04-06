package device

import (
	"piper.octohelm.tech/wd"
	"piper.octohelm.tech/exec"
	"piper.octohelm.tech/client"
)

#Mkfs: {
	cwd: wd.#WorkDir

	device!: #Device

	_check: exec.#Run & {
		"cwd": cwd
		"cmd": """
		blkid \(device.path) | grep TYPE=
		"""
		"with": {
			failfast: false
			stdout:   true
		}
	}

	_mkfs: exec.#Run & {
		$dep: client.#Skip & {
			when: _check.$ok
		}

		"cwd": cwd
		"cmd": """
		mkfs.\(device.fstype) -F \(device.path)
		"""
		"with": {
			failfast: true
		}
	}

	_ret: client.#Wait & {
		"$ok":    _check.$ok || _mkfs.$ok
		"device": close(device)
	}

	$ok:    _ret.$ok
	output: _ret.device
}
