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
	cwd!:        wd.#WorkDir
	config!:     #ClusterConfig
	arch!:       string
	role!:       string
	k0sVersion!: string

	dataDir:    string | *"/data/k0s"
	configFile: string | *"/etc/k0s/k0s.yaml"

	labels: [Name=string]:    string
	manifests: [Name=string]: file.#File
	images: [Name=string]:    file.#File

	_bin: #Bin & {
		"version": k0sVersion
		"arch":    arch
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

		// sync
		// https://github.com/containerd/containerd/blob/main/docs/hosts.md#registry-configuration---introduction
		enable_containerd_hosts: file.#WriteAsTOML & {
			outFile: {
				"wd":       cwd
				"filename": "/etc/k0s/containerd.d/cr.toml"
			}
			data: {
				plugins: "io.containerd.grpc.v1.cri": "registry": {
					config_path: "/etc/containerd/certs.d"
				}
			}
		}

		if labels["nvidia.com/gpu.present"] == "true" {
			enable_containerd_nvidia_runtime: file.#WriteAsTOML & {
				outFile: {
					"wd":       cwd
					"filename": "/etc/k0s/containerd.d/nvidia.toml"
				}
				data: {
					plugins: "io.containerd.grpc.v1.cri": "containerd": {
						default_runtime_name: "nvidia"
						runtimes: "nvidia": {
							privileged_without_host_devices: false
							runtime_engine:                  ""
							runtime_root:                    ""
							runtime_type:                    "io.containerd.runc.v1"
							options: {
								BinaryName: "/usr/bin/nvidia-container-runtime"
							}
						}
					}
				}
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
		"labels":  labels
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
