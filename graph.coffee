define ['d3'],
(d3) ->

  class Graph
    constructor: (nodes, links) ->
      @height = 600
      @width = 430
      @nodes = nodes
      @links = links
      @rendered = false
      @animateSequentially = true

    setupForce: ->
      @force = d3.layout.force()
                .charge(-200)
                .linkDistance(30)
                .size([@width, @height])

    setupSVG: ->
      @svg = d3.select('#chart').append('svg')
        .attr('width', @width)
        .attr('height', @height)

    setupLegend: ->
      legend = @svg.append('svg:g')
                .attr('class', 'legend')
                .attr('transform', "translate(20,20)")

      items = [{t: 'object'}, {t:'function'}, {t:'constructor'}, {t:'instantiation'}]

      litems = legend.selectAll('.legend-item')
                  .data(items)
                .enter().append('svg:g')
                  .attr('class', (d) -> d.t + ' legend-item')

      litems.append('circle')
              .attr('r', 5)

      litems.append('text')
              .text( (d) -> d.t)
              .attr('dy', 5)
              .attr('dx', 10)

      litems.attr('transform', (d,i) -> "translate(0, #{i*20})")
              #.attr('dy', (d,i) -> i*1.2+'em')
    
      controls = @svg.append('svg:g')
                  .attr('class', 'controls')
                  .attr('transform', 'translate(410,20)')

      that = @
      controls.append('circle')
                .attr('r', 5)
                .style('stroke', '#000000')
                .style('fill', 'black')
                .style('stroke-width', 1)
      controls.append('text')
                .text('Slow animations')
                .style('text-anchor', 'end')
                .attr('x', -10)
                .attr('dy', 4)

      controls.on('click', ->
        circle = d3.select(@).select('circle')
        if that.animateSequentially
          that.animateSequentially = false
          circle.style('fill', 'black')
        else
          that.animateSequentially = true
          circle.style('fill', 'white')
      )

    setupGraph: ()->
      @force.nodes(@nodes)
            .links(@links)

      @link = @svg.selectAll('line.link')
                .data(@links, (d) -> "#{d.source.id}-#{d.target.id}")

      enteredLinks = @link.enter()
      
      enteredLinks.append('line')
                  .attr('class', 'link')
                  .style('stroke-width', 2)

      @node = @svg.selectAll('.node')
                  .data(@nodes, (d) -> d.id)

      entered = @node.enter().append('g')
                  .attr('class', (d) -> c="node #{d.group}")
                  .call(@force.drag)

      entered.append('circle')
          .attr('class', 'node')
          .attr('cx', 0)
          .attr('cy', 0)
          .attr('r', 5)

      
      entered.append('text')
            .attr('dx', 0)
            .attr('dy', '1.2em')
            .text( (d)->d.name )

      @force.start()

    onTick: ->
      @force.on 'tick', (t) =>
        @link.attr('x1', (d) -> d.source.x)
              .attr('y1', (d) -> d.source.y)
              .attr('x2', (d) -> d.target.x)
              .attr('y2', (d) -> d.target.y)

        @node.attr('transform', (d) -> "translate(#{d.x}, #{d.y})")

    render: ->
      @setupForce()
      @setupSVG()
      @setupLegend()
      @setupGraph()
      @onTick()
      @rendered = true
      @
  
    triggers: []
    queueTrigger: (node) ->
      if @triggers.length == 0
        @triggers.push(node)
        @animateQueue()
      else
        @triggers.push(node)

    triggerNode: (node) ->
      @queueTrigger(node)

    animateQueue: () =>
      node = @triggers[0]
      if node
        updated = @node.data([node], (d)->d.id)
        
        updated.append('circle')
              .attr('class', 'ring')
              .attr('r', 10)
              .attr('cx', 0)
              .attr('cy', 0)
              .attr('opacity', 1)
            .transition().duration(2000)
              .attr('r', 20)
              .attr('opacity', 0)

        if @animateSequentially
          updated.selectAll('circle.node')
            .transition().duration(100)
            .attr('r', 25)
            .transition().delay(100).duration(100)
              .attr('r', 5)
              .each('end', => @triggers.shift(); @animateQueue())
        else
          updated.selectAll('circle.node')
            .transition().duration(100)
            .attr('r', 25)
            .transition().delay(100).duration(100)
              .attr('r', 5)
          @triggers.shift()
          @animateQueue()

    updateNodes: (nodes, links) ->
      @nodes = nodes
      @links = links
      @setupGraph()

  return Graph
