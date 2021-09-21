package config

import "github.com/RaulZuo/deep-process/internal/apiserver/options"

// Config is the running configuration structure of the DEEP_PROCESS pump service.
type Config struct {
	*options.Options
}

func CreateConfigFromOptions(opts *options.Options) (*Config, error)  {
	return &Config{opts}, nil
}