package app

import cliflag "github.com/marmotedu/component-base/pkg/cli/flag"

// CliOptions abstracts configurations options for reading parameters from the command line.
type CliOptions interface {
	Flags() (fss cliflag.NamedFlagSets)
	Validate() []error
}