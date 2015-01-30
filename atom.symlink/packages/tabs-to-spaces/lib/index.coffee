TabsToSpaces = null
tabsToSpaces = null

module.exports =
  config:
    onSave:
      type: 'string'
      default: 'none'
      enum: ['none', 'tabify', 'untabify']

  # Public: Activates the package.
  activate: ->
    @commands = atom.commands.add 'atom-workspace',
      'tabs-to-spaces:tabify': =>
        @loadModule()
        tabsToSpaces.tabify()

      'tabs-to-spaces:untabify': =>
        @loadModule()
        tabsToSpaces.untabify()

    @editorObserver = atom.workspace.observeTextEditors (editor) =>
      @handleEvents(editor)

  deactivate: ->
    @commands.dispose()
    @editorObserver.dispose()

  # Private: Creates event handlers.
  #
  # * `editor` {TextEditor} to attach the event handlers to
  handleEvents: (editor) ->
    editor.getBuffer().onWillSave =>
      return if editor.getPath() is atom.config.getUserConfigPath()

      switch atom.config.get(editor.getRootScopeDescriptor(), 'tabs-to-spaces.onSave')
        when 'untabify'
          @loadModule()
          tabsToSpaces.untabify()
        when 'tabify'
          @loadModule()
          tabsToSpaces.tabify()

  # Private: Loads the module on-demand.
  loadModule: ->
    TabsToSpaces ?= require './tabs-to-spaces'
    tabsToSpaces ?= new TabsToSpaces()
