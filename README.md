# cross-account-managed-prometheus

```
+-----------------------------+   +---------------------------------+   +-------------------------------+
|AWS Prod Account             |   |AWS Management                   |   |AWS Dev Account                |
|                             |   |Account                          |   |                               |
|                             |   |                                 |   |                               |
|                             |   |                                 |   |                               |
|                             |   |                                 |   |                               |
| +------------------------+  |   |         +-----------+           |   | +--------------------------+  |
| |EKS Prod Cluster        |  |   |         |Managed    |           |   | |EKS Dev Cluster           |  |
| |                        |  |   |         |Grafana    +----+      |   | |                          |  |
| |                        |  |   |         |           |    |      |   | |                          |  |
| |                        |  |   |         ++----------+    |      |   | |                          |  |
| |                        |  |   |          |               |      |   | |                          |  |
| | +--------------------+ | VPC  |   +------v-----------------+    |   | | +----------------------+ |  |
| | |Prometheus          +------------>Managed Prometheus    | |    | +-----+Prometheus            | |  |
| | |Server              | |Endpoint  |Prod Workspace        | |    | | | | |Server                | |  |
| | +--------------------+ |  |   |   +------------------------+    | | | | +----------------------+ |  |
| | +--------------------+ |  |   |   +----------------------v-+  VPC | | | +----------------------+ |  |
| | |Alert Manager       | |  |   |   |Managed Prometheus      <------+ | | |Alert Manager         | |  |
| | |                    | |  |   |   |Dev Workspace           |Endpoint| | |                      | |  |
| | +--------------------+ |  |   |   +------------------------+    |   | | +----------------------+ |  |
| +------------------------+  |   |                                 |   | +--------------------------+  |
|            |                |   |                                 |   |                |              |
+-----------------------------+   +---------------------------------+   +-------------------------------+
             |                                                                           |
             |                             +----------------+                            |
             |                             |Slack           |                            |
             |                             |                |                            |
             +----------------------------->                <----------------------------+
                                           |                |
                                           +----------------+

```

# Overview

A common pattern is to have a management account to contain monitoring, logs etc but this can be complex to setup in AWS because of the requirement for cross-account IAM. AWS have a blog   
[Setting up cross-account ingestion into Amazon Managed Service for Prometheus](https://aws.amazon.com/blogs/opensource/setting-up-cross-account-ingestion-into-amazon-managed-service-for-prometheus/) but fail to supply a git repository with the terraform and kubernetes yaml for implementing this. This is that repo. 

In this example there are 2 AWS accounts prod and dev that have EKS clusters, and a management account with the managed prometheus workspaces for dev and prod and a managed grafana that can access both workspaces. At time of writing managed grafana is not supported by terraform so needs to be done manually in the AWS console.   

## terraform directory 

Contains terraform to create the managed prometheus workspaces and cross-account roles and policies. It assumes that there are 3 terraform workspaces - dev, prod, and management. 

## Alerts

Example alert rules for EKS kubernetes at [neillturner/alerting_rules.yml](https://gist.github.com/neillturner/45915fdbfb3359d7d98b97fee281eadb)

## kubernetes directory 

Contains the kubernetes yaml definitions for the prometheus server in the dev EKS cluster using the public helm chart. then can be applied with [flux](https://fluxcd.io/docs/) in a gitops fashion or modify to use helm/kubectl using [prometheus helm chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus). Its necessary to update prometheus.yaml for the fields: 
- &lt;dev-aws-account-id&gt; 
- &lt;management-aws-account-id&gt;
- &lt;prometheus-workspace-id&gt;

NOTE: Need similar definitions for the prod EKS cluster. 

# Usage 

- Run the terraform against all 3 workspaces - dev, prod, management. 
- After updating the kubernetes yaml use flux or helm/kubectl to deploy the prometheus server in dev EKS cluster.
- deploy similar kubernetes yaml for the prod eks cluster. 

# References 

[https://aws.amazon.com/blogs/opensource/setting-up-cross-account-ingestion-into-amazon-managed-service-for-prometheus/](https://aws.amazon.com/blogs/opensource/setting-up-cross-account-ingestion-into-amazon-managed-service-for-prometheus/) 

[https://aws.amazon.com/blogs/mt/getting-started-amazon-managed-service-for-prometheus/](https://aws.amazon.com/blogs/mt/getting-started-amazon-managed-service-for-prometheus/)

[https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus)
