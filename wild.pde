// alec giorgio final lab
// .mp3 visualizer
// beats by monday midnight
// thanks minim for saving my lab and math and libraries for existing

import controlP5.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

Minim       minim;
AudioPlayer player=null;
FFT         fft;
ControlP5 cp5;
BeatDetect beat;

String filename;
float t=0.01;
float Parameter_1=0.01;
float Parameter_2=0.1, Parameter_4,Parameter_5,Parameter_6;
int Parameter_3=0;

void setup() {
  size(800, 600);
  minim = new Minim(this);
  cp5 = new ControlP5(this);
  beat = new BeatDetect();
  selectFile();
  cp5.addSlider("Parameter_1").setRange(0.0,20.0).setValue(10.3).setPosition(10,10);
  cp5.addSlider("Parameter_2").setRange(0.01,20.0).setValue(12.2).setPosition(10,30);
  cp5.addSlider("Parameter_3").setRange(0,50).setPosition(10,50);
  cp5.addSlider("Parameter_4").setRange(0.01,20.0).setValue(14.3).setPosition(10,70);
  cp5.addSlider("Parameter_5").setRange(0.01,20.0).setValue(0.81).setPosition(10,90);
  cp5.addSlider("Parameter_6").setRange(0.01,20.0).setPosition(10,110);
  colorMode(HSB);
  noFill();
  stroke(255);
  strokeWeight(2);
}

void draw() {
  background(0);
  pushMatrix();
  if (player != null && player.isPlaying()) {
    fft.forward(player.mix);
    beat.detect(player.mix);
    float avg=0;
    
    translate(width/2, height/2);
    beginShape();
    for (float i = 0; i<=2*PI; i+=0.01) {
      int index = int(constrain(map(i, 0, 2*PI, 0, 29), 0, 29));
      avg = fft.getAvg(index);
      float centerFrequency = fft.getAverageCenterFrequency(index);
      float averageWidth = fft.getAverageBandWidth(index);
      float lowFreq = centerFrequency - averageWidth/2;
      float highFreq = centerFrequency + averageWidth/2;
      int xlowfreq = (int)fft.freqToIndex(lowFreq);
      int xhighfreq = (int)fft.freqToIndex(highFreq);
      float theta = i;
     
      if(beat.isOnset()){
        stroke(avg*360, 255, 255, 255);
      }else{
        fill(avg*360, 255, 255, avg*255);  
      }
      float rad = r(
        theta, 
        Parameter_1 * sin(t), //  a
        Parameter_2 * cos(xhighfreq), // b
        Parameter_3, // c
        Parameter_4 * sin(avg), // x1
        Parameter_5 *- avg, // x2
        Parameter_6 * cos(xlowfreq) // x3
        );

      float x = rad * cos(theta) * (width/20);
      float y = rad * sin(theta) * (width/20);
      strokeWeight(abs(sin(avg))*10.00);
      vertex(x, y);
    }
    endShape();
    t+=0.0001;
  }
  popMatrix();
}

 float r(float theta, float a , float b, float c, float x1, float x2, float x3) {
   return pow(pow(abs(cos(c*theta/4.0) / a), x2) + 
   pow(abs(sin(c*theta /4.0) / b), x3), -1.0 /x1);
 }
 void fileSelected(File selection) {
    filename = selection.getAbsolutePath();
    player = minim.loadFile(filename, 2048);
    fft = new FFT(player.bufferSize(), player.sampleRate());
    fft.logAverages(30, 3);
    player.loop();
  }

void selectFile() {
  selectInput("Select an .mp3 file to continue :", "fileSelected");
}