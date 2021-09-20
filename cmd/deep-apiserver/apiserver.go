// apiserver is the api server for deep-apiserver service.
// it is responsible for serving the platform RESTful resource management.

package main

import (
	"math/rand"
	"os"
	"runtime"
	"time"
)

func main() {
	rand.Seed(time.Now().UTC().UnixNano())
	if len(os.Getenv("GOMAXPROCS")) == 0 {
		runtime.GOMAXPROCS(runtime.NumCPU())
	}

	//apiserver.NewApp("deep-apiserver").Run()
}