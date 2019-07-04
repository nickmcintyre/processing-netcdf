/**
 * Inspect Example.
 *
 * Load weather data from the Unidata Test THREDDS Data Server, then
 * print information on a variable.
 */
import netcdf.*;

PDataset data;

data = new PDataset(this);
String url = "https://thredds-jumbo.unidata.ucar.edu/thredds/dodsC/grib/HRRR/CONUS_3km/surface/TwoD";
data.openFile(url);

println("Inspecting 'Temperature_surface' variable...");
Table info = data.getInfo("Temperature_surface");
info.print();

println();
if (data.getRank("Temperature_surface") == info.getRowCount()) {
  println("We have information on ALL dimensions!");
} else {
  println("Uh oh...");
}

data.close();
