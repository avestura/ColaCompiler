/* JFlex example: part of Java language lexer specification */
package ir.ac.guilan.Compiler.Project.Cola.lexical;
import java_cup.runtime.*;
import java_cup.sym;
import java_cup.runtime.Symbol;
import java_cup.runtime.ComplexSymbolFactory;
import java_cup.runtime.ComplexSymbolFactory.Location;

import static ir.ac.guilan.Compiler.Project.Cola.syntactic.sym.*;
/**
* This class is a simple example lexer.
*/
%%
%public
%class Lexer
%unicode
%cup
%implements sym, Constants
%line
%column
%char
/*%standalone*/
%{
    StringBuffer string = new StringBuffer();
    ComplexSymbolFactory symbolFactory = new ComplexSymbolFactory();

    public static int Counter = 1;

    private void print(String text, int line, int column, String type){
        System.out.printf("%03d- %s\t\t  Line %02d\t\t Col %02d\t\t Content = [%s]\n", Counter++, type, line, column, text );
    }

    public Lexer(java.io.Reader in, ComplexSymbolFactory sf){
    	this(in);
    	symbolFactory = sf;
    }

    private Symbol symbol(String name, int sym) {
          return symbolFactory.newSymbol(name, sym, new Location(yyline+1,yycolumn+1,yychar), new Location(yyline+1,yycolumn+yylength(),yychar+yylength()));
    }

    private Symbol symbol(String name, int sym, Object val) {
          Location left = new Location(yyline+1,yycolumn+1,yychar);
          Location right= new Location(yyline+1,yycolumn+yylength(), yychar+yylength());
          return symbolFactory.newSymbol(name, sym, left, right,val);
    }

    private Symbol symbol(String name, int sym, Object val,int buflength) {
          Location left = new Location(yyline+1,yycolumn+yylength()-buflength,yychar+yylength()-buflength);
          Location right= new Location(yyline+1,yycolumn+yylength(), yychar+yylength());
          return symbolFactory.newSymbol(name, sym, left, right,val);
    }



%}

// ============ General Rules ============
LineTerminator       = \r|\n|\r\n
InputCharacter       = [^\r\n]
WhiteSpace           = {LineTerminator} | [ \t\f]
Semi                 = ";"

// ============ Comments ============
Comment              = {MultiLineComment} | {EndOfLineComment} | {DocumentationComment}

MultiLineComment     = "/*"[\w\W\n\r]*?"*/"
EndOfLineComment     = "//" {InputCharacter}* {LineTerminator}?
DocumentationComment = "///" {InputCharacter}* {LineTerminator}?

// ============ Identifier ============
Identifier           = ([a-zA-Z_@])([a-zA-Z0-9_])*

// ============ Numbers ============
DecIntegerLiteral    = ([\+\-]?)(0|[1-9][0-9]*)
FloatNumber          = {DecIntegerLiteral}?((\.(0|[1-9][0-9]*(f|F)?))|(f|F))
Signed64BitInteger   = {DecIntegerLiteral}(L|l)
HexaNumber           = (0x)(([0-9a-fA-F]+))

MatchingGroup        = "$"([0-9]+)

%state STRING
%%
// ============ Keywords ============
<YYINITIAL> "class"            { return symbol("class",      TypeDef                               ); }
<YYINITIAL> "string"           { return symbol("string",     Type,         new Integer(TypeString) ); }
<YYINITIAL> "int"              { return symbol("int",        Type,         new Integer(TypeInt)    ); }
<YYINITIAL> "void"             { return symbol("void",       Type,         new Integer(TypeVoid)   ); }
<YYINITIAL> "new"              { return symbol("new",        MemDef                                ); }
<YYINITIAL> "for"              { return symbol("for",        ForLoop                               ); }
<YYINITIAL> "var"              { return symbol("var",        Var                                   ); }
<YYINITIAL> "in"               { return symbol("in",         In                                    ); }
<YYINITIAL> "if"               { return symbol("if",         If                                    ); }
<YYINITIAL> "else"             { return symbol("else",       Else                                  ); }
<YYINITIAL> "true"             { return symbol("true",       True                                  ); }
<YYINITIAL> "false"            { return symbol("false",      False                                 ); }
<YYINITIAL> "return"           { return symbol("return",     Return                                ); }
<YYINITIAL> "while"            { return symbol("while",      While                                 ); }
<YYINITIAL> "main()"           { return symbol("EntryPoint", EntryPoint                            ); }

<YYINITIAL> {

// ============ Identifier ============
{Identifier}                   { return symbol("Identifier", Identifier, yytext()                 ); }

// ============ Numbers ============
{HexaNumber}                   { return symbol("Hexa",       NumValue,     new Integer(Hexa)      ); }
{FloatNumber}                  { return symbol("Float",      NumValue,     new Integer(Float)     ); }
{Signed64BitInteger}           { return symbol("S64",        NumValue,     new Integer(S64)       ); }
{DecIntegerLiteral}            { return symbol("DecInt",     NumValue,     new Integer(DecInt)    ); }

// ============ String Init  ============
\"                             { string.setLength(0); yybegin(STRING); }

// ============ Delimiters ============
{Semi}                         { return symbol(";",          Semi                                ); }
"("                            { return symbol("(",          LPar                                ); }
")"                            { return symbol(")",          RPar                                ); }
"{"                            { return symbol("{",          BeginBlock                          ); }
"}"                            { return symbol("}",          EndBlock                            ); }
"["                            { return symbol("[",          LBracelet                           ); }
"]"                            { return symbol("]",          RBracelet                           ); }
":"                            { return symbol(":",          Colon                               ); }
","                            { return symbol(",",          Comma                               ); }

// ============ Operators ============
"="                            { return symbol("=",          Assign                              ); }
"=~"                           { return symbol("=~",         Comparator                          ); }
"!~"                           { return symbol("!~",         Comparator                          ); }
"=="                           { return symbol("Eq",         Comparator, new Integer(Eq)         ); }
"!="                           { return symbol("NotEq",      Operator,   new Integer(NotEq)      ); }
"++"                           { return symbol("PlusPlus",   PlusPlus                            ); }
"+"                            { return symbol("Plus",       Operator,   new Integer(Plus)       ); }
"--"                           { return symbol("MinusMinus", MinusMinus                          ); }
"-"                            { return symbol("Minus",      Operator,   new Integer(Minus)      ); }
"\\"                           { return symbol("\\",         Operator                            ); }
"*"                            { return symbol("Mult",       Operator,   new Integer(Mult)       ); }
">"                            { return symbol("GrT",        Comparator, new Integer(GrT)        ); }
"<"                            { return symbol("LoT",        Comparator, new Integer(LoT)        ); }
"|"                            { return symbol("Or",         Comparator, new Integer(Or)         ); }
"/"                            { return symbol("Divide",     Operator,   new Integer(Divide)     ); }
"^"                            { return symbol("NNot",       Operator                            ); }
"!"                            { return symbol("Not",        Operator,   new Integer(Not)        ); }
"."                            { return symbol("Dot",        Dot                                 ); }

// ============ Comments ============
{Comment}                      { /* ignore */ }

// ============ Whitespace ============
{WhiteSpace}                   { /* ignore */ }
}

// ============ String Rules ============
<STRING> {
\"                             {
                                 yybegin(YYINITIAL);
                                 return symbol("StringConst", StringConst, string.toString(), string.length());
                               }

[^\n\r\"\\]+                   { string.append( yytext() ); }
\\t                            { string.append('\t'); }
\\n                            { string.append('\n'); }
\\r                            { string.append('\r'); }
\\\"                           { string.append('\"'); }
\\                             { string.append('\\'); }
}

// ============ Error Fallback ============
[^]                            { throw new Error("Parsing Failed! Illegal character ["+ yytext()+"] at line " + yyline + ", col " + yycolumn); }

