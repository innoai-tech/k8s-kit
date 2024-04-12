package k0s

import (
	"strings"
	"path"

	"piper.octohelm.tech/wd"
	"piper.octohelm.tech/file"
	"piper.octohelm.tech/client"
	"piper.octohelm.tech/exec"
)

#Deploy: {
	cwd!:    wd.#WorkDir
	config!: #ClusterConfig
	arch!:   string
	role!:   string

	dataDir:    string | *"/data/k0s"
	configFile: string | *"/etc/k0s/k0s.yaml"

	manifests: [Name=string]: file.#File
	images: [Name=string]:    file.#File

	_bin: #Bin & {
		"arch": arch
	}

	k0s: file.#File & {
		wd:       cwd
		filename: "/usr/local/bin/k0s"
	}

	sync: client.#Group & {
		k0s_bin: file.#Sync & {
			srcFile: _bin.file
			outFile: k0s
		}

		make_k0s_execable: exec.#Run & {
			"cwd": k0s.wd
			"cmd": "chmod +x \(k0s.filename)"
		}

		create_aliases: #CommandAliases & {
			"cwd": cwd
			"aliases": {
				kubectl: "k0s kubectl"
				ctr:     "k0s ctr"
			}
		}

		if strings.Contains(role, "controller") {
			k0s_config: file.#WriteAsYAML & {
				outFile: {
					wd:       cwd
					filename: configFile
				}
				data: config
			}
		}

		for name, i in manifests {
			"manifests:\(name)": file.#Sync & {
				srcFile: i
				outFile: {
					wd: cwd
					filename: path.Join([dataDir, "manifests", name, "\(name).yaml"])
				}
			}
		}

		for name, i in images {
			"image:\(name)": file.#Sync & {
				srcFile: i
				outFile: {
					wd: cwd
					filename: path.Join([dataDir, "images", "\(name).tar"])
				}
			}
		}
	}

	install: #Install & {
		$dep: sync.$ok

		"cwd":     cwd
		"role":    role
		"dataDir": dataDir
	}

	restart: #Restart & {
		$dep: install.$ok

		"cwd": cwd
	}

	$ok: restart.$ok

	if role == "worker" {
		controllerDir!: wd.#WorkDir

		create_token: #CreateWorkerToken & {
			"controllerDir": controllerDir
			"workerDir":     cwd
		}

		restart: $dep: create_token.$ok
	}

}
