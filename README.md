# Personal Low-Cost GKE Cluster

My personal miniature low-cost GKE cluster Terraform and Kitchen configuration for running small apps (e.g. Go servers). Built starting from https://github.com/nkoson/gke-tutorial, attempting to fully automate configuration and updates by bringing the whole setup into Terraform, make it possible to write tests, and configure to deploy my own services.

Budget should be well under $10/mo, all in. For details on how that's achieved see the above tutorial, but basically the idea is to use small numbers of small nodes, and avoid charges for Cloud Load Balancing (~$18/mo) by internally hosting a single Traefik ingress server and using kubeip to give it a static IP.

In principle this project would work as a template for others- a fork, change of project names, and replacing the services and routes and secrets with whatever you want to run should get a ready to deploy infrastructure. But this is a learning project, so might be broken in ways I don't know about and is certainly not using idioms effectively yet.

For dev environment requirements, you need gcloud and Terraform, with openssl and Ruby for the tests, and also see the Auth section to be able to authenticate to GCP.

Test/production environment requirements before initial deployment:

- Create the test and production GCP projects.
- Enable Cloud Resource Manager API, Cloud Storage API, and Compute Engine APIs if not already enabled, in both.
- Ensure your account has the Storage Admin permission on both projects (might be a way to narrow this down).
- For each service in services, push a Docker image of that service to each project's container registry.
- Prod only: Go to the "persistent" subfolder, create a "secrets" subfolder, add all files referenced in the various *-secrets.tf to that subfolder, and terraform apply. This creates the static IP, provides all the secrets for the cluster that I don't want in source code, and is where I can instantiate persistent stores for my services that should not be destroyed by rebuilding infrastructure, etc. In the test environment the test fixture is made to provide ephemeral resources.

With the above done it should now be possible to deploy the cluster:

- Run "bundle install" to download Kitchen-Terraform to run the tests.
- Run "bundle exec kitchen converge" to deploy the test environment to the test project.
- Run "bundle exec kitchen verify" to run tests.
- Run "bundle exec kitchen destroy" to tear down the test environment.
- If all tests passed, run "terraform init", then "terraform apply" to create/update the production environment.


Further areas of work:

- This process should be able to be performed on Cloud Build for CI/CD, but this is as yet unbuilt. It would be cool if the "persistent" setup could configure as much of this as possible.
- Tests are currently limited to end-to-end testing that the ingress IP is serving services correctly over HTTP and HTTPS with the right TLS certificates. They don't check any of the internal state achieving that.

Note that the terraform apply step cannot be *fully* tested by the test environment; changing configuration is not quite the same thing as recreating it, which is what the testing process checks, and e.g. overly full node pools can inhibit rolling update strategies. CRD changes might also cause problems if Terraform attempts to incrementally update them, although I try to prevent that from happening.  The alternative process of a full "terraform destroy" and rerun of the "terraform apply" command should produce results matching the test environment (modulo different persistent storage contents) but incurs downtime. For a personal cluster this will do for now.

Also note that Terraform does not really like having Kubernetes clusters managed in the same state that manages things deployed into those clusters. If this becomes an issue in future use, splitting /gke/ and cluster from the main module, like persistent, would be a recommended way forwards.  

### Auth

Rather than giving extra permissions to the default compute service account and retrieving a token for that per nkoson's original tutorial, this setup uses implicit authentication to Google and thus requires you have run "gcloud auth login" and "gcloud auth application-default login".

### WSL

Terraform can misbehave inside WSL2, seemingly because WSL2 lacks properly functioning IPv6 connectivity, and this seems to cause Terraform to fail to reach registry.terraform.io.

To work around this, run terraform init on Windows in all of root, persistent, and test/fixtures/tf_module, and inside WSL run terraform init -plugin-path=[path to terraform.d/plugins] in each of them.

After updating Terraform providers, it may also be necessary to run on Windows:

<code>terraform providers lock -platform=linux_amd64 -platform=windows_amd64</code>

To set all the provider hashes.