// Package apiserver does all of the work necessary to create a DeepProcess APIserver.
package apiserver

import (
	"github.com/RaulZuo/deep-process/internal/apiserver/config"
	"github.com/RaulZuo/deep-process/internal/apiserver/options"
	"github.com/RaulZuo/deep-process/pkg/app"
)

const commandDesc = `The IAM API server validates and configures data
for the api objects which include users, policies, secrets, and
others. The API Server services REST operations to do the api objects management.`

// NewAPP creates a App object with default parameters.
func NewApp(basename string) *app.App {
	opts := options.NewOptions()
	application := app.NewApp("DEEP_PROCESS API Server",
		basename,
		app.WithOptions(opts),
		app.WithDescription(commandDesc),
		app.WithDefaultValidArgs(),
		app.WithRunFunc(run(opts)),
	)

	return application
}

func run(opts *options.Options) app.RunFunc {
	return func(basename string) error {
		cfg, err := config.CreateConfigFromOptions(opts)
		if err != nil {
			return err
		}

		return Run(cfg)
	}
}