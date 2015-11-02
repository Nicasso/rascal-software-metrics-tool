module Calculate

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import IO;
import List;

public M3 software;
public int LOC;

public void begin() {
   println("Begin");
   
   Calculate::software = createM3FromEclipseProject(|project://TestProject|);
   println(Calculate::software@containment[|java+compilationUnit:///C:/Users/Nico/workspace/TestProject/src/Test.java|]);
   
   helloWorldMethods = [ e | e <- Calculate::software@containment[|java+class:///Test|], e.scheme == "java+method"];
   
   println(helloWorldMethods);
   println(helloWorldMethods[0]);
   println(size(helloWorldMethods));
   
   methodSrc = readFile(helloWorldMethods[0]);
   print(methodSrc);
   
   print(size(methodSrc));
   
   methodAST = getMethodASTEclipse(helloWorldMethods[0], model=Calculate::software);
}


