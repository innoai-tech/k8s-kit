package networking

import (
	"github.com/innoai-tech/deployer/cuedevpkg/helm"
)

#Contour: helm.#ToKubePkg & {
	namespace: _ | *"networking-system"

	chart: {
		name:    "contour"
		version: "1.0.0"
		dependencies: {
			"contour": {
				// https://charts.bitnami.com/bitnami/index.yaml
				repository: "https://charts.bitnami.com/bitnami"
				// 10.6.1
				version: "17.0.1"
			}
		}
	}

	values: "contour": {
		contour: {
			image: {
				registry:   "docker.io"
				repository: "bitnami/contour"
			}

			tolerations: [
				{
					key:      "node-role.kubernetes.io/master"
					operator: "Exists"
					effect:   "NoSchedule"
				},
			]
		}

		envoy: {
			image: {
				registry:   "docker.io"
				repository: "bitnami/envoy"
			}
			tolerations: [
				{
					key:      "node-role.kubernetes.io/master"
					operator: "Exists"
					effect:   "NoSchedule"
				},
			]

			useHostPort: {
				http:  true
				https: true
			}
		}
	}

	output: {

	}
}
