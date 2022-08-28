# nephelaiio.k8s

[![Build Status](https://github.com/nephelaiio/ansible-role-k8s/workflows/Molecule/badge.svg)](https://github.com/nephelaiio/ansible-role-k8s/actions)
[![Ansible Galaxy](http://img.shields.io/badge/ansible--galaxy-nephelaiio.k8s-blue.svg)](https://galaxy.ansible.com/nephelaiio/k8s/)

An opinionated [ansible role](https://galaxy.ansible.com/nephelaiio/k8s) to bootstrap K8s cluster deployments with the following components:
* MetalLB (Helm deployment)
* ArgoCD (Helm deployment)
* OLM_(Manifest deployment)
* NGINX ingress controllers (Helm deployment)

All components are configured for 2 public + 1 private external networks

## Role Variables

The following is the list of parameters intended for end-user manipulation: 

Cluster wide parameters

| Parameter                        |         Default | Type   | Description                                           | Required |
|:---------------------------------|----------------:|:-------|:------------------------------------------------------|:---------|
| k8s_cluster_type                 |           local | string | One of ['local', 'aws']                               | no       |
| k8s_kubeconfig                   |  ~/.kube/config | string | Kubeconfig file for deployment operations             | no       |
| k8s_helm_bin                     |    _autodetect_ | string | Helm bin file for deployment operations               | no       |
| k8s_wait_timeout                 |             600 | int    | Global wait timeout for deployemnt operations         | no       |
| k8s_cluster_name                 | k8s.nephelai.io | string | Cluster base fqdn                                     | no       |
| k8s_address_pool_private_name    |         private | string | Private pool name                                     | no       |
| k8s_address_pool_private_iprange |     _undefined_ | string | LB private network address (in network/prefix format) | yes      |
| k8s_address_pool_ispa_name       |            ispa | string | LB public network name                                | no       |
| k8s_address_pool_ispa_iprange    |     _undefined_ | string | LB public network address (in network/prefix format)  | yes      |
| k8s_address_pool_ispb_name       |            ispb | string | LB public network name                                | no       |
| k8s_address_pool_ispa_iprange    |     _undefined_ | string | LB public network address (in network/prefix format)  | yes      |

ArgoCD parameters

| Parameter                | Default | Type   | Description                                                         | Required |
|:-------------------------|--------:|:-------|:--------------------------------------------------------------------|----------|
| k8s_argocd_chart_release |  4.10.9 | string | From argo-cd tags at https://github.com/argoproj/argo-helm/releases | no       |
| k8s_argocd_exec_timeout  |      3m | string | ArgoCD git operation timeout fo                                     | no       |

OLM paramters

| Parameter       | Default | Type   | Description                                                                    | Required |
|:----------------|--------:|:-------|:-------------------------------------------------------------------------------|----------|
| k8s_olm_release | v0.22.0 | string | From https://github.com/operator-framework/operator-lifecycle-manager/releases | no       |

MetalLB parameters:

| Parameter                  |     Default | Type   | Description                                | Required |
|:---------------------------|------------:|:-------|:-------------------------------------------|----------|
| k8s_metallb_chart_release  |      2.6.14 | string | From command `search repo bitnami/metallb` | no       |
| k8s_metallb_speaker_secret | _undefined_ | string |                                            | yes      |

## Dependencies

### System

The below requirements are needed on the host that executes this module.
* Linux 64 bit OS
* kubectl binary is available on PATH

### Python

The below requirements are needed on the host that executes this module.

* kubernetes = "^24.2.0"
* openshift = "^0.13.1"

### Ansible

The below python roles are needed on the host that executes this module:

* nephelaiio.plugins

## Example Playbook

``` yaml
---
- name: Deploy local kind cluster

  hosts: localhost

  gather_facts: false
  
  roles:

    - nephelaiio.plugins
    - nephelaiio.kind
    - nephelaiio.k8s

```

## Testing

Please make sure your environment has [docker](https://www.docker.com) installed; then test the role from the project root using the following commands

* ` poetry instasll`
* ` poetry run molecule test `

## License

This project is licensed under the terms of the [MIT License](/LICENSE)
