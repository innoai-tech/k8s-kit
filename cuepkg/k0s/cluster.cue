package k0s

import (
	"strings"

	"piper.octohelm.tech/wd"
	kubepkgspec "github.com/octohelm/kubepkg/cuepkg/kubepkg"
)

#Cluster: {
	name!: string
	host!: [Name=string]: #Host
	k0sVersion!: string
	network: {
		provider: "kuberouter" | "calico" | *"kuberouter"
	}

	// 宿主机环境准备
	prepare: {
		for _name, h in host {
			"\(_name)": #HostSetup & {
				"cwd":     h.cwd
				"datadir": h.datadir
				"network": h.network
			}
		}
	}

	_cluster_config: #ClusterConfig & {
		metadata: "name": name
		spec: "network": "provider": "\(network.provider)"
		spec: "network": "kubeProxy": mode: "ipvs"
	}

	component: [Name=string]: {
		output: kubepkgspec.#KubePkg & {}
		...
	}

	airgap: {
		for _name, h in host {
			"\(_name)": {
				core: #Airgap & {
					"k0sVersion": k0sVersion
					arch:   h.arch
					role:   h.role
					config: _cluster_config
				}

				addon: #AirgapAddon & {
					"name": _name
					"arch": h.arch
					"component": {
						for name, c in component {
							"\(name)": c.output
						}
					}
				}

				manifests: {
					addon.manifests
				}

				images: {
					core.images
					addon.images
				}
			}
		}
	}

	_controller_dir: [
				for _name, h in host if strings.Contains(h.role, "controller") {
			h.cwd
		},
	][0]

	deploy: {
		for _name, h in host {
			"\(_name)": #Deploy & {
				"k0sVersion": k0sVersion
				cwd:    h.cwd
				arch:   h.arch
				role:   h.role
				labels: h.labels
				config: _cluster_config

				images: airgap["\(_name)"].images

				if strings.Contains(h.role, "controller") {
					manifests: airgap["\(_name)"].manifests
				}

				if h.role == "worker" {
					controllerDir: _controller_dir
				}
			}
		}
	}

	kubeconfig: #KubeConfig & {
		"name":          name
		"controllerDir": _controller_dir
	}
}

#Host: {
	cwd!: wd.#WorkDir

	role!: "controller+worker" | "controller" | "worker"
	arch!: "amd64" | "arm64"

	datadir!: {
		path!:     string
		diskName?: string
	}

	network: {
		interface: string | *"eth0"
	}

	labels: [Name=string]: string
}
