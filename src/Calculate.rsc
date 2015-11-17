module Calculate

import Volume;
import Duplication;
import UnitMetrics;

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

public real analyzabilityScore;
public real changeabilityScore;
public str stabilityScore;
public real testabilityScore;
public real maintainabilityScore;

public M3 software;
public str dupRank;

public loc currentProject = |project://smallsql0.21_src|;
//public loc currentProject = |project://hsqldb-2.3.1|;
//public loc currentProject = |project://TestProject|;

/**
 * The starting point which initializes all metric calculations.
 */
public void begin() {
	println("Let\'s begin!");
	
	println(printTime(now(), "HH:mm:ss"));
   
	Calculate::software = createM3FromEclipseProject(currentProject);
    
   	map[str, int] projectVolumeValues = countVolume(Calculate::software);
   	Volume::printResults(projectVolumeValues);
   	
   	println(printTime(now(), "HH:mm:ss"));
	
	calculateUnitMetrics(Calculate::software);
	UnitMetrics::printResults();
	
	println(printTime(now(), "HH:mm:ss"));
	
	allClasses = classes(Calculate::software);
	map[str,int] duplicateValues = calculateDuplication(allClasses);
		
	int dupPercentage = calculateDuplicatePercentage(duplicateValues["duplicates"], duplicateValues["total"]);
	dupRank = calculateDuplicateRating(dupPercentage);
	
	Duplication::printResults(dupPercentage, dupRank);
	
	println(printTime(now(), "HH:mm:ss"));
	
	calculateSummary();
}



public void calculateSummary(){
	analyzabilityScore = (rankToInt(Volume::volumeRank) + rankToInt(UnitMetrics::unitSizeScore) + rankToInt(Calculate::dupRank)) / 3. + 0.00;
	changeabilityScore = (rankToInt(UnitMetrics::unitCCScore) + rankToInt(Calculate::dupRank)) / 2. + 0.00;
	stabilityScore = "not applicable";
	testabilityScore = (rankToInt(UnitMetrics::unitCCScore) + rankToInt(UnitMetrics::unitSizeScore)) / 2. + 0.00;
	maintainabilityScore = (analyzabilityScore + changeabilityScore + testabilityScore) / 3. + 0.00;
	printSummary();
}

public int rankToInt(str rank){
	switch(rank){
		case "++": return 5;
		case "+" : return 4;
		case "o" : return 3;
		case "-" : return 2;
		case "--": return 1;
	}
}

public str realToRank(real score){
	if (score >= 4 && score <= 5) {
		return "++";
	} else if (score >= 3 && score < 4) {
		return "+";
	} else if (score >= 2 && score < 3) {
		return "o";
	} else if (score >= 1 && score < 2) {
		return "-";
	} else {
		return "--";
	}
}

public void printSummary(){
	println("Summary");
	println("----------------------------------------");
	println("SIG Analyzability Score:   <realToRank(analyzabilityScore)> (<analyzabilityScore>)");
	println("SIG Changeability Score:   <realToRank(changeabilityScore)> (<changeabilityScore>)");
	println("SIG Stability Score:       <stabilityScore>");
	println("SIG Testability Score:     <realToRank(testabilityScore)> (<testabilityScore>)");
	println("SIG Maintainability Score: <realToRank(maintainabilityScore)> (<maintainabilityScore>)");
}