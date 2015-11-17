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

rel[list[str],loc,int] allPossibleLineBlocks = {};

/**
 * Calculate the amount of duplicate lines present in the given software project.
 */
public map[str,int] calculateDuplication(set[loc] allLocations) {

	allPossibleLineBlocks = {};
	
	int totalLines = 0;

	for (currentLocation <- allLocations) {
		list[str] sixLines = [];
		int i = 0;
		int currentLine = 1;
		
		for (line <- readFileLines(currentLocation)) {
			line = trim(line);
			currentLine += 1;
			
			if (i < 6) {
				sixLines += line;
				i += 1;
			} else {
				sixLines = drop(1, sixLines);
				sixLines += line;
				
				allPossibleLineBlocks += {<sixLines, currentLocation, currentLine-6>};
			}
			
			totalLines += 1;
		}
	}
	
	lrel[loc,int,list[str]] dups = [ <y,z,x> | <x,y,z> <- allPossibleLineBlocks, size(allPossibleLineBlocks[x]) > 1];
	
	dups = sort(dups);
	
	totalDupLines = 0;
	dupLines = 6;
	
	list[list[str]] alreadyFound = [];
	
	for (singleDup <- dups) {
	
	
		tuple[loc,int,list[str]] nextDup = <singleDup[0],singleDup[1]+1,singleDup[2]>;
		bool found = findLongerDups(dups, nextDup);

		if (found) {
			dupLines += 1;
		} else {
			// totalDupLines += dupLines;
			
			// Does this work?
			if (singleDup[2] in alreadyFound) {
				totalDupLines += dupLines;
			} else {
				alreadyFound += [singleDup[2]]; 
			}
			
			dupLines = 6;
		}
	}
	
	
	map[str,int] values = ();
	values["duplicates"] = totalDupLines;
	values["total"] = totalLines;
	
	return values;
}

/**
 * Finds out if the duplicate is longer than the amount of lines we found so far.
 */
public bool findLongerDups(lrel[loc,int,list[str]] dups, tuple[loc,int,list[str]] dupToFind) {
	for (singleDup <- dups) {
		if (singleDup[0] == dupToFind[0] && singleDup[1] == dupToFind[1]) {
			return true;
		}
	}
	return false;
}

public int calculateDuplicatePercentage(int totalDupLOC, int totalLOC) {
	return percent(totalDupLOC, totalLOC);
}

public str calculateDuplicateRating(int dupPercent) {
	str dupRank;
	
	if (dupPercent >= 0 && dupPercent <= 3) {
		dupRank = "++";
	} else if (dupPercent > 3 && dupPercent <= 5) {
		dupRank = "+";
	} else if (dupPercent > 5 && dupPercent <= 10) {
		dupRank = "o";
	} else if (dupPercent > 10 && dupPercent <= 20) {
		dupRank = "-";
	} else if (dupPercent > 20 && dupPercent <= 100) {
		dupRank = "--";
	}
	
	return dupRank;
}

/**
 * Prints the duplication percentage and rank for the given software project.
 */ 
public void printResults(int totalDupPercentage, str duplicationRank) {
	println();
	println("Duplication Report");
	println("Duplication: <totalDupPercentage>%"); 
	println("Duplication Score: <duplicationRank>");
	println();
}