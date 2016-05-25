# xtext-vscode
Initial prototyping of [Visual Studio Code](http://code.visualstudio.com) integration for [Xtext](http://xtext.org).
The main purpose is to play around with VSCode's Language Server API.

## How to Run the Integration

The Xtext language server accepts socket connections to localhost port 5007. The included example VS Code extension uses Node.js to connect with the Xtext server.

 1. Do `./gradlew run` to start the server.
 2. Run `npm install` in `vscode-extension`.
 3. Open the project `vscode-extension` in VS Code, build the project, and press F5 to start a new instance including the extension.
 4. Create a file with extension `.statemachine` to start a client for the State Machine example language.
