////////////////////////////////////////////////////////////////////// 
// Euclidean.java
// (c) 2019 Buhm Han
// 

import java.io.*;
import java.util.*;
import cern.colt.matrix.*;

public class Euclidean
{
    public Euclidean() {
    }

    public double squaredDistance(DoubleMatrix1D a, DoubleMatrix1D b) {
        cern.jet.math.Functions F = cern.jet.math.Functions.functions;
        return a.aggregate(b, F.plus, F.chain(F.square, F.minus));
    }
}
