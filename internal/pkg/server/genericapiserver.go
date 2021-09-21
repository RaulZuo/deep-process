package server

import (
	"github.com/gin-gonic/gin"
	"github.com/marmotedu/component-base/pkg/core"
	"github.com/marmotedu/log"
	"net/http"
	"time"
)

// GenericAPIServer contains state for a iam api server.
// type GenericAPIServer gin.Engine.
type GenericAPIServer struct {
	middlewares []string
	mode        string
	// SecureServingInfo holds configuration of the TLS server.
	// TODO
	//SecureServingInfo *SecureServingInfo

	// InsecureServingInfo holds configuration of the insecure HTTP server.
	// TODO
	//InsecureServingInfo *InsecureServingInfo

	// ShutdownTimeout is the timeout used for server shutdown. This specifies the timeout before server
	// gracefully shutdown returns.
	ShutdownTimeout time.Duration

	*gin.Engine
	healthz         bool
	// TODO
	//enableMetrics   bool
	//enableProfiling bool
	// wrapper for gin.Engine

	insecureServer, secureServer *http.Server
}

func initGenericAPIServer(s *GenericAPIServer) {
	// do some setup
	// s.GET(path, ginSwagger.WrapHandler(swaggerFiles.Handler))

	s.Setup()
	// TODO
	//s.InstallMiddlewares()
	s.InstallAPIs()
}

// InstallAPIs install generic apis.
func (s *GenericAPIServer) InstallAPIs() {
	// install healthz handler
	if s.healthz {
		s.GET("/healthz", func(c *gin.Context) {
			core.WriteResponse(c, nil, map[string]string{"status": "ok"})
		})
	}

	// TODO
	//// install metric handler
	//if s.enableMetrics {
	//	prometheus := ginprometheus.NewPrometheus("gin")
	//	prometheus.Use(s.Engine)
	//}
	//
	//// install pprof handler
	//if s.enableProfiling {
	//	pprof.Register(s.Engine)
	//}

	//s.GET("/version", func(c *gin.Context) {
	//	core.WriteResponse(c, nil, version.Get())
	//})
}

// Setup do some setup work for gin engine.
func (s *GenericAPIServer) Setup() {
	gin.SetMode(s.mode)
	gin.DebugPrintRouteFunc = func(httpMethod, absolutePath, handlerName string, nuHandlers int) {
		log.Infof("%-6s %-s --> %s (%d handlers)", httpMethod, absolutePath, handlerName, nuHandlers)
	}
}

