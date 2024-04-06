package host

import (
	"strings"

	"piper.octohelm.tech/wd"
	"piper.octohelm.tech/file"
)

#ReadSecurityLimits: {
	srcDir!: wd.#WorkDir

	_read: file.#ReadAsString & {
		"file": {
			"wd":       srcDir
			"filename": "/etc/security/limits.conf"
		}
	}

	contents: _read.contents
}

#SetSecurityLimits: {
	cwd!: wd.#WorkDir

	limits: [...#SecurityLimit]
	limits: [
		{
			domain: "*"
			type:   "soft"
			item:   "nofile"
			value:  "655350"
		},
		{
			domain: "*"
			type:   "hard"
			item:   "nofile"
			value:  "655350"
		},
		{
			domain: "*"
			type:   "soft"
			item:   "nproc"
			value:  "262144"
		},
		{
			domain: "*"
			type:   "hard"
			item:   "nproc"
			value:  "262144"
		},
	]

	_write: file.#Write & {
		"outFile": {
			"wd":       cwd
			"filename": "/etc/security/limits.conf"
		}
		"contents": strings.Join([
			"# <domain> <type> <item> <value>\n",
			for l in limits {
				"\(l.output)\n"
			},
		], "")
	}

	"file": _write.file
}

#SecurityLimit: {
	domain: string
	type:   string
	item:   string
	value:  string

	output: """
	\(domain) \(type) \(item) \(value)
	"""
}
