package netcdf;

import java.io.IOException;
import java.util.List;
import java.util.HashMap;

import processing.core.PApplet;
import processing.data.FloatList;

import ucar.nc2.NetcdfFile;
import ucar.nc2.dataset.NetcdfDataset;
import ucar.nc2.Dimension;
import ucar.nc2.Variable;
import ucar.ma2.Array;
import ucar.ma2.InvalidRangeException;

/**
 * ##library.name##
 * ##library.sentence##
 * ##library.url##
 *
 * 
 * @author      ##author##
 * @modified    ##date##
 * @version     ##library.prettyVersion## (##library.version##)
 *
 * @example InspectExample
 * @example VisualizeExample
 */
public class PDataset {
	
	public PApplet parent;
	public static HashMap<String, ucar.ma2.Array> variables;
	
	private static String filename;
	private static NetcdfFile ncfile;

	/**
	 * Initialize the PDataset object.
	 * 
	 * @param theParent
	 */
	public PDataset(PApplet theParent) {
		parent = theParent;
		parent.registerMethod("dispose", this);
		ncfile = null;
		filename = null;
		variables = new HashMap<String, Array>();
	}
	
	/**
	 * Open a dataset for inspection.
	 * 
	 * @param theFile
	 */
	public void openFile(String theFile) {
		filename = theFile;
		try {
			ncfile = NetcdfDataset.openFile(filename, null);
		    System.out.println("Loading " + filename);
		} catch (IOException ioe) {
		    System.out.println("Trying to open " + filename);
		    System.out.println(ioe);
		}
	}
	
	/**
	 * Close a dataset. 
	 * 
	 */
	public void close() {
		if (null != ncfile) {
			try {
				ncfile.close();
				ncfile = null;
			} catch (IOException ioe) {
				System.out.println("Trying to close " + filename);
				System.out.println(ioe);
			}
		}	
	}
	
	/**
	 * Get the dimensions of a dataset.
	 * 
	 * @return {@code List<Dimension>} containing dimensions
	 */
	public List<Dimension> getDimensions() {
		return ncfile.getDimensions();
	}
	
	/**
	 * Get the variables included in a dataset.
	 * 
	 * @return {@code List<Variable>} containing variables
	 */
	public List<Variable> getVariables() {
		return ncfile.getVariables();
	}
	
	/**
	 * Find a variable with the specified name.
	 * 
	 * @param fullNameEscaped
	 * @return null if no dataset is open, {@code Variable} otherwise
	 */
	public Variable findVariable(String fullNameEscaped) {
		if (null != ncfile) {
			return ncfile.findVariable(fullNameEscaped);
		}
		
		return null;
	}
	
	/**
	 * Read data from a variable with a section specifier and store
	 * with a shortened name.
	 * 
	 * @param fullNameEscaped
	 * @param sectionSpec
	 * @param shortName
	 */
	public void readData(String fullNameEscaped, String sectionSpec, String shortName) {
		if (null != ncfile) {
			try {
				Variable v = ncfile.findVariable(fullNameEscaped);
				ucar.ma2.Array data = v.read(sectionSpec);
				if (null != data) {
					variables.put(shortName, data);
				}
				
			} catch (IOException | InvalidRangeException ex) {
				System.out.println(ex);
			}
		}
	}
	
	/**
	 * Read data from a variable with a section specifier.
	 * 
	 * @param fullNameEscaped
	 * @param sectionSpec
	 */
	public void readData(String fullNameEscaped, String sectionSpec) {
		readData(fullNameEscaped, sectionSpec, fullNameEscaped);
	}
	
	/**
	 * Read data from a variable.
	 * 
	 * @param fullNameEscaped
	 */
	public void readData(String fullNameEscaped) {
		readData(fullNameEscaped, "", fullNameEscaped);
	}
	
	/**
	 * Get the array backing a variable. 
	 * 
	 * @param shortName
	 * @return {@code ucar.ma2.Array} containing data
	 */
	public ucar.ma2.Array get(String shortName) {
		return variables.get(shortName);
	}
	
	/**
	 * Get a FloatList representation of a variable.
	 * 
	 * @param shortName
	 * @return data
	 */
	public FloatList getFloatList(String shortName) {
		int numSteps = (int) get(shortName).getSize();
		FloatList data = new FloatList(numSteps);
		for (int i = 0; i < numSteps; i++) {
			data.append(get(shortName).getFloat(i));
		}
		
		return data;
	}
	
	/**
	 * Close the dataset upon exiting the sketch.
	 * 
	 */
	public void dispose() {
		variables = null;
		close();
	}
}
