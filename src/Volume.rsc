module Volume

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

public str volumeRank;

public map[str,int] countVolume(list[loc] allLocations) {

	map[str,int] values = ();
	
	values["code"] = 0;
	values["comment"] = 0;
	values["blank"] = 0;
	values["total"] = 0;
	
	bool commentBlock = false;
	
	for (currentLocation <- allLocations) {
	
		for (line <- readFileLines(currentLocation)) {
		
			values["total"] += 1;
		
			if (trim(line) == "") {
				values["blank"] += 1;
			} else if (startsWith(trim(line),"/*")) {
				if (!endsWith(trim(line),"*/")) {
					commentBlock = true;
				}
				values["comment"] += 1;
			} else if (startsWith(trim(line),"*/") || endsWith(trim(line),"*/")) {
				commentBlock = false;
				values["comment"] += 1;
			} else if (commentBlock || startsWith(trim(line),"/") || startsWith(trim(line),"*")) {
				values["comment"] += 1;
			} else {
				if (endsWith(trim(line),"/*")) {
					commentBlock = true;
				}
				values["code"] += 1;
			}
		}
	
	}
	
	calculateVolumeRank(values["code"]);
	
	return values;
}

private void calculateVolumeRank(int linesOfCode) {
	if (0 < linesOfCode && linesOfCode <= 66000) {
		Volume::volumeRank = "++";
	} else if (66000 < linesOfCode && linesOfCode <= 246000) {
		Volume::volumeRank = "+";
	} else if (246000 < linesOfCode && linesOfCode <= 665000) {
		Volume::volumeRank = "0";
	} else if (665000 < linesOfCode && linesOfCode <= 1310000) {
		Volume::volumeRank = "-";
	} else {
		Volume::volumeRank = "--";
	}
}

public void printResults(map[str,int] values) {
	println("Volume");
	println();
	println("Lines of code for the whole project: <values["code"]>");   
   	println("Lines of comments for the whole project: <values["comment"]>");
   	println("Total amount of blank lines for the whole project: <values["blank"]>");
   	println("Total amount of lines for the whole project: <values["total"]>");
   	println();	
	println("Volume Rating: <Volume::volumeRank>");
	println();
}