module Calculate


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

public int projectLOC;
public int projectLOCOM;
public int projectTotalLines;
public int projectBlankLines;
public str unitSizeScore;
public str unitCCScore;

public int lowRiskUnitSize;
public int mediumRiskUnitSize;
public int highRiskUnitSize;
public int veryHighRiskUnitSize;

public int lowRiskUnitCC;
public int mediumRiskUnitCC;
public int highRiskUnitCC;
public int veryHighRiskUnitCC;

public loc currentProject = |project://smallsql0.21_src|;
//public loc currentProject = |project://hsqldb-2.3.1|;
//public loc currentProject = |project://testProject|;

public void begin() {
	println("Let\'s begin!");
   
	Calculate::software = createM3FromEclipseProject(currentProject);
     
	Calculate::allFiles = getAllJavaFiles();
   
	calculateVolume();
	
	calculateUnitMetrics();
	
	calculateDuplication();
	
   	printResults();
}

public void calculateVolume() {
	// Calculate the amount of lines of code for all the java files in the project.
	Calculate::projectLOC = sum([ countLOC(m) | m <- allFiles]);
   	// Calculate the amount of lines of comments for all the java files in the project.
   	Calculate::projectLOCOM = sum([ countLOCOM(m) | m <- allFiles]);
   	
   	Calculate::projectTotalLines = sum([ countTotalLines(m) | m <- allFiles]);
   	
   	Calculate::projectBlankLines = sum([ countBlankLines(m) | m <- allFiles]);
}

public void calculateUnitMetrics() {
	// Get all classes so we can access all methods.
   	allClasses = classes(Calculate::software);
   	   	
   	list[tuple[int,int]] locAndCC = [];
   	
   	int i = 0;
   	// Loop through all classes.
	for (currentClass <- allClasses) {
		// Get all methods per class.
		myMethods = [ e | e <- Calculate::software@containment[currentClass], e.scheme == "java+method"];
   		
   		// Calculate the lines of code for every method.
		for (method <- myMethods) {
			int currentLoc = countLOC(method);
						
			methodAST = getMethodASTEclipse(method, model = Calculate::software);
			
			int methodCC = 0;
			
			visit (methodAST) {
				case \if(Expression condition, Statement thenBranch): methodCC += 1;
				case \if(Expression condition, Statement thenBranch, Statement elseBranch): methodCC += 1;
				case \switch(Expression expression, list[Statement] statements): methodCC += 1;
				case \case(Expression expression): methodCC += 1;
				case \defaultCase(): methodCC += 1;
				case \while(Expression condition, Statement body): methodCC += 1;
				case \foreach(Declaration parameter, Expression collection, Statement body): methodCC += 1;
				case \for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body): methodCC += 1;
				case \for(list[Expression] initializers, list[Expression] updaters, Statement body): methodCC += 1;
				case \do(Statement body, Expression condition): methodCC += 1;
				case \catch(Declaration exception, Statement body): methodCC += 1;
			};
			
			locAndCC = locAndCC + <currentLoc, methodCC>;
		}
	}
		
	map[str,int] unitSizes = unitSize(locAndCC);
	calculateUnitSizeRisk(unitSizes);
	
	map[str,int] unitCCs = unitCC(locAndCC);
	calculateUnitCCRisk(unitCCs);
}

public void calculateUnitSizeRisk(map[str,int] unitResults) {
	Calculate::lowRiskUnitSize = percent(unitResults["low"], unitResults["total"]);
	Calculate::mediumRiskUnitSize = percent(unitResults["medium"], unitResults["total"]);
	Calculate::highRiskUnitSize = percent(unitResults["high"], unitResults["total"]);
	Calculate::veryHighRiskUnitSize = percent(unitResults["veryHigh"], unitResults["total"]);
		
	if (mediumRiskUnitSize <= 25 && highRiskUnitSize == 0 && veryHighRiskUnitSize == 0) {
		Calculate::unitSizeScore = "++";
	} else if (mediumRiskUnitSize <= 25 && highRiskUnitSize == 0 && veryHighRiskUnitSize == 0) {
		Calculate::unitSizeScore = "+";
	} else if (mediumRiskUnitSize <= 25 && highRiskUnitSize == 0 && veryHighRiskUnitSize == 0) {
		Calculate::unitSizeScore = "0";
	} else if (mediumRiskUnitSize <= 25 && highRiskUnitSize == 0 && veryHighRiskUnitSize == 0) {
		Calculate::unitSizeScore = "-";
	} else {
		Calculate::unitSizeScore = "--";
	}
}

public void calculateUnitCCRisk(map[str,int] unitResults) {
	Calculate::lowRiskUnitCC = percent(unitResults["low"], unitResults["total"]);
	Calculate::mediumRiskUnitCC = percent(unitResults["medium"], unitResults["total"]);
	Calculate::highRiskUnitCC = percent(unitResults["high"], unitResults["total"]);
	Calculate::veryHighRiskUnitCC = percent(unitResults["veryHigh"], unitResults["total"]);
		
	if (mediumRiskUnitCC <= 25 && highRiskUnitCC == 0 && veryHighRiskUnitCC == 0) {
		Calculate::unitCCScore = "++";
	} else if (mediumRiskUnitCC <= 25 && highRiskUnitCC == 0 && veryHighRiskUnitCC == 0) {
		Calculate::unitCCScore = "+";
	} else if (mediumRiskUnitCC <= 25 && highRiskUnitCC == 0 && veryHighRiskUnitCC == 0) {
		Calculate::unitCCScore = "0";
	} else if (mediumRiskUnitCC <= 25 && highRiskUnitCC == 0 && veryHighRiskUnitCC == 0) {
		Calculate::unitCCScore = "-";
	} else {
		Calculate::unitCCScore = "--";
	}
}

public void calculateDuplication() {

}

public void printResults() {

	println("Results");
	println();
	
	println("Volume");
	println();

	println("Lines of code for the whole project: <Calculate::projectLOC>");   
   	println("Lines of comments for the whole project: <Calculate::projectLOCOM>");
   	println("Total amount of blank lines for the whole project: <Calculate::projectBlankLines>");
   	println("Total amount of lines for the whole project: <Calculate::projectTotalLines>");
	
	println();
	
	println("Unit Size");
	println();
	
	println("lowRisk: <Calculate::lowRiskUnitSize>%");
	println("mediumRisk: <Calculate::mediumRiskUnitSize>%");
	println("highRisk: <Calculate::highRiskUnitSize>%");
	println("veryHighRisk: <Calculate::veryHighRiskUnitSize>%");	
	
	println();
	
	println("Unit Size Rating: <Calculate::unitSizeScore>");
	
	println();
	
	println("Unit complexity");
	println();
	
	println("lowRisk: <Calculate::lowRiskUnitCC>%");
	println("mediumRisk: <Calculate::mediumRiskUnitCC>%");
	println("highRisk: <Calculate::highRiskUnitCC>%");
	println("veryHighRisk: <Calculate::veryHighRiskUnitCC>%");	
	
	println();
	
	println("Unit Size Rating: <Calculate::unitCCScore>");
	
	println("Duplication");
	println();
	
	//println("Unit Size");
	//println(sum);
  
}

public list[loc] getAllJavaFiles() {
	return crawl(currentProject, ".java");
}

public map[str, int] unitSize(list[tuple[int,int]] unitSizes) {
	
	map[str, int] values = ();
	values["low"] = 0;
	values["medium"] = 0;
	values["high"] = 0;
	values["veryHigh"] = 0;
   	values["total"] = 0;
	
	for (currentSize <- unitSizes) {
	
		int currentLoc = currentSize[0];
	
		if (currentLoc >= 1 && currentLoc <= 20) {
			values["low"] += currentLoc;
		} else if (currentLoc >= 21 && currentLoc <= 50) {
			values["medium"] += currentLoc;
		} else if (currentLoc >= 51 && currentLoc <= 100) {
			values["high"] += currentLoc;
		} else if (currentLoc > 100) {
			values["veryHigh"] += currentLoc;
		}
		
		values["total"] = values["total"] + currentLoc;
	}
	
	return values;
}

public map[str, int] unitCC(list[tuple[int,int]] unitSizes) {
	
	map[str, int] values = ();
	values["low"] = 0;
	values["medium"] = 0;
	values["high"] = 0;
	values["veryHigh"] = 0;
   	values["total"] = 0;
	
	for (currentSize <- unitSizes) {
	
		int currentCC = currentSize[1];
	
		if (currentCC >= 1 && currentCC <= 10) {
			values["low"] += currentCC;
		} else if (currentCC >= 11 && currentCC <= 20) {
			values["medium"] += currentCC;
		} else if (currentCC >= 21 && currentCC <= 50) {
			values["high"] += currentCC;
		} else if (currentCC > 50) {
			values["veryHigh"] += currentCC;
		}
		
		values["total"] = values["total"] + currentCC;
	}
	
	return values;
}

public int countLOC(loc location) {
	int count = 0;
	
	for (line <- readFileLines(location)) {
		if (trim(line) != "") {
			if (!startsWith(trim(line),"/") && !startsWith(trim(line),"*")) {
				count += 1;
			}
		}
	}
	return count;	
}

public int countLOCOM(loc location) {
	int count = 0;
	
	for (line <- readFileLines(location)) {
		if (startsWith(trim(line),"/") || startsWith(trim(line),"*")) {
			count += 1;
		}
	}
	
	return count;	
}

public int countTotalLines(loc location) {
	int count = 0;
	
	for (line <- readFileLines(location)) {
		count += 1;
	}
	
	return count;	
}

public int countBlankLines(loc location) {
	int count = 0;
	
	for (line <- readFileLines(location)) {
		if (trim(line) == "") {
			count += 1;
		}
	}
	
	return count;	
}



