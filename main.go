//
package main

import (
	"beshir-personal-cluster/cluster"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

func main() {
	pulumi.Run(func(ctx *pulumi.Context) error {

		// Retrieve and/or prepare persistent resources.
		var persistent *persistentResources
		switch ctx.Stack() {
		case "persistent":
			// Setup stateful resources we must not destroy in normal flow (loss of user data, persistent IPs, etc)
			// We then return; this stack doesn't do anything else.
			_, err := createPersistent(ctx, false)
			if err != nil {
				return err
			}
			return nil
		case "dev":
			// Setup test versions of stateful resources.
			var err error
			persistent, err = createPersistent(ctx, true)
			if err != nil {
				return err
			}
		case "prod":
			// Import persistent resources created by the persistent stack.
			var err error
			persistent, err = getPersistent(ctx)
			if err != nil {
				return err
			}
		default:
			panic("unknown stack; persistent resources not configured")
		}

		// Create the actual Kubernetes cluster, node pools, VPC networks, and associated service accounts.
		err := cluster.Create(ctx, persistent.PersistentRoles)
		if err != nil {
			return err
		}

		return nil
	})
}
