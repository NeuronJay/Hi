%{
#include <stdio.h>
#include <string.h>

#include "variable.hpp"
#include "print.hpp"

void yyerror(char *s);
int yylex(void);
extern char *yytext;
%}

%token NUMBER STRING NAME
%token ADD SUB MUL DIV MOD ABS EQUATE
%token PAREN_O PAREN_C
%token DOUBLE_QUOTE SINGLE_QUOTE
%token SEMICOLON
%token PRINTLN PRINT VAR

%union {
    struct str_params {
        char *text;
        int length;
    };
    struct str_params str;
    double dval;
}

%type <str> STRING
%type <str> NAME
%type <dval> NUMBER
%type <dval> exp
%type <dval> factor
%type <dval> term

%%

instructionlist     :
                    | instructionlist exp
                    | instructionlist print
                    | instructionlist variable
                    ;

print               : PRINT PAREN_O exp PAREN_C SEMICOLON { compiler::printd($3); }
                    | PRINT PAREN_O STRING PAREN_C SEMICOLON {
                        printf("%.*s", ($3).length - 2, ($3).text + 1 );
                    }
                    | PRINT PAREN_O NAME PAREN_C SEMICOLON {
                        char var[($3).length];
                        int n = sprintf(var, "%.*s", ($3).length, ($3).text);
                        compiler::print(var);
                    }
                    | PRINTLN PAREN_O exp PAREN_C SEMICOLON { compiler::printdn($3); }
                    | PRINTLN PAREN_O STRING PAREN_C SEMICOLON {
                        printf("%.*s\n", ($3).length - 2, ($3).text + 1 );
                    }
                    | PRINTLN PAREN_O NAME PAREN_C SEMICOLON {
                        char var[($3).length];
                        int n = sprintf(var, "%.*s", ($3).length, ($3).text);
                        compiler::println(var);
                    }
                    ;

variable            : NAME EQUATE exp SEMICOLON {
                        char var[($1).length];
                        int n = sprintf(var, "%.*s", ($1).length, ($1).text);
                        compiler::addNumVar(var, $3);
                    }
                    | VAR NAME EQUATE exp SEMICOLON {
                        char var[($2).length];
                        int n = sprintf(var, "%.*s", ($2).length, ($2).text);
                        compiler::addNumVar(var, $4);
                    }
                    | NAME EQUATE STRING SEMICOLON {
                        char var[($1).length];
                        char value[($3).length - 2];
                        int n;

                        n = sprintf(var, "%.*s", ($1).length, ($1).text);
                        n = sprintf(value, "%.*s", ($3).length - 2, ($3).text + 1);
                        compiler::addStringVar(var, value);
                    }
                    | VAR NAME EQUATE STRING SEMICOLON {
                        char var[($2).length];
                        char value[($4).length - 2];
                        int n;

                        n = sprintf(var, "%.*s", ($2).length, ($2).text);
                        n = sprintf(value, "%.*s", ($4).length - 2, ($4).text + 1);
                        compiler::addStringVar(var, value);
                    }
                    ;

exp                 : factor            { $$ = $1; }
                    | exp ADD factor    { $$ = $1 + $3; }
                    | exp SUB factor    { $$ = $1 - $3; }
                    ;

factor              : term              { $$ = $1; }
                    | factor MOD term   {
                        if($3){
                            if($1 - (int)$1 || $3 - (int)$3){
                                fprintf(stderr, "Error: Decimals in '%' Operation\n");
                                exit(1);
                            } else {
                                $$ = (int)$1 % (int)$3;
                            }
                        } else {
                            fprintf(stderr, "Error: Division by 0\n");
                            exit(1);
                        }
                    }
                    | factor MUL term   { $$ = $1 * $3; }
                    | factor DIV term   {
                        if($3){
                            $$ = $1 / $3;
                        } else {
                            fprintf(stderr, "Error: Division by 0\n");
                            exit(1);
                        }
                    }
                    ;

term                : NUMBER
                    | NAME {
                        char var[($1).length];
                        int n = sprintf(var, "%.*s", ($1).length, ($1).text);
                        $$ = compiler::getNumValue(var);
                    }

%%

void yyerror(char *s){
    fprintf(stderr, "error: %s\n", s);
}
