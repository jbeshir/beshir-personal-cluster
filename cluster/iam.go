package cluster

import (
	"errors"
	"fmt"
	"github.com/pulumi/pulumi-gcp/sdk/v5/go/gcp/projects"
	"github.com/pulumi/pulumi-gcp/sdk/v5/go/gcp/serviceaccount"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

var IAMCustomRoleNil = errors.New("iam custom role must not be nil")

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
	sa.Node, _, err = singleRoleServiceAccount(ctx, "cluster_node", "Cluster Node", roles.Node)
	if err != nil {
		return nil, err
	}

	sa.Kubeip, _, err = singleRoleServiceAccount(ctx, "kubeip", "Kubeip", roles.Kubeip)
	if err != nil {
		return nil, err
	}

	return sa, nil
}

// singleRoleServiceAccount creates a service account with the given ID, name, and custom role.
func singleRoleServiceAccount(ctx *pulumi.Context, id, name string, role *projects.IAMCustomRole) (*serviceaccount.Account, *projects.IAMMember, error) {
	if role == nil {
		return nil, nil, IAMCustomRoleNil
	}

	sa, err := serviceaccount.NewAccount(ctx, id+"_service_account", &serviceaccount.AccountArgs{
		AccountId:   pulumi.String(id),
		DisplayName: pulumi.String(name),
	})
	if err != nil {
		return nil, nil, err
	}

	member, err := projects.NewIAMMember(ctx, id+"_service_account_iam_member", &projects.IAMMemberArgs{
		Member: sa.Email.ApplyT(func(email string) (string, error) {
			return fmt.Sprintf("%v%v", "serviceAccount:", email), nil
		}).(pulumi.StringOutput),
		Role: role.Name,
	})
	if err != nil {
		return nil, nil, err
	}

	return sa, member, nil
}
