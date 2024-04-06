package k0s

import (
	"encoding/yaml"

	"piper.octohelm.tech/wd"
	"piper.octohelm.tech/exec"
	piperfile "piper.octohelm.tech/file"
)

#KubeConfig: {
	name!:          string
	controllerDir!: wd.#WorkDir

	file: piperfile.#File & {
		filename: ".kube_config/config--\(name).yaml"
	}

	_kubeconfig_raw: exec.#Run & {
		"cwd": controllerDir
		"cmd": "k0s kubeconfig admin"
		"with": {
			stdout: true
		}
	}

	_kubeconfig: yaml.Unmarshal(_kubeconfig_raw.stdout)

	_write: piperfile.#WriteAsYAML & {
		"outFile": file
		"data": {
			apiVersion: "v1"
			kind:       "Config"
			clusters: [
				{
					"name":    name
					"cluster": _kubeconfig.clusters[0].cluster
				},
			]
			users: [
				{
					"name": name
					"user": _kubeconfig.users[0].user
				},
			]
			"current-context": name
			contexts: [
				{
					"name": name
					"context": {
						cluster: name
						user:    name
					}
				},
			]
		}
	}

	$ok: _write.$ok
}
