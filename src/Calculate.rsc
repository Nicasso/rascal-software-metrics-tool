module Calculate

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import IO;

public void begin() {
   println("Begin");
   
   software = createM3FromEclipseProject(|project://smallsql0.21_src|);
}
