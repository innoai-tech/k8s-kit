package storage

import (
	kubepkgspec "github.com/octohelm/kubepkg/cuepkg/kubepkg"
)

#LocalPVProvisioner: kubepkgspec.#KubePkg & {
	metadata: {
		name:      _ | *"openebs-localpv-provisioner"
		namespace: _ | *"storage-system"
	}

	spec: {
		version: _ | *"3.5.0"

		deploy: {
			kind: "Deployment"
			spec: replicas: _ | *1

			spec: template: spec: {
				nodeSelector: "node-role.kubernetes.io/control-plane": "true"
				tolerations: [
					{
						key:      "node-role.kubernetes.io/master"
						operator: "Exists"
						effect:   "NoSchedule"
					},
				]
			}
		}

		containers: "openebs-localpv-provisioner": {
			image: {
				name: _ | *"docker.io/openebs/provisioner-localpv"
				tag:  _ | *"\(spec.version)"
			}

			args: [
				"--bd-time-out=$(BDC_BD_BIND_RETRIES)",
			]

			env: {
				BDC_BD_BIND_RETRIES:     "12"
				OPENEBS_SERVICE_ACCOUNT: "@field/spec.serviceAccountName"
				OPENEBS_NAMESPACE:       "@field/metadata.namespace"
				NODE_NAME:               "@field/spec.nodeName"
				OPENEBS_IO_BASE_PATH:    "/data/openebs/local"
				OPENEBS_IO_HELPER_IMAGE: "docker.io/openebs/linux-utils:\(spec.version)"
			}

			livenessProbe: {
				exec: command: [
					"sh",
					"-c",
					"test `pgrep -c \"^provisioner-loc.*\"` = 1",
				]
				initialDelaySeconds: 30
				timeoutSeconds:      1
				periodSeconds:       60
				successThreshold:    1
				failureThreshold:    3
			}
		}

		serviceAccount: #LocalPVProvisionerServiceAccount

		manifests: "local-path": #StorageClass & {
			metadata: name: "local-path"
			provisioner:       "openebs.io/local"
			reclaimPolicy:     "Delete"
			volumeBindingMode: "WaitForFirstConsumer"
		}
	}

	// for mark OPENEBS_IO_HELPER_IMAGE
	status: images: "docker.io/openebs/linux-utils:\(spec.version)": ""
}

#StorageClass: {
	apiVersion: "storage.k8s.io/v1"
	kind:       "StorageClass"
	metadata: name: string
	provisioner:       string
	reclaimPolicy:     string
	volumeBindingMode: string
}

#LocalPVProvisionerServiceAccount: kubepkgspec.#ServiceAccount & {
	scope: "Cluster"
	rules: [
		{
			verbs: [
				"*",
			]
			apiGroups: [
				"*",
			]
			resources: [
				"nodes",
				"nodes/proxy",
			]
		},
		{
			verbs: [
				"*",
			]
			apiGroups: [
				"*",
			]
			resources: [
				"namespaces",
				"services",
				"pods",
				"pods/exec",
				"deployments",
				"deployments/finalizers",
				"replicationcontrollers",
				"replicasets",
				"events",
				"endpoints",
				"configmaps",
				"secrets",
				"jobs",
				"cronjobs",
			]
		},
		{
			verbs: [
				"*",
			]
			apiGroups: [
				"*",
			]
			resources: [
				"statefulsets",
				"daemonsets",
			]
		},
		{
			verbs: [
				"list",
				"watch",
			]
			apiGroups: [
				"*",
			]
			resources: [
				"resourcequotas",
				"limitranges",
			]
		},
		{
			verbs: [
				"list",
				"watch",
			]
			apiGroups: [
				"*",
			]
			resources: [
				"ingresses",
				"horizontalpodautoscalers",
				"verticalpodautoscalers",
				"poddisruptionbudgets",
				"certificatesigningrequests",
			]
		},
		{
			verbs: [
				"*",
			]
			apiGroups: [
				"*",
			]
			resources: [
				"storageclasses",
				"persistentvolumeclaims",
				"persistentvolumes",
			]
		},
		{
			verbs: [
				"get",
				"list",
				"watch",
				"create",
				"update",
				"patch",
				"delete",
			]
			apiGroups: [
				"volumesnapshot.external-storage.k8s.io",
			]
			resources: [
				"volumesnapshots",
				"volumesnapshotdatas",
			]
		},
		{
			verbs: [
				"get",
				"list",
				"create",
				"update",
				"delete",
				"patch",
			]
			apiGroups: [
				"apiextensions.k8s.io",
			]
			resources: [
				"customresourcedefinitions",
			]
		},
		{
			verbs: [
				"*",
			]
			apiGroups: [
				"openebs.io",
			]
			resources: [
				"*",
			]
		},
		{
			verbs: [
				"*",
			]
			apiGroups: [
				"cstor.openebs.io",
			]
			resources: [
				"*",
			]
		},
		{
			verbs: [
				"get",
				"watch",
				"list",
				"delete",
				"update",
				"create",
			]
			apiGroups: [
				"coordination.k8s.io",
			]
			resources: [
				"leases",
			]
		},
		{
			verbs: [
				"get",
				"create",
				"list",
				"delete",
				"update",
				"patch",
			]
			apiGroups: [
				"admissionregistration.k8s.io",
			]
			resources: [
				"validatingwebhookconfigurations",
				"mutatingwebhookconfigurations",
			]
		},
		{
			verbs: [
				"get",
			]
			nonResourceURLs: [
				"/metrics",
			]
		},
	]
}
