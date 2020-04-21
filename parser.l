%{
    #include <stdio.h>
    #include <stdlib.h>

    #define PROGRAM_TOKEN 1
    #define IDENTIFIER_TOKEN 2
    #define SET_TOKEN 3
    #define IF_TOKEN 4
    #define IFELSE_TOKEN 5
    #define WHILE_TOKEN 6
    #define INT_LITERAL_TOKEN 7
    #define FLOAT_LITERAL_TOKEN 8
    #define ADDITION_TOKEN 9
    #define SUBSTRACTION_TOKEN 10
    #define MULTIPLICATION_TOKEN 11
    #define DIVISION_TOKEN 12
    #define EQUAL_TOKEN 13
    #define LT_TOKEN 14
    #define GT_TOKEN 15
    #define OPEN_CURLY_BRACKET 16
    #define CLOSE_CURLY_BRACKET 17
    #define OPEN_PARENTHESIS 18
    #define CLOSE_PARENTHESIS 19
    #define SEMICOLON_TOKEN 20
    #define EPSILON_TOKEN 21

    #define OTHER_TOKEN -1

    int first_progr(int input) {
        return (input==PROGRAM_TOKEN);
    }

    int first_stmt(int input) {
        return (
            input == SET_TOKEN ||
            input == IDENTIFIER_TOKEN ||
            input == IFELSE_TOKEN ||
            input == WHILE_TOKEN
        );
    }

    int first_opt_stmts(int input) {
        return (
            input == OPEN_CURLY_BRACKET || 
            input == SEMICOLON_TOKEN ||  
            first_stmt(input)
        );
    }

    int first_stmt_lst(int input) {
        return (
            input == SEMICOLON_TOKEN ||  
            first_stmt(input)
        );
    }

    int first_stmt_lstP(int input) {
        return (
            input == SEMICOLON_TOKEN ||  
            input == EPSILON_TOKEN ||  
            first_stmt(input)
        );
    }

%}


%%

[[:space:]]+

"program"						{return PROGRAM_TOKEN;}
"set"							{return SET_TOKEN;}
"if"							{return IF_TOKEN;}
"else"							{return IFELSE_TOKEN;}
"while"							{return WHILE_TOKEN;}
"+"								{return ADDITION_TOKEN;}
"-"								{return SUBSTRACTION_TOKEN;}
"*"								{return MULTIPLICATION_TOKEN;}
"/"								{return DIVISION_TOKEN;}
"="								{return EQUAL_TOKEN;}
"<"								{return LT_TOKEN;}
">"								{return GT_TOKEN;}
"{"								{return OPEN_CURLY_BRACKET;}
"}"								{return CLOSE_CURLY_BRACKET;}
"("								{return OPEN_PARENTHESIS;}
")"								{return CLOSE_PARENTHESIS;}
";"								{return SEMICOLON_TOKEN;}

("+"|"-")?[01-9]+"."[01-9]+		{return FLOAT_LITERAL_TOKEN;}
("+"|"-")?[01-9]+				{return INT_LITERAL_TOKEN;}
[a-zA-Z][A-Za-z0-9]*			{return IDENTIFIER_TOKEN;}

.								{return OTHER_TOKEN;}

%%

/******* CODIGO *******/

int yywrap(){} 

void reportSyntaxError(){
    printf("Syntax error (%s) at line: %d\n", yytext, yylineno);
}

void expr(){}

void opt_stmts() {
    int token = yylex();
    printf("%d: %s\n", token, yytext);
}

void progr() {
    if(yylex() == IDENTIFIER_TOKEN){
        opt_stmts();
    } else {
        reportSyntaxError();
    }
}

int main(int argc, char **argv) {
	if(argc >= 2) {
		freopen(argv[1], "r", stdin);
	}

    if(first_progr(yylex())){
        progr();
    } else {
        reportSyntaxError();
    }
}