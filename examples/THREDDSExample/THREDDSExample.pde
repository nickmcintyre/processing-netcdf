/**
 * THREDDS Example.
 *
 * Load weather data from the Unidata Test THREDDS Data Server, then
 * display surface wind velocity and temperature. Visualization gratefully
 * borrowed from p5.js. (CC BY-NC-SA)
 *
 * https://p5js.org/examples/hello-p5-weather.html
 */
import netcdf.*;

PDataset data;
PVector position;
PVector wind;
String temp, wspd;

void setup() {
  size(720, 200);
  
  data = new PDataset(this);
  String url = "https://thredds-jumbo.unidata.ucar.edu/thredds/dodsC/grib/HRRR/CONUS_3km/surface/TwoD";
  data.openFile(url);

  data.loadData("u-component_of_wind_height_above_ground", "0:1,0:1,0:1,0:1,0:1");
  data.loadData("v-component_of_wind_height_above_ground", "0:1,0:1,0:1,0:1,0:1");
  data.loadData("Temperature_surface", "0:1,0:1,0:1,0:1");
  
  float[][][][][] u = data.get5DFloatArray("u-component_of_wind_height_above_ground");
  float[][][][][] v = data.get5DFloatArray("v-component_of_wind_height_above_ground");
  float[][][][] t = data.get4DFloatArray("Temperature_surface");
  
  position = new PVector(width/2, height/2);
  wind = new PVector(u[0][0][0][0][0], v[0][0][0][0][0]);
  temp = String.format("%.1f˚C", t[0][0][0][0] - 272.15);
  wspd = String.format("%.1f m/s", wind.mag());
  
  data.close();
}

void draw() {
  background(200);
  
  pushMatrix();
  // Display temperature and windspeed
  textSize(16);
  text(temp, 64, height - 32);
  text(wspd, 64, height - 16);
  
  translate(32, height - 32);
  // Rotate by the wind's angle
  rotate(wind.heading() + PI/2);
  noStroke();
  fill(255);
  ellipse(0, 0, 48, 48);

  stroke(45, 123, 182);
  strokeWeight(3);
  line(0, -16, 0, 16);

  noStroke();
  fill(45, 123, 182);
  triangle(0, -18, -6, -10, 6, -10);
  popMatrix();
  
  // Move in the wind's direction
  position.add(wind);
  
  stroke(0);
  fill(51);
  ellipse(position.x, position.y, 16, 16);

  if (position.x > width)  position.x = 0;
  if (position.x < 0)      position.x = width;
  if (position.y > height) position.y = 0;
  if (position.y < 0)      position.y = height;
}
