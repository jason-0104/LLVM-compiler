all: myChecker_test.class myChecker.class

myChecker_test.class myChecker.class: myChecker_test.java myCheckerLexer.java myCheckerParser.java
	javac -cp ./antlr-3.5.2-complete-no-st3.jar myChecker_test.java myCheckerLexer.java myCheckerParser.java
myCheckerLexer.java myCheckerParser.java myChecker.token: myChecker.g 
	java -cp ./antlr-3.5.2-complete-no-st3.jar org.antlr.Tool myChecker.g

clean:
	rm *.tokens myCheckerLexer.java myCheckerParser.java *.class
