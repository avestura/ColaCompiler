/* JFlex example: part of Java language lexer specification */
import java_cup.runtime.*;
/**
* This class is a simple example lexer.
*/
%%
%class Lexer
%unicode
/*%cup*/
%line
%column
%standalone
%{
    StringBuffer string = new StringBuffer();

    public static int Counter = 1;

    private void print(String text, int line, int column, String type){
        System.out.printf("%03d- %s\t\t  Line %02d\t\t Col %02d\t\t Content = [%s]\n", Counter++, type, line, column, text );
    }
%}

// ============ General Rules ============
LineTerminator       = \r|\n|\r\n
InputCharacter       = [^\r\n]
WhiteSpace           = {LineTerminator} | [ \t\f]
Delimiter            = "(" | ")" | "{" | "}" | "[" | "]" | ":" | ","
EndOfStatement       = ";"

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
HexaNumber           = (0x)([1-9a-fA-F][0-9a-fA-F]*)

MatchingGroup        = "$"([0-9][0-9]*)

%state STRING
%%
// ============ Keywords ============
<YYINITIAL> "class"            { print(yytext(), yyline, yycolumn, "Keyword(Class)"); }
<YYINITIAL> "string"           { print(yytext(), yyline, yycolumn, "Keyword(String)"); }
<YYINITIAL> "int"              { print(yytext(), yyline, yycolumn, "Keyword(Integer)"); }
<YYINITIAL> "new"              { print(yytext(), yyline, yycolumn, "Keyword(New)"); }
<YYINITIAL> "for"              { print(yytext(), yyline, yycolumn, "Keyword(For)"); }
<YYINITIAL> "foreach"          { print(yytext(), yyline, yycolumn, "Keyword(ForEach)"); }
<YYINITIAL> "var"              { print(yytext(), yyline, yycolumn, "Keyword(Variable)"); }
<YYINITIAL> "in"               { print(yytext(), yyline, yycolumn, "Keyword(In)"); }
<YYINITIAL> "if"               { print(yytext(), yyline, yycolumn, "Keyword(If)"); }
<YYINITIAL> "continue"         { print(yytext(), yyline, yycolumn, "Keyword(Continue)"); }
<YYINITIAL> "get"              { print(yytext(), yyline, yycolumn, "Keyword(Get)"); }
<YYINITIAL> "set"              { print(yytext(), yyline, yycolumn, "Keyword(Set)"); }
<YYINITIAL> "return"           { print(yytext(), yyline, yycolumn, "Keyword(Return)"); }
<YYINITIAL> "as"               { print(yytext(), yyline, yycolumn, "Keyword(As)"); }

<YYINITIAL> {

// ============ Identifier ============
{Identifier}                   { print(yytext(), yyline, yycolumn, "Identifier\t"); }
{Delimiter}                    { print(yytext(), yyline, yycolumn, "Delimiter\t"); }
{EndOfStatement}               { print(yytext(), yyline, yycolumn, "Semicolon\t"); }
{MatchingGroup}                { print(yytext(), yyline, yycolumn, "MatchingGroup"); }

// ============ Numbers ============
{HexaNumber}                   { print(yytext(), yyline, yycolumn, "Number(Hex)"); }
{FloatNumber}                  { print(yytext(), yyline, yycolumn, "Number(float)"); }
{Signed64BitInteger}           { print(yytext(), yyline, yycolumn, "Number(signed 64)"); }
{DecIntegerLiteral}            { print(yytext(), yyline, yycolumn, "Number(int)"); }

// ============ String Init  ============
\"                             { string.setLength(0); yybegin(STRING); }

// ============ Operators ============
"="                            { print(yytext(), yyline, yycolumn, "Operator(=)"); }
"=~"                           { print(yytext(), yyline, yycolumn, "Operator(=~)");}
"!~"                           { print(yytext(), yyline, yycolumn, "Operator(!~)");}
"+"                            { print(yytext(), yyline, yycolumn, "Operator(+)"); }
"-"                            { print(yytext(), yyline, yycolumn, "Operator(-)"); }
"\\"                           { print(yytext(), yyline, yycolumn, "Operator(\\)"); }
"*"                            { print(yytext(), yyline, yycolumn, "Operator(*)"); }
">"                            { print(yytext(), yyline, yycolumn, "Operator(>)"); }
"<"                            { print(yytext(), yyline, yycolumn, "Operator(<)"); }
"|"                            { print(yytext(), yyline, yycolumn, "Operator(|)"); }
"/"                            { print(yytext(), yyline, yycolumn, "Operator(/)"); }
"^"                            { print(yytext(), yyline, yycolumn, "Operator(^)"); }
"$"                            { print(yytext(), yyline, yycolumn, "Operator($)"); }
"."                            { print(yytext(), yyline, yycolumn, "Operator(Dot)"); }

// ============ Comments ============
{Comment}                      { { print(yytext(), yyline, yycolumn, "Comment\t"); } }

// ============ Whitespace ============
{WhiteSpace}                   { /* ignore */ }
}

// ============ String Rules ============
<STRING> {
\"                             {
                                 yybegin(YYINITIAL);
                                 print(string.toString(), yyline, yycolumn, "String\t");
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

