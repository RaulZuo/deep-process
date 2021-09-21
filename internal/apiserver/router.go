package apiserver

import "github.com/gin-gonic/gin"

func initRouter(g *gin.Engine) {
	installMiddleware(g)
	installAPI(g)
}

func installMiddleware(g *gin.Engine) {}

func installAPI(g *gin.Engine) *gin.Engine {
	return g
}