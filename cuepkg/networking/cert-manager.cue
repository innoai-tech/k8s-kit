package networking

import (
	"piper.octohelm.tech/file"
	"piper.octohelm.tech/http"

	kubepkgspec "github.com/octohelm/kubepkg/cuepkg/kubepkg"
)

#CertManager: {
	version:   string | *"v1.14.4"
	namespace: string | *"cert-manager"
	name:      string | *"cert-manager"

	_manifests: http.#Fetch & {
		url:   "https://github.com/cert-manager/cert-manager/releases/download/\(version)/cert-manager.yaml"
		hitBy: "Content-Md5"
	}

	_read: file.#ReadFromYAML & {
		file: _manifests.file
		with: asList: true
	}

	output: kubepkgspec.#KubePkg & {
		metadata: "namespace": namespace
		metadata: "name":      name
		spec: "version":       version

		for v in _read.data {
			if v.kind != _|_ {
				let k = "\(v.metadata.name).\(v.kind)"

				spec: manifests: "\(k)": v
			}
		}
	}
}
