package host

import (
	"strings"

	"piper.octohelm.tech/wd"
	"piper.octohelm.tech/file"
)

#SetSysctl: {
	cwd!: wd.#WorkDir

	values: [Name=string]: string
	values: {
		"vm.swappiness":                "0"
		"net.core.somaxconn":           "65535"
		"net.ipv4.tcp_max_tw_buckets":  "20000"
		"net.ipv4.tcp_max_syn_backlog": "100000"
		"fs.file-max":                  "1100000"
		"fs.nr_open":                   "1100000"
		"kernel.pid_max":               "655350"
	}

	_write: file.#Write & {
		"outFile": {
			"wd":       cwd
			"filename": "/etc/sysctl.conf"
		}
		"contents": strings.Join([
			for k, v in values {
				"\(k)=\(v)"
			},
		], "\n")
	}

	"file": _write.file
}
