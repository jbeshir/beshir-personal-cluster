package cluster

import (
	"fmt"
	"github.com/pulumi/pulumi-gcp/sdk/v5/go/gcp/projects"
	"github.com/pulumi/pulumi-gcp/sdk/v5/go/gcp/serviceaccount"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

// PersistentRoles provides roles that the cluster package uses to set up its service accounts.
type PersistentRoles struct {
	Node   *projects.IAMCustomRole
	Kubeip *projects.IAMCustomRole
}

type serviceAccounts struct {
	Node   *serviceaccount.Account
	Kubeip *serviceaccount.Account
}

// createServiceAccounts creates the service accounts needed by the cluster and its ingress services,
// along with assigning their IAM roles.
func createServiceAccounts(ctx *pulumi.Context, roles *PersistentRoles) (*serviceAccounts, error) {
	sa := new(serviceAccounts)

	var err error
	sa.Node, err = serviceaccount.NewAccount(ctx, "cluster_node_service_account", &serviceaccount.AccountArgs{
		AccountId:   pulumi.String("cluster-node"),
		DisplayName: pulumi.String("Cluster Node"),
	})
	if err != nil {
		return nil, err
	}

	_, err = projects.NewIAMMember(ctx, "cluster_node_service_account_iam_member", &projects.IAMMemberArgs{
		Member: sa.Node.Email.ApplyT(func(email string) (string, error) {
			return fmt.Sprintf("%v%v", "serviceAccount:", email), nil
		}).(pulumi.StringOutput),
		Role: roles.Node.Name,
	})
	if err != nil {
		return nil, err
	}

	sa.Kubeip, err = serviceaccount.NewAccount(ctx, "kubeip_service_account", &serviceaccount.AccountArgs{
		AccountId:   pulumi.String("kubeip"),
		DisplayName: pulumi.String("Kubeip"),
	})
	if err != nil {
		return nil, err
	}

	_, err = projects.NewIAMMember(ctx, "kubeip_service_account_iam_member", &projects.IAMMemberArgs{
		Member: sa.Kubeip.Email.ApplyT(func(email string) (string, error) {
			return fmt.Sprintf("%v%v", "serviceAccount:", email), nil
		}).(pulumi.StringOutput),
		Role: roles.Kubeip.Name,
	})
	if err != nil {
		return nil, err
	}

	return sa, nil
}
