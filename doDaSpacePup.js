
var G = {}

G.loading = {

      loaded:0,
      neededToLoad:0

    },

G.shaders = new ShaderLoader( 'shaders' , 'shaders/chunks' );

G.init = function(){

  G.logoData = G.doLogoData(G.logo.image);

  G.uniforms = {
    time: {type:"f", value:0},
    iModelMat:{type:"m4", value:new THREE.Matrix4()},
    t_cube:{type:"t", value: null },
    t_logo:{type:"t",value:G.logo},
    noiseSize1:{type:"f", value:1},
    noiseSize2:{type:"f", value:1},
  }

  G.uniforms.t_cube.value = G.skyMap;

  var ar = window.innerWidth / window.innerHeight;

  G.three = {

    scene           : new THREE.Scene(),
    camera          : new THREE.PerspectiveCamera( 40 , ar , .01 , 100 ),
    renderer        : new THREE.WebGLRenderer(),
    clock           : new THREE.Clock(),
    stats           : new Stats()

  }

  G.three.renderer.setSize( window.innerWidth, window.innerHeight );
  G.three.renderer.setClearColor( 0xffffff , 1 )
  G.three.renderer.domElement.id = "renderer"
  G.three.renderer.setPixelRatio(  2 );
  document.body.appendChild( G.three.renderer.domElement );

  G.three.stats.domElement.style.position = "absolute";
  G.three.stats.domElement.style.left = "0px";
  G.three.stats.domElement.style.bottom = "-30px";
  G.three.stats.domElement.style.zIndex = "999";
  document.body.appendChild( G.three.stats.domElement );



  G.objectControls = new ObjectControls( G.three.camera );

  G.controls = new THREE.TrackballControls( G.three.camera );
  //G.controls.noZoom = true;
  //G.controls.noPan = true;
  //G.controls.noRoll = true;
  G.three.camera.position.z = .3;

  G.doDaSpacePup();

  
}

G.animate = function(){

  requestAnimationFrame( G.animate );
  G.controls.update();
  G.objectControls.update();


  var h = G.objectControls.raycaster.intersectObject( G.sp , G.objectControls.raycaster );
  //console.log( h );

  if( h[0] ){

    G.getColor( h[0].uv.x , h[0].uv.y );
    //console.log( h[0] )
  }

  G.uniforms.time.value += G.three.clock.getDelta();
  G.sp.rotation.y = .3 * Math.sin( G.uniforms.time.value * 1.);
  G.sp.rotation.x = .2 * Math.sin( G.uniforms.time.value * 1.3);

  //G.sp.position.x = Math.sin( G.uniforms.time.value * .1 ) * .01;
  G.uniforms.iModelMat.value.getInverse( G.sp.matrixWorld );

  G.three.renderer.render( G.three.scene , G.three.camera );
  G.three.stats.update();



  
}

G.doDaSpacePup = function(){

  var mat = new THREE.ShaderMaterial({
    uniforms: G.uniforms,
    vertexShader:G.shaders.vs.trace,
    fragmentShader:G.shaders.fs.trace,
    side: THREE.DoubleSide
  });

  //var mat = new THREE.MeshNormalMaterial({
  //  side: THREE.DoubleSide
  //});
  

  var geo = new THREE.CylinderGeometry( 0,.1,.13,3,1);
  var geo = new THREE.PlaneGeometry(.15,.15 * 1.2);

  var mesh = new THREE.Mesh( geo , mat );
  //mesh.rotation.

  mesh.hovering = function(){
    console.log("yello");
  }
  

  G.sp = mesh;


  G.objectControls.add( G.sp );
  G.three.scene.add( mesh );

}

G.getColor = function( u , v ){

  var tx = Math.min(emod(u, 1) * G.logoData.width  | 0, G.logoData.width - 1);
  var ty = Math.min(emod(v, 1) * G.logoData.height | 0, G.logoData.height - 1);
  var offset = (ty * G.logoData.width + tx) * 4;
  var r = G.logoData.data[offset + 0];
  var g = G.logoData.data[offset + 1];
  var b = G.logoData.data[offset + 2];
  var a = G.logoData.data[offset + 3];

  console.log( r );

}

G.doLogoData = function(img){
  console.log( img );

  var canvasElement = $("<canvas></canvas>");
  console.log( canvasElement );
  G.canvas = canvasElement.get(0).getContext("2d");
  // make the canvas same size as the image
  canvasElement.width  = img.width;
  canvasElement.height = img.height;
// draw the image into the canvas
  G.canvas.drawImage(img, 0, 0);
// copy the contents of the canvas
  var texData = G.canvas.getImageData(0, 0, img.width, img.height);

  console.log( texData );
  return texData;
}

// this is only needed if your UV coords are < 0 or > 1
// if you're using CLAMP_TO_EDGE then you'd instead want to
// clamp the UVs to 0 to 1.
function emod(n, m) {
  return ((n % m) + m) % m;
}

