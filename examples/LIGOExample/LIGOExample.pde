/**
 * LIGO Example.
 * 
 * Load LIGO (gravitational wave) data from an HDF5 file, then plot the
 * strain using a series of points. Visit the Graviational Wave Open
 * Science Center https://www.gw-openscience.org/about/ for tutorials
 * and datasets.
 * 
 */
import netcdf.PDataset;

PDataset data;
FloatList strain;

void setup() {
  size(1000, 250);
  
  data = new PDataset(this);
  String filename = dataPath("H-H1_LOSC_4_V1-815411200-4096.hdf5");
  data.openFile(filename);
  data.readData("strain/Strain", "0:999", "strain");
  
  DoubleList raw = data.getDoubleList("strain");
  strain = scaleData(raw);
  
  data.close();
  
  strokeWeight(2);
  stroke(0, 0, 255);
}

void draw() {
  background(255);
  
  pushMatrix();
  scale(1, -1);
  translate(0, -height);
  for (int i = 0; i < strain.size(); i++) {
    point(2*i + 1, height/2 + strain.get(i));
  }
  popMatrix();
}

// Scale the strain data from the interferometer
FloatList scaleData(DoubleList raw) {
  FloatList scaled = new FloatList(raw.size());
  
  for (int i = 0; i < raw.size(); i++) {
    scaled.append((float) raw.get(i)*pow(11, 16));
  }
  
  return scaled;
}
