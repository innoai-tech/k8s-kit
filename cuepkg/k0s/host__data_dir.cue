package k0s

import (
	"piper.octohelm.tech/wd"

	cuepkgparted "github.com/innoai-tech/k8s-kit/cuepkg/parted"
	cuepkgdevice "github.com/innoai-tech/k8s-kit/cuepkg/device"
)

#DataDir: {
	cwd!:        wd.#WorkDir
	mountPoint!: string
	diskName!:   string

	_parted: cuepkgparted.#Parted & {
		"cwd":      cwd
		"diskName": diskName
		"parts": [
			{
				from: "1"
				to:   "100%"
			},
		]
	}

	_mkfs: cuepkgdevice.#Mkfs & {
		"cwd":    cwd
		"device": _parted.device["\(diskName)1"]
	}

	_mount: cuepkgdevice.#Mount & {
		"cwd":        cwd
		"device":     _mkfs.output
		"mountPoint": mountPoint
	}

	_write_fatab: cuepkgdevice.#WriteToFstab & {
		"cwd":        cwd
		"device":     _mkfs.output
		"mountPoint": mountPoint
	}

	$ok: _mount.$ok && _write_fatab.$ok
}
