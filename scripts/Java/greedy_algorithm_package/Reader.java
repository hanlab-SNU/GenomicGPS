////////////////////////////////////////////////////////////////////// 
// Reader.java
// (c) 2011-2020 Buhm Han
// 
// This file may be used for your personal use.
// This file may be modified but the modified version must retain this copyright notice.
// This file or modified version must not be redistributed
// without prior permission from the author.
// This software is provided “AS IS”, without warranty of any kind.
// In no event shall the author be liable for any claim, damages or other liability
// in connection with the software or the use or other dealings in the software.

import java.io.*;
import java.util.*;
import cern.colt.matrix.*;

public class Reader 
{
   public Reader() {
   }

   public DoubleMatrix2D fileToDoubleMatrix(String file, int nrow, int ncol) {
      int numCols = ncol;
      int numRows_ = nrow;
      DoubleMatrix2D matrix = DoubleFactory2D.dense.make(numRows_, numCols); 
      BufferedReader bufferedReader = null;
      try {
	 bufferedReader = new BufferedReader(new FileReader(file));
	 String readLine;
	 int i = 0;
	 while((readLine = bufferedReader.readLine()) != null) {
	    String[] tokens = readLine.split("\\s+");
	    if (tokens.length > 0) {             // Care only non-empty,
	       if (tokens[0].charAt(0) != '#') { // non-comment lines.
		  for (int j = 0; j < numCols; j++) {
		     try {
			matrix.set(i, j, 
			 Double.valueOf(tokens[j]));
		     }
		     catch (Exception exception) {
			System.err.printf("Incorrect float value %s\n", 
					  tokens[j]);
			System.exit(-1);
		     }
		  }
		  ++i;
	       }
	    }
	 }
      }
      catch (Exception exception) {
	 System.err.println(exception);
      } // File exceptions are already checked in rectangularity check
      return matrix;
   }

   public ArrayList<Double> fileToDoubleArrayList(String file) {
      ArrayList<Double> doubles = new ArrayList<Double>();
      BufferedReader bufferedReader = null;
      try {
	 bufferedReader = new BufferedReader(new FileReader(file));
	 String readLine;
	 while((readLine = bufferedReader.readLine()) != null) {
	    String[] tokens = readLine.split("\\s+");
	    if (tokens.length > 0) {             // Care only non-empty,
	       if (tokens[0].charAt(0) != '#') { // non-comment lines.
		  doubles.add(Double.valueOf(tokens[0]));
	       }
	    }
	 }
      }
      catch (Exception exception) {
	 System.err.println(exception);
      } // File exceptions are already checked in rectangularity check
      return doubles;
   }
}
