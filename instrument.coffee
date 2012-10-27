define ['underscore', 'graph', 'backbone', 'instrumentor'],
(_, Graph, Backbone, Instrumentor) ->

  App = {
    Views: {}
  }
  
  class App.Views.ListItem extends Backbone.View
    events:
      'hover' : 'onHover'
      'click a[rel=delete]' : 'onDelete'
      
    initialize: ->
      @model.bind 'destroy', => $(@el).remove()

    tagName: 'li'

    onDelete: -> @model.destroy()
    onHover: -> console.log 'hovered'

    template: (o) ->
      "#{o.get('text')} <a href='#' rel='delete'>x</a>"

    render: =>
      $(@el).append @template(@options.model)
      @

  class App.Views.ListView extends Backbone.View
    initialize: ->
      @models = new Backbone.Collection([
        {text: 'Item 1'}
        {text: 'Item 2'}
        {text: 'Item 3'}
        {text: 'Item 4'}
      ])
      
      @i = 4
      @models.bind 'add', @addOne

    events:
      'click [rel=add]' : 'addModel'
    
    addModel: ->
      @i++
      @models.add {text: "Item #{@i}"}

    template:
      """
        <ul></ul>
        <a rel='add' href='#' class='btn btn-primary btn-small'>+ add item</a>
      """

    addOne: (model) =>
      @$('ul').append new App.Views.ListItem(model: model).render().el
      
    render: =>
      $(@el).html @template
      @models.each (model) => @addOne(model)
      @
     
  App.init = ->
    list = new App.Views.ListView()
    list.render()
    $('#content').append list.el

  window.App = App
  
  new Instrumentor(App)
  
  return App
