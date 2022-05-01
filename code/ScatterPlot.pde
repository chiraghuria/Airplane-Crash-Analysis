
import processing.opengl.*;
PFont label ;
float k=0;

ArrayList<Exo> Circles = new ArrayList();
float o=0;
float maxax=0;
float ER = 1;          
float AU = 1500;        
float YEAR = 50000;

// Max/Min numbers
float maxTemp = 3257;
float minTemp = 3257;

float yMax = 10;
float yMin = 0;

float maxSize = 0;
float minSize = 1000000;

// Axis labels
String xLabel = "Years";
String yLabel = "Size";

// Rotation Vectors - control the main 3D space
PVector rot = new PVector();
PVector trot = new PVector();

// Master zoom
float zoom = 0;
float tzoom = 0.3;

// This is a zero-one weight that controls whether the aboards are less
// plane (0) or not (1)
float flatness = 0;
float tflatness = 0;

// add controls (e.g. zoom, sort selection)
Controls controls; 
int showControls;
boolean draggingZoomSlider = false;

void setup() {
  size(displayWidth, displayHeight, OPENGL);
  background(0);
  smooth();  
label= createFont("Helvetica", 92);
  textFont(label,92);

  getCircles("KeplerData.csv");
  println(Circles.size());

  updatePlanetColors();
  
  controls = new Controls();
  showControls = 1;
  
}

void getCircles(String url) {
  // Here, the data is loaded and a arrayList is made from each line.
  String[] pArray = loadStrings(url);
 
  for (int i = 1; i < pArray.length; i++) {
    Exo p;
  
      p = new Exo().fromCSV(split(pArray[i], ",")).init();

    
    Circles.add(p);
    maxSize = max(p.radius, maxSize);
    minSize = min(p.radius, minSize);

   
  }
}

void updatePlanetColors()
{
  // Calculate overall min/max aboards 
  for (int i = 0; i < Circles.size(); i++)
  {
    Exo p = Circles.get(i);
    maxTemp = max(p.temp, maxTemp);
    minTemp = min(abs(p.temp), minTemp);
  }

  colorMode(HSB);
  for (int i = 0; i < Circles.size(); i++)
  {
    Exo p = Circles.get(i);

    if (0 < p.temp)
    {
      float h = map(sqrt(p.temp), sqrt(minTemp), sqrt(maxTemp), 200, 0);
      p.col = color(h, 255, 255);
    }
    else
    {
      //color for the aboards less then 20
      p.col = color(200, 255, 255);
    }
  }
  colorMode(RGB);
}




void draw() {
  // Ease rotation vectors, zoom
  zoom += (tzoom - zoom) * 0.01;     
  if (zoom < 0)  {
     zoom = 0;
  } else if (zoom > 3.0) {
     zoom = 3.0;
  }
  controls.updateZoomSlider(zoom);  
  rot.x += (trot.x - rot.x) * 0.1;
  rot.y += (trot.y - rot.y) * 0.1;
  rot.z += (trot.z - rot.z) * 0.1;

  // Ease the flatness weight
  flatness += (tflatness - flatness) * 0.1;

  // MousePress - Controls Handling 
  if (mousePressed) {
     if((showControls == 1) && controls.isZoomSliderEvent(mouseX, mouseY)) {
        draggingZoomSlider = true;
        zoom = controls.getZoomValue(mouseY);        
        tzoom = zoom;
     } 
     
     // MousePress - Rotation Adjustment
     else if (!draggingZoomSlider) {
       trot.x += (pmouseY - mouseY) * 0.01;
       trot.z += (pmouseX - mouseX) * 0.01;
     }
  }



  background(10);
  
  // show controls
  if (showControls == 1) {
     controls.render(); 
  }
    
  // We want the center to be in the middle and slightly down when flat, and to the left and down when raised
  translate(width/2 - (width * flatness * 0.4), height/2 + (160 * rot.x));
  rotateX(rot.x);
  rotateZ(rot.z);
  scale(zoom);

  // Draw the centre
  fill(255 - (255 * flatness));
  noStroke();
  ellipse(0, 0, 10, 10);

  // Draw rings:
  strokeWeight(2);
  noFill();

  // Draw second ring
  stroke(255, 100 - (90 * flatness));
  ellipse(0, 0, AU * 2, AU * 2);

  // Draw third ring
  stroke(255, 50 - (40 * flatness));
  ellipse(0, 0, AU, AU);

  // Draw outer ring
  ellipse(0, 0, AU * 10, AU * 10);

  // Draw the Y Axis
  stroke(255, 100);
  pushMatrix();
  rotateY(-PI/2);
  line(0, 0, 500 * flatness, 0);

  // Draw Y Axis max/min
  pushMatrix();
  fill(255, 100 * flatness);
  rotateZ(PI/2);
  textFont(label);
  textSize(30);
  text(round(yMin), -textWidth(str(yMin)), 0);
  text(round(yMax), -textWidth(str(yMax)), -500);
  popMatrix();

  // Draw Y Axis Label
  fill(255, flatness * 255);
  text(yLabel, 250 * flatness, -10);

  popMatrix();

  // Draw the X Axis if we are not flat
  pushMatrix();
  rotateZ(PI/2);
  line(0, 0, 1500 * flatness, 0);

  if (flatness > 0.5) {
    pushMatrix();
    rotateX(PI/2);
    line(AU * 1.06, -10, AU * 1.064, 10); 
    line(AU * 1.064, -10, AU * 1.068, 10);   
    popMatrix();
  }

  // Draw X Axis Label
  fill(255, flatness * 255);
  rotateX(-PI/2);
  text(xLabel, 50 * flatness, 72);

  // Draw X Axis min/max
  fill(255, 100 * flatness);
  text(" ", AU, 60);
  text(" ", AU/2, 60);

  popMatrix();

  // Render the data
  for (int i = 0; i < Circles.size(); i++) {
    Exo p = Circles.get(i);

      p.update();
      p.render();
    
  }    
  

  

  
}

void sortBySize() {
  // Raise the Circles off of the plane according to their size
  for (int i = 0; i < Circles.size(); i++) {
    Circles.get(i).tz = map(Circles.get(i).radius, 0, maxSize, 0, 500);
  }
}

void sortByTemp() {
  // Raise the Circles off of the plane according to their temperature
  for (int i = 0; i < Circles.size(); i++) {
    Circles.get(i).tz = map(Circles.get(i).temp, minTemp, maxTemp, 0, 500);
  }
}

void unSort() {
  // Put all of the Circles back onto the plane
  for (int i = 0; i < Circles.size(); i++) {
    Circles.get(i).tz = 0;
  }
}

void keyPressed() {
  String timeStamp = hour() + "_"  + minute() + "_" + second();
  if (key == 's') {
    save("out/Kepler" + timeStamp + ".png");
  } else if (key == 'c'){
     showControls = -1 * showControls;
  }

  if (keyCode == UP) {
    tzoom += 0.025;
  } 
  else if (keyCode == DOWN) {
    tzoom -= 0.025;
  }

  if (key == '1') {
    sortBySize(); 
    toggleFlatness(1);
    yLabel = "Aboard";
    yMax = maxSize;
    yMin = 0;
  } 
  else if (key == '2') {
    sortByTemp(); 
    trot.x = PI/2;
    yLabel = "Aboard";
    //toggleFlatness(1);
    yMax = 644;
    yMin = 0;
  } 
  else if (key == '`') {
    unSort(); 
    toggleFlatness(0);
  }
  else if (key == '3') {
    trot.x = 1.5;
  }
  else if (key == '4') {
    tzoom = 1;
  }

  if (key == 'f') {
    tflatness = (tflatness == 1) ? (0):(1);
    toggleFlatness(tflatness);
  }
}

// MouseWheel - zoom controller (auto-triggered on event: mousewheel)
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  float tempzoom = zoom;
  if (tempzoom >= controls.minZoomValue && tempzoom <= controls.maxZoomValue) {
    if (tempzoom >0.15) {
      tempzoom += (e*(0.05*tempzoom));
    } else { //tempzoom >= 0.15
      tempzoom += (e*0.0075);
    }
  }
  if (tempzoom < controls.maxZoomValue && tempzoom > controls.minZoomValue) { 
    tzoom = tempzoom + (e * (0.112*tempzoom)); 
    zoom = tempzoom;
  }
}

void toggleFlatness(float f) {
  tflatness = f;
  if (tflatness == 1) {
    trot.x = PI/2;
    trot.z = -PI/2;
  }
  else {
    trot.x = 0;
  }
}

void mouseReleased() {
   draggingZoomSlider = false;
}