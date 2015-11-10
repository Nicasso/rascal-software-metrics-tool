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

public int calculateDuplication(set[loc] allLocations) {

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
				
				allPossibleLineBlocks += {<sixLines, currentLocation, currentLine-6>};
			}
		}
	}
	
	//iprintln(allPossibleLineBlocks);
	
	lrel[loc,int,list[str]] dups = [ <y,z,x> | <x,y,z> <- allPossibleLineBlocks, size(allPossibleLineBlocks[x]) > 1];
	
	dups = sort(dups);
	
	//iprintln(dups);
	
	//lrel[loc,int] longDups = [ <x,y,z> | <x,y,z> <- dups, size(dups[x]) > 1];
	
	//iprintln([ dups[x] | <x,y> <- dups, size(dups[x]) > 1]);
	
	totalDupLines = 0;
	dupLines = 6;
	
	for (singleDup <- dups) {
		tuple[loc,int,list[str]] nextDup = <singleDup[0],singleDup[1]+1,singleDup[2]>;
		//iprintln(nextDup);
		bool found = findLongerDups(dups, nextDup);
		if (found) {
			dupLines += 1;
		} else {
			//iprintln("DUPLINES <dupLines>");
			totalDupLines += dupLines;
			dupLines = 6;
		}
	}
	
	//iprintln("TOTALDUPSLINES <totalDupLines>");
	return totalDupLines;
}

public bool findLongerDups(lrel[loc,int,list[str]] dups, tuple[loc,int,list[str]] dupToFind) {
	for (singleDup <- dups) {
		if(singleDup[0] == dupToFind[0] && singleDup[1] == dupToFind[1]) {
			return true;
		}
	}
	return false;
}

public void printResults(int totalDupPercentage, str duplicationRank) {
	println("Duplication");
	println();
	println("Duplication: <totalDupPercentage>%"); 
   	println();	
	println("Duplication rank: <duplicationRank>");
	println();
}