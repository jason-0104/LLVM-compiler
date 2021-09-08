import org.antlr.runtime.ANTLRFileStream;
import org.antlr.runtime.CharStream;
import org.antlr.runtime.Token;

public class textLexer {
    public static void main(String[] args) {
        try {
            CharStream input = new ANTLRFileStream(args[0]);
            test1 lexer = new test1(input);
            Token token = lexer.nextToken();
            while (token.getType() != -1) {
                System.out.println("Token: " + token.getType() + " " + token.getText());
                token = lexer.nextToken();
            }

        } catch (Throwable t) {
            System.out.println("Exception: " + t);
            t.printStackTrace();
        }
    }
}