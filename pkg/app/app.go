package app

// App is the main construct of a cli application.
// It is recommended that an app be created with the app.NewApp() function.
type App struct {
	basename	string
	name		string
	description string
	//options     CliOptions
	//runFunc     RunFunc
	silence		bool
	noVersion	bool
	noConfig	bool
	//commands    []*Command
	//args		cobra.PositionalArgs
	//cmd 		*cobra.Command
}

// Option defines optional parameters for initializing the application structure.
type Option func(*App)

// NewApp creates a new application instance based on the given application name,
// binary name, and other options.
func NewApp(name string, basename string, opts ...Option) *App {
	a := &App{
		name:	  name,
		basename: basename,
	}

	for _, o := range opts {
		o(a)
	}

	//a.buildCommand();
	return a
}