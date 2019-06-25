#!/usr/bin/env bash
echo "Compiling........." 1>&2
javac -cp lib/commons-cli-1.2.jar:lib/colt.jar:lib/commons-math-2.1.jar:lib/guava-r09.jar:. Greedy.java

echo "Running........." 1>&2
java -cp lib/commons-cli-1.2.jar:lib/colt.jar:lib/commons-math-2.1.jar:lib/guava-r09.jar:. Greedy $@
