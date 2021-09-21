package options

import (
	genericoptions "github.com/RaulZuo/deep-process/internal/pkg/options"
	cliflag "github.com/marmotedu/component-base/pkg/cli/flag"
)

// Options runs a deep-process api server.
type Options struct {
	GenericServerRunOptions *genericoptions.ServerRunOptions       `json:"server"   mapstructure:"server"`
}

// NewOptions creates a new Option object with default parameters.
func NewOptions() *Options {
	o := Options{
		GenericServerRunOptions: genericoptions.NewServerRunOptions(),
	}

	return &o
}

// Flags returns flags for a specific APIServer by section name.
func (o *Options) Flags() (fss cliflag.NamedFlagSets) {
	o.GenericServerRunOptions.AddFlags(fss.FlagSet("generic"))

	return fss
}