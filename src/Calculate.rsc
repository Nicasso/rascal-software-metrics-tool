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

public M3 software;
public list[loc] allFiles;

//public loc currentProject = |project://smallsql0.21_src|;
public loc currentProject = |project://hsqldb-2.3.1|;
//public loc currentProject = |project://Test_Java_Project|;

public void begin() {
	println("Let\'s begin!");
   
	Calculate::software = createM3FromEclipseProject(currentProject);
	Calculate::allFiles = getAllJavaFiles();
   
   	map[str, int] projectVolumeValues = countVolume(Calculate::allFiles);
   	Volume::printResults(projectVolumeValues);
   	
   	set[Declaration] decls = createAstsFromEclipseProject(currentProject, true);
	calculateUnitMetrics(allMethods(decls));
	UnitMetrics::printResults();
	
	//calculateDuplication();
}

public list[loc] getAllJavaFiles() {
	return crawl(currentProject, ".java");
}

public void calculateDuplication() {

}






