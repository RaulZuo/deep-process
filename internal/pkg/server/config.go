package server

import "github.com/gin-gonic/gin"

// Config is a structure used to configure a GenericAPIServer.
// Its members are sorted roughly in order of importance for composers.
type Config struct {
	//SecureServing   *SecureServingInfo
	//InsecureServing *InsecureServingInfo
	//Jwt             *JwtInfo
	Mode            string
	Middlewares     []string
	Healthz         bool
	//EnableProfiling bool
	//EnableMetrics   bool
}

// NewConfig returns a Config struct with the default values.
func NewConfig() *Config {
	return &Config{
		Mode: 		 gin.ReleaseMode,
		Middlewares: []string{},
		Healthz: 	 true,
	}
}

// CompletedConfig is the completed configuration for GenericAPIServer.
type CompletedConfig struct {
	*Config
}

// Complete fills in any fields not set that are required to have valid data and can be derived
// from other fields. If you're going to `ApplyOptions`, do that first. It's mutating the receiver.
func (c *Config) Complete() CompletedConfig {
	return CompletedConfig{c}
}

// New returns a new instance of GenericAPIServer from the given config.
func (c CompletedConfig) New() (*GenericAPIServer, error) {
	s := &GenericAPIServer{
		//SecureServingInfo:   c.SecureServing,
		//InsecureServingInfo: c.InsecureServing,
		mode:                c.Mode,
		healthz:             c.Healthz,
		//enableMetrics:       c.EnableMetrics,
		//enableProfiling:     c.EnableProfiling,
		middlewares:         c.Middlewares,
		Engine:              gin.New(),
	}

	initGenericAPIServer(s)

	return s, nil
}
