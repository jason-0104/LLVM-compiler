all: textLexer.class test1.class

textLexer.class test1.class: textLexer.java test1.java
	javac -cp ./antlr-3.5.2-complete-no-st3.jar  textLexer.java test1.java 
test1.java test1.token: test1.g
	java -cp ./antlr-3.5.2-complete-no-st3.jar org.antlr.Tool test1.g

clean:
	rm *.tokens test1.java *.class
