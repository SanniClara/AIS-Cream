/*
Thomas Sanchez Lengeling.
http://codigogenerativo.com/
KinectPV2, Kinect for Windows v2 library for processing
Depth  and infrared Test

*/

import KinectPV2.*;

import gab.opencv.*;

KinectPV2 kinect;
OpenCV opencv;


boolean foundUsers = false;
float polygonFactor = 1;

int threshold = 10;

//Distance in cm
int maxD = 1000; //4.5m
int minD = 50; //50cm

boolean    contourBodyIndex = false;

void setup() {
  size(2000, 2000, P3D);
 

  kinect = new KinectPV2(this);
  opencv = new OpenCV(this, 512, 424);
   
  kinect.enableDepthImg(true);
  kinect.enableInfraredImg(true);
  kinect.enableInfraredLongExposureImg(true);
  kinect.enableBodyTrackImg(true);
  kinect.enablePointCloud(true);
  kinect.init();
}

void draw() {
  background(160,12,200);
  
  fill(255);
  rect(100, 100, 50,10);

  //obtain the depth frame, 8 bit gray scale format
  //image(kinect.getDepthImage(), 0, 0);

  //obtain the depth frame as strips of 256 gray scale values
  //image(kinect.getDepth256Image(), 512, 0);

  //infrared data

  image(kinect.getInfraredLongExposureImage(), 512, 512);


  //raw Data int valeus from [0 - 4500]
  int [] rawData = kinect.getRawDepthData();

  //values for [0 - 256] strip
  int [] rawData256 = kinect.getRawDepth256Data();

  stroke(255);
  text(frameRate, 50, height - 50);
  
  
  image(kinect.getBodyTrackImage(), 0, 0);
  //image(kinect.getDepthImage(), 512, 0);

  //raw body data 0-6 users 255 nothing
  int [] rawData2 = kinect.getRawBodyTrack();

  foundUsers = false;
  //iterate through 1/5th of the data
  for(int i = 0; i < rawData.length; i+=5){
    if(rawData[i] != 255){
     //found something
     foundUsers = true;
     break;
    }
    
    
   
  }


  fill(0);
  textSize(55);
  text(kinect.getNumOfUsers(), 50, 300);
  text("Found User: "+foundUsers, 50, 400);
  //text(frameRate, 50, 130);
  
   if (contourBodyIndex)
    image(kinect.getBodyTrackImage(), 512, 0);
  else
    image(kinect.getPointCloudDepthImage(), 512, 0);

  if (contourBodyIndex) {
    opencv.loadImage(kinect.getBodyTrackImage());
    opencv.gray();
    opencv.threshold(threshold);
    PImage dst = opencv.getOutput();
  } else {
    opencv.loadImage(kinect.getPointCloudDepthImage());
    opencv.gray();
    opencv.threshold(threshold);
    PImage dst = opencv.getOutput();
  }

  ArrayList<Contour> contours = opencv.findContours(false, false);

  if (contours.size() > 0) {
    for (Contour contour : contours) {

      contour.setPolygonApproximationFactor(polygonFactor);
      if (contour.numPoints() > 50) {

        stroke(0, 200, 200);
        beginShape();

        for (PVector point : contour.getPolygonApproximation ().getPoints()) {
          vertex(point.x + 512*2, point.y);
        }
        endShape();
      }
    }
  }

  noStroke();
  fill(0);
  rect(0, 0, 130, 100);
  fill(255, 0, 0);
  text("fps: "+frameRate, 20, 20);
  text("threshold: "+threshold, 20, 40);
  text("minD: "+minD, 20, 60);
  text("maxD: "+maxD, 20, 80);

  kinect.setLowThresholdPC(minD);
  kinect.setHighThresholdPC(maxD);
  
}



void keyPressed() {
  //change contour finder from contour body to depth-PC
  if( key == 'b'){
   contourBodyIndex = !contourBodyIndex;
   if(contourBodyIndex)
     threshold = 200;
    else
     threshold = 40;
  }

  if (key == 'a') {
    threshold+=1;
  }
  if (key == 's') {
    threshold-=1;
  }

  if (key == '1') {
    minD += 10;
  }

  if (key == '2') {
    minD -= 10;
  }

  if (key == '3') {
    maxD += 10;
  }

  if (key == '4') {
    maxD -= 10;
  }

  if (key == '5')
    polygonFactor += 0.1;

  if (key == '6')
    polygonFactor -= 0.1;
}
