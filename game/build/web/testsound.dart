import 'dart:html';
import 'dart:collection' show HashMap;
import 'dart:async';
import 'dart:math';
import 'dart:web_audio';

keyboard k = new keyboard();

PlanetaryBody sun2;
PlanetaryBody enemy;
var FIP = false ;
var blob = true ;
var arrowlist = new List();
var platforms = new List();
void oldmain() {
  window.animationFrame.then(animate);
}

void animate(double _)  {
  window.animationFrame.then(animate);
  checkkey();
}

void checkkey() {
  if (k.isPressed(KeyCode.W)) {
    //window.console.log('it works');
    sun2.jump();
  }
  sun2.moveleftright(0);
  if (k.isPressed(KeyCode.D)) {
     sun2.moveleftright(1);
   }
  if (k.isPressed(KeyCode.A)) {
       sun2.moveleftright(-1);
     }
  if (k.isPressed(KeyCode.PERIOD)) {
    // Fire weapon
    if (! FIP ) {
    sun2.fire("Arrow");
    FIP = true ;
    // Play sound
    if (globalfunction[65] != null) globalfunction[65]();
    }
  }
  else {
  FIP = false;
  }
  
}
  

class keyboard {
    HashMap _key = new HashMap<int, int>();
    keyboard() {
      window.onKeyDown.listen((e){
        if (!_key.containsKey(e.keyCode)) {
          //If it's not set yet, set it with a time stamp.
          _key[e.keyCode] = e.timeStamp;
        }
      });
      window.onKeyUp.listen((e){
        _key.remove(e.keyCode);
      });
    }
    //check if key is being pressed.
    isPressed(int keyCode) => _key.containsKey(keyCode);
}

int istouching(num x, num y) {
  var istouching = 0;
  if (y>300)
    istouching = 1;
  for (var i = 0; i < platforms.length; i++) {
   // Detect if touching platform
var Platform = platforms [i];
if ((Platform.x < x) &&
    (x < Platform.x + Platform.imgwidth) &&
    (y < Platform.y + Platform.imgheight) &&
    (Platform.y < y)) {
  istouching = 1 ;
}
}
  return istouching;
} 


int isharming(num x, num y) {
  var isharming = 0;
  if (y>300)
    isharming = 1;
  for (var i = 0; i <arrowlist.length; i++) {
   // Detect if touching projectile
var Projectile = arrowlist [i];
if ((Projectile.x < x) &&
    (x < Projectile.x + Projectile.imgwidth) &&
    (y < Projectile.y + Projectile.imgheight) &&
    (Projectile.y < y)) {
  isharming= 1 ;
}
}
  return isharming;
}
void main() {
CanvasElement canvas = querySelector("#area");
scheduleMicrotask(new SolarSystem(canvas).start);
startaudio();
}

Element notes = querySelector("#fps");
num fpsAverage;

/// Display the animation's FPS in a div.
void showFps(num fps) {
if (fpsAverage == null) fpsAverage = fps;
fpsAverage = fps * 0.05 + fpsAverage * 0.95;
notes.text = "${fpsAverage.round()} fps";
}

/**
 * A representation of the solar system.
*
 * This class maintains a list of planetary bodies, knows how to draw its
 * background and the planets, and requests that it be redraw at appropriate
 * intervals using the [Window.requestAnimationFrame] method.
 */
class SolarSystem {
CanvasElement canvas;

num width;
num height;

PlanetaryBody sun;

num renderTime;

SolarSystem(this.canvas);

// Initialize the planets and start the simulation.
start() {
 // Measure the canvas element.
 Rectangle rect = canvas.parent.client;
 width = rect.width;
 height = rect.height;
 canvas.width = width;

 // Create sun.
 sun = new PlanetaryBody(this, "green", 0, 200, true);
 
 //Create enemy.
 enemy = new PlanetaryBody(this, "red 1", 500, 200, true);
// Enemy AI shooting
new Future.delayed(const Duration(seconds:1), () {
  AI();
});
 
 //Create Platfrom
 var Platform = new PlanetaryBody (this, "block 1", 0, 250, false);
 
 platforms.add((Platform));
 
 sun2 = sun;

requestRedraw();
}
void AI() {
  enemy.fire("blob"); 
  new Future.delayed(const Duration(seconds:1), () {
    AI();
  });
  // Play sound
  if (globalfunction[66] != null) globalfunction[66]();
}

void draw(num _) {
 num time = new DateTime.now().millisecondsSinceEpoch;
 if (renderTime != null) showFps(1000 / (time - renderTime));
 renderTime = time;
 
 checkkey();

 var context = canvas.context2D;
 drawBackground(context);
 drawPlanets(context);
 requestRedraw();
}

void drawBackground(CanvasRenderingContext2D context) {
 context.clearRect(0, 0, width, height);
}

void drawPlanets(CanvasRenderingContext2D context) {
 sun.draw(context, new Point(width / 2, height / 2));
 enemy.draw(context, new Point ( 0,0));
 for (var i = 0; i < arrowlist.length; i++) {
 arrowlist [i].draw(context, new Point ( 0,0));
 }
 for (var i = 0; i < platforms.length; i++) {
 platforms [i].draw(context, new Point ( 0,0));

 }
}
void requestRedraw() {
 window.requestAnimationFrame(draw);
}
}

/**
 * A representation of a plantetary body.
 * This class can calculate its position for a given time index,
 * and draw itself and any child planets.
 */
class PlanetaryBody {
final String color;
final num orbitPeriod;
final SolarSystem solarSystem;

num bodySize;
num orbitRadius;
num orbitSpeed;

num x;
num y;
num speedx;
num speedy;
ImageElement image;
ImageElement imageleft;
ImageElement imageright;
num imgheight;
num imgwidth;
var gravity;

final List<PlanetaryBody> planets = <PlanetaryBody>[];

PlanetaryBody(this.solarSystem, this.color, this.x, this.y, this.gravity,
   [this.orbitRadius = 0.0, this.orbitPeriod = 0.0]) {
  speedx=0; speedy=0;
  imageleft = new ImageElement(src:color + "-left.png");
  imageright = new ImageElement(src:color + "-right.png");
  image = imageright;
  imgheight = imageright.height;
  imgwidth = imageright.width;
  bodySize = 0;
}


void draw(CanvasRenderingContext2D context, Point p) {
 Point pos = calculatePos(p);
 drawSelf(context, pos);
}

void drawSelf(CanvasRenderingContext2D context, Point p) {
  if (bodySize == 0) {
    bodySize = imageright.width;
  }
 // Check for clipping.
 if (p.x + bodySize < 0 || p.x - bodySize >= context.canvas.width) return;
 if (p.y + bodySize < 0 || p.y - bodySize >= context.canvas.height) return;

 // Draw the figure.
 
 context.drawImage(image, x, y);
 

 
}

Point calculatePos(Point p) {
  num newx;
  num newy;
  if (imgheight == 0) {
    // image was not yet loaded last time we tried
    imgheight = imageright.height;
  }
  if (imgwidth == 0) {
     // image was not yet loaded last time we tried
     imgwidth = imageright.width;
   }
  newx=x+speedx;
  if (istouching (newx, y+imgheight) == 1) {
    speedx = 0;    
  } else {
    x = newx;
  }
  newy=y+speedy;
  if (istouching(x, newy+imgheight) == 1) {
    speedy = 0;
  } else {
    y = newy;
    // gravity
    if (gravity)
    speedy=speedy+0.04;
  }
  return new Point(x, y);
 }

void jump() {
  if (istouching(x, y+imgheight+1) == 1) {
    speedy=-2;
  }
}
void moveleftright(num direction){
speedx=5*direction;
if (direction == 1) {
  image = imageright;
}
if (direction == -1) {
  image = imageleft;
}
 }

 void fire(imgname) {
  PlanetaryBody arrow;
    arrow = new PlanetaryBody(this.solarSystem, imgname, x, y, false);
    arrow.moveleftright(image == imageright ? 1 : -1);
    arrow.jump();
    arrowlist.add (arrow);
 }
 
  
 
  
}
   
// ======================= Audio ====================

// https://www.dartlang.org/samples/webaudio/
// https://github.com/dart-lang/dart-samples/tree/master/html5/web/webaudio/intro

var globalfunction = new List(100);

void startaudio() {

  addSound("bow.ogg", 65);
  addSound("pop1.ogg", 66);
       
}

// ==============================
// http://practicaldart.wordpress.com/

// AudioContext HttpRequest decodeAudioData AudioBufferSourceNode dart

void addSound(soundurl, index) {
  AudioContext audioContext = new AudioContext();

  // async request for the wave file
  HttpRequest xhr = new HttpRequest();
  xhr.open("GET", soundurl);
  xhr.responseType = "arraybuffer"; 
  xhr.addEventListener("load", (e) {
    // asynchronous decoding
    audioContext.decodeAudioData(xhr.response).then((buffer){
    
      // define function to play the sound
      void doPlaySound() {
        AudioBufferSourceNode source = audioContext.createBufferSource();
        source.connectNode(audioContext.destination, 0, 0);
        source.buffer = buffer;
        //source.noteOn(0);
        source.start(0);
      }

      globalfunction[index] = doPlaySound;
 });
  });  

  xhr.send();
}





