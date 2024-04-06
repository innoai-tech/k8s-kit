package parted

import (
	"list"

	"piper.octohelm.tech/wd"
	"piper.octohelm.tech/exec"
	"piper.octohelm.tech/client"

	cuepkgdevice "github.com/innoai-tech/k8s-kit/cuepkg/device"
)

#Parted: {
	cwd!:      wd.#WorkDir
	diskName!: string

	label: string | *"gpt"
	parts: [...{
		from!: string
		to!:   string
		align: string | *"optimal"
		lvm:   bool | *false
	}]

	_bin: #Bin & {
		"cwd": cwd
	}

	_info: cuepkgdevice.#DiskInfo & {
		"cwd":      cwd
		"diskName": diskName
	}

	_part: exec.#Run & {
		$dep: client.#Skip & {
			when: _info.info.label != ""
		}
		"cwd": cwd
		"cmd": list.FlattenN([
			"\(_bin.cli.parted.filename) /dev/\(diskName) --script mklabel \(label);",

			for p in parts {
				[
					"\(_bin.cli.parted.filename) -a \(p.align) /dev/\(diskName) --script mkpart primary \(p.from) \(p.to);",
					if p.lvm {
						"\(_bin.cli.parted.filename) -a \(p.align) /dev/\(diskName) --script set 1 lvm on;"
					},
				]
			},
		], 2)
	}

	_path: client.#Wait & {
		$ok: _info.$ok || _part.$ok

		output: {
			for i, p in parts if $ok {
				"\(diskName)\(i+1)": cuepkgdevice.#Device & {
					path: "/dev/\(diskName)\(i+1)"
				}
			}
		}
	}

	$ok:    _path.$ok
	device: _path.output
}
