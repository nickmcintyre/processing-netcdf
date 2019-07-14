package netcdf;

import java.io.IOException;
import java.util.List;
import java.util.HashMap;

import processing.core.PApplet;
import processing.data.FloatList;
import processing.data.DoubleList;
import processing.data.StringList;
import processing.data.Table;
import processing.data.TableRow;

import ucar.nc2.NetcdfFile;
import ucar.nc2.dataset.NetcdfDataset;
import ucar.nc2.Dimension;
import ucar.nc2.Variable;
import ucar.ma2.Array;
import ucar.ma2.Range;
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
 * @example LIGOExample
 * @example THREDDSExample
 * @example WRFExample
 */
public class PDataset {
	
	public PApplet parent;
	public HashMap<String, ucar.ma2.Array> variables;
	
	private String filename;
	private NetcdfFile ncfile;

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
		variables = new HashMap<String, ucar.ma2.Array>();
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
		    System.out.println("Opening " + filename + "\n");
		} catch (IOException ioe) {
		    System.out.println("Failed to open " + filename);
		    System.out.println(ioe);
		} finally {
			System.out.println("...done!\n");
		}
	}
	
	/**
	 * Close a dataset.
	 */
	public void close() {
		if (null != ncfile) {
			try {
				ncfile.close();
				ncfile = null;
			} catch (IOException ioe) {
				System.out.println("Failed to close " + filename);
				System.out.println(ioe);
			}
		}	
	}
	
	/**
	 * Get a Table containing information about a variable.
	 * 
	 * @param fullNameEscaped
	 * @return {@code Table} containing info
	 */
	public Table getInfo(String fullNameEscaped) {
		Table info = new Table();
		info.addColumn("name");
		info.addColumn("length");
		info.addColumn("range");
		
		Variable variable = ncfile.findVariable(fullNameEscaped);
		String[] names = variable.getDimensionsString().split("\\s");
		int[] lengths = variable.getShape();
		List<ucar.ma2.Range> ranges = variable.getRanges();
		int rank = variable.getRank();
		
		for (int i = 0; i < rank; i++) {
			TableRow newRow = info.addRow();
			newRow.setString("name", names[i]);
			newRow.setInt("length", lengths[i]);
			newRow.setString("range", ranges.get(i).toString());
		}
		
		return info;
	}
	
	/**
	 * Get a variable's number of dimensions (rank).
	 * 
	 * @param fullNameEscaped
	 * @return {@code int} number of dimensions
	 */
	public int getRank(String fullNameEscaped) {
		Variable variable = ncfile.findVariable(fullNameEscaped);
		int rank = variable.getRank();
		
		return rank;
	}
	
	/**
	 * Get the full names of variables included in a dataset.
	 * 
	 * @return {@code StringList} of full names
	 */
	public StringList getFullNames() {
		StringList names = new StringList();
		for (Variable v : ncfile.getVariables()) {
			names.append(v.getFullName());
		}
		
		return names;
	}
	
	/**
	 * Load data from a variable with a section specifier.
	 * 
	 * @param fullNameEscaped
	 * @param sectionSpec
	 */
	public void loadData(String fullNameEscaped, String sectionSpec) {
		if (null != ncfile) {
			try {
				Variable v = ncfile.findVariable(fullNameEscaped);
				ucar.ma2.Array data = v.read(sectionSpec);
				if (null != data) {
					variables.put(fullNameEscaped, data);
					System.out.println("Loaded " + fullNameEscaped + "...\n");
				}		
			} catch (IOException | InvalidRangeException ex) {
				System.out.println("Failed to load " + fullNameEscaped);
				System.out.println(ex);
			}
		}
	}
	
	/**
	 * Load all data from a variable.
	 * 
	 * @param fullNameEscaped
	 */
	public void loadData(String fullNameEscaped) {
		int rank = ncfile.findVariable(fullNameEscaped).getRank();
		String sectionSpec = "";
		for (int i = 0; i < rank; i++) {
			sectionSpec += ":,";
		}
		
		loadData(fullNameEscaped, sectionSpec);
	}
	
	/**
	 * Return the value at a given index as a float.
	 * 
	 * @param fullNameEscaped
	 * @param index
	 * @return {@code float} value
	 */
	public float getFloat(String fullNameEscaped, int index) {
		return variables.get(fullNameEscaped).getFloat(index);
	}
	
	/**
	 * Return the first value as a float.
	 * 
	 * @param fullNameEscaped
	 * @return {@code float} value
	 */
	public float getFloat(String fullNameEscaped) {
		return getFloat(fullNameEscaped, 0);
	}
	
	/**
	 * Return the value at a given index as a double.
	 * 
	 * @param fullNameEscaped
	 * @param index
	 * @return {@code double} value
	 */
	public double getDouble(String fullNameEscaped, int index) {
		return variables.get(fullNameEscaped).getDouble(index);
	}
	
	/**
	 * Return the first value as a double.
	 * 
	 * @param fullNameEscaped
	 * @return {@code double} value
	 */
	public double getDouble(String fullNameEscaped) {
		return getDouble(fullNameEscaped, 0);
	}
	
	/**
	 * Copy the variable to a n-dimensional array. 
	 * 
	 * @param fullNameEscaped
	 * @return {@code ucar.ma2.Array} copy containing data
	 */
	public Object getNDJavaArray(String fullNameEscaped) {
		return variables.get(fullNameEscaped).copyToNDJavaArray();
	}
	
	/**
	 * Copy the variable to a 1-dimensional float array.
	 * 
	 * @param fullNameEscaped
	 * @return {@code float[]} containing data
	 */
	public float[] get1DFloatArray(String fullNameEscaped) {
		float[] variable = (float[]) getNDJavaArray(fullNameEscaped);
		
		return variable;
	}
	
	/**
	 * Copy the variable to a 2-dimensional float array.
	 * 
	 * @param fullNameEscaped
	 * @return {@code float[][]} containing data
	 */
	public float[][] get2DFloatArray(String fullNameEscaped) {
		float[][] variable = (float[][]) getNDJavaArray(fullNameEscaped);
		
		return variable;
	}
	
	/**
	 * Copy the variable to a 3-dimensional float array.
	 * 
	 * @param fullNameEscaped
	 * @return {@code float[][][]} containing data
	 */
	public float[][][] get3DFloatArray(String fullNameEscaped) {
		float[][][] variable = (float[][][]) getNDJavaArray(fullNameEscaped);
		
		return variable;
	}
	
	/**
	 * Copy the variable to a 4-dimensional float array.
	 * 
	 * @param fullNameEscaped
	 * @return {@code float[][][][]} containing data
	 */
	public float[][][][] get4DFloatArray(String fullNameEscaped) {
		float[][][][] variable = (float[][][][]) getNDJavaArray(fullNameEscaped);
		
		return variable;
	}
	
	/**
	 * Copy the variable to a 5-dimensional float array.
	 * 
	 * @param fullNameEscaped
	 * @return {@code float[][][][][][]} containing data
	 */
	public float[][][][][] get5DFloatArray(String fullNameEscaped) {
		float[][][][][] variable = (float[][][][][]) getNDJavaArray(fullNameEscaped);
		
		return variable;
	}
	
	/**
	 * Copy the variable to a 6-dimensional float array.
	 * 
	 * @param fullNameEscaped
	 * @return {@code float[][][][][][]} containing data
	 */
	public float[][][][][][] get6DFloatArray(String fullNameEscaped) {
		float[][][][][][] variable = (float[][][][][][]) getNDJavaArray(fullNameEscaped);
		
		return variable;
	}
	
	/**
	 * Copy the variable to a 7-dimensional float array.
	 * 
	 * @param fullNameEscaped
	 * @return {@code float[][][][][][][]} containing data
	 */
	public float[][][][][][][] get7DFloatArray(String fullNameEscaped) {
		float[][][][][][][] variable = (float[][][][][][][]) getNDJavaArray(fullNameEscaped);
		
		return variable;
	}
	
	/**
	 * Copy the variable to a 1-dimensional double array.
	 * 
	 * @param fullNameEscaped
	 * @return {@code double[]} containing data
	 */
	public double[] get1DDoubleArray(String fullNameEscaped) {
		double[] variable = (double[]) getNDJavaArray(fullNameEscaped);
		
		return variable;
	}
	
	/**
	 * Copy the variable to a 2-dimensional double array.
	 * 
	 * @param fullNameEscaped
	 * @return {@code double[][]} containing data
	 */
	public double[][] get2DDoubleArray(String fullNameEscaped) {
		double[][] variable = (double[][]) getNDJavaArray(fullNameEscaped);
		
		return variable;
	}
	
	/**
	 * Copy the variable to a 3-dimensional double array.
	 * 
	 * @param fullNameEscaped
	 * @return {@code double[][][]} containing data
	 */
	public double[][][] get3DDoubleArray(String shortName) {
		double[][][] variable = (double[][][]) getNDJavaArray(shortName);
		
		return variable;
	}
	
	/**
	 * Copy the variable to a 4-dimensional double array.
	 * 
	 * @param fullNameEscaped
	 * @return {@code double[][][][]} containing data
	 */
	public double[][][][] get4DDoubleArray(String shortName) {
		double[][][][] variable = (double[][][][]) getNDJavaArray(shortName);
		
		return variable;
	}
	
	/**
	 * Copy the variable to a 5-dimensional double array.
	 * 
	 * @param fullNameEscaped
	 * @return {@code double[][][][][]} containing data
	 */
	public double[][][][][] get5DDoubleArray(String shortName) {
		double[][][][][] variable = (double[][][][][]) getNDJavaArray(shortName);
		
		return variable;
	}
	
	/**
	 * Copy the variable to a 6-dimensional double array.
	 * 
	 * @param fullNameEscaped
	 * @return {@code double[][][][][][]} containing data
	 */
	public double[][][][][][] get6DDoubleArray(String shortName) {
		double[][][][][][] variable = (double[][][][][][]) getNDJavaArray(shortName);
		
		return variable;
	}
	
	/**
	 * Copy the variable to a 7-dimensional double array.
	 * 
	 * @param fullNameEscaped
	 * @return {@code double[][][][][][][]} containing data
	 */
	public double[][][][][][][] get7DDoubleArray(String shortName) {
		double[][][][][][][] variable = (double[][][][][][][]) getNDJavaArray(shortName);
		
		return variable;
	}
	
	/**
	 * Close the dataset upon exiting the sketch.
	 */
	public void dispose() {
		variables = null;
		close();
	}
}

