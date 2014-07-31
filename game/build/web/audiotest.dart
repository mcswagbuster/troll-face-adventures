import 'dart:html';
import 'dart:web_audio';


// https://www.dartlang.org/samples/webaudio/
// https://github.com/dart-lang/dart-samples/tree/master/html5/web/webaudio/intro

var globalfunction = new List(100);

void main() {

  addSound("bow.ogg", 65);
  addSound("pop1.ogg", 66);
  
      // add the yrskeypressed invocation to the keyboard event handler
      window.onKeyDown.listen((e){
       // a = 65, b = 66 etc
  	   // window.console.log(k);
  	   if (e.keyCode == 65) globalfunction[65]();
       if (e.keyCode == 66) globalfunction[66]();
      });
      
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
