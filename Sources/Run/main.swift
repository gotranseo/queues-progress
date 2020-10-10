import App
import ConsoleKit
import Foundation
import NIO

let console: Console = Terminal()
var input = CommandInput(arguments: CommandLine.arguments)
var context = CommandContext(console: console, input: input)

var commands = Commands(enableAutocomplete: false)
commands.use(ProgressCommand(), as: "progress", isDefault: true)

do {
    let group = commands.group(help: "A CLI for viewing data on your Redis queue jobs.")
    try console.run(group, input: input)
} catch let error {
    console.error("\(error)")
    exit(1)
}
