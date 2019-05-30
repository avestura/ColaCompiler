package ir.ac.guilan.Compiler.Project.Cola.syntactic;

import ir.ac.guilan.Compiler.Project.Cola.lexical.Lexer;
import java_cup.runtime.ComplexSymbolFactory;

import java.io.*;
import java.util.Scanner;

public class CustomScanner {
    public static void main(String[] args) {

        if(args.length != 1){
            System.out.println("> You should exactly have one argument for file name. Program terminates.");
            return;
        }
        String fileName = args[0];
        Lexer scanner = null;

        try{
            FileInputStream fioStream = new FileInputStream(fileName);
            Reader fioReader = new InputStreamReader(fioStream);
            scanner = new Lexer(fioReader);

            Parser parser = new Parser(scanner);


            parser.parse();
        }
        catch (FileNotFoundException ex){
            System.out.println("Sorry, but program can't find the specified file. Program terminates.");
        }
        catch (IOException ex){
            System.out.println("Sorry, something wrong with I/O system. Program terminates.");
        } catch (Exception e) {
            System.out.println("There were errors.");
            e.printStackTrace();
        }

    }
}
