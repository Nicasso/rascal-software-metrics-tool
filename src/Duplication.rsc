module Duplication

import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;
import Tuple;
import String;
import Relation;
import Prelude;
import util::Math;
import demo::common::Crawl;

rel[list[str],loc,int] duplications = {};

rel[list[str],loc,int] allPossibleLineBlocks = {};

public void calculateDuplication(set[loc] allLocations) {

	duplications = {};
	allPossibleLineBlocks = {};

	for (currentLocation <- allLocations) {
		list[str] sixLines = [];
		int i = 0;
		int currentLine = 1;
		
		for (line <- readFileLines(currentLocation)) {
			line = trim(line);
			currentLine += 1;
			
			if( i < 6) {
				sixLines += line;
				i += 1;
			} else {
				sixLines = drop(1, sixLines);
				sixLines += line;
				
				allPossibleLineBlocks += {<sixLines, currentLocation, currentLine>};
			}
		}
	}
	
	//iprintln(allPossibleLineBlocks);
	
	lrel[list[str],loc,int] dups = [ <x,y,z> | <x,y,z> <- allPossibleLineBlocks, size(allPossibleLineBlocks[x]) > 1];
	
	iprintln(dups);
	

}