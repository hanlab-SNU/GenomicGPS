////////////////////////////////////////////////////////////////////// 
// Writer.java
// (c) 2011-2020 Buhm Han
// 

import java.io.*;
import java.util.*;

public class Writer
{
   public static PrintWriter openWriter(String file) {
      PrintWriter printWriter = null;
      try {
	 printWriter = new PrintWriter(new BufferedWriter(new FileWriter(file)));
      }
      catch (Exception exception) {
	 System.err.printf("ERROR: Ouput file %s cannot be opened\n", file);
	 System.exit(-1);
      }
      return printWriter;
   }

   public static void closeWriter(PrintWriter printWriter) {
      try {
	 printWriter.close();
      }
      catch (Exception exception) {
	 System.err.println("ERROR: file cannot be closed");
	 System.exit(-1);
      }
   }
}
