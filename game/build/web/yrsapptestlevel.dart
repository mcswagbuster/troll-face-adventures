import 'dart:html';
import 'dart:collection' show HashMap;
import 'dart:async';
import 'dart:math';
import 'dart:web_audio';
import 'getCrime.dart';

keyboard k = new keyboard();

PlanetaryBody sun2;
List<PlanetaryBody> enemy;

CanvasElement canvas = querySelector('#canvas');
CanvasRenderingContext2D context = canvas.context2D;

bool FIP = false ;
bool blob = true ;
List<PlanetaryBody> arrowlist = new List();
List platforms = new List();

void main() {
  getLocation();
  
  canvas.width = 2000;
  canvas.height = 750;
}

void stuff() {
   print(numEnim);
   enemy = new List(numEnim);
   scheduleMicrotask(new SolarSystem(canvas).start);
   startaudio();
}

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
  for (var i = 0; i < platforms.length; i++) {
   // Detect if touching platform
var Platform = platforms [i];
if ((Platform.x < x + sun2.imgwidth) &&
    (x < Platform.x + Platform.imgwidth) &&
    (y < Platform.y + Platform.imgheight) &&
    (Platform.y < y)) {
  istouching = 1 ;
}
}
  return istouching;
} 

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
 sun = new PlanetaryBody(this, "green", 0, 200, true, 4, true, 0);
 
// Enemy AI shooting
new Future.delayed(const Duration(seconds:1), () {
  AI();
});

 //Create Platforms
 // x, y, w, h but scaling not implemented yet
var platformscoord = [
  [0,360,227,15], /* 0 */
  [220,300,227,15], /* 1 */
  [220,60,227,15], /* 2 */
  [440,240,227,15], /* 3 */
  [440,120,227,15], /* 4 */
  [660,180,227,15], /* 5 */
  [880,240,227,15], /* 6 */
  [1100,300,227,15], /* 7 */
  // Borders for testing
  //[0,0,8,400], /* 8 */
  //[0,392,1350,8], /* 9 */
  //[1342,0,8,400], /* 10 */
  //[0,0,1350,8], /* 11 */
];

for (var i = 0; i < platformscoord.length; i++) {
    var z = platformscoord[i];
    platforms.add(new PlanetaryBody (this, "block 1", z[0], z[1], false, 0, false, i));
}

for (int i = 0; i < enemy.length; i++) {
   var z = platformscoord[i];
   enemy[i] = new PlanetaryBody(this, "red 1", z[0] + 100, z[1] - 60, true, 4, true, i);
}

 //Create Platfrom
 // var Platform = new PlanetaryBody (this, "block 1", 0, 250, false, 4);
 // platforms.add((Platform));
 
 sun2 = sun;

requestRedraw();
}
void AI() {
  bool neimVis = false;
  for (int i = 0; i < enemy.length; i++) {
    if (enemy[i].isvisable == 1) {
        neimVis = true;
        enemy[i].fire("blob"); 
  }
  }
  new Future.delayed(const Duration(seconds: 1), () {
    AI();
  });
  // Play sound
  if (neimVis)
    if (globalfunction[66] != null) globalfunction[66]();
}
void draw(num _) {
 num time = new DateTime.now().millisecondsSinceEpoch;
 renderTime = time;
 
 checkkey();

 var context = canvas.context2D;
 drawBackground(context);
 drawPlanets(context);
 requestRedraw();
}

void drawBackground(CanvasRenderingContext2D context) {
 canvas.width = canvas.width;
}

void drawPlanets(CanvasRenderingContext2D context) {
 sun.draw(new Point(width / 2, height / 2));
 for (var i = 0; i < platforms.length; i++) {
  platforms[i].draw(new Point ( 0,0));
 }
 for (int i = 0; i < enemy.length; i++) {
    enemy[i].draw(new Point (0,0));
 }
 for (var i = 0; i < arrowlist.length; i++) {
 arrowlist [i].draw(new Point ( 0,0));
 }
 
}
void requestRedraw() {
 window.requestAnimationFrame(draw);
}
}

class PlanetaryBody {
final String color;
final num orbitPeriod;
final SolarSystem solarSystem;

num bodySize;
num orbitRadius;
num orbitSpeed;
num isvisable;
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
num speed;
bool candie; // can die
bool dying = false;

final List<PlanetaryBody> planets = <PlanetaryBody>[];

PlanetaryBody(this.solarSystem, this.color, this.x, this.y, this.gravity, this.speed, this.candie, 
   int direction, [this.orbitRadius = 0.0, this.orbitPeriod = 0.0]) {
  speedx=0; speedy=0;
  imageleft  = new ImageElement(src: "img/${color}-left.png");
  imageright = new ImageElement(src: "img/${color}-right.png");
  
  if (direction % 2 == 0) {
    image = imageright;
  } else {
    image = imageleft;
  }
  imgheight = imageright.height;
  imgwidth = imageright.width;
  bodySize = 0;
  isvisable= 1;
}
void kill() {
  isvisable = 0;
}

int isharming() {
  var isharming = 0;
  for (var i = 0; i <arrowlist.length; i++) {
   // Detect if touching projectile
var Projectile = arrowlist [i];
if ((Projectile.x < x) &&
    (x < Projectile.x + Projectile.imgwidth) &&
    (y < Projectile.y + Projectile.imgheight) &&
    (Projectile.y < y + imgheight)) {
  isharming= 1 ;
}
}
  return isharming;
}


void draw(Point p) {
  Point pos = calculatePos(p);
  
  if (candie && isharming() == 1) {
   isvisable = 0;
   // teleport out of the way
   x = -20;
   y = -20;
 }
 
 if (isvisable == 1) {
   drawSelf(context, pos);
 }
 
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
    speedy=-3;
  }
}
void moveleftright(num direction){
speedx=speed*direction;
if (direction == 1) {
  image = imageright;
}
if (direction == -1) {
  image = imageleft;
}
 }

 void fire(imgname) {
  PlanetaryBody arrow;
  // start a bit away from us so it doesn't kill us
    var xadjust = image == imageright ? 5 : -25;
    arrow = new PlanetaryBody(this.solarSystem, imgname, x + xadjust, y, false, 8, true, 0);
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