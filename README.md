# processing-netcdf
**Simple access to scientific datasets with Processing**

- Thin wrapper around the [Unidata NetCDF Java library](https://www.unidata.ucar.edu/software/thredds/current/netcdf-java/documentation.htm).
- Friendly API for scientific file formats and remote access protocols.
- GRIB 1/2, HDF 4/5, NetCDF 3/4, OPeNDAP, and [many more](https://www.unidata.ucar.edu/software/thredds/current/netcdf-java/reference/formats/FileTypes.html).

## Example
The following example loads the first observation of a gravitational wave from an [HDF5 file](https://www.gw-openscience.org/catalog/GWTC-1-confident/data/GW150914/H-H1_GWOSC_4KHZ_R1-1126257415-4096.hdf5) stored in the sketch's `data` folder, then plots the data (strain). Visit the [Graviational Wave Open Science Center](https://www.gw-openscience.org/about/) for tutorials and datasets.

![Plot of LIGO data](ligo.png)

```java
import netcdf.*;

PDataset data;
double[] strain;
float start;
float duration;

void setup() {
  size(1000, 350);

  data = new PDataset(this);
  String filename = dataPath("H-H1_GWOSC_4KHZ_R1-1126257415-4096.hdf5");
  data.openFile(filename);
  
  data.loadData("strain/Strain");
  data.loadData("meta/GPSstart");
  data.loadData("meta/Duration");
  
  strain = data.get1DDoubleArray("strain/Strain");
  // Access metadata contained in a NetCDF-Java Array object
  start = data.variables.get("meta/GPSstart").getFloat(0);
  duration = data.variables.get("meta/Duration").getFloat(0);
  
  data.close();

  noLoop();
}

void draw() {
  background(255);
  fill(0);
  stroke(0);
  
  // Draw plot title
  textSize(18);
  textAlign(CENTER, CENTER);
  text("Waves, waves, waves", width/2, 20);

  // Draw y-axis
  line(50, 50, 50, height - 50);
  line(width - 50, 50, width - 50, height - 50);
  for (int y = -100; y <= 100; y += 50) {
    line(width - 50, height/2 + y, width - 60, height/2 + y);
    line(50, height/2 + y, 60, height/2 + y);
  }

  // Draw y labels
  textSize(12);
  textAlign(CENTER, CENTER);
  text("1", 40, height/2 - 100);
  text("0.5", 38, height/2 - 50);
  text("0", 40, height/2);
  text("-0.5", 34, height/2 + 50);
  text("-1", 36, height/2 + 100);

  // Draw y title
  pushMatrix();
  textAlign(CENTER, BOTTOM);
  translate(20, height/2);
  rotate(-HALF_PI);
  text("H1 Strain (E-19)", 0, 0);
  popMatrix();

  // Draw x-axis
  line(50, 50, width - 50, 50);
  line(50, height - 50, width - 50, height - 50);
  for (int x = 50; x <= width - 50; x += 100) {
    line(x, height - 50, x, height - 60);
    line(x, 50, x, 60);
  }

  // Draw x labels
  text(String.format("+%1.8E", start), width - 110, height - 10);
  textAlign(CENTER, CENTER);
  for (int i = 0; i < 10; i++) {
    int t = int(i * duration / 9);
    text(t, 50 + i*100, height - 40);
  }

  // Draw x title
  textAlign(CENTER, BOTTOM);
  text("GPS Time (s)", width/2, height - 10);

  // Plot data points
  pushMatrix();
  stroke(0, 0, 255);
  scale(1, -1);
  translate(0, -height);
  for (int i = 0; i < strain.length; i++) {
    float x = map(i * (float)width/strain.length, 0, width, 50, width - 50);
    float y = height/2 + (float)strain[i]*pow(10, 19);
    point(x, y);
  }
  popMatrix();
}
```