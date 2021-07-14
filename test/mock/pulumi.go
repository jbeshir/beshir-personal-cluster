// Package mock provides mock implementations for testing.
package mock

// https://github.com/golang/mock/issues/494
import (
	"github.com/golang/mock/gomock"
	_ "github.com/golang/mock/mockgen/model"
	"github.com/pulumi/pulumi/sdk/v3/go/common/resource"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

// Produce a Pulumi MockResourceMonitor mock.
//go:generate mockgen -package mock -destination pulumi_mocks.go github.com/pulumi/pulumi/sdk/v3/go/pulumi MockResourceMonitor

// AddPulumiDefaultStubs adds defaults to a Pulumi mock which cause it to accept unexpected calls.
// It can be used after attaching other expectations, if we don't want to make claims about all calls that exist,
// but want to provide e.g. some outputs for some.
func AddPulumiDefaultStubs(ctrl *gomock.Controller, m *MockMockResourceMonitor) {
	m.EXPECT().NewResource(gomock.Any()).DoAndReturn(func(args pulumi.MockResourceArgs) (string, resource.PropertyMap, error) {
		return args.Name + "_id", args.Inputs, nil
	}).AnyTimes()

	m.EXPECT().Call(gomock.Any()).DoAndReturn(func(args pulumi.MockCallArgs) (resource.PropertyMap, error) {
		return args.Args, nil
	}).AnyTimes()
}
