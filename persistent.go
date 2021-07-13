package main

import (
	"beshir-personal-cluster/cluster"
	"github.com/pulumi/pulumi-gcp/sdk/v5/go/gcp/projects"
	"github.com/pulumi/pulumi-random/sdk/v4/go/random"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

const clusterNodeRoleProdID = pulumi.ID("cluster_node")
const kubeipRoleProdID = pulumi.ID("kubeip")

// persistentResources contains all resources that should be setup once and not destroyed+recreated during upgrades.
// This includes IAM roles, buckets, etc.
type persistentResources struct {
	*cluster.PersistentRoles
}

// createPersistent creates persistent resources that may contain state and aren't safe to tear down and recreate.
// It should be run on a separate stack in the same GCP project as other resources,
// and its created resources made available in the normal stack via getPersistent.
//
// Given the test flag, it creates transient "mock" persistent resources instead, which may be used directly.
func createPersistent(ctx *pulumi.Context, test bool) (*persistentResources, error) {
	pr := new(persistentResources)

	var err error
	pr.PersistentRoles, err = createPersistentRoles(ctx, test)
	if err != nil {
		return nil, err
	}

	return pr, nil
}

// createPersistentRoles creates all the GCP IAM roles used in the project.
func createPersistentRoles(ctx *pulumi.Context, test bool) (*cluster.PersistentRoles, error) {
	roles := new(cluster.PersistentRoles)

	var err error
	roles.Node, err = createPersistentRole(ctx, test, "cluster_node", "Cluster Node Role",
		clusterNodeRoleProdID, pulumi.StringArray{
			pulumi.String("compute.addresses.list"),
			pulumi.String("compute.instances.addAccessConfig"),
			pulumi.String("compute.instances.deleteAccessConfig"),
			pulumi.String("compute.instances.get"),
			pulumi.String("compute.instances.list"),
			pulumi.String("compute.projects.get"),
			pulumi.String("container.clusters.get"),
			pulumi.String("container.clusters.list"),
			pulumi.String("resourcemanager.projects.get"),
			pulumi.String("compute.networks.useExternalIp"),
			pulumi.String("compute.subnetworks.useExternalIp"),
			pulumi.String("compute.addresses.use"),
			pulumi.String("resourcemanager.projects.get"),
			pulumi.String("storage.objects.get"),
			pulumi.String("storage.objects.list"),

			// Needed if the Monitoring API is turned on.
			pulumi.String("monitoring.metricDescriptors.create"),
			pulumi.String("monitoring.metricDescriptors.get"),
			pulumi.String("monitoring.metricDescriptors.list"),
			pulumi.String("monitoring.monitoredResourceDescriptors.get"),
			pulumi.String("monitoring.monitoredResourceDescriptors.list"),
			pulumi.String("monitoring.timeSeries.create"),

			// Needed for logging; allows logging to be easily enabled later.
			pulumi.String("logging.logEntries.create"),
		})
	if err != nil {
		return nil, err
	}

	roles.Kubeip, err = createPersistentRole(ctx, test, "kubeip", "Kubeip Role",
		kubeipRoleProdID, pulumi.StringArray{
			pulumi.String("compute.addresses.list"),
			pulumi.String("compute.instances.addAccessConfig"),
			pulumi.String("compute.instances.deleteAccessConfig"),
			pulumi.String("compute.instances.get"),
			pulumi.String("compute.instances.list"),
			pulumi.String("compute.projects.get"),
			pulumi.String("container.clusters.get"),
			pulumi.String("container.clusters.list"),
			pulumi.String("resourcemanager.projects.get"),
			pulumi.String("compute.networks.useExternalIp"),
			pulumi.String("compute.subnetworks.useExternalIp"),
			pulumi.String("compute.addresses.use"),
		})
	if err != nil {
		return nil, err
	}

	return roles, nil
}

// createPersistentRole handles the creation of an IAM role appropriately for either test or non-test environments.
// Test environments get a randomly generated role ID, ensuring they won't conflict with deleted roles.
// Non-test environments don't- it's required they set their persistent state up and don't subsequently destroy it.
func createPersistentRole(ctx *pulumi.Context, test bool, idPrefix, name string, prodRoleID pulumi.StringInput, permissions pulumi.StringArray) (*projects.IAMCustomRole, error) {
	var roleID pulumi.StringInput
	if test {
		id, err := random.NewRandomId(ctx, idPrefix+"_role_id", &random.RandomIdArgs{
			ByteLength: pulumi.Int(16),
		})
		if err != nil {
			return nil, err
		}
		roleID = id.Hex
	} else {
		roleID = prodRoleID
	}

	role, err := projects.NewIAMCustomRole(ctx, idPrefix+"_role", &projects.IAMCustomRoleArgs{
		Description: pulumi.String(name),
		Permissions: permissions,
		RoleId:      roleID,
		Title:       pulumi.String(name),
	})
	if err != nil {
		return nil, err
	}

	return role, nil
}

// getPersistent retrieves references to already existing persistent resources created outside the current stack.
func getPersistent(ctx *pulumi.Context) (*persistentResources, error) {
	pr := new(persistentResources)

	pr.PersistentRoles = new(cluster.PersistentRoles)
	var err error
	pr.PersistentRoles.Node, err = projects.GetIAMCustomRole(ctx, "cluster_node_role", clusterNodeRoleProdID, nil, nil)
	if err != nil {
		return nil, err
	}
	pr.PersistentRoles.Kubeip, err = projects.GetIAMCustomRole(ctx, "kubeip_role", kubeipRoleProdID, nil, nil)
	if err != nil {
		return nil, err
	}

	return pr, nil
}
