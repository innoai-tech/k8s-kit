package host

import (
	"strings"

	"piper.octohelm.tech/wd"
)

#SetHostnameByIPv4: {
	cwd!: wd.#WorkDir
	network: interface: string | *"eth0"

	_ip_info: #IPInfo & {
		"cwd":       cwd
		"interface": network.interface
	}

	_set_hostname: #SetHostname & {
		"cwd":      cwd
		"hostname": "ip-\(strings.Replace(_ip_info.output.ipv4, ".", "-", -1))"
	}

	output: _set_hostname.output
}
