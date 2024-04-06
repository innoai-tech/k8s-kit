package k0s

#ClusterConfig: {
	// https://docs.k0sproject.io/head/configuration/
	apiVersion: "k0s.k0sproject.io/v1beta1"
	kind:       "ClusterConfig"
	metadata: name?: string

	spec: #ClusterConfigSpec & {
		api: extraArgs: {
			"service-node-port-range": "20000-40000"
			"authorization-mode":      "Node,RBAC"
			"allow-privileged":        "true"
		}

		storage: type: "etcd"

		network: {
			podCIDR:       "10.244.0.0/16"
			serviceCIDR:   "10.68.0.0/16"
			clusterDomain: "cluster.local"
		}
	}
}

#ClusterConfigSpec: {
	// https://docs.k0sproject.io/head/configuration/#specapi
	api: {
		extraArgs?: [Flag=string]: string
	}

	// https://docs.k0sproject.io/head/configuration/#specstorage
	storage: {
		type: "etcd"
		etcd: {
			peerAddress?: string
			extraArgs?: [Flag=string]: string
		}
	} | {
		type: "kine"
		kine: {
			dataSource?: string
		}
	}

	// https://docs.k0sproject.io/head/configuration/#network
	network: {
		podCIDR:       string
		serviceCIDR:   string
		clusterDomain: string

		{
			provider: "calico"
			calico: {
				mode:    "vxlan" | "ipip" | "bird" | *"vxlan"
				overlay: "Always" | "CrossSubnet" | "Never" | *"Always"
			}
		} | {
			provider: "kuberouter"
			kuberouter: {
				// 
			}
		}

		kubeProxy: {
			metricsBindAddress: string | *"0.0.0.0:10249"

			{
				mode: "iptables"
				iptables: {
					masqueradeAll:  bool | *false
					masqueradeBit?: string
					minSyncPeriod:  string | *"0s"
					syncPeriod:     string | *"0s"
				}
			} | {
				mode: "ipvs"
				ipvs: {
					minSyncPeriod: string | *"0s"
					syncPeriod:    string | *"0s"
					tcpFinTimeout: string | *"0s"
					tcpTimeout:    string | *"0s"
					udpTimeout:    string | *"0s"
				}
			}
		}
	}

	// https://docs.k0sproject.io/head/configuration/#speckonnectivity
	konnectivity: {
		agentPort: number | *8132
		adminPort: number | *8133
	}

	// https://docs.k0sproject.io/head/configuration/#specscheduler
	scheduler: {
		extraArgs?: [Flag=string]: string
	}

	installConfig: {
		users: {
			etcdUser:          string | *"etcd"
			kineUser:          string | *"kube-apiserver"
			konnectivityUser:  string | *"konnectivity-server"
			kubeAPIserverUser: string | *"kube-apiserver"
			kubeSchedulerUser: string | *"kube-scheduler"
		}
	}

	// disable telemetry
	telemetry: enabled: bool | *false
}

#Image: {
	image:   string
	version: string
}

#ImageSet: {
	network: provider: string

	images: {
		metricsserver: #Image
		coredns:       #Image
		pause:         #Image
		konnectivity:  #Image
		kubeproxy:     #Image
		calico: {
			cni:             #Image
			kubecontrollers: #Image
			node:            #Image
		}
		kuberouter: {
			cni:          #Image
			cniInstaller: #Image
		}
		pushgateway: #Image
		...
	}

	output: {
		for group, subOrImage in images {
			if group == "kuberouter" || group == "calico" {
				for sub, i in subOrImage if group == network.provider {
					"\(group)-\(sub)": {
						image:   i.image
						version: i.version
					}
				}
			}

			if !(group == "kuberouter" || group == "calico" || group == "default_pull_policy") {
				"\(group)": {
					image:   subOrImage.image
					version: subOrImage.version
				}
			}
		}
	}
}
