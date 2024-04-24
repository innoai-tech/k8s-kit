package k0s

import (
	"strings"
	"encoding/yaml"

	"piper.octohelm.tech/client"
	"piper.octohelm.tech/wd"
	"piper.octohelm.tech/file"
	"piper.octohelm.tech/container"

	kubepkgspec "github.com/octohelm/kubepkg/cuepkg/kubepkg"
	"github.com/innoai-tech/deployer/cuedevpkg/kubepkg"
)

#AirgapImages: {
	version!: string
	network: provider: string

	_pull: container.#Pull & {
		source: "docker.io/k0sproject/k0s:\(strings.Replace(version, "+", "-", -1))"
	}

	_config_create: container.#Run & {
		input: _pull.output
		run:   "k0s config create --include-images > /k0s.yaml"
	}

	_read: container.#ReadFile & {
		input: _config_create.output.rootfs
		path:  "/k0s.yaml"
	}

	_ret: client.#Wait & {
		_config: yaml.Unmarshal(_read.contents)

		_images: #ImageSet & {
			"images": _config.spec.images
			"network": "provider": network.provider
		}

		output: _images.output
	}

	images: _ret.output
}

#Airgap: {
	config!: #ClusterConfig
	arch!:   string
	role!:   string
	k0sVersion!: string

	_bin: #Bin & {
		"version": k0sVersion
		"arch": arch
	}

	_tmp: wd.#Temp & {
		id: "k0s-airgap"
	}

	_airgap_images: #AirgapImages & {
		network: provider: config.spec.network.provider
		version: _bin.version
	}

	_x: client.#Group & {
		export: {
			for name, i in _airgap_images.images {
				"\(name)": file.#WriteAsJSON & {
					"outFile": {
						"wd":       _tmp.dir
						"filename": "\(name).kubepkg.json"
					}
					"data": kubepkgspec.#KubePkg & {
						"metadata": {
							"name":      "\(name)"
							"namespace": "kube-system"
						}
						spec: version: i.version
						status: images: "\(i.image):\(i.version)": ""
					}
				}
			}
		}

		airgap: {
			for name, _ in _airgap_images.images {
				"\(name)": kubepkg.#Airgap & {
					"platform":    "linux/\(arch)"
					"kubepkgFile": export["\(name)"].file
				}
			}
		}
	}

	export: _x.export
	airgap: _x.airgap

	_images: #ImageSet & {network: provider: config.spec.network.provider}

	images: {
		for name, i in _images.output {
			"\(name)": file.#File & {
				wd:       _tmp.dir
				filename: "\(name).\(arch).tar"
			}
		}
	}
}
