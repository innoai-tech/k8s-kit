package k0s

import (
	"piper.octohelm.tech/http"
)

#Bin: {
	version: string | *"v1.28.7+k0s.0"
	arch!:   string

	_fetch: http.#Fetch & {
		url:   "https://github.com/k0sproject/k0s/releases/download/\(version)/k0s-\(version)-\(arch)"
		hitBy: "Content-Md5"
	}

	file: _fetch.file
}
