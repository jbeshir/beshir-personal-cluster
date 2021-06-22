Fork of https://github.com/nkoson/gke-tutorial with the changes needed to stand up my cluster.

Rough deployment process:

- Deploy cluster with terraform at top level.
- Set kubeip secret per original tutorial.
- Deploy Kubernetes CRDs using terraform in system/traefik-crds 
- Deploy any services configured in system/routes.tf. It will refuse to allow the routes to be deployed otherwise.
- Set any TLS secrets in system/routes.tf with certificates from Cloudflare for their domains, e.g. kubectl create secret tls howwastoday-cf-certificate --cert=[pem cert] --key=[pem key] --namespace=howwastoday
- Deploy the cluster system services (kubeip, traefik, etc) using terraform in system.

Subsequently changes to things other than the CRDs can generally be performed with just a terraform apply.

The CRDs are painful, because some changes to them invalidate the resources using them. Also, a lot of incremental updates fail for them. The process I know so far is to remove the resources using them from the config, tf apply, remove the CRDs from the config, tf apply, readd the modified versions to the config, tf apply, and finally restore the resources using them and tf apply. 