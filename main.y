%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<math.h>

	extern int yylineno;  // Declare yylineno from lexer

	int yylex(void);
	void yyerror(const char *s);

	int sym[30];

	// Counters
	int variablenumber=0;
	int expressionnumber=0;
	int variableassignment=0;
	int switchnumber=0;
	int printnumber=0;
	int fornumber=0;
	int arraynumber=0;
	int classnumber=0;
	int trycatchnumber=0;
	int functionnumber=0;
	int whilenumber=0;
	int mathexpressionnumber=0;
	int ifelsenumber=0;
%}

%token NUM VAR IF ELSE ARRAY MAIN INT FLOAT CHAR BRACKETSTART BRACKETEND FOR WHILE ODDEVEN PRINTFUNCTION SIN COS TAN LOG FACTORIAL CASE DEFAULT SWITCH CLASS TRY CATCH FUNCTION
%nonassoc IFX
%nonassoc ELSE

%left '<' '>' LE GE EQ NE
%left '+' '-'
%left '*' '/' '%'
%right '^'
%left UMINUS

%%

program: MAIN ':' BRACKETSTART line BRACKETEND {printf("Main function END\n");}
	;

line: /* empty */
	| line statement
	;

statement: ';'
	| declaration ';' {printf("Declaration\n"); variablenumber++;}
	| expression ';' {printf("\nvalue of expression: %d\n", $1); $$=$1; expressionnumber++;}
	| VAR '=' expression ';' {
		printf("\nValue of the variable: %d\n",$3);
		sym[$1]=$3;
		$$=$3;
		variableassignment++;
	}
	| WHILE '(' expression ')' BRACKETSTART statement BRACKETEND {
		printf("WHILE Loop execution\n");
		whilenumber++;
	}
	| IF '(' expression ')' BRACKETSTART statement BRACKETEND %prec IFX {
		if($3) printf("\nvalue of expression in IF: %d\n",$6);
		else printf("\ncondition value zero in IF block\n");
		ifelsenumber++;
	}
	| IF '(' expression ')' BRACKETSTART statement BRACKETEND ELSE BRACKETSTART statement BRACKETEND {
		if($3) printf("value of expression in IF: %d\n",$6);
		else printf("value of expression in ELSE: %d\n",$11);
		ifelsenumber++;
	}
	| PRINTFUNCTION '(' expression ')' ';' {
		printf("\nPrint Expression %d\n",$3);
		printnumber++;
	}
	| FACTORIAL '(' NUM ')' ';' {
		int i, f=1;
		for(i=1;i<=$3;i++) f=f*i;
		printf("FACTORIAL of %d is : %d\n",$3,f);
		functionnumber++;
	}
	| ODDEVEN '(' NUM ')' ';' {
		if($3 %2 ==0) printf("Number : %d is -> Even\n",$3);
		else printf("Number is :%d is -> Odd\n",$3);
		functionnumber++;
	}
	| FUNCTION VAR '(' expression ')' BRACKETSTART statement BRACKETEND {
		printf("FUNCTION found\n");
		printf("Function Parameter : %d\n",$4);
		printf("Function internal block statement : %d\n",$7);
		functionnumber++;
	}
	| ARRAY TYPE VAR '[' NUM ']' ';' {
		printf("ARRAY Declaration\n");
		printf("Size of the ARRAY is : %d\n",$5);
		arraynumber++;
	}
	| SWITCH '(' expression ')' BRACKETSTART switchcase BRACKETEND {
		printf("\nSWITCH CASE Declaration\n");
		printf("\nFinally Choose Case number :-> %d\n",$3);
		switchnumber++;
	}
	| CLASS VAR BRACKETSTART statement BRACKETEND {
		printf("Class Declaration\n");
		printf("Expression : %d\n",$4);
		classnumber++;
	}
	| CLASS VAR ':' VAR BRACKETSTART statement BRACKETEND {
		printf("Inheritance occur \n");
		printf("Expression value : %d",$6);
		classnumber++;
	}
	| TRY BRACKETSTART statement BRACKETEND CATCH '(' expression ')' BRACKETSTART statement BRACKETEND {
		printf("TRY CATCH block found\n");
		printf("TRY Block operation : %d\n",$3);
		printf("CATCH Value : %d\n",$7);
		printf("Catch Block operation :%d\n",$10);
		trycatchnumber++;
	}
	| FOR '(' expression ',' expression ',' expression ')' BRACKETSTART statement BRACKETEND {
		printf("FOR Loop execution");
		for($3; $5; $7=$7) {
			printf("\nvalue of the i: %d expression value : %d\n", $3, $9);
		}
		fornumber++;
	}
	;

declaration: TYPE idlist {printf("\nvariable Declaration\n");}
	;

TYPE: INT {printf("integer declaration\n");}
	| FLOAT {printf("float declaration\n");}
	| CHAR {printf("char declaration\n");}
	;

idlist: idlist ',' VAR
	| VAR
	;

switchcase: /* empty */
	| switchcase casenumber
	| switchcase DEFAULT ':' statement {printf("\nDefault case\n");}
	;

casenumber: CASE NUM ':' statement {printf("Case No : %d\n",$2);}
	;

expression: NUM {$$ = $1;}
	| VAR {$$ = sym[$1];}
	| expression '+' expression {$$ = $1 + $3;}
	| expression '-' expression {$$ = $1 - $3;}
	| expression '*' expression {$$ = $1 * $3;}
	| expression '/' expression {
		if($3==0) {
			yyerror("division by zero");
			$$ = 0;
		} else $$ = $1 / $3;
	}
	| expression '%' expression {
		if($3==0) {
			yyerror("mod by zero");
			$$ = 0;
		} else $$ = $1 % $3;
	}
	| expression '^' expression {$$ = pow($1, $3);}
	| expression '<' expression {$$ = $1 < $3;}
	| expression '>' expression {$$ = $1 > $3;}
	| '(' expression ')' {$$ = $2;}
	| SIN expression {$$ = sin($2*3.1416/180);}
	| COS expression {$$ = cos($2*3.1416/180);}
	| TAN expression {$$ = tan($2*3.1416/180);}
	| LOG expression {$$ = log($2);}
	| '-' expression %prec UMINUS {$$ = -$2;}
	;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error at line %d: %s\n", yylineno, s);
}

int main() {
    freopen("input.txt", "r", stdin);
   // freopen("output.txt", "w", stdout);

    printf("Before parsing\n");
    yyparse();
    printf("After parsing\n");

    printf("\n**********************************\n");
    printf("All the input parsing complete \n");
    printf("**********************************\n");

    printf("Number of arrays: %d\n", arraynumber);
    printf("Number of if-else: %d\n", ifelsenumber);
    printf("Number of while loops: %d\n", whilenumber);
    printf("Number of for loops: %d\n", fornumber);
    printf("Number of switch cases: %d\n", switchnumber);
    printf("Number of classes: %d\n", classnumber);
    printf("Number of print functions: %d\n", printnumber);
    printf("Number of try-catch blocks: %d\n", trycatchnumber);
    printf("Number of variable declarations: %d\n", variablenumber);
    printf("Number of variable assignments: %d\n", variableassignment);
    printf("Number of expressions: %d\n", expressionnumber);

    printf("\n**********************************\n");
    printf("Name: Shihab Sumon\n");


    fflush(stdout); // Ensure all output is written
    return 0;
}
