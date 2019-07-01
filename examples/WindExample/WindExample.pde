/**
 * Wind Example.
 *
 * Load WRF (weather) data from an netCDF file, then draw a vector
 * field representing the wind. Visit the UCAR and OpenWFM websites
 * https://www.mmm.ucar.edu/weather-research-and-forecasting-model
 * http://www.openwfm.org/wiki/How_to_interpret_WRF_variables
 * for tutorials and datasets.
 */
import netcdf.*;

PDataset data;
float[][][][] u, v, w, ph, phb, elev;
int NSTEPS, NLAT, NLON, NVERT;
int step, delta;
float minWind, maxWind, windRange;

void setup() {
  size(600, 730, P3D);

  // Open the dataset and read wind components
  data = new PDataset(this);
  String filename = dataPath("wrfout_v2_Lambert.nc");
  data.openFile(filename);
  // Load the wind components into 4D arrays and get the dimensions
  data.readData("U", ":,:,:,:", "u");
  u = (float[][][][]) data.getNDJavaArray("u");
  data.readData("V", ":,:,:,:", "v");
  v = (float[][][][]) data.getNDJavaArray("v");
  data.readData("W", ":,:,:,:", "w");
  w = (float[][][][]) data.getNDJavaArray("w");
  data.readData("PH", ":,:,:,:", "ph");
  ph = (float[][][][]) data.getNDJavaArray("ph");
  data.readData("PHB", ":,:,:,:", "phb");
  phb = (float[][][][]) data.getNDJavaArray("phb");
  int[] shape = data.getShape("phb");

  data.close();

  NSTEPS = shape[0];
  NVERT = shape[1] - 1;
  NLAT = shape[2];
  NLON = shape[3];
  elev = new float[NSTEPS][NVERT][NLAT][NLON];
  step = 1;
  delta = 1;
  minWind = 10;
  maxWind = 0;
  windRange = 0;
  
  interpolateWind();
  interpolateElevation();
  getWindRange();
  frameRate(5);
}

void draw() {
  background(255);
  camera(mouseX, mouseY, (height/2) / tan(PI/6), width/2, height/2, 0, 0, 1, 0);
  pushMatrix();
  // Invert the y-axis
  scale(1, -1);
  translate(0, -height);
  for (int i = 0; i < NVERT; i++) {
    for (int j = 0; j < NLAT; j++) {
      for (int k = 0; k < NLON; k++) {
        float m = mag(u[step][i][j][k], v[step][i][j][k], w[step][i][j][k]);
        float[] start = {k*5, 0.25*elev[step][i][j][k], j*5};
        float[] end = {start[0] + 5*v[step][i][j][k]/m, start[1] + 5*w[step][i][j][k]/m, start[2] + 5*u[step][i][j][k]/m};
        stroke(lerpColor(255, 0, (m - minWind)/windRange));
        line(start[0], start[1], start[2], end[0], end[1], end[2]);
      }
    }
  }

  popMatrix();
  // Update the time step
  step += delta;
  if (step > NSTEPS - 2 || step < 1 ) {
    delta *= -1;
  }
}

// Interpolate wind components to theta points (cell centers)
// Note: it turns out indices are not in the same order, nor the same size
// http://www.openwfm.org/wiki/How_to_interpret_WRF_variables#Wind
void interpolateWind() {
  for (int t = 0; t < u.length; t++) {
    for (int i = 0; i < u[0].length; i++) {
      for (int j = 0; j < u[0][0].length - 1; j++) {
        for (int k = 0; k < u[0][0][0].length; k++) {
          u[t][i][j][k] = 0.5*(u[t][i][j][k] + u[t][i][j+1][k]);
        }
      }
    }
  }

  for (int t = 0; t < v.length; t++) {
    for (int i = 0; i < v[0].length; i++) {
      for (int j = 0; j < v[0][0].length; j++) {
        for (int k = 0; k < v[0][0][0].length - 1; k++) {
          v[t][i][j][k] = 0.5*(v[t][i][j][k] + v[t][i][j][k+1]);
        }
      }
    }
  }

  for (int t = 0; t < w.length; t++) {
    for (int i = 0; i < w[0].length - 1; i++) {
      for (int j = 0; j < w[0][0].length; j++) {
        for (int k = 0; k < w[0][0][0].length; k++) {
          w[t][i][j][k] = 0.5*(w[t][i][j][k] + w[t][i+1][j][k]);
        }
      }
    }
  }
}

// Interpolate elevation to theta points (cell centers)
// http://www.openwfm.org/wiki/How_to_interpret_WRF_variables#Location
void interpolateElevation() {
  for (int t = 0; t < ph.length; t++) {
    for (int i = 0; i < ph[0].length - 1; i++) {
      for (int j = 0; j < ph[0][0].length - 1; j++) {
        for (int k = 0; k < ph[0][0][0].length; k++) {
          elev[t][i][j][k] = 0.5*(phb[t][i][j][k] + ph[t][i][j][k] + ph[t][i + 1][j][k] + phb[t][i + 1][j][k])/9.81;
        }
      }
    }
  }

  ph = null;
  phb = null;
}

// Calculate the range of wind values in the dataset
void getWindRange() {
  for (int t = 0; t < NSTEPS; t++) {
    for (int i = 0; i < NVERT; i++) {
      for (int j = 0; j < NLAT; j++) {
        for (int k = 0; k < NLON; k++) {
          float m = mag(u[t][i][j][k], v[t][i][j][k], w[t][i][j][k]);
          maxWind = max(maxWind, m);
          minWind = min(minWind, m);
        }
      }
    }
  }
  
  windRange = maxWind - minWind;
}
