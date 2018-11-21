/* 
 * Inspect Example.
 *
 * Load weather data from the Unidata Test THREDDS Data Server, then
 * print information on units, coordinates, etc. 
 *  
 */
import netcdf.PDataset;

PDataset data;

void setup() {
  data = new PDataset(this);
  String filename = "https://thredds-jumbo.unidata.ucar.edu/thredds/dodsC/grib/HRRR/CONUS_3km/surface/TwoD";
  data.openFile(filename);
  
  println();
  print("Short name: ");
  println(data.getShortNames().get(0));
  println();
  print("Full name: ");
  println(data.getFullNames().get(0));
  println();
  println("Complete description:");
  println(data.getVariables().get(0));
  
  data.close();
}

void draw() {
  
}
