module UnitMetrics

import Volume;

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

/**
 * Calculates the unit size and unit complexity metrics.
 */
public void calculateUnitMetrics(M3 currentSoftware) {
   	
   	set[loc] allClasses = classes(currentSoftware);
   	   	
   	list[tuple[int,int]] locAndCC = [];
   	
	for (currentClass <- allClasses) {
		myMethods = [ e | e <- currentSoftware@containment[currentClass], e.scheme == "java+method" || e.scheme == "java+constructor"];
   		
		for (method <- myMethods) {
			//iprintln([ e | e <- currentSoftware@documentation]);
			
			int currentLoc = countMethodLoc(method)["code"];
			
			Declaration methodAST = getMethodASTEclipse(method, model = currentSoftware);
			
			int methodCC = computeCC(methodAST);
			
			locAndCC += <currentLoc, methodCC>;
			
			//iprintln("<method> - LOC: <currentLoc> - methodCC: <methodCC>");
		}
	}
	
	map[str,int] unitSizes = unitSize(locAndCC);
	calculateUnitSizeRisk(unitSizes);
	
	map[str,int] unitCCs = unitCC(locAndCC);
	calculateUnitCCRisk(unitCCs);
}

/**
 * Calculates the LOC for a certain method, it uses string matching to filter out the comments.
 */
public map[str,int] countMethodLoc(loc method) {

	map[str,int] values = ();
	
	values["code"] = 0;
	values["comment"] = 0;
	values["blank"] = 0;
	values["total"] = 0;
	
	bool commentBlock = false;
	
	for (line <- readFileLines(method)) {
	
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
	
	return values;
}

/**
 * Computes the Cyclomatic complexity for a method based on its AST.
 */
public int computeCC(Declaration statement) {
	int methodCC = 1;
				
	visit (statement) {
		case \if(Expression condition, Statement thenBranch): {
			methodCC += countAndOr(condition);
		}
		case \if(Expression condition, Statement thenBranch, Statement elseBranch): {
			methodCC += countAndOr(condition);
		}
		case \case(Expression expression): {
			methodCC += 1;
		}
		case \while(Expression condition, Statement body): {
			methodCC += countAndOr(condition);
		}
		case \foreach(Declaration parameter, Expression collection, Statement body): {
			methodCC += 1;
		}
		case \for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body): {
			methodCC += countAndOr(condition);
		}
		case \for(list[Expression] initializers, list[Expression] updaters, Statement body): {
			methodCC += 1;
		}
		case \catch(Declaration exception, Statement body): {
			methodCC += 1;
		}
	};
	return methodCC;
}

/**
 * Counts the amount of "&&" and "||" operators within a condition.
 */
public int countAndOr(Expression expression) {
	int expressionCC = 1;
	
	visit (expression) {
		case \infix(Expression lhs, str operator, Expression rhs): {
			//iprintln("OPERATOR: <operator>");
			if (operator == "&&" || operator == "||") { 
				expressionCC += 1;
			}
		}
	};
	
	return expressionCC; 
}

/**
 * Orders the unit sizes in their related risk categories.
 */
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

/**
 * Orders the unit complexities in their related risk categories.
 */
public map[str, int] unitCC(list[tuple[int,int]] unitSizes) {
	
	map[str, int] values = ();
	values["low"] = 0;
	values["medium"] = 0;
	values["high"] = 0;
	values["veryHigh"] = 0;
   	values["total"] = 0;
	
	for (currentSize <- unitSizes) {
	
		int currentLOC = currentSize[0];
		int currentCC = currentSize[1];
	
		if (currentCC >= 1 && currentCC <= 10) {
			values["low"] += currentLOC;
		} else if (currentCC >= 11 && currentCC <= 20) {
			values["medium"] += currentLOC;
		} else if (currentCC >= 21 && currentCC <= 50) {
			values["high"] += currentLOC;
		} else if (currentCC > 50) {
			values["veryHigh"] += currentLOC;
		}
		
		values["total"] = values["total"] + currentLOC;
	}
	
	return values;
}

/**
 * Calculates the overall risk based on the unit sizes. 
 */
public void calculateUnitSizeRisk(map[str,int] unitResults) {
	UnitMetrics::lowRiskUnitSize = percent(unitResults["low"], unitResults["total"]);
	UnitMetrics::mediumRiskUnitSize = percent(unitResults["medium"], unitResults["total"]);
	UnitMetrics::highRiskUnitSize = percent(unitResults["high"], unitResults["total"]);
	UnitMetrics::veryHighRiskUnitSize = percent(unitResults["veryHigh"], unitResults["total"]);
		
	if (mediumRiskUnitSize <= 25 && highRiskUnitSize == 0 && veryHighRiskUnitSize == 0) {
		UnitMetrics::unitSizeScore = "++";
	} else if (mediumRiskUnitSize <= 30 && highRiskUnitSize == 5 && veryHighRiskUnitSize == 0) {
		UnitMetrics::unitSizeScore = "+";
	} else if (mediumRiskUnitSize <= 40 && highRiskUnitSize == 10 && veryHighRiskUnitSize == 0) {
		UnitMetrics::unitSizeScore = "0";
	} else if (mediumRiskUnitSize <= 50 && highRiskUnitSize == 15 && veryHighRiskUnitSize == 5) {
		UnitMetrics::unitSizeScore = "-";
	} else {
		UnitMetrics::unitSizeScore = "--";
	}
}

/**
 * Calculates the overall risk based on the unit complexities. 
 */
public void calculateUnitCCRisk(map[str,int] unitResults) {
	UnitMetrics::lowRiskUnitCC = percent(unitResults["low"], unitResults["total"]);
	UnitMetrics::mediumRiskUnitCC = percent(unitResults["medium"], unitResults["total"]);
	UnitMetrics::highRiskUnitCC = percent(unitResults["high"], unitResults["total"]);
	UnitMetrics::veryHighRiskUnitCC = percent(unitResults["veryHigh"], unitResults["total"]);
		
	if (mediumRiskUnitCC <= 25 && highRiskUnitCC == 0 && veryHighRiskUnitCC == 0) {
		UnitMetrics::unitCCScore = "++";
	} else if (mediumRiskUnitCC <= 30 && highRiskUnitCC <= 5 && veryHighRiskUnitCC == 0) {
		UnitMetrics::unitCCScore = "+";
	} else if (mediumRiskUnitCC <= 40 && highRiskUnitCC <= 10 && veryHighRiskUnitCC == 0) {
		UnitMetrics::unitCCScore = "0";
	} else if (mediumRiskUnitCC <= 50 && highRiskUnitCC <= 15 && veryHighRiskUnitCC <= 5) {
		UnitMetrics::unitCCScore = "-";
	} else {
		UnitMetrics::unitCCScore = "--";
	}
}

/**
 * Prints the results for the unit size and unit compelxity. 
 */
public void printResults() {
	println("Unit Size");
	println();
	
	println("lowRisk: <UnitMetrics::lowRiskUnitSize>%");
	println("mediumRisk: <UnitMetrics::mediumRiskUnitSize>%");
	println("highRisk: <UnitMetrics::highRiskUnitSize>%");
	println("veryHighRisk: <UnitMetrics::veryHighRiskUnitSize>%");	
	println();	
	println("Unit Size Rating: <UnitMetrics::unitSizeScore>");
	
	println();
	
	println("Unit complexity");
	println();
	
	println("lowRisk: <UnitMetrics::lowRiskUnitCC>%");
	println("mediumRisk: <UnitMetrics::mediumRiskUnitCC>%");
	println("highRisk: <UnitMetrics::highRiskUnitCC>%");
	println("veryHighRisk: <UnitMetrics::veryHighRiskUnitCC>%");	
	
	println();
	
	println("Unit Complexity Rating: <UnitMetrics::unitCCScore>");  
}