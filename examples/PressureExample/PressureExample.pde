/**
 * Pressure Example.
 *
 * Load WRF (weather) data from an netCDF file, then animate the
 * change in surface pressure over time. Visit the UCAR website
 * https://www.mmm.ucar.edu/weather-research-and-forecasting-model
 * for tutorials and datasets.
 *
 */
import netcdf.PDataset;

PDataset data;
float[][][] press;
float maxP, minP;
int NSTEPS, NLAT, NLON;
int t;

void setup() {
  size(300, 365);

  // Open the dataset and read surface pressure
  data = new PDataset(this);
  String filename = dataPath("wrfout_v2_Lambert.nc");
  data.openFile(filename);
  data.readData("PSFC", ":,:,:", "press");

  // Find the maximum and minimum surface pressure
  FloatList p = data.getFloatList("press");
  maxP = p.max();
  minP = p.min();

  // Load the surface pressure into a 3D array and get its dimensions
  press = (float[][][]) data.getNDJavaArray("press");
  int[] shape = data.getShape("press");
  NSTEPS = shape[0];
  NLAT = shape[1];
  NLON = shape[2];

  data.close();

  t = 1;
  noStroke();
  frameRate(1);
}

void draw() {
  pushMatrix();
  // Invert the y-axis
  scale(1, -1);
  translate(0, -height);
  // Use grayscale to represent surface pressure
  for (int j = 0; j < NLAT; j++) {
    for (int k = 0; k < NLON; k++) {
      fill(map(press[t][j][k], minP, maxP, 0, 255));
      rect(j*5, k*5, 5, 5);
    }
  }
  
  popMatrix();
  // Update the time step
  t++;
  if (t >= NSTEPS) {
    t = 1;
  }
}
