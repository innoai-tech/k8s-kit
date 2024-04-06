package device

import (
	"strings"

	"piper.octohelm.tech/client"
	"piper.octohelm.tech/wd"
	"piper.octohelm.tech/exec"
)

#DiskInfo: {
	cwd!:      wd.#WorkDir
	diskName!: string

	_device_path: "/dev/\(diskName)"

	_resolve_exists: exec.#Run & {
		"cwd": cwd
		cmd:   "fdisk -l \(_device_path)"
		with: {
			failfast: true
			stdout:   true
		}
	}

	_resolve_label: exec.#Run & {
		$dep: _resolve_exists.$ok

		"cwd": cwd
		// example:
		// Disklabel type: gpt
		cmd: "fdisk -l \(_device_path) | grep 'Disklabel type' | awk '{ print $3 }'"
		with: {
			failfast: false
			stdout:   true
		}
	}

	_resolve_identifier: exec.#Run & {
		$dep: _resolve_exists.$ok

		"cwd": cwd
		// Disk identifier: uuid
		cmd: "fdisk -l \(_device_path) | grep 'Disk identifier' | awk '{ print $3 }'"
		with: {
			failfast: false
			stdout:   true
		}
	}

	info: client.#Wait & {
		label: {
			if _resolve_label.$ok {
				strings.TrimSpace(_resolve_label.stdout)
			}
		}

		identifier: {
			if _resolve_identifier.$ok {
				strings.TrimSpace(_resolve_identifier.stdout)
			}
		}
	}

	$ok: _resolve_exists.$ok
}
