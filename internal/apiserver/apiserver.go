// Package apiserver does all of the work necessary to create a DeepProcess APIserver.
package apiserver

import (
	"github.com/RaulZuo/deep-process/pkg/app"
)

const commandDesc = `The IAM API server validates and configures data
for the api objects which include users, policies, secrets, and
others. The API Server services REST operations to do the api objects management.`

// NewAPP creates a App object with default parameters.
func NewApp(basename string) *app.App {
	application := app.NewApp("DEEPPROCESS API Server",
		basename,
	)

	return application
}

func run() {}