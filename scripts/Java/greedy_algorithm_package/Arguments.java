////////////////////////////////////////////////////////////////////// 
// Arguments.java
// (c) 2019 Buhm Han
// 
////////////////////////////////////////////////////////////////////// 

import java.io.*;
import java.util.*;
import org.apache.commons.cli.*;

public class Arguments
{
    public long    nSnp_ ;
    public long    nRef_ ;
    public double  nSim_ ;
    public String  pref_ ;
    public String  outputFile_ = "02_solutions.txt";
    public int     seed_ = 0;
    public String  argsSummary_;

    public Arguments(String[] args) {
	if (args.length == 0) {
	    Misc.printErrorAndQuit("ERROR: No argument. Please type 'java -jar Greedy.jar -help' to see a list of options");
	}
	CommandLineParser parser = new GnuParser();
	Options options = new Options();
	// Option build-up
	options.addOption( OptionBuilder
			   .withLongOpt("nsnp")
			   .withDescription("Number of SNPs")
			   .hasArg()
			   .withArgName("INT")
               .isRequired(true)
			   .create() );
	options.addOption( OptionBuilder
			   .withLongOpt("nref")
			   .withDescription("Number of reference satellites")
			   .hasArg()
			   .withArgName("INT")
               .isRequired(true)
			   .create() );
	options.addOption( OptionBuilder
			   .withLongOpt("nsim")
			   .withDescription("Number of simulations")
			   .hasArg()
			   .withArgName("INT")
               .isRequired(true)
			   .create() );
	options.addOption( OptionBuilder
			   .withLongOpt("pref")
			   .withDescription("Input file prefix")
			   .hasArg()
			   .withArgName("STR")
               .isRequired(true)
			   .create() );
	options.addOption( OptionBuilder
			   .withLongOpt("output")
			   .withDescription("Output file (default='02_solutions.txt')")
			   .hasArg()
			   .withArgName("FILE")
			   .create() );
	options.addOption( OptionBuilder
			   .withLongOpt("seed")
			   .withDescription("Random number generator seed (default=0)")
			   .hasArg()
			   .withArgName("INT")
			   .create() );
	options.addOption( OptionBuilder
			   .withLongOpt("help")
			   .withDescription("Print help")
			   .create() );
	// Parsing
	try {
	    CommandLine line = parser.parse(options, args);
	    if (line.hasOption("nsnp")) {
		    nSnp_ = Long.valueOf(line.getOptionValue("nsnp"));
	    }
	    if (line.hasOption("nref")) {
		    nRef_ = Long.valueOf(line.getOptionValue("nref"));
	    }
	    if (line.hasOption("nsim")) {
		    nSim_ = Long.valueOf(line.getOptionValue("nsim"));
	    }
	    if (line.hasOption("pref")) {
		    pref_ = line.getOptionValue("pref");
	    }
	    if (line.hasOption("output")) {
		    outputFile_ = line.getOptionValue("output");
	    }
	    if (line.hasOption("seed")) {
		seed_ = Integer.valueOf(line.getOptionValue("seed"));
	    }
	    if (line.hasOption("help")) {
		HelpFormatter formatter = new HelpFormatter();
		formatter.setLongOptPrefix("-");
		formatter.setWidth(100);
		formatter.setOptionComparator(null);
		formatter.printHelp("java -jar Greedy.jar [options]",options);
		System.out.println("------------------------------------------------");
		System.out.println();
		System.exit(-1);
	    }
	} catch (ParseException exp) {
	    Misc.printErrorAndQuit(exp.getMessage()+
				       "\nPlease type 'java -jar Greedy.jar -help' to see a list of options");
	}
	// Make summary for printing
	argsSummary_ = "";
	for (String s: args) {
	    argsSummary_ += " " + s;
	}
    }
}
