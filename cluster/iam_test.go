package cluster

import (
	"beshir-personal-cluster/test/mock"
	"github.com/golang/mock/gomock"
	"github.com/pulumi/pulumi-gcp/sdk/v5/go/gcp/projects"
	"github.com/pulumi/pulumi/sdk/v3/go/common/resource"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
	"sync"
	"testing"
)

func TestSingleRoleServiceAccount(t *testing.T) {
	ctrl := gomock.NewController(t)
	mockPulumi := mock.NewMockMockResourceMonitor(ctrl)
	mockPulumi.EXPECT().NewResource(gomock.Any()).DoAndReturn(func(args pulumi.MockResourceArgs) (string, resource.PropertyMap, error) {
		outputs := args.Inputs.Mappable()

		// Provide the email so we can test we use it properly to setup the IAMMember resource.
		if args.TypeToken == "gcp:serviceAccount/account:Account" {
			outputs["email"] = args.Name + "@example.invalid"
		}

		return args.Name + "_id", resource.NewPropertyMapFromMap(outputs), nil
	}).AnyTimes()

	pulumi.Run(func(ctx *pulumi.Context) error {

		fooRole, err := projects.NewIAMCustomRole(ctx, "foo", &projects.IAMCustomRoleArgs{
			Description: pulumi.String("foo"),
			Permissions: pulumi.StringArray{},
			RoleId:      pulumi.String("foo"),
			Title:       pulumi.String("foo"),
		})
		if err != nil {
			t.Fatalf("unable to create test role: %v", err)
		}

		cases := []struct {
			TestName string
			ID       string
			Name     string
			Role     *projects.IAMCustomRole
			Err      error
		}{
			{
				TestName: "simple case",
				ID:       "foo",
				Name:     "Foo",
				Role:     fooRole,
				Err:      nil,
			},
			{
				TestName: "missing role",
				ID:       "foo",
				Name:     "Foo",
				Role:     nil,
				Err:      IAMCustomRoleNil,
			},
		}

		for _, c := range cases {
			t.Run(c.TestName, func(t *testing.T) {
				sa, member, err := singleRoleServiceAccount(ctx, c.ID, c.Name, c.Role)
				if err != c.Err {
					t.Errorf("singleRoleServiceAccount(ctx, %q, %q, %p) gave err %q, expected %q", c.ID, c.Name, c.Role, c.Err, err)
					if sa != nil {
						t.Errorf("singleRoleServiceAccount(ctx, %q, %q, %p) gave non-nil account with err %q, expected nil result", c.ID, c.Name, c.Role, err)
					}
					if member != nil {
						t.Errorf("singleRoleServiceAccount(ctx, %q, %q, %p) gave non-nil member with err %q, expected nil result", c.ID, c.Name, c.Role, err)
					}
				}

				if err == nil {
					if sa == nil {
						t.Errorf("singleRoleServiceAccount(ctx, %q, %q, %p) gave nil account with nil err, expected non-nil result", c.ID, c.Name, c.Role)
					} else {

						var wg sync.WaitGroup
						wg.Add(2)

						sa.AccountId.ApplyT(func(id string) string {
							if id != c.ID {
								t.Errorf("singleRoleServiceAccount(ctx, %q, %q, %p) gave account with ID %q, expected %q", c.ID, c.Name, c.Role, id, c.ID)
							}
							wg.Done()
							return id
						})

						sa.DisplayName.ApplyT(func(name *string) *string {
							if name == nil {
								t.Errorf("singleRoleServiceAccount(ctx, %q, %q, %p) gave account with nil name", c.ID, c.Name, c.Role)
							} else {
								if *name != c.Name {
									t.Errorf("singleRoleServiceAccount(ctx, %q, %q, %p) gave account with name %q, expected %q", c.ID, c.Name, c.Role, *name, c.Name)
								}
							}
							wg.Done()
							return name
						})

						wg.Wait()
					}

					if member == nil {
						t.Errorf("singleRoleServiceAccount(ctx, %q, %q, %p) gave nil member with nil err, expected non-nil result", c.ID, c.Name, c.Role)
					} else {
						var wg sync.WaitGroup
						wg.Add(1)

						pulumi.All(member.Member, sa.Email).ApplyT(func(all []interface{}) error {
							member, saEmail := all[0].(string), all[1].(string)
							if saEmail == "" {
								t.Errorf("singleRoleServiceAccount(ctx, %q, %q, %p) created account with empty email", c.ID, c.Name, c.Role)
							}

							expected := "serviceAccount:" + saEmail
							if member != expected {
								t.Errorf("singleRoleServiceAccount(ctx, %q, %q, %p) created binding to member %q, expected %q", c.ID, c.Name, c.Role, member, expected)
							}

							wg.Done()
							return nil
						})

						wg.Wait()
					}
				}
			})
		}

		return nil
	}, pulumi.WithMocks("project", "stack", mockPulumi))
}
