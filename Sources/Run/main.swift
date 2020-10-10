import Vapor
import App

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)

let app = Application(env)
defer { app.shutdown() }
app.commands.defaultCommand = ProgressCommand()
app.commands.use(ProgressCommand(), as: "progress")
try app.run()
