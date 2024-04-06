package host

import (
	"strings"

	"piper.octohelm.tech/client"
	"piper.octohelm.tech/wd"
	"piper.octohelm.tech/exec"
)

#IPInfo: {
	cwd!:      wd.#WorkDir
	interface: string | *"eth0"

	_resolve_ipv4: exec.#Run & {
		"cwd": cwd
		"cmd": "ifconfig \(interface) | sed -n 2p | awk '{ print $2 }'"
		"with": {
			failfast: false
			stdout:   true
		}
	}

	_resolve_ipv6: exec.#Run & {
		"cwd": cwd
		"cmd": "ifconfig \(interface) | sed -n 3p | awk '{ print $2 }'"
		"with": {
			failfast: false
			stdout:   true
		}
	}

	output: client.#Wait & {
		ipv4: {
			if _resolve_ipv4.$ok {
				strings.TrimSpace(_resolve_ipv4.stdout)
			}
		}
		ipv6: {
			if _resolve_ipv6.$ok {
				strings.TrimSpace(_resolve_ipv6.stdout)
			}
		}
	}
}
