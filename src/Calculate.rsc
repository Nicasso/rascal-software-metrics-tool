module Calculate

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import IO;
import List;
import String;
import demo::common::Crawl;


public M3 software;
public int LOC;
public int LOCOM;
public int avgUnitSize;

public loc currentProject = |project://TestProject|;

public void begin() {
	println("Let\'s begin!");
   
	Calculate::software = createM3FromEclipseProject(currentProject);
     
	list[loc] allFiles = getAllJavaFiles();
   
	// Calculate the amount of lines of code for all the java files in the project.
	Calculate::LOC = sum([ countLOC(m) | m <- allFiles]);
   	// Calculate the amount of lines of comments for all the java files in the project.
   	Calculate::LOCOM = sum([ countLOCOM(m) | m <- allFiles]);
   
   
	// Get all classes so we can access all methods.
   	allClasses = classes(Calculate::software);
   	
   	int sum = 0;
   	int totalMethods = 0;
   	
   	// Loop through all classes.
	for (currentClass <- allClasses) {
		// Get all methods per class.
		myMethods = [ e | e <- Calculate::software@containment[currentClass], e.scheme == "java+method"];
   		
   		// Calculate the lines of code for every method.
		for (method <- myMethods) {
			int currentLoc = countLOC(method);
			sum += currentLoc;
			totalMethods+=1;
		}
	} 
   
   	// Set the average unit size.
	Calculate::avgUnitSize = sum / totalMethods;
	
   printResults();
}

public void printResults() {

	println("Results:");
	println();

	println("LOC: ");
	println(Calculate::LOC);
	
	println();
   
   	println("LOCOM: ");
	println(Calculate::LOCOM);
	
	println();
	
	println("avgUnitSize");
	println(Calculate::avgUnitSize);
	
   
}

public list[loc] getAllJavaFiles() {
	return crawl(currentProject, ".java");
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



