/*
PixelFlow for using pixels in Earth and also for using Intels Graphics
PeasyCam for rotation of globe about its axis
Softbodydynamics for making graphics smooth
PShape for adding texture 
PGraphics for 3rd plotting of data
*/


import java.util.ArrayList;
import java.util.Locale;
import peasy.*;
import com.thomasdiewald.pixelflow.java.*;
import com.thomasdiewald.pixelflow.java.accelerationstructures.*;
import com.thomasdiewald.pixelflow.java.dwgl.*;
import com.thomasdiewald.pixelflow.java.fluid.*;
import com.thomasdiewald.pixelflow.java.geometry.*;
import com.thomasdiewald.pixelflow.java.imageprocessing.*;
import com.thomasdiewald.pixelflow.java.imageprocessing.filter.*;
import com.thomasdiewald.pixelflow.java.render.skylight.*;
import com.thomasdiewald.pixelflow.java.rigid_origami.*;
import com.thomasdiewald.pixelflow.java.sampling.*;
import com.thomasdiewald.pixelflow.java.softbodydynamics.*;
import com.thomasdiewald.pixelflow.java.softbodydynamics.constraint.*;
import com.thomasdiewald.pixelflow.java.softbodydynamics.particle.*;
import com.thomasdiewald.pixelflow.java.softbodydynamics.softbody.*;
import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.softbodydynamics.DwPhysics;
import com.thomasdiewald.pixelflow.java.softbodydynamics.constraint.DwSpringConstraint;
import com.thomasdiewald.pixelflow.java.softbodydynamics.particle.DwParticle;
import com.thomasdiewald.pixelflow.java.softbodydynamics.particle.DwParticle3D;
import com.thomasdiewald.pixelflow.java.softbodydynamics.softbody.DwSoftBody3D;
import com.thomasdiewald.pixelflow.java.softbodydynamics.softbody.DwSoftGrid3D;
import com.thomasdiewald.pixelflow.java.utils.*;
import com.thomasdiewald.pixelflow.java.utils.DwCoordinateTransform;
import processing.core.PApplet;
import processing.core.PShape;
import processing.opengl.PGraphics3D;
int b=0;
int h=0;
PShader blur;
int amp2=0;
float noise1=0;
float noise2=0;
Table table;
Table main;                          //contains main database 
Table america;                       //contains data of all American States
String[] name1=new String[4000];     //for loading names of Countries
String[] state1=new String[4000];    //for loading names of American States
float[] lat1=new float[4000];        //contains latitude of Countries
float[] lon1=new float[4000];        //contains longitude of Countries
float[] lat2=new float[4000];        //contains latitude of American States
float[] lon2=new float[4000];        //contains latitude of American States
float[] lat3=new float[4000];        //contains latitude(of entire data)
float[] lon3=new float[4000];        //contains longitude(of entire data)
int count3=0;                        //counter
PImage backdrop;                     //loads background image
int[] count2=new int[2500];          //Second counter
int x=0;                             //Variables for color Code
int i=0;
int t=0;
int amp=0;                           //amplitude  
PeasyCam cam;
float rad1=0;                        //radians for longitude and latitude
PImage starfield;                    
int[] count1=new int[180];
PShape sun;                          // shape of Globe
PImage suntex;                       // surface
int[] totd4=new int[250];
PShape planet1;                     
PImage surftex1;
PImage cloudtex;
 DwPixelFlow context;
PShape planet2;
PImage surftex2; 
PVector[] vecs = new PVector[1000];
 
void setup() {
  size(1024,900, P3D);
  backdrop = loadImage("back.png");     // Image
  int q=0;
  smooth(8);                               // Smoothness of pixels
  context = new DwPixelFlow(this);
  context.print();
  context.printGL();
  blur = loadShader("blur.glsl");        // shader  
  cam = new PeasyCam(this, 6000);  
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(50000);
  starfield = loadImage("starfield.jpg");
  suntex = loadImage("hardik map-3037x1519-2277x1139.jpg"); // Surface of globe 
  surftex1 = loadImage("planet.jpg");  
  table = loadTable("Air.csv", "header");
  main=loadTable("LocationFilteredAirplane_Crashes_and_Fatalities_Since_1908 .csv","header");
  america=loadTable("Statae_LLocation_LongLAt.csv","header");
  surftex2 = loadImage("mercury.jpg");  
  noStroke();
  fill(255);
  sphereDetail(40);
  sun = createShape(SPHERE, 1500);                //creates sphere for plotting of data
  sun.setTexture(suntex);  
  planet1 = createShape(SPHERE, 150);
  planet1.setTexture(surftex1);
  planet2 = createShape(SPHERE, 50);
  planet2.setTexture(surftex2);
  for (int j=0; j<1000; j++) {
    vecs[j] = new PVector(0,0,0);                   //adding vectors for chaning the lines according to latitude and longitude
}
    
    // prints the database
    
    println(table.getRowCount() + " total rows in table"); 
    println(main.getRowCount() + " total rows in table");
    println(america.getRowCount() + " total rows in table");
    for (TableRow row : table.rows()) {
      t=0;
      x++;
    
    //loads the data in the array variables
      float lon = row.getFloat("Longitude");
      float lat = row.getFloat("Latitude");
      int totd2 = row.getInt("Total Death");
      String name = row.getString("Name");
  /*
  Sorting the database
  Arranging data in corresponding variables
  Counting and deleting the duplicate countries
  */
        for(i=0;i<=q;i++)
        {
          if(name.equals(name1[i])== true)
          { 
            t=1;
            count1[i]++;
            count2[i]+=totd2;
          }  
        }
        if(t==0)
        {

          count1[q]++;
          lon1[q]=lon;
          lat1[q]=lat;
          name1[q]=name;
          count2[q]+=totd2;
          q++;
        } 
        t=0;
      }
      for(int i=0;i<=5000;i++)
      {
        b=b+count1[i];
        if(name1[i]== null)
      {break;}
      println(i+1 + " " + name1[i] +" " + lon1[i]+" " +lat1[i] + "    " +count2[i] +"  "   );
    }
    for (TableRow row : america.rows()){
      String statesamer = row.getString("State");            //Adding American states in the data

      float lon4 = row.getFloat("Longitude");                 //Adding longitude 
      float lat4 = row.getFloat("Latitude");                  //Adding latitude
      state1[h]=statesamer;
      lon2[h]=lon4;
      lat2[h]=lat4;
      h++;
}
for (TableRow row : main.rows()){
  String state2 = row.getString("Location - Split 2");
  int totd3 = row.getInt("Total Death");
  for(int u=0;u<=50;u++)
  {
    if(state2.equals(state1[u])== true)
    {
      totd4[u]=totd4[u]+totd3;
    }
  }
}
for(int u=0;u<=50;u++)
{
  println(u+176 + " " + state1[u] +" " + lon2[u]+" " +lat2[u] + "    " +totd4[u] +"  "  );
}
int p=0;
for(int r=176;r<=230;r++)
{
  name1[r]=state1[p];
  lon1[r]=lon2[p];
  lat1[r]=lat2[p];
  count2[r]=totd4[p];
  p++;
}
for(int r=0;r<=226;r++)
{
  println(r+1 + " " + name1[r] +" " + lon1[r]+" " +lat1[r] + "    " +count2[r] +"  "   );
}
int f=0;;
for(int r=0;r<=226;r++)
{
  if(count2[r]>=6500 )
{
  f++;
  println(f);
}
}
frameCount=100;
  }
void draw() {
  randomSeed(0);                  //Makes the random variables fix corresponding to its first loop value 
  delay(30);
  background(0);                 
  stroke(255,0,0);
  strokeWeight(20);
  hint(DISABLE_DEPTH_MASK);
  hint(ENABLE_DEPTH_MASK);
  pushMatrix();                    //Translates the matrix
  shape(sun);                      //Loads the Sun
  popMatrix();
  for (int i=1; i<230;i++) {
    amp=count2[i];
    stroke(255,0,255);
    if(amp<=500)
  {  
      stroke(34,34,255);
  }
      strokeWeight(2);
    if(amp>=6500)                   //Plotting 9/11 
  { 
      stroke(255,0,0);
      strokeWeight(4);
  }                               //Plotting data using lines by its latitude and longitude
  line((2000+amp/10)*cos(radians(lat1[i]))*sin(radians(lon1[i]-90)),-(2000+amp/10)*sin(radians(lat1[i])),(2000+amp/10)*cos(radians(lat1[i]))*cos(radians(lon1[i]-90)),0,0,0);
  x=1;
  }
}