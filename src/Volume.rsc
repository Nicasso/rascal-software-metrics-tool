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
import DateTime;
import Calculate;

public str volumeRank;

/**
 *	Counts the total ammount of comments for the whole software project.
 */
public int countTotalComments(M3 currentSoftware) {

	comments = [ e | e <- currentSoftware@documentation];
	
	int total = 0;
	
	for (comment <- comments) {
		for (line <- readFileLines(comment[1])) {		
			total+=1;
		}
	}
	
	return total;
}

/**
 * Counts the total amount of blank lines, comment lines, code lines, and total lines for the current software project.
 */
public map[str,int] countVolume(M3 currentProject) {	
	int commentCount = countTotalComments(currentProject);
	
	list[loc] allLocations = getAllJavaFiles();

	map[str,int] values = ();
	
	values["code"] = 0;
	values["comment"] = commentCount;
	values["blank"] = 0;
	values["total"] = 0;
		
	for (currentLocation <- allLocations) {
	
		for (line <- readFileLines(currentLocation)) {
		
			values["total"] += 1;
		
			if (trim(line) == "") {
				values["blank"] += 1;
			} else {
				values["code"] += 1;
			}
		}
	
	}
	
	values["code"] = values["code"] - commentCount;
	
	calculateVolumeRank(values["code"]);
	
	return values;
}

/**
 * Retreives a list with locations for all the .java files in the given software project.
 */
public list[loc] getAllJavaFiles() {
	return crawl(Calculate::currentProject, ".java");
}

/**
 * Calculates the overall rank for the LOC metric using the given threshold.
 */
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

/**
 * Prints all the calculated volume metrics.
 */
public void printResults(map[str,int] values) {
	println("Volume");
	println();
	println("LOC: <values["code"]>");   
   	println("Comments: <values["comment"]>");
   	println("Blanks: <values["blank"]>");
   	println("Total: <values["total"]>");
   	println();	
	println("Volume Rating: <Volume::volumeRank>");
	println();
}