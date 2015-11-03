module Calculate


import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;
import String;
import util::Math;
import demo::common::Crawl;


public M3 software;
public list[loc] allFiles;

public int projectLOC;
public int projectLOCOM;
public int projectTotalLines;
public int projectBlankLines;
public str unitSizeScore;

public int lowRisk;
public int mediumRisk;
public int highRisk;
public int veryHighRisk;

//public loc currentProject = |project://smallsql0.21_src|;
public loc currentProject = |project://testProject|;

public void begin() {
	println("Let\'s begin!");
   
	Calculate::software = createM3FromEclipseProject(currentProject);
     
	Calculate::allFiles = getAllJavaFiles();
   
	calculateVolume();
	
	calculateUnitSize();
	
	calculateUnitComplexity();
	
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

public void calculateUnitSize() {
	// Get all classes so we can access all methods.
   	allClasses = classes(Calculate::software);
   	
   	list[int] sum = [];
   	
   	int i = 0;
   	// Loop through all classes.
	for (currentClass <- allClasses) {
		// Get all methods per class.
		myMethods = [ e | e <- Calculate::software@containment[currentClass], e.scheme == "java+method"];
   		
   		// Calculate the lines of code for every method.
		for (method <- myMethods) {
			int currentLoc = countLOC(method);
			sum = sum + [currentLoc];
		}
	}
		
	map[str,int] unitSizes = unitSize(sum);
	
	Calculate::lowRisk = percent(unitSizes["low"], unitSizes["total"]);
	Calculate::mediumRisk = percent(unitSizes["medium"], unitSizes["total"]);
	Calculate::highRisk = percent(unitSizes["high"], unitSizes["total"]);
	Calculate::veryHighRisk = percent(unitSizes["veryHigh"], unitSizes["total"]);
		
	if (mediumRisk <= 25 && highRisk == 0 && veryHighRisk == 0) {
		Calculate::unitSizeScore = "++";
	} else if (mediumRisk <= 25 && highRisk == 0 && veryHighRisk == 0) {
		Calculate::unitSizeScore = "+";
	} else if (mediumRisk <= 25 && highRisk == 0 && veryHighRisk == 0) {
		Calculate::unitSizeScore = "0";
	} else if (mediumRisk <= 25 && highRisk == 0 && veryHighRisk == 0) {
		Calculate::unitSizeScore = "-";
	} else {
		Calculate::unitSizeScore = "--";
	}
}

public void calculateUnitComplexity() {
	// Get all classes so we can access all methods.
   	allClasses = classes(Calculate::software);
   	
   	list[int] allCC = [];
   	
   	println("CC");
   	
   	int i = 0;
   	// Loop through all classes.
	for (currentClass <- allClasses) {
		// Get all methods per class.
		myMethods = [ e | e <- Calculate::software@containment[currentClass], e.scheme == "java+method"];
   		
   		for (method <- myMethods) {
			methodAST = getMethodASTEclipse(method, model = Calculate::software);
			
			int c = 0;
			
			visit(methodAST) {
				case \if(Expression condition, Statement thenBranch): c += 1;
				case \if(Expression condition, Statement thenBranch, Statement elseBranch): c += 1;
				case \switch(Expression expression, list[Statement] statements): c += 1;
				case \case(Expression expression): c += 1;
				case \defaultCase(): c += 1;
				case \while(Expression condition, Statement body): c += 1;
				case \foreach(Declaration parameter, Expression collection, Statement body): c += 1;
				case \for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body): c += 1;
				case \for(list[Expression] initializers, list[Expression] updaters, Statement body): c += 1;
				case \do(Statement body, Expression condition): c += 1;
				case \catch(Declaration exception, Statement body): c += 1;
			};
			
			///allCC[i] = c;
			
			//i+=1;
		}
	}
	
	riskAssessmentUnitComplexity(allCC);
}

public map[str, int] riskAssessmentUnitComplexity(list[int] unitCC) {

	map[str, int] values = ();
	values["low"] = 0;
	values["medium"] = 0;
	values["high"] = 0;
	values["veryHigh"] = 0;
   	values["total"] = 0;
	
	for (currentCC <- unitCC) {
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
	
	println("lowRisk: <Calculate::lowRisk>%");
	println("mediumRisk: <Calculate::mediumRisk>%");
	println("highRisk: <Calculate::highRisk>%");
	println("veryHighRisk: <Calculate::veryHighRisk>%");	
	
	println();
	
	println("Unit Size Rating: <Calculate::unitSizeScore>");
	
	println();
	
	println("Unit complexity");
	println();
	
	println("Duplication");
	println();
	
	//println("Unit Size");
	//println(sum);
  
}

public list[loc] getAllJavaFiles() {
	return crawl(currentProject, ".java");
}

public map[str, int] unitSize(list[int] unitSizes) {
	
	map[str, int] values = ();
	values["low"] = 0;
	values["medium"] = 0;
	values["high"] = 0;
	values["veryHigh"] = 0;
   	values["total"] = 0;
	
	for (currentSize <- unitSizes) {
		if (currentSize >= 1 && currentSize <= 20) {
			values["low"] += currentSize;
		} else if (currentSize >= 21 && currentSize <= 50) {
			values["medium"] += currentSize;
		} else if (currentSize >= 51 && currentSize <= 100) {
			values["high"] += currentSize;
		} else if (currentSize > 100) {
			values["veryHigh"] += currentSize;
		}
		
		values["total"] = values["total"] + currentSize;
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



