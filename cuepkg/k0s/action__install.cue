package k0s

import (
	"list"
	"strings"

	"piper.octohelm.tech/wd"
	"piper.octohelm.tech/exec"
)

#Install: {
	$dep?: _

	cwd!:  wd.#WorkDir
	role!: string

	dataDir:    string | *"/data/k0s"
	configFile: string | *"/etc/k0s/k0s.yaml"
	tokenFile:  string | *"/etc/k0s/token"

	_install: exec.#Run & {
		if $dep != _|_ {
			"$dep": $dep
		}

		"cwd": cwd
		"cmd": strings.Join(list.FlattenN([
			"k0s", "install",

			if strings.Contains(role, "controller") {
				[
					"controller",
					"--config=\(configFile)",
				]
			},

			if !strings.Contains(role, "controller") {
				[
					"worker",
					"--token-file=\(tokenFile)",
				]
			},

			"--force",

			"--data-dir=\(dataDir)",

			if strings.Contains(role, "controller+worker") {
				"--enable-worker"
			},

			if strings.Contains(role, "controller") {
				"--disable-components=helm,autopilot"
			},
		], 2), " ")
	}

	$ok: _install.$ok
}
