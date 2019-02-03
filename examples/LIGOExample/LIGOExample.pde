/**
 * LIGO Example.
 *
 * Load LIGO (gravitational wave) data from an HDF5 file, then plot the
 * strain using a series of line segments. Visit the Graviational Wave Open
 * Science Center https://www.gw-openscience.org/about/ for tutorials
 * and datasets.
 *
 */
import netcdf.PDataset;

PDataset data;
FloatList strain;
float start;
int step;

void setup() {
  size(1000, 350);

  data = new PDataset(this);
  String filename = dataPath("H-H1_LOSC_4_V1-815411200-4096.hdf5");
  data.openFile(filename);
  data.readData("strain/Strain", "0:8999", "strain");
  strain = scaleData(data.getDoubleList("strain"));
  start = data.findVariable("strain/Strain").getAttributes().get(0).getNumericValue().floatValue();
  step = round(1/data.findVariable("strain/Strain").getAttributes().get(5).getNumericValue().floatValue()/10);

  data.close();
}

void draw() {
  background(255);

  // Draw plot title
  textSize(18);
  textAlign(CENTER, CENTER);
  text("Waves, waves, waves", width/2, 20);

  // Draw y-axis
  stroke(0);
  line(50, 50, 50, height - 50);
  line(width - 50, 50, width - 50, height - 50);
  for (int y = 0; y <= 100; y += 50) {
    line(width - 50, height/2 - y, width - 60, height/2 - y);
    line(width - 50, height/2 + y, width - 60, height/2 + y);
    line(50, height/2 - y, 60, height/2 - y);
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
  fill(0);
  text("H1 Strain (E-15)", 0, 0);
  popMatrix();

  // Draw x-axis
  line(50, 50, width - 50, 50);
  line(50, height - 50, width - 50, height - 50);
  for (int x = 50; x <= width; x += step/2) {
    line(x, height - 50, x, height - 60);
    line(x, 50, x, 60);
  }

  // Draw x labels
  text(String.format("+%1.8E", start), width - 110, height - 10);
  textAlign(CENTER, CENTER);
  text("0", 50, height - 40);
  text("0.5", 50 + step/2, height - 40);
  text("1", 50 + 2*step/2, height - 40);
  text("1.5", 50 + 3*step/2, height - 40);
  text("2", 50 + 4*step/2, height - 40);

  // Draw x title
  textAlign(CENTER, BOTTOM);
  text("GPS Time (s)", width/2, height - 10);

  // Plot every tenth data point
  pushMatrix();
  stroke(0, 0, 255);
  scale(1, -1);
  translate(0, -height);
  for (int i = 1; i < strain.size()/10; i++) {
    line(i - 1 + 50, height/2 + strain.get(i*10 - 10), i + 50, height/2 + strain.get(i*10));
  }
  
  popMatrix();
}

// Scale the strain data to fit the window
FloatList scaleData(DoubleList raw) {
  FloatList scaled = new FloatList(raw.size());
  for (int i = 0; i < raw.size(); i++) {
    scaled.append((float) raw.get(i)*pow(10, 17));
  }

  return scaled;
}
