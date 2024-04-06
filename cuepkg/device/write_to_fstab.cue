package device

import (
	"strings"

	"piper.octohelm.tech/wd"
	"piper.octohelm.tech/file"
	"piper.octohelm.tech/client"
)

#WriteToFstab: {
	cwd!:        wd.#WorkDir
	device!:     #Device
	mountPoint!: string

	_records: #FstabRecords & {
		"cwd": cwd
	}

	_fs_record: #FstabRecord & {
		"mountPoint": mountPoint
		"fileSystem": device.path
		"type":       device.fstype
	}

	_write: file.#Write & {
		"outFile": {
			"wd":       cwd
			"filename": "/etc/fstab"
		}
		"contents": strings.Join([
			for r in _records.records if r.mountPoint != mountPoint {
				r.output
			},
			_fs_record.output,
		], "\n") + "\n"
	}

	$ok: _write.$ok
}

#FstabRecords: {
	cwd: wd.#WorkDir

	_read: file.#ReadAsTable & {
		"file": {
			"wd":       cwd
			"filename": "/etc/fstab"
		}
	}

	_ret: client.#Wait & {
		records: [
			for row in _read.data {
				#FstabRecord & {
					fileSystem: row[0]
					mountPoint: row[1]
					type:       row[2]
					options:    row[3]
					dump:       row[4]
					pass:       row[5]
				}
			},
		]
	}

	records: _ret.records
}

#FstabRecord: {
	fileSystem: string
	mountPoint: string
	type:       string
	options:    string | *"defaults"
	dump:       string | *"0"
	pass:       string | *"0"

	output: "\(fileSystem) \(mountPoint) \(type) \(options) \(dump) \(pass)"
}
