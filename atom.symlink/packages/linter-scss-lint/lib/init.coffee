{CompositeDisposable} = require 'atom'
{findFile, exec, tempFile} = helpers = require "atom-linter"
path = require 'path'

module.exports =
  config:
    additionalArguments:
      title: 'Additional Arguments'
      type: 'string'
      default: ''
    executablePath:
      title: 'Executable Path'
      type: 'string'
      default: ''

  activate: ->
    console.log 'activate linter-scss-lint'
    @subs = new CompositeDisposable
    @subs.add atom.config.observe 'linter-scss-lint.executablePath',
      (executablePath) =>
        @executablePath = executablePath
    @subs.add atom.config.observe 'linter-scss-lint.additionalArguments',
      (additionalArguments) =>
        @additionalArguments = additionalArguments
  deactivate: ->
    @subs.dispose()
  provideLinter: ->
    provider =
      grammarScopes: ['source.css.scss', 'source.scss']
      scope: 'file'
      lintOnFly: yes
      lint: (editor) =>
        filePath = editor.getPath()
        tempFile path.basename(filePath), editor.getText(), (tmpFilePath) =>
          config = findFile path.dirname(filePath), '.scss-lint.yml'
          params = [
            tmpFilePath,
            "--format=JSON",
            if config? then "--config=#{config}",
            @additionalArguments.split(' ')...
          ].filter((e) -> e)
          throw new TypeError(
            "Error linting #{filePath}: No 'scss-lint' executable specified"
          ) if @executablePath is ''
          return helpers.exec(@executablePath, params).then (stdout) ->
            lint = try JSON.parse stdout
            throw new TypeError(stdout) unless lint?
            return [] unless lint[tmpFilePath]
            return lint[tmpFilePath].map (msg) ->
              line = (msg.line || 1) - 1
              col = (msg.column || 1) - 1

              type: msg.severity || 'error',
              text: (msg.reason || 'Unknown Error') +
                (if msg.linter then " (#{msg.linter})" else ''),
              filePath: filePath,
              range: [[line, col], [line, col + (msg.length || 0)]]
