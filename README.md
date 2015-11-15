# MMT (Metrics Measurement Tool)

A tool written in Rascal to measure certain metric of Java based projects. 
These results are used to calculate SIG maintainability model scores.
[Read more about the SIG maintainability model here](http://ieeexplore.ieee.org/xpl/articleDetails.jsp?arnumber=4335232).

Running this tool on a Java project will result in the metrics defined below.

## Volume metrics
* Lines of code
* Lines of comments
* Blank lines
* Total lines

And the lines of code is used to calculate a SIG score for the volume of the project.

## Unit size
Unit sizes categorized by the following risk level as a percentage of the total lines of code:
* Low risk
* Medium risk
* High risk
* Very high risk

And of course a SIG score is calculated for the unit size.

## Unit complexity
Unit complexity categorized by the following risk level as a percentage of the total lines of code:
* Low risk
* Medium risk
* High risk
* Very high risk

Also here a SIG score calculated is for the unit comeplxity.

## Duplication
* The percentage of code duplication within the project

Which is also used for a SIG score specifically for duplication.
