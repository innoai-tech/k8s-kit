package k0s

import (
	"piper.octohelm.tech/http"
)

#Bin: {
	arch!:    string
	version!: string

	_fetch: http.#Fetch & {
		url:   "https://github.com/k0sproject/k0s/releases/download/\(version)/k0s-\(version)-\(arch)"
		hitBy: "Content-Md5"
	}

	file: _fetch.file
}
