%{
    #include <stdio.h>
    #include <stdlib.h>

    #define PROGRAM_TOKEN 1
    #define IDENTIFIER_TOKEN 2
    #define SET_TOKEN 3
    #define IF_TOKEN 4
    #define IFELSE_TOKEN 5
    #define WHILE_TOKEN 6
    #define NUMBER_TOKEN 7
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
            input == IF_TOKEN ||
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

    int first_instr(int input) {
         return (
            input == SEMICOLON_TOKEN || 
            first_stmt(input)
        );
    }

    int first_expr(int input) {
        return (
            input == OPEN_PARENTHESIS || 
            input == IDENTIFIER_TOKEN ||
            input == NUMBER_TOKEN
        );
    }

    int firs_exprP(int input) {
        return (
            input == ADDITION_TOKEN ||
            input == SUBSTRACTION_TOKEN ||
            input == EPSILON_TOKEN
        );
    }

    int first_term(int input) {
        return first_expr(input);
    }

    int first_termP(int input) {
        return (
            input == MULTIPLICATION_TOKEN ||
            input == DIVISION_TOKEN ||
            input == EPSILON_TOKEN
        );
    }

    int first_factor(int input) {
        return first_expr(input);
    }

    int first_expresion(int input) {
        return  first_expr(input);
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

("+"|"-")?[01-9]+				{return NUMBER_TOKEN;}
[a-zA-Z][A-Za-z0-9]*			{return IDENTIFIER_TOKEN;}

.								{return OTHER_TOKEN;}

%%

/******* CODIGO *******/

int yywrap(){} 

int prog();
int progP();
int stmt();
int opt_stmts();
int stmt_lst();
int stmt_lstP();
int intr();
int expr();
int exprP();
int term();
int termP();
int factor();
int expresion();

int currentToken;

void debug(char *non_terminal){
    printf("*** %s \t\t\t | text=%s [token: %d] at line: %d\n", non_terminal, yytext, currentToken, yylineno);
}

int syntaxError(){
    printf("Syntax error (text=%s) at line: %d\n", yytext, yylineno);
    return 0;
}

int factor() {
    debug("factor");
    return (
        currentToken == IDENTIFIER_TOKEN ||
        currentToken == NUMBER_TOKEN ||
        (currentToken == OPEN_PARENTHESIS && expr() && yylex() == CLOSE_PARENTHESIS)
    );
}

int termP() {
    currentToken = yylex();
    if(first_termP(currentToken)) {
        debug("term' -> {*, /}");
        return (factor() && termP());
    } else return 1;
}

int term() {
    debug("term");
    return (factor() && termP());
}

int exprP(){
    debug("expr'");
    return 1;
}

int expr(){
    debug("expr");
    return (term() && exprP());
}

int instr(){
    if(currentToken==SEMICOLON_TOKEN)
        return 1;
    if(first_stmt(currentToken)){
        debug("instr -> stmt ;");
        return (stmt() && (yylex() == SEMICOLON_TOKEN));
    } else return syntaxError();
}

int stmt_lstP() {
    debug("stmt_lst'");
    return (instr() && stmt_lstP()) || 1;
} 

int stmt_lst() {
    if(first_instr(currentToken)){
        return (instr() && stmt_lstP());
    }else return syntaxError();
}

int opt_stmts() {
    currentToken = yylex();
    if(first_instr(currentToken)){
        debug("opt_stmts -> instr");
        return instr();
    } if(first_opt_stmts(currentToken)){
        currentToken = yylex();
        if(currentToken == CLOSE_CURLY_BRACKET){
            debug("opt_stmts -> {}");
            return 1;
        }
        if(first_stmt_lst(currentToken)){
            while(stmt_lst()){
                currentToken = yylex();
                debug("opt_stmts -> {stmt}");
            }
            return (yylex() == CLOSE_CURLY_BRACKET);
        } else {
            return syntaxError();
        }
    }else {
        return syntaxError();
    }
}

int stmt() {
    if(currentToken == SET_TOKEN){
        currentToken = yylex();
        return expr();
    } if(currentToken == IF_TOKEN){
        currentToken = yylex();
        if(1){ //expresion
            currentToken = yylex();
            return (currentToken == CLOSE_PARENTHESIS && opt_stmts());
        }
    } if(currentToken == IFELSE_TOKEN){
        currentToken = yylex();
        if(1){//expresion
            currentToken = yylex();
            return (currentToken == CLOSE_PARENTHESIS && opt_stmts() && opt_stmts());
        }
    } else return syntaxError();
}

int progr() {
    currentToken = yylex();
    if(first_progr(currentToken)){
        currentToken = yylex();
        if(currentToken == IDENTIFIER_TOKEN)
            return opt_stmts();
    } else {
        return syntaxError();
    }
}

int main(int argc, char **argv) {
	if(argc >= 2) {
		freopen(argv[1], "r", stdin);
	}

    if(progr()){
        printf("\nSi\n");
    }else{
        printf("\nNo\n");
    }

}