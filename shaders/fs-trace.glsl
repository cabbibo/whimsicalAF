
uniform float time;

uniform samplerCube t_cube;
uniform sampler2D t_logo;

uniform sampler2D t_matcap;
uniform sampler2D t_normal;
uniform sampler2D t_color;

uniform mat4 modelViewMatrix;
uniform mat3 normalMatrix;

uniform float noiseSize1;
uniform float noiseSize2;


varying vec3 vPos;
varying vec3 vCam;
varying vec3 vNorm;

varying vec3 vMNorm;
varying vec3 vMPos;

varying vec2 vUv;
varying float vNoise;

varying vec3 vAudio;


$uvNormalMap
$semLookup


// Branch Code stolen from : https://www.shadertoy.com/view/ltlSRl
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

const float MAX_TRACE_DISTANCE = 1.0;             // max trace distance
const float INTERSECTION_PRECISION = 0.0001;        // precision of the intersection
const int NUM_OF_TRACE_STEPS = 50;
const float PI = 3.14159;

const int NUM_COL_RAYS = 3;



$smoothU
$opU
$pNoise



vec3 vHash( vec3 x )
{
  x = vec3( dot(x,vec3(127.1,311.7, 74.7)),
        dot(x,vec3(269.5,183.3,246.1)),
        dot(x,vec3(113.5,271.9,124.6)));

  return fract(sin(x)*43758.5453123);
}



vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv(float h, float s, float v)
{
    
  return mix( vec3( 1.0 ), clamp( ( abs( fract(
    h + vec3( 3.0, 2.0, 1.0 ) / 3.0 ) * 6.0 - 3.0 ) - 1.0 ), 0.0, 1.0 ), s ) * v;
}


float fNoise( vec3 pos ){
    float n = pNoise( pos * 200. * noiseSize1 + .1 * vec3( time ));
    float n2 = pNoise( pos * 40. * noiseSize2 + .1 * vec3( time ));
    return n * .005 + n2 * .01;
}







// green fur
vec3 col1( vec3 ro , vec3 rd ){

  vec3 col = vec3( 0. );
  for( int i = 0; i<10; i++){
    vec3 p = ro + rd * .003 * float( i );

     float n = abs(sin( p.x * 500. )) + abs(sin( p.y * 500.));//fNoise( p  * 10.2);

    col += n * hsv( n  * .4, 1. , 1. )/10. ;



  }

  return col;

}


// white fur / pin base
vec3 col2( vec3 ro , vec3 rd ){

    vec3 col = vec3( .5 );
  for( int i = 0; i<10; i++){
    vec3 p = ro + rd * .001 * float( i );

     float n =fNoise( p  * 4.2 * vec3(1.,1.,4.) - vec3( 0., 0., time * .01)  ) *1000.;// abs(sin( p.x * 1000. )) + abs(sin( p.y * 1000.));//fNoise( p  * 10.2);

    if( n < 10. && n > 8. ){
      col = vec3( 1. - float( i ) / 20. );//hsv( float( i ) / 10. , 1. , 1. );
      break;////vec3(1.);
    }

  }


  return col;// / 3.;

}


// pin head
vec3 col3( vec3 ro , vec3 rd ){

  vec3 col = hsv( 1. + time * .1 , 1. , 1. );;
  for( int i = 0; i<10; i++){
    vec3 p = ro + rd * .001 * float( i );

    float n = fNoise( p * 5.2  + vec3( 0., time * .01, time * .001)) * 100.;

    if( n < 1. && n > .8 ){
      col = hsv( float( i ) / 10. + time * .1 , 1. , 1. );
      break;////vec3(1.);
    }

    //col += hsv( n * 1. , 1. , 1. ) * n /100. ;


  }

  return col;


  return col;

}


//black lines
vec3 col4( vec3 ro , vec3 rd ){

  vec3 col = vec3( 0. );
  for( int i = 0; i<10; i++){
    vec3 p = ro + rd * .0005 * float( i );

    float n = fNoise( p  * 10.2 + vec3( 0.,  0., time * .001)) * 100.;

    col += n * hsv( n  , 1. , 1. )/10. ;


  }

  return col;

}

vec3 render( vec3 ro , vec3 rd , float whichTrace ){

  if( whichTrace == 1. ){
    return col1( ro , rd );
  }else if( whichTrace == 2. ){
    return col2( ro , rd );
  }else if( whichTrace == 3. ){
    return col3( ro , rd );
  }else if( whichTrace == 4. ){
    return col4( ro , rd );
  }


}



void main(){

  vec3 fNorm =  vNorm; //uvNormalMap( t_normal , vPos , vUv * 20. , vNorm , .4 * pain , .6 * pain * pain);

  vec3 ro = vPos;// + vec3( sin( time ) * .01 , 0. , .1);

  vec3 rd = normalize( vPos - vCam );

  vec3 p = vec3( 0. );
  vec3 col =  vec3( 0. );

  


  //col += fNorm * .5 + .5;


  vec4 logo = texture2D( t_logo , vUv );

  float d = length(logo.xyz - vec3( 1. ));
  if( logo.w < .1 ){ discard; }else{


  //vec3 col1 = vec3( 12.  , 168. , 224. )/256.;
  //vec3 col2 = vec3( 150. , 130. , 225. )/256.;
  //vec3 col3 = vec3( 148. , 188. , 162. )/256.;
  //vec3 col4 = vec3( 62.  , 218. , 244. )/256.;



  vec3 col1 = vec3( 55.  ,148. , 80. )/256.;
  vec3 col2 = vec3( 239. , 244. , 241. )/256.;
  vec3 col3 = vec3( 235. , 49. , 145. )/256.;
  vec3 col4 = vec3( 246.  , 236. , 51. )/256.;
  vec3 col5 = vec3( 55.  , 53. , 53. )/256.;


  float d1 = length( logo.xyz - col1 );
  float d2 = length( logo.xyz - col2 );
  float d3 = length( logo.xyz - col3 );
  float d4 = length( logo.xyz - col4 );
  float d5 = length( logo.xyz - col5 );

  float nearest = 10000.;

  float whichTrace = 1000.;

  if( d1 < nearest ){ nearest = d1; whichTrace = 1.; }
  if( d2 < nearest ){ nearest = d2; whichTrace = 2.; }
  if( d3 < nearest ){ nearest = d3; whichTrace = 3.; }
  if( d4 < nearest ){ nearest = d4; whichTrace = 3.; }
  if( d5 < nearest ){ nearest = d5; whichTrace = 4.; }


  col = render( ro , rd , whichTrace );

  //col = mix( col , vec3( 1. ) , 1. - logo.a );

  }

  col = mix(vec3( 0.), col  , logo.a * 1. );


  //col = vec3( 1. , 0., 0.);




  gl_FragColor = vec4( col , 1. );

}
