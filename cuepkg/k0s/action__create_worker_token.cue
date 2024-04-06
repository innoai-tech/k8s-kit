package k0s

import (
	"piper.octohelm.tech/wd"
	"piper.octohelm.tech/file"
	"piper.octohelm.tech/exec"
	"piper.octohelm.tech/client"
)

#CreateWorkerToken: {
	controllerDir!: wd.#WorkDir
	workerDir!:     wd.#WorkDir

	tokenFile: string | *"/etc/k0s/token"

	_create: exec.#Run & {
		"cwd": controllerDir
		"cmd": """
			k0s token create --role=worker
			"""
		"with": stdout: true
	}

	_write: file.#Write & {
		outFile: {
			wd:       workerDir
			filename: tokenFile
		}
		contents: _create.stdout
	}

	_ret: client.#Wait & {
		$ok: _write.$ok
	}

	$ok: _write.$ok
}
