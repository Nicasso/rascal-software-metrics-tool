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

public void calculateDuplication(list[loc] allLocations) {

	for (currentLocation <- allLocations) {
		for (line <- readFileLines(currentLocation)) {
			line = trim(line);
			iprintln(line);
		}
	}

}