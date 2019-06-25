//////////////////////////////////////////////////////////////////////
// Greedy.java
// (c) 2019 Buhm Han
//
//////////////////////////////////////////////////////////////////////

import java.io.*;
import java.util.*;
import cern.jet.stat.Probability;
import cern.colt.matrix.*;
import cern.colt.matrix.linalg.*;
import cern.jet.random.*;
import cern.jet.random.engine.*;
//import com.google.common.primitives.Ints;

public class Greedy
{
    private static String logMsg_ = "";

    public static void main(String[] args) {
        double startTime = System.currentTimeMillis();
        Arguments arg = new Arguments(args);
        System.err.printf("Arguments:\n%s\n",arg.argsSummary_);
        System.err.printf("----- Performing multilateration\n");
        doIt(arg);
        System.err.println("----- Finished");
        double endTime   = System.currentTimeMillis();
        System.err.printf("----- Elapsed time: %.2f minutes\n", (endTime - startTime)/(60*1000F));
    }

    private static void doIt(Arguments arg) {
        int N = (int)arg.nSnp_;
        int K = (int)arg.nRef_;
        int B = (int)arg.nSim_;
        String pref = arg.pref_;
        String outputFile = arg.outputFile_;
        RandomEngine tw = new MersenneTwister(arg.seed_);
        cern.jet.math.Functions F = cern.jet.math.Functions.functions; // alias
        Reader reader = new Reader();
        Euclidean euc = new Euclidean();
        Uniform unifo = new Uniform(tw);

        // Read files.
        DoubleMatrix2D ref = reader.fileToDoubleMatrix(pref.concat(".ref"), K, N);
        DoubleMatrix1D sam = reader.fileToDoubleMatrix(pref.concat(".sam"), 1, N).viewRow(0);
        DoubleMatrix1D af = reader.fileToDoubleMatrix(pref.concat(".af"), N, 1).viewColumn(0);
        DoubleMatrix1D dv = reader.fileToDoubleMatrix(pref.concat(".dv"), K, 1).viewColumn(0);

        // Random generator.
        Binomial[] binom = new Binomial[N];
        for (int i = 0; i < N; i++) {
            binom[i] = new Binomial(2, af.get(i), tw);
        }

        // Simulate and search.
        DoubleMatrix1D x = DoubleFactory1D.dense.make(N);
        DoubleMatrix1D xdv = DoubleFactory1D.dense.make(K);
        DoubleMatrix1D xdvtry1 = DoubleFactory1D.dense.make(K);
        DoubleMatrix1D xdvtry2 = DoubleFactory1D.dense.make(K);
        DoubleMatrix2D randomsol = DoubleFactory2D.dense.make(B, N);
        DoubleMatrix2D solutions = DoubleFactory2D.dense.make(B, N);
        double sse;
        DoubleMatrix1D xbest = DoubleFactory1D.dense.make(N);
        double ssebest;
        for (int b = 0; b < B; b++) {
            if (b % 10 == 0) {
                System.err.println(b);
            }
            ssebest = Double.MAX_VALUE;
            for (int re = 0; re < 1000; re++) { // restart to avoid local stuck 
                // One random sample: "x"
                for (int i = 0; i < N; i++) {
                    x.set(i, (double)binom[i].nextInt());
                }
                randomsol.viewRow(b).assign(x);
                for (int k = 0; k < K; k++) {
                    xdv.set(k, euc.squaredDistance(ref.viewRow(k), x));
                }
                sse = euc.squaredDistance(dv, xdv);
                int unmoved = 0;
                while(unmoved < 1000) {
                    //System.out.printf("%.0f ", sse);
                    // randomly choose one SNP
                    int m = unifo.nextIntFromTo(0, N-1);
                    int type = (int)x.get(m);
                    int try1 = (type + 1) % 3;
                    int try2 = (type + 2) % 3;
                    // Trial#1
                    for (int k = 0; k < K; k++) {
                        xdvtry1.set(k, xdv.get(k) 
                                - Math.pow(ref.get(k, m) - type, 2) 
                                + Math.pow(ref.get(k, m) - try1, 2));
                    }
                    double sse1 = euc.squaredDistance(dv, xdvtry1);
                    // Trial#2
                    for (int k = 0; k < K; k++) {
                        xdvtry2.set(k, xdv.get(k) 
                                - Math.pow(ref.get(k, m) - type, 2) 
                                + Math.pow(ref.get(k, m) - try2, 2));
                    }
                    double sse2 = euc.squaredDistance(dv, xdvtry2);
                    // Decide move
                    if (sse < sse1 && sse < sse2) {
                        unmoved++;
                    } else {
                        unmoved = 0;
                        if (sse1 < sse2) {
                            x.set(m, try1);
                            xdv.assign(xdvtry1);
                            sse = sse1;
                        } else {
                            x.set(m, try2);
                            xdv.assign(xdvtry2);
                            sse = sse2;
                        }
                    }
                }
                //System.out.println();
                if (sse < ssebest) {
                    xbest.assign(x);
                    ssebest = sse;
                }
            }
            solutions.viewRow(b).assign(xbest);
        }

        // Write both random solutions and greedy solutions.
        PrintWriter pw = Writer.openWriter(outputFile.concat(".rand"));
        pw.println(randomsol.toString());
        Writer.closeWriter(pw);
        pw = Writer.openWriter(outputFile);
        pw.println(solutions.toString());
        Writer.closeWriter(pw);
        
        //System.out.println(ref.toString());
        //System.out.println(af.toString());
    }
}
