require ['underscore', 'graph', 'backbone', 'instrumentor'],
(_, Graph, Backbone, Instrumentor) ->
  window.App = {
    Views: {}
  }
  
  class App.Views.ListItem extends Backbone.View
    events:
      'hover' : 'onHover'
      'click' : 'onClick'

    tagName: 'li'

    onHover: ->
      console.log 'hovered'

    onClick: ->
      console.log 'click'

    render: =>
      console.log @options
      $(@el).append @options.model.get('text')
      @

  class App.Views.ListView extends Backbone.View
    tagName: 'ul'
    initialize: ->
      @models = new Backbone.Collection([
        {text: 'Hi'}
        {text: 'There'}
        {text: 'Boo'}
        {text: 'Yah'}
      ])

    render: ->
      @models.each (model) =>
        $(@el).append new App.Views.ListItem(model: model).render().el
      @
     
  App.init = ->
    list = new App.Views.ListView()
    list.render()
    console.log list
    $('#content').append list.el

  
  new Instrumentor(App)

  App.init()
