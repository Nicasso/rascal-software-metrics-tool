module Calculate

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import IO;
import List;
import String;
import demo::common::Crawl;

public M3 software;
public list[loc] allFiles;

public int projectLOC;
public int projectLOCOM;

public loc currentProject = |project://TestProject|;

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
	
	
}

public void calculateUnitComplexity() {

}

public void calculateDuplication() {

}

public void printResults() {

	println("Results:");
	println();

	println("LOC: ");
	println(Calculate::projectLOC);
	
	println();
   
   	println("LOCOM: ");
	println(Calculate::projectLOCOM);
	
	println();
	
	//println("Unit Size");
	//println(sum);
	
   
}

public list[loc] getAllJavaFiles() {
	return crawl(currentProject, ".java");
}

public map[str, int] unitSize(list[int] unitSizes) {
	map[str, int] values;
	
	for (currentSize <- unitSizes) {
		if (currentSize >= 1 && currentSize <= 10) {
			values
			println("a");
		} else if (currentSize >= 11 && currentSize <= 20) {
			println("a");
		} else if (currentSize >= 21 && currentSize <= 50) {
			println("a");
		} else if (currentSize >= 50) {
			println("a");
		}
	}
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



