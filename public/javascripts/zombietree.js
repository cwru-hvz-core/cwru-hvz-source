var labelType, useGradients, nativeTextSupport, animate;

(function() {
  var ua = navigator.userAgent,
    iStuff = ua.match(/iPhone/i) || ua.match(/iPad/i),
    typeOfCanvas = typeof HTMLCanvasElement,
    nativeCanvasSupport = (typeOfCanvas == 'object' || typeOfCanvas == 'function'),
    textSupport = nativeCanvasSupport 
      && (typeof document.createElement('canvas').getContext('2d').fillText == 'function');
  //I'm setting this based on the fact that ExCanvas provides text support for IE
  //and that as of today iPhone/iPad current text support is lame
  labelType = (!nativeCanvasSupport || (textSupport && !iStuff))? 'Native' : 'HTML';
  nativeTextSupport = labelType == 'Native';
  useGradients = nativeCanvasSupport;
  animate = !(iStuff || !nativeCanvasSupport);
})();

var Log = {
  elem: false,
  write: function(text){
    if (!this.elem) 
      this.elem = document.getElementById('log');
    this.elem.innerHTML = text;
    this.elem.style.left = (500 - this.elem.offsetWidth / 2) + 'px';
  }
};


function init_graph(data){
  //init data
  //end
  //init Spacetree
  //Create a new ST instance
  var st = new $jit.ST({
    //id of viz container element
    injectInto: 'gametree',
    //set duration for the animation
    duration: 800,
    //set animation transition type
    transition: $jit.Trans.Quart.easeInOut,
    //set distance between node and its children
    levelDistance: 32,
    orientation: "left",
    //enable panning
    Navigation: {
      enable:true,
      panning:true
    },
    //set node and edge styles
    //set overridable=true for styling individual
    //nodes or edges
    Node: {
        height: 20,
        width: 128,
        type: 'rectangle',
        color: '#fff',
        overridable: true
    },
    
    Edge: {
        type: 'bezier',
        color: '#aaa',
        overridable: true
    },
    
    onBeforeCompute: function(node){
        Log.write("Loading " + node.name);
    },
    
    onAfterCompute: function(){
        Log.write("");
    },
    
    //This method is called on DOM label creation.
    //Use this method to add event handlers and styles to
    //your node.
    onCreateLabel: function(label, node){
        label.id = node.id;
        label.innerHTML = node.name;
        if(node.data.tags != null)
            label.innerHTML += " (" + node.data.tags + ")";
        label.onclick = function(){
            st.onClick(node.id);
        };
        //set label styles
        var style = label.style;
        style.width = 120 + 'px';
        style.height = 17 + 'px';            
        style.cursor = 'pointer';
        style.color = '#000';
        style.fontSize = '0.8em';
        style.textAlign= 'center';
        style.paddingTop = '3px';
    },
    
    //This method is called right before plotting
    //a node. It's useful for changing an individual node
    //style properties before plotting it.
    //The data properties prefixed with a dollar
    //sign will override the global node style properties.
    onBeforePlotNode: function(node){
        //add some color to the nodes in the path between the
        //root node and the selected node.
        if (node.selected) {
            node.data.$color = "#58FF3A";
        }
        else {
            node.data.$color = "#88FF88";
        }
    },
    
    //This method is called right before plotting
    //an edge. It's useful for changing an individual edge
    //style properties before plotting it.
    //Edge data proprties prefixed with a dollar sign will
    //override the Edge global style properties.
    onBeforePlotLine: function(adj){
        if (adj.nodeFrom.selected && adj.nodeTo.selected) {
            adj.data.$color = "#58FF3A";
            adj.data.$lineWidth = 3;
        }
        else {
            delete adj.data.$color;
            delete adj.data.$lineWidth;
        }
    }
  });
  //load json data
  st.loadJSON(data);
  //compute node positions and layout
  st.compute();
  //optional: make a translation of the tree
  //st.geom.translate(new $jit.Complex(-200, 0), "current");
  //emulate a click on the root node.
  st.onClick(st.root);
  //end
}
