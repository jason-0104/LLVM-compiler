all: testParser.class myparser.class

testParser.class myparser.class: testParser.java myparserLexer.java myparserParser.java
	javac -cp ./antlr-3.5.2-complete-no-st3.jar testParser.java myparserLexer.java myparserParser.java
myparserLexer.java myparserParser.java myparser.token: myparser.g 
	java -cp ./antlr-3.5.2-complete-no-st3.jar org.antlr.Tool myparser.g

clean:
	rm *.tokens myparserLexer.java myparserParser.java *.class
