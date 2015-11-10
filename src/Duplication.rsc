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
import util::Math;
import demo::common::Crawl;

rel[loc,int,list[str]] duplications;

rel[loc,int,list[str]] allPossibleLineBlocks;

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
				
				//allPossibleLineBlocks += {currentLocation, currentLine, sixLines};
			}
		}
	}

}