# Akeboshi_Bot

A command bot for Twitch.

## Features

At time of writing:

[this space intentionally left blank]

Additionally, this comes with a [`tree-sitter`][ts] grammar to parse commands
and generate their output. This probably isn't very useful to you unless you're
writing this bot.

[ts]: https://github.com/tree-sitter/zig-tree-sitter

### Roadmap

- [ ] Twitch support through [WSS][twitchdev], using [websocket.zig][wszig]
- [ ] Parsing of a simple command syntax, interpolating variables and functions
      through `$(var)` or `$(func arg)` syntax
- [ ] Configuration through a web portal
- [ ] A separate type of command, only editable through the web portal, to run
      arbitrary javascript through `deno`.
      - This will probably be implemented as a sort of worker pool. Workers in
        Typescript, worker manager in Typescript.

[twitchdev]: https://dev.twitch.tv/docs/eventsub/handling-websocket-events/
[wszig]: https://github.com/karlseguin/websocket.zig

## License

This project is divided into two parts, each with its own license:

1. The main project (all the zig code and most of the surrounding structure) is
   MIT licensed.
2. The "akbs" language parser located within the `tree-sitter-akbs` folder is
   0BSD licensed.
