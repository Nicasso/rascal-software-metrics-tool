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

public void calculateUnitMetrics(rel[loc, Statement] myMethods) {
	// Get all classes so we can access all methods.
   	//allClasses = classes(currentSoftware);
   	   	
   	list[tuple[int,int]] locAndCC = [];
   	
   	//int i = 0;
   	// Loop through all classes.
	//for (currentClass <- allClasses) {
		// Get all methods and constructors per class. @TODO DO WE ALSO NEED TO CALCULATE CONSTRUCTORS?
		//myMethods = [ e | e <- currentSoftware@containment[currentClass], e.scheme == "java+method" || e.scheme == "java+constructor"];
   		
   		// Calculate the lines of code for every method.
		for (method <- myMethods) {
			list[loc] tmp = [];
			tmp = tmp + [method[0]]; 
			int currentLoc = countVolume(tmp)["code"];
			int methodCC = computeCC(method[1]);
			
			//methodAST = getMethodASTEclipse(method, model = currentSoftware);
			
			
			
			locAndCC += <currentLoc, methodCC>;
			
			//iprintln("<method> - methodCC: <methodCC>");
		}
	//}
	iprintln(locAndCC);
	map[str,int] unitSizes = unitSize(locAndCC);
	calculateUnitSizeRisk(unitSizes);
	
	map[str,int] unitCCs = unitCC(locAndCC);
	calculateUnitCCRisk(unitCCs);
}

public int computeCC(Statement statement) {
	int methodCC = 1;
			
			//iprintln(methodAST);
			
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
					// @TODO ALSO ADD countAndOr HERE FOR THE ENTIRE LIST OF EXPRESSIONS?
					methodCC += updaters;
				}
				case \catch(Declaration exception, Statement body): {
					methodCC += 1;
				}
				case \continue(): {
					methodCC += 1;
				}
				case \continue(str label): {
					methodCC += 1;
				}
				case \do(Statement body, Expression condition): {
					methodCC += countAndOr(condition);
				}
			};
			return methodCC;
}

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

public rel[loc, Statement] allMethods(set[Declaration] decls){
	results = {};
	visit(decls){
		case m: \method(_,_,_,_, Statement s):
			results += <m@src, s>;
		case c: \constructor(_,_,_, Statement s):
			results += <c@src, s>;
	}
	return results; 
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

public void calculateUnitSizeRisk(map[str,int] unitResults) {
	UnitMetrics::lowRiskUnitSize = percent(unitResults["low"], unitResults["total"]);
	UnitMetrics::mediumRiskUnitSize = percent(unitResults["medium"], unitResults["total"]);
	UnitMetrics::highRiskUnitSize = percent(unitResults["high"], unitResults["total"]);
	UnitMetrics::veryHighRiskUnitSize = percent(unitResults["veryHigh"], unitResults["total"]);
		
	if (mediumRiskUnitSize <= 25 && highRiskUnitSize == 0 && veryHighRiskUnitSize == 0) {
		UnitMetrics::unitSizeScore = "++";
	} else if (mediumRiskUnitSize <= 25 && highRiskUnitSize == 0 && veryHighRiskUnitSize == 0) {
		UnitMetrics::unitSizeScore = "+";
	} else if (mediumRiskUnitSize <= 25 && highRiskUnitSize == 0 && veryHighRiskUnitSize == 0) {
		UnitMetrics::unitSizeScore = "0";
	} else if (mediumRiskUnitSize <= 25 && highRiskUnitSize == 0 && veryHighRiskUnitSize == 0) {
		UnitMetrics::unitSizeScore = "-";
	} else {
		UnitMetrics::unitSizeScore = "--";
	}
}

public void calculateUnitCCRisk(map[str,int] unitResults) {
	UnitMetrics::lowRiskUnitCC = percent(unitResults["low"], unitResults["total"]);
	UnitMetrics::mediumRiskUnitCC = percent(unitResults["medium"], unitResults["total"]);
	UnitMetrics::highRiskUnitCC = percent(unitResults["high"], unitResults["total"]);
	UnitMetrics::veryHighRiskUnitCC = percent(unitResults["veryHigh"], unitResults["total"]);
		
	if (mediumRiskUnitCC <= 25 && highRiskUnitCC == 0 && veryHighRiskUnitCC == 0) {
		UnitMetrics::unitCCScore = "++";
	} else if (mediumRiskUnitCC <= 25 && highRiskUnitCC == 0 && veryHighRiskUnitCC == 0) {
		UnitMetrics::unitCCScore = "+";
	} else if (mediumRiskUnitCC <= 25 && highRiskUnitCC == 0 && veryHighRiskUnitCC == 0) {
		UnitMetrics::unitCCScore = "0";
	} else if (mediumRiskUnitCC <= 25 && highRiskUnitCC == 0 && veryHighRiskUnitCC == 0) {
		UnitMetrics::unitCCScore = "-";
	} else {
		UnitMetrics::unitCCScore = "--";
	}
}

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