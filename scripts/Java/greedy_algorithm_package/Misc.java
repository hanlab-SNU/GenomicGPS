////////////////////////////////////////////////////////////////////// 
// Misc.java
// (c) 2019 Buhm Han
////////////////////////////////////////////////////////////////////// 

import java.io.*;
import java.util.*;

public class Misc
{
    public static void printErrorAndQuit(String msg) {
	System.err.println(msg);
	System.exit(-1);
    }

    // private static final double LOG_SQRT2PI = 0.5*Math.log(2*Math.PI);

    // public static double logGaussianDensity(double x, double mu, double var) {
    // 	return -(x - mu) * (x - mu) / (2 * var) - Math.log(var) / 2 - LOG_SQRT2PI;
    // }

    // public static double logGaussianDensity(double x, double mu, double var, double logVar) {
    // 	return -(x - mu) * (x - mu) / (2 * var) - logVar / 2 - LOG_SQRT2PI;
    // }

    // public static double logOfSumGivenTwoLogs(double logx, double logy) {
    // 	if (logx >= logy) {
    // 	    return logx + Math.log(1 + Math.exp(logy-logx));
    // 	} else {
    // 	    return logy + Math.log(1 + Math.exp(logx-logy));
    // 	}
    // }
   
}
