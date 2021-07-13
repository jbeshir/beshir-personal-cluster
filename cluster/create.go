// Package cluster handles creating the k8s cluster, its node pools, VPC networks, and associated service accounts.
package cluster

import "github.com/pulumi/pulumi/sdk/v3/go/pulumi"

// Create defines the k8s cluster, its node pools, VPC networks, and its associated service accounts.
func Create(ctx *pulumi.Context, roles *PersistentRoles) error {
	_, err := createServiceAccounts(ctx, roles)
	if err != nil {
		return err
	}

	return nil
}
