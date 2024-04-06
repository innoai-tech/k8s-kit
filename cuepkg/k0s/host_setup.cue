package k0s

import (
	"piper.octohelm.tech/wd"

	cuepkghost "github.com/innoai-tech/k8s-kit/cuepkg/host"
)

#HostSetup: {
	cwd: wd.#WorkDir

	datadir: {
		path!:     string
		diskName?: string

		if diskName != _|_ {
			_prepare: #DataDir & {
				"cwd":        cwd
				"mountPoint": path
				"diskName":   diskName
			}
		}
	}

	network: {
		interface: string | *"eth0"
	}

	hostname: cuepkghost.#SetHostnameByIPv4 & {
		"cwd": cwd
		"network": "interface": network.interface
	}

	securityLimits: cuepkghost.#SetSecurityLimits & {
		"cwd": cwd
	}

	sysctl: cuepkghost.#SetSysctl & {
		"cwd": cwd
	}
}
