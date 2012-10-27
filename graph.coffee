define ['d3'],
(d3) ->

  class Graph
    constructor: (nodes, links) ->
      @height = 600
      @width = 430
      @nodes = nodes
      @links = links
      @rendered = false

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


      console.log legend
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
  
    triggerNode: (node) ->
      updated = @node.data([node], (d)->d.id)
      updated.selectAll('circle')
        .transition().duration(200)
        .attr('r', 25)
        .transition().delay(200).duration(200)
          .attr('r', 5)

    updateNodes: (nodes, links) ->
      @nodes = nodes
      @links = links
      @setupGraph()

  return Graph
