# nephelaiio.k8s

[![Test](https://github.com/nephelaiio/ansible-role-k8s/workflows/molecule/badge.svg)](https://github.com/nephelaiio/ansible-role-k8s/actions)
[![Release](https://github.com/nephelaiio/ansible-role-k8s/workflows/release/badge.svg)](https://github.com/nephelaiio/ansible-role-k8s/actions)
[![Update](https://github.com/nephelaiio/ansible-role-k8s/workflows/update/badge.svg)](https://github.com/nephelaiio/ansible-role-k8s/actions)
[![Ansible Galaxy](http://img.shields.io/badge/ansible--galaxy-nephelaiio.k8s-blue.svg)](https://galaxy.ansible.com/nephelaiio/k8s/)

An opinionated [ansible role](https://galaxy.ansible.com/nephelaiio/k8s) to bootstrap K8s cluster deployments with the following components:
* [MetalLB](https://metallb.universe.tf/installation/#installation-with-helm) (Helm deployment)
* [Cert-Manager](https://cert-manager.io/docs/installation/helm/) (Helm deployment)
* [NGINX ingress](https://github.com/kubernetes/ingress-nginx) controllers (Helm deployment)
* [ArgoCD](https://github.com/argoproj/argo-cd) (Helm deployment)
* [OLM](https://github.com/operator-framework/operator-lifecycle-manager) (Manifest deployment)
* [LongHorn](https://github.com/longhorn/charts) (Helm deployment)
* [AWX Operator](https://github.com/ansible/awx-operator) (ArgoCD Helm deployment)
* [Strimzi](https://operatorhub.io/operator/strimzi-kafka-operator) (OLM deployment)
* [Zalando Postgres](https://github.com/zalando/postgres-operator) Operator (Helm deployment)
* [MySQL Operator](https://dev.mysql.com/doc/mysql-operator/en/) (Helm deployment)
* [ExternalDNS](https://github.com/kubernetes-sigs/external-dns) (TODO)
* [Grafana](https://github.com/grafana/grafana) (TODO)
* [Kyverno](https://github.com/kyverno/kyverno) (TODO)

Role includes a cluster verifier that can be activated by setting `k8s_verify: true` that performs the following checks:
* All pods are successful
* All helm deployments are successful
* All certificates deployments are successful
* All ingresses haven been assigned external ips
* All ingresses haven been assigned a valid certificate
* All ingresses respond with HTTP 200
* All volumes deployments are successful
* All ArgoCD applications are successful
* All OLM operator deployments are successful
* All Zalando instances are deployed
* All MySQL InnoDB clusters are deployed

## Role Variables

The following is the list of parameters intended for end-user manipulation: 

Cluster wide parameters

| Parameter                        |         Default | Type    | Description                          | Required |
|:---------------------------------|----------------:|:--------|:-------------------------------------|:---------|
| k8s_deploy                       |            true | boolean | Toggle flag for cluster deployer     | no       |
| k8s_verify                       |           false | boolean | Toggle flag for cluster verification | no       |
| k8s_service_verify               |            true | boolean | Toggle flag for service verification | no       |
| k8s_ingress_verify               |            true | boolean | Toggle flag for ingress verification | no       |
| k8s_volume_verify                |            true | boolean | Toggle flag for volume verification | no       |
| k8s_cluster_type                 |           local | string  | One of ['local', 'aws']              | no       |
| k8s_kubeconfig                   |  ~/.kube/config | string  | Kubeconfig deploy bin file path      | no       |
| k8s_helm_bin                     |    _autodetect_ | string  | Helm deploy bin file path            | no       |
| k8s_wait_timeout                 |             600 | int     | Global deploy wait timeout           | no       |
| k8s_cluster_name                 | k8s.nephelai.io | string  | Cluster base fqdn                    | no       |
| k8s_address_pool_private_name    |         private | string  | Private pool name                    | no       |
| k8s_address_pool_private_iprange |     _undefined_ | string  | LB private network/prefix            | yes      |
| k8s_address_pool_public_name     |          public | string  | LB public network name               | no       |
| k8s_address_pool_public_iprange  |     _undefined_ | string  | LB public network/prefix             | yes      |
| k8s_retry_num                    |               3 | int     | Retries for cluster operations       | no       |
| k8s_retry_delay                  |              30 | int     | Retry delay for cluster operations   | no       |

ArgoCD parameters

| Parameter                |                   Default | Type    | Description                         | Required |
|:-------------------------|--------------------------:|:--------|:------------------------------------|----------|
| k8s_argocd_deploy        |                      true | boolean | Toggle flag for ArgoCD deployment   | no       |
| k8s_argocd_verify        |                      true | boolean | Toggle flag for ArgoCD verification | no       |
| k8s_argocd_chart.release |                    4.10.9 | string  | ArgoCD helm chart release           | no       |
| k8s_argocd_hostname      | argocd.<k8s_cluster_name> | string  | ArgoCD ingress hostname             | no       |
| k8s_argocd_exec_timeout  |                        3m | string  | ArgoCD git operation timeout        | no       |

OLM paramters

| Parameter       | Default | Type    | Description                                 | Required |
|:----------------|--------:|:--------|:--------------------------------------------|----------|
| k8s_olm_release | v0.22.0 | string  | From OLM [releases](https://bit.ly/41VF9kp) | no       |
| k8s_olm_deploy  |   false | boolean | Toggle flag for OLM deployment              | no       |

MetalLB parameters:

| Parameter                  |     Default | Type   | Description                                     | Required |
|:---------------------------|------------:|:-------|:------------------------------------------------|----------|
| k8s_metallb_chart.release  |      2.6.14 | string | From command `helm search repo bitnami/metallb` | no       |
| k8s_metallb_speaker_secret | _undefined_ | string |                                                 | yes      |

Cert-Manager parameters:

| Parameter                     |                                                Default | Type   | Description                    | Required |
|:------------------------------|-------------------------------------------------------:|:-------|:-------------------------------|----------|
| k8s_certmanager_chart.release |                                                 v1.9.1 | string | Certmanager helm chart release | no       |
| k8s_certmanager_acme_secret   |                                            _undefined_ | string | Cloudflare api token           | yes      |
| k8s_certmanager_acme_email    |                                            _undefined_ | string | Cloudflare api email           | yes      |
| k8s_certmanager_issuer_server | https://acme-staging-v02.api.letsencrypt.org/directory | string | ACME registration server       | no       |

Longhorn parameters:

| Parameter                  |  Default | Type       | Description                           | Required |
|:---------------------------|---------:|:-----------|:--------------------------------------|----------|
| k8s_longhorn_deploy        |     true | boolean    | Toggle flag for Longhorn deployment   | no       |
| k8s_longhorn_verify        |     true | boolean    | Toggle flag for Longhorn verification | no       |
| k8s_longhorn_chart.release | _object_ | dictionary | Longhorn helm chart relesae           | no       |

Strimzi parameters:
| Parameter            |        Default | Type    | Description                             | Required |
|:---------------------|---------------:|:--------|:----------------------------------------|----------|
| k8s_strimzi_deploy   |           true | boolean | Toggle flag for Strimzi deployment      | no       |
| k8s_strimzi_verify   |           true | boolean | Toggle flag for Strimzi verification    | no       |
| k8s_strimzi_channel  | strimzi-0.31.x | string  | OLM deploy channel for Strimzi operator | no       |
| k8s_strimzi_approval |      Automatic | Manual  | Automatic                               | no       |

Secret parameters:

| Parameter   | Default | Type     | Description          | Required |
|:------------|--------:|:---------|:---------------------|----------|
| k8s_secrets |      [] | [Secret] | [Secret] definitions | no       |

Verifier parameters:

| Parameter         |     Default | Type   | Description                     | Required |
|:------------------|------------:|:-------|:--------------------------------|----------|
| k8s_verifier_path | _undefined_ | string | Verification artifact directory | no       |

Zalando parameters:

| Parameter                 |            Default | Type    | Description                          | Required |
|:--------------------------|-------------------:|:--------|:-------------------------------------|----------|
| k8s_zalando_deploy        |               true | boolean | Toggle flag for Zalando deployment   | no       |
| k8s_zalando_verify        |               true | boolean | Toggle flag for Zalando verification | no       |
| k8s_zalando_chart.release |              1.8.2 | string  | Zalando helm chart release           | no       |
| k8s_zalando_basedomain    | _k8s_cluster_name_ | string  | Domain for postgresql load balancers | no       |

## Data Types

### Secret
```
{
  "name": string,
   "namespace": string 
   "type": [string]
   "data": hash
}
```

## Dependencies

The below python roles are needed on the host that executes this module:
* nephelaiio.plugins

The below python collections are needed on the host that executes this module:
* ansible.utils

### System

The below requirements are needed on the host that executes this module.
* Linux 64 bit OS
* kubectl binary is available on PATH

### Python

The below requirements are needed on the host that executes this module.

* kubernetes = "^24.2.0"
* openshift = "^0.13.1"
* jmespath = "^1.0.1"

### Ansible

The below Ansible roles are needed on the host that executes this module:

* nephelaiio.plugins

The below Ansible collections  are needed on the host that executes this module:

* community.general

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
* ` SCENARIO=default make molecule test `

## License

This project is licensed under the terms of the [MIT License](/LICENSE)
