package k0s

import (
	"piper.octohelm.tech/wd"
	"piper.octohelm.tech/file"

	kubepkgspec "github.com/octohelm/kubepkg/cuepkg/kubepkg"
	"github.com/innoai-tech/deployer/cuedevpkg/kubepkg"
)

#AirgapAddon: {
	name!: string
	arch!: string

	_tmp: wd.#Temp & {
		id: "k0s-addon"
	}

	component: [Name=string]: kubepkgspec.#KubePkg

	export: {
		for name, c in component {
			"\(name)": file.#WriteAsJSON & {
				"outFile": {
					"wd":       _tmp.dir
					"filename": "\(name).kubepkg.json"
				}
				"data": c
			}
		}
	}

	airgap: {
		for name, c in component {
			"\(name)": kubepkg.#Airgap & {
				"platform":    "linux/\(arch)"
				"kubepkgFile": export["\(name)"].file
			}
		}
	}

	manifests: {
		for name, _ in component {
			"\(name)": file.#File & {
				"wd":       _tmp.dir
				"filename": "\(name).yaml"
			}
		}
	}

	images: {
		for name, _ in component {
			"\(name)": file.#File & {
				"wd":       _tmp.dir
				"filename": "\(name).\(arch).tar"
			}
		}
	}
}
