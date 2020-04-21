%{
#include <stdio.h>
#include <stdlib.h>

// Terminals, recognized by lexer
#define PROGRAM_TOKEN 1
#define IDENTIFIER_TOKEN 2
#define SET_TOKEN 3
#define IF_TOKEN 4
#define IFELSE_TOKEN 5
#define WHILE_TOKEN 6
#define INT_LITERAL_TOKEN 7
#define ADDITION_TOKEN 10
#define SUBSTRACTION_TOKEN 12
#define MULTIPLICATION_TOKEN 13
#define DIVISION_TOKEN 14
#define EQUAL_TOKEN 15
#define LT_TOKEN 16
#define GT_TOKEN 17
#define OPEN_CURLY_BRACKET 18
#define CLOSE_CURLY_BRACKET 19
#define OPEN_PARENTHESIS 20
#define CLOSE_PARENTHESIS 21
#define SEMICOLON_TOKEN 22

#define OTHER_TOKEN -1

%}

%%

[[:space:]]+

"program"						{return PROGRAM_TOKEN;}
"set"							{return SET_TOKEN;}
"ifelse"						{return IFELSE_TOKEN;}
"if"							{return IF_TOKEN;}
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

[01-9]+							{return INT_LITERAL_TOKEN;}
[a-zA-Z][A-Za-z0-9]*			{return IDENTIFIER_TOKEN;}

.								{return OTHER_TOKEN;}

%%

// Functions to test for non-terminals

int current_token;

void next() {
	current_token = yylex();
	//printf("%d: %s\n", current_token, yytext);
}

// If token == current token, advance and return true. If not, just return false
int check(int token) {
	if(current_token == token) {
		next();
		return 1;
	}
	else {
		return 0;
	}
}

// Rules

int expr();

int expresion_p() {
	if(check(LT_TOKEN)) {
		if(!expr()) {return 0;}

		return 1;
	}
	else if(check(GT_TOKEN)) {
		if(!expr()) {return 0;}

		return 1;
	}
	else if(check(EQUAL_TOKEN)) {
		if(!expr()) {return 0;}

		return 1;
	}

	return 0;
}

int expresion() {
	if(!expr()) {return 0;}

	if(!expresion_p()) {return 0;}

	return 1;
}

int factor() {
	if(check(OPEN_PARENTHESIS)) {

		if(!expr()) {return 0;}

		if(!check(CLOSE_PARENTHESIS)) {return 0;}

		return 1;
	}
	else if(check(IDENTIFIER_TOKEN)){
		return 1;
	}
	else if(check(INT_LITERAL_TOKEN)) {
		return 1;
	}

	return 0;
}

int term_p() {
	if(check(MULTIPLICATION_TOKEN)) {
		if(!factor()) {return 0;}

		if(!term_p()) {return 0;}

		return 1;
	}
	else if(check(DIVISION_TOKEN)) {
		if(!factor()) {return 0;}

		if(!term_p()) {return 0;}

		return 1;
	}
	else {
		return 1;
	}
}

int term() {
	if(!factor()) {return 0;}

	if(!term_p()) {return 0;}

	return 1;
}

int expr();
int expr_p();

int expr() {
	if(!term()) {return 0;}

	if(!expr_p()) {return 0;}

	return 1;
}

int expr_p() {
	if(check(ADDITION_TOKEN)) {
		if(!term()) {return 0;}

		if(!expr_p()) {return 0;}

		return 1;
	}
	else if(check(SUBSTRACTION_TOKEN)) {
		if(!term()) {return 0;}

		if(!expr_p()) {return 0;}

		return 1;
	}
	else{
		return 1;
	}
}

int stmt();
int stmt_lst();

int instr() {
	if(check(SEMICOLON_TOKEN)) {
		return 1;
	}
	else if(stmt()){
		if(!check(SEMICOLON_TOKEN)) {return 0;}

		return 1;
	}

	return 0;
}

int stmt_lst_p() {
	if(instr()) {
		if(!stmt_lst_p()) {return 0;}

		return 1;
	}
	else {
		return 1;
	}
}

int stmt_lst() {
	if(!instr()) {return 0;}

	if(!stmt_lst_p()) {return 0;}

	return 1;
}

int opt_stmts_p() {
	if(check(CLOSE_CURLY_BRACKET)) {
		return 1;
	}
	else if(stmt_lst()) {
		if(!check(CLOSE_CURLY_BRACKET)) {return 0;}
		return 1;
	}

	return 0;
}

int opt_stmts() {
	if(check(OPEN_CURLY_BRACKET)) {
		if(!opt_stmts_p()) {return 0;}

		return 1;
	}
	else if(instr()) {
		return 1;
	}

	return 0;
}

int stmt() {
	if(check(SET_TOKEN)) {
		if(!check(IDENTIFIER_TOKEN)) {return 0;}

		if(!expr()) {return 0;}

		return 1;
	}
	else if(check(IF_TOKEN)){
		if(!check(OPEN_PARENTHESIS)) {return 0;}

		if(!expresion()) {return 0;}

		if(!check(CLOSE_PARENTHESIS)) {return 0;}

		if(!opt_stmts()) {return 0;}

		return 1;
	}
	else if(check(IFELSE_TOKEN)){
		if(!check(OPEN_PARENTHESIS)) {return 0;}

		if(!expresion()) {return 0;}
		
		if(!check(CLOSE_PARENTHESIS)) {return 0;}

		if(!opt_stmts()) {return 0;}

		if(!opt_stmts()) {return 0;}

		return 1;
	}
	else if(check(WHILE_TOKEN)){
		if(!check(OPEN_PARENTHESIS)) {return 0;}

		if(!expresion()) {return 0;}
		
		if(!check(CLOSE_PARENTHESIS)) {return 0;}

		if(!opt_stmts()) {return 0;}

		return 1;
	}

	return 0;
}

int prog() {
	next();

	if(!check(PROGRAM_TOKEN)) {return 0;}

	if(!check(IDENTIFIER_TOKEN)) {return 0;}

	if(!opt_stmts()) {return 0;}

	if(!check(0)) {return 0;}

	return 1;
}

int main(int argc, char **argv) {
	if(argc >= 2) {
		freopen(argv[1], "r", stdin);
	}

	if(prog()) {
		printf("si\n");
	}
	else {
		printf("no\n");
	}

	return 0;
}
