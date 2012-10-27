define ['graph', 'underscore'],
(Graph, _) ->
  _.isConstructor = (thing) ->
    if thing.name && thing.name[0].toUpperCase() == thing.name[0]
      true
    else
      false

  class Instrumentor
    constructor: (namespace) ->
      @dontInstrument = ['constructor', '_configure', 'make', 'initialize', 'delegateEvents', 'undelegateEvents', 'setElement']
      @nodes = []
      @links = []
      @instrument(namespace)

    addLink: (from, to) ->
      @links.push { source: from.id, target: to.id, value: 1 }
      
    nextNodeId: ->
      if @nodes.length == 0
        0
      else
        _(@nodes).last().id + 1

    addNode: (name, type, parent=null) =>
      node = {
        id: @nextNodeId()
        name: name
        group: type
      }
      @nodes.push node
      @addLink(parent, node) if parent
      @graph.updateNodes(@nodes, @links) if @graph and @graph.rendered 
      node

    trigger: (node) =>
      @graph.triggerNode(node)
      console.log('triggered', node)

    instrument: (namespace) ->
      @instrumentObject(null, 'App', namespace)
      @graph = new Graph(@nodes, @links).render()
    
    instrumentConstructor: (parentNode, cons) =>
      node = @addNode(cons.name, 'function', parentNode)
      trigger = @trigger
      addNode = @addNode
      instrumentObject = @instrumentObject

      newCons = (args...) ->
        o = cons.apply(@, args)
        trigger node
        o

      newCons.prototype = @instrumentObject(node, cons.name, cons.prototype)
      newCons

    instrumentFunction: (parentNode, name, func) =>
      node = @addNode(name, 'function', parentNode)
      trigger = @trigger

      return (args...) ->
        trigger(node)
        console.log("Calling", name)
        func.apply(@, args)

    instrumentObject: (parentNode, name, object) =>
      node = @addNode(name||'Anon', 'object', parentNode)
      
      for key, val of object
        do (key, val) =>
          if (object.hasOwnProperty(key)) or (object.__proto__.hasOwnProperty(key))
            unless _(@dontInstrument).include(key) || key[0] == '_'
              if _.isFunction(val)
                if _.isConstructor(val)
                  object[key] = @instrumentConstructor(node, val)
                else
                  object[key] = @instrumentFunction(node, key, val)
              else if _.isObject(val)
                object[key] = @instrumentObject(node, key, val)
      object

  return Instrumentor
