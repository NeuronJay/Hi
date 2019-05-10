%{
#include "rules.tab.h"
%}

%%

"+"         { return ADD; }
"-"         { return SUB; }
"*"         { return MUL; }
"/"         { return DIV; }
"%"         { return MOD; }
[0-9]+      { yylval = atoi(yytext); return NUMBER; }
"\n"        { return EOL; }

"print"     { return PRINT; } 

[ \t]       { }
.           { printf("Anything\n"); }

%%

int main(int argc, char **argv){
    if(argc > 1){
        if(!(yyin = fopen(argv[1], "r"))){
            perror(argv[1]);
            return 1;
        }
    }

    yyparse();
    return 0;
}
