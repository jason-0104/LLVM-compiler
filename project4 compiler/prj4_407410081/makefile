all: myCompiler_test.class myCompiler.class

myCompiler_test.class myCompiler.class: myCompiler_test.java myCompilerLexer.java myCompilerParser.java
	javac -cp ./antlr-3.5.2-complete-no-st3.jar myCompiler_test.java myCompilerLexer.java myCompilerParser.java
myCompilerLexer.java myCompilerParser.java myCompiler.token: myCompiler.g 
	java -cp ./antlr-3.5.2-complete-no-st3.jar org.antlr.Tool myCompiler.g

clean:
	rm *.tokens myCompilerLexer.java myCompilerParser.java *.class
