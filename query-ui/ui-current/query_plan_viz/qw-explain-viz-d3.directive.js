/**
 * Angular directive to convert JSON into HTML tree. Inspired by Brian Park's
 * MIT Licensed "angular-json-human.js" which turns JSON to HTML tables.
 *
 *  Extended for trees by Eben Haber at Couchbase.
 *
 *  This class takes a JS object or JSON string, and displays it as an HTML
 *  table. Generally, it expects an array of something. If it's an array of objects,
 *  then each row corresponds to one object, and the columns are the union of all
 *  fields of the objects. If an object doesn't have a field, that cell is blank.
 *
 *
 *  , which object members indented. This is similar to pretty-printing
 *  JSON, but is more compact (no braces or commas), and permits using colors
 *  to highlight field names vs. values, and one line from the next.
 *
 *  For usage, see the header to qw-json-table.
 */
/* global _, angular */
(function() {

  'use strict';
  angular.module('qwExplainVizD3', []).directive('qwExplainVizD3', ['$compile', '$timeout', 'qwQueryService', getD3Explain]);

  var queryService = null;

  function getD3Explain($compile,$timeout, qwQueryService) {
    queryService = qwQueryService;
    return {
      restrict: 'A',
      scope: { data: '=qwExplainVizD3' },
      template: '<div></div>',
      link: function (scope, element) {

        scope.$watch('data', function (data) {
          // start with an empty div, if we have data convert it to HTML
          var content = "<div>{}</div>";
          if (data) {
            //console.log("Got data: " + JSON.stringify(data));
            content = "";

            if (_.isString(data))
              content = '<p class="error">' + data + '</p>';
            else if (data.data_not_cached)
              content = '<p class="error">' + JSON.stringify(data) + '</p>';

            // summarize plan in panel at the top
            if (data.analysis) {
              content += "<div class='row items-top qw-explain-summary indent-1'>";
              content += "<div class='column'>";
              content += "<h5>Indexes</h5>";
//              content += "<li>Indexes used: <ul>";
              for (var f in data.analysis.indexes)
                if (f.indexOf("#primary") >= 0)
                  content += "<em class='cbui-plan-expensive'>" + f + "</em>&nbsp;&nbsp; ";
                else
                  content += "<em>" + f + "</em>&nbsp;&nbsp; ";
              content += "</div>";

              content += "<div class='column'>";
              content += "<h5>Buckets</h5>";
              for (var b in data.analysis.buckets)
                content += "<em>" + b + "</em>&nbsp;&nbsp; ";
              content += "</div>";

              content += "<div class='column'>";
              content += "<h5>Fields</h5>";
              for (var f in data.analysis.fields)
                content += "<em>" + f + "</em>&nbsp;&nbsp; ";
              content += "</div>";

              content += "<div class='column text-right nowrap'>";
              content += '<a ng-click="zoomIn()"><span class="icon fa-search"></span></a>';
              content += '<a ng-click="zoomOut()"><span class="icon fa-search fa-2x"></span></a>';
              content += "</div>";

              content += "<div class='column text-right nowrap'>";
              content += '<a ng-click="bottomTop()"><span class="icon fa-caret-square-o-down fa-2x"></span></a>';
              content += '<a ng-click="rightLeft()"><span class="icon fa-caret-square-o-right fa-2x"></span></a>';
              content += '<a ng-click="topDown()"><span class="icon fa-caret-square-o-up fa-2x"></span></a>';
              content += '<a ng-click="leftRight()"><span class="icon fa-caret-square-o-left fa-2x"></span></a>';
              content += "</div>";

              content += "</div>";

              scope.topDown = topDown;
              scope.leftRight = leftRight;
              scope.bottomTop = bottomTop;
              scope.rightLeft = rightLeft;

              scope.zoomIn = zoomIn;
              scope.zoomOut = zoomOut;
            }

          }

          // set our element to use this HTML
          var header = angular.element(content);
          element.empty();
          $compile(header)(scope, function(compiledHeader) {element.append(compiledHeader)});

          //element.html(content);

          // now add the d3 content

          if (data.plan_nodes) {
            // put the SVG inside a wrapper to allow scrolling
            wrapperElement = angular.element('<div class="d3-tree-wrapper"></div>');
//            wrapperElement = angular.element('<div></div>');
            element.append(wrapperElement);
            simpleTree = makeSimpleTreeFromPlanNodes(data.plan_nodes,null,"null");

            // if we're creating the wrapper for the first time, allow a delay for it to get a size
            if ($('.d3-tree-wrapper').height())
              makeTree();
            else
              $timeout(makeTree,100);
          }
        });
      }
    };
  }

  //
  // global so we can rebuild the tree when necessary
  //

  var wrapperElement;
  var simpleTree; // underlying data

  function makeTree() {

    makeD3TreeFromSimpleTree(simpleTree);
  }

  //
  // handle zooming
  //

  var orientLR = 1;
  var orientTB = 2;
  var orientRL = 3;
  var orientBT = 4;

  function topDown() {changeOrient(orientTB);}
  function bottomTop() {changeOrient(orientBT);}
  function leftRight() {changeOrient(orientLR);}
  function rightLeft() {changeOrient(orientRL);}

  function changeOrient(newOrient) {
    wrapperElement.empty();
    queryService.query_plan_options.orientation = newOrient;
    makeTree();
  }

  // handle drag/zoom events

  function zoom() {
    //var scale = d3.event.scale,
    //    translation = d3.event.translate;
    //console.log("scale: " + JSON.stringify(scale));
    //console.log("translate: " + JSON.stringify(translation));
    d3.select(".drawarea")
        .attr("transform", "translate(" + zoomer.translate() + ")" +
              " scale(" + zoomer.scale() + ")");
  }


  function zoomIn()  {zoomButton(false);}
  function zoomOut() {zoomButton(true); }

  function zoomButton(zoom_in) {
    var scale = zoomer.scale(),
      center = [canvas_width / 2 , canvas_height / 2],
      extent = zoomer.scaleExtent(),
      translate = zoomer.translate(),
      x = translate[0], y = translate[1],
      factor = zoom_in ? 2 : 1/2,
      target_scale = scale * factor;

    //  If we're already at an extent, done
    if (target_scale === extent[0] || target_scale === extent[1]) { return false; }
    //  If the factor is too much, scale it down to reach the extent exactly
    var clamped_target_scale = Math.max(extent[0], Math.min(extent[1], target_scale));
    if (clamped_target_scale != target_scale){
      target_scale = clamped_target_scale;
      factor = target_scale / scale;
    }

    //  Center each vector, stretch, then put back
    x = (x - center[0]) * factor + center[0];
    y = (y - center[1]) * factor + center[1];

    //  Transition to the new view over 100ms
    d3.transition().duration(100).tween("zoom", function () {
      var interpolate_scale = d3.interpolate(scale, target_scale),
      interpolate_trans = d3.interpolate(translate, [x,y]);
      return function (t) {
        zoomer.scale(interpolate_scale(t))
        .translate(interpolate_trans(t));
        zoom();
      };
    })
    //.each("end", function(){
    //  if (pressed) zoomButton(zoom_in);
  //  })
    ;
  }

  //////////////////////////////////////////////////////////////////////////
  // make a d3 tree
  //

  // Magic numbers for layout
  var svg, g, zoomer;
  var svg_scale = 1.0;
  var lineHeight = 15;        // height for line of text, on which node height is based
  var interNodeXSpacing = 25; // spacing between nodes horizonally
  var interNodeYSpacing = 40; // spacing between nodes vertically

  var canvas_width, canvas_height;

  function makeD3TreeFromSimpleTree(root) {
    var duration = 500,
      i = 0;
    var vert = (queryService.query_plan_options.orientation == orientTB ||
        queryService.query_plan_options.orientation == orientBT);

    canvas_width = $('.d3-tree-wrapper').width();
    canvas_height =  $('.d3-tree-wrapper').height();

    //console.log("Svg width: " + canvas_width + ", height: " + canvas_height);
    //console.log("Got expected width: " + width + ", height: " + height);

    svg = d3.select(wrapperElement[0]).append('svg:svg')
        .attr("width", canvas_width)
        .attr("height", canvas_height)
        .attr("id", "outer_svg")
        .style("overflow", "scroll")
       .append("svg:g")
          .attr("class","drawarea")
          .attr("id", "svg_g")
      ;

    // need a definition for arrows on lines
    var arrowhead_refX = vert ? 0 : 0;
    var arrowhead_refY = vert ?  2 : 2;

    svg.append("defs").append("marker")
    .attr("id", "arrowhead")
    .attr("refX", arrowhead_refX) /*must be smarter way to calculate shift*/
    .attr("refY", arrowhead_refY)
    .attr("markerWidth", 6)
    .attr("markerHeight", 4)
    .attr("orient", "auto")
    .append("path")
    .attr("d", "M 6 0 V 4 L 0 2 Z"); //this is actual shape for arrowhead

    // minimum fixed sizes for nodes, depending on orientation, to prevent overlap
    var minNodeSize = vert ? [125,lineHeight*6] : [lineHeight*6,195];

    var tree = d3.layout.cluster()
    //.size([height, width])
    .nodeSize(minNodeSize) // give nodes enough space to avoid overlap
    ;

    // use nice curves between the nodes
    var diagonal = d3.svg.diagonal().projection(getConnectionEndPoint);

    // assign nodes and links
    var nodes = tree.nodes(root);
    var links = tree.links(nodes);

    // used for tool tips
    var div = d3.select("body").append("div")
      .attr("class", "svg_tooltip")
      .style("opacity", 0);

    //
    // we want to pan/zoom so that the whole graph is visible.
    //
    // for some reason I can't get getBBox() to give me the bounding box for the overall
    // graph, so instead I'll just check the coords of all the nodes to get a bounding box
    //

    var minX = canvas_width, maxX = 0, minY = canvas_height, maxY = 0;
    nodes.forEach(function(d)
        {minX = Math.min(d.x,minX); minY = Math.min(d.y,minY); maxX = Math.max(d.x,maxX);maxY = Math.max(d.y,maxY);});
    //console.log("Actual width: " + (maxX - minX) + ", height: " + (maxY - minY));

    // to make a horizontal tree, x and y are swapped
    var dx = (vert ? maxX - minX : maxY - minY);
    var dy = (!vert ? maxX - minX : maxY - minY);
    var x = (vert ? (minX + maxX)/2 : (minY + maxY)/2);
    var y = (!vert ? (minX + maxX)/2 : (minY + maxY)/2);

    // if flipped, we need to flip the bounding box
    if (queryService.query_plan_options.orientation == orientBT)
      y = -y;
    else if (queryService.query_plan_options.orientation == orientRL)
      x = -x;

    var scale = Math.max(0.15,Math.min(2,.9 / Math.max(dx / canvas_width, dy / canvas_height)));
    var translate = [canvas_width / 2 - scale * x, canvas_height / 2 - scale * y];



    //console.log("Got new scale: " + scale + ", translate: " + JSON.stringify(translate));

    // set up zooming, including initial values to show the entire graph
    d3.select(".drawarea")
    .attr("transform","translate(" + translate + ")scale(" + scale + ")");

    zoomer = d3.behavior.zoom().scaleExtent([0.1, 2.5]).on("zoom", zoom);
    zoomer.translate(translate);
    zoomer.scale(scale);

    d3.select("svg").call(zoomer);

    // Each node needs a unique id. If id field doesn't exist, use incrementing value
    var node = svg.selectAll("g.node")
      .data(nodes, function(d) { return d.id || (d.id = ++i); });

    // Enter any new nodes at the parent's previous position.
    var nodeEnter = node.enter().append("svg:g")
    .attr("class", "node")
    .attr("transform", getRootTranslation)
    .on("mouseover", function(d) {
      div.transition().duration(200).style("opacity", 0.9);
      div.html(d.tooltip)
        .style("left", (d3.event.pageX) + "px")
        .style("top", (d3.event.pageY - 50) + "px");
    })
    .on("mouseout", function(d) {
      div.transition().duration(500).style("opacity",0);
    })
    ;

    // ********* create node style from data *******************
    nodeEnter.append("rect")
    .attr("width", function(d) {return getWidth(d);})
    .attr("height", function(d) {return getHeight(d);})
    .attr("rx", lineHeight) // sets corner roundness
    .attr("ry", lineHeight)
    .attr("x", function(d) {return(-1/2*getWidth(d))}) // make the rect centered on our x/y coords
    .attr("y", function(d) {return getHeight(d)*-1/2})
    .attr("class", function(d) { return d.level; })
    ;


    nodeEnter.append("text")
    .attr("dy", function(d) {return getHeight(d)*-1/2 + lineHeight}) // m
    .text(function(d) { return d.name })
    ;

    // handle up to 3 lines of details
    for (var i=0;i<3;i++) nodeEnter.append("text")
    .attr("dy", function(d) {return getHeight(d)*-1/2 + lineHeight*(i+2)})
    .text(function(d) { return d.details[i] })
    ;

    // Transition nodes to their new position.
    var nodeUpdate = node.transition()
      .duration(duration)
      .attr("transform", getNodeTranslation);

    //Transition exiting nodes to the parent's new position.
    var nodeExit = node.exit().transition()
      .duration(duration)
      .attr("transform", function(d) { return "translate(" + root.y + "," + root.x + ")"; })
      .remove();

    nodeExit.select("rect")
    .attr("r", 1e-6);

    // Update the links…
    var link = svg.selectAll("path.link")
    .data(links, function(d) { return d.target.id; });

    // Enter any new links at the parent's previous position.
    link.enter().insert("path", "g")
    .attr("class", "link")
    // .style("stroke", function(d) { return d.target.level; }) // color line with level color
    .attr("marker-start", "url(#arrowhead)")
    .attr("d", function(d) {
      var o = {x: root.x0, y: root.y0};
      return diagonal({source: o, target: o});
    });

    // Transition links to their new position.
    link.transition()
    .duration(duration)
    .attr("d", diagonal);

    // Transition exiting nodes to the parent's new position.
    link.exit().transition()
    .duration(duration)
    .attr("d", function(d) {
      var o = {x: root.x, y: root.y};
      return diagonal({root: o, target: o});
    })
    .remove();

    // Stash the old positions for transition.
    nodes.forEach(function(d) {
      d.x0 = d.x;
      d.y0 = d.y;
    });

  }


  //////////////////////////////////////////////////////////////////////////////////
  // layout/size functions that differ based on the orientation of the tree
  //

  function getConnectionEndPoint(node) {
    switch (queryService.query_plan_options.orientation) {
    case orientTB:
      return [node.x, node.y + getHeight(node)/2];

    case orientBT:
      return [node.x, -node.y - getHeight(node)/2];

    case orientLR:
      return [node.y + getWidth(node)/2, node.x];

    case orientRL:
    default:
      return [-node.y - getWidth(node)/2, node.x];
    }
  }


  function getRootTranslation(root) {
    switch (queryService.query_plan_options.orientation) {
    case orientTB:
    case orientBT:
      root.x0 = 50;
      root.y0 = 0;
      break;

    case orientLR:
    case orientRL:
    default:
      root.x0 = 50;
      root.y0 = 0;
      break;
    }

    return "translate(" + root.x0 + "," + root.y0 + ")";
  }

  function getNodeTranslation(node) {
    switch (queryService.query_plan_options.orientation) {
    case orientTB:
      return "translate(" + node.x + "," + node.y + ")";

    case orientBT:
      return "translate(" + node.x + "," + -node.y + ")";

    case orientLR:
      return "translate(" + node.y + "," + node.x + ")";

    case orientRL:
    default:
      return "translate(" + -node.y + "," + node.x + ")";
    }
  }

  //
  // function to compute height for a given node based on how many lines
  // of details it has
  //

  function getHeight(node) {
    var numLines = 2;
    if (node.details)
      numLines += node.details.length;
    return(lineHeight*numLines);
  }

  //
  // compute width by finding the longest line, counting characters
  //

  function getWidth(node) {
    var maxWidth = 20; // leave at least this much space
    if (node.name && node.name.length > maxWidth)
      maxWidth = node.name.length;
    if (node.details) for (var i=0; i < node.details.length; i++)
      if (node.details[i].length > maxWidth)
        maxWidth = node.details[i].length;

    return(maxWidth * 5); //allow 5 units for each character
  }


  //
  // recursively turn the tree of ops into a simple tree to give to d3
  //

  function makeSimpleTreeFromPlanNodes(plan,next,parent) {
    // we ignore operators of nodes with subsequences, and put in the subsequence
    if (plan.subsequence)
      return(makeSimpleTreeFromPlanNodes(plan.subsequence,plan.predecessor,parent));

    if (!plan || !plan.operator)
      return(null);

    // otherwise build a node based on this operator
    var opName = (plan && plan.operator && plan.operator['#operator'])
      ? plan.operator['#operator'] : "unknown op";

    var result = {
        name: plan.GetName(),
        details: plan.GetDetails(),
        parent: parent,
        children: [],
        level: "node", // default background color
        time: plan.time,
        time_percent: plan.time_percent,
        tooltip: plan.GetTooltip()
    };

    // how expensive are we? Color background by cost, if we know
    if (plan && plan.time_percent) {
      if (plan.time_percent >= 20)
        result.level = "node-expensive-3";
      else if (plan.time_percent >= 5)
        result.level = "node-expensive-2";
      else if (plan.time_percent >= 1)
        result.level = "node-expensive-1";
    }

    // if the plan has a 'predecessor', it is either a single plan node that should be
    // our child, or an array marking multiple children

    if (plan.predecessor)
      if (!_.isArray(plan.predecessor))
        result.children.push(makeSimpleTreeFromPlanNodes(plan.predecessor,next,result.name));
      else for (var i=0; i< plan.predecessor.length; i++)
        result.children.push(makeSimpleTreeFromPlanNodes(plan.predecessor[i],null,result.name));

    return(result);
  }

})();