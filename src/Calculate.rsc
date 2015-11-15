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

public M3 software;

//public loc currentProject = |project://smallsql0.21_src|;
public loc currentProject = |project://hsqldb-2.3.1|;
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
	int totalDupLOC = calculateDuplication(allClasses);
	
	int dupPercentage = calculateDuplicatePercentage(totalDupLOC, projectVolumeValues["total"]);
	str dupRank = calculateDuplicateRating(dupPercentage);
	
	Duplication::printResults(dupPercentage, dupRank);
	
	println(printTime(now(), "HH:mm:ss"));
}