package parted

import (
	"github.com/innoai-tech/k8s-kit/cuepkg/debian"
)

#Bin: debian.#Bin & {
	pkgName: "parted"
	binRoot: "/sbin/"
}
