package debian

import (
	"path"
	"strings"

	"piper.octohelm.tech/wd"
	"piper.octohelm.tech/exec"
	"piper.octohelm.tech/client"
	"piper.octohelm.tech/file"
)

#Bin: {
	// 工作目录
	cwd!: wd.#WorkDir
	// 包名
	pkgName!: string
	// bin 文件根目录
	binRoot: string | *"/sbin/"

	_check: exec.#Run & {
		"cwd": cwd
		// https://packages.debian.org/bookworm/lvm2
		"cmd": "dpkg -L \(pkgName) | grep \(binRoot)"
		"env": {
			"_CHECK": "true" // env to disable cache
		}
		"with": {
			failfast: false
			stdout:   true
		}
	}

	_install: exec.#Run & {
		$dep: client.#Skip & {
			when: _check.$ok
		}

		"cwd": cwd
		"cmd": [
			"apt-get", "install", "-y", pkgName,
		]

		"with": {
			failfast: true
		}
	}

	_re_check: exec.#Run & {
		$dep: client.#Skip & {
			when: !_install.$ok
		}

		"cwd": cwd
		"cmd": "dpkg -L \(pkgName) | grep \(binRoot)"
		"with": {
			failfast: false
			stdout:   true
		}
	}

	_ret: [
		_check,
		_re_check,
	]

	_bin: client.#Wait & {
		_bin_list: [
				for _x in _ret {
				strings.TrimSpace(_x.stdout)
			},
		][0]

		output: {
			for binfile in strings.Split(_bin_list, "\n") {
				"\(path.Base(binfile))": file.#File & {
					wd:       cwd
					filename: binfile
				}
			}
		}
	}

	cli: _bin.output
}
