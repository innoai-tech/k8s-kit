package k0s

import (
	"piper.octohelm.tech/wd"
	"piper.octohelm.tech/file"
	"piper.octohelm.tech/exec"
	"piper.octohelm.tech/client"
)

#CommandAliases: {
	cwd: wd.#WorkDir
	aliases: [Name=string]: string

	_run: {
		for name, shell in aliases {
			"\(name)": {
				_write: file.#Write & {
					outFile: {
						"wd":       cwd
						"filename": "/usr/local/bin/\(name)"
					}
					contents: """
						#!/bin/sh
						\(shell) $@
						"""
				}

				_make_execable: exec.#Run & {
					"cwd": _write.file.wd
					"cmd": "chmod +x \(_write.file.filename)"
				}

				_wait: client.#Wait & {
					$ok: _make_execable.$ok

					"file": _write.file
				}

				"file": _wait.file
			}
		}
	}

	bin: client.#Wait & {
		for name, shell in aliases {
			"\(name)": _run["\(name)"].file
		}
	}
}
