
%{
    #include<stdio.h>
    #include<string.h>
    #include<stdlib.h>
    #include<ctype.h>
    #include"lex.yy.c"

    void yyerror(const char *s);
    void add(char);
    void insert_type();
    void yyerror(const char*);

    int yylex();
    int yywrap();
    int count=0;
    int q;
    int search(char *);
    char type[10];

    struct node { 
        struct node *left; 
        struct node *right; 
        char *token; 
    };

    struct node* mknode(struct node *left, struct node *right, char *token);
    struct dataType { //Tabela de Simbolos
        char * id_name;
        char * data_type;
        char * type;
        int line_no;
    } symbolTable[100];
    struct node *head;

    void printTree(struct node*);
    void printInorder(struct node *);

    extern int countn;
    extern FILE *yyin;
%}

%union { 
	struct var_name { 
		char name[100]; 
		struct node* nd;
	} nd_obj; 
} 

%token VOID 
%token <nd_obj> TK_CLASS CHARACTER PRINTFF SCANFF INT FLOAT CHAR WHILE IF CLASS ELSE TRUE FALSE NUMBER VET_TAM FLOAT_NUM ID LE GE EQ NE GT LT MAIN /*AND OR*/ STR ADD MULTIPLY DIVIDE SUBTRACT UNARY INCLUDE RETURN 
%type <nd_obj> printf scanf headers functions class parameters vector main body return datatype expression statement init value arithmetic relop program condition else


%%

program: headers functions main '(' parameters ')' '{' body return '}' { 
    $3.nd = mknode($5.nd, $8.nd, "main");
    struct node* new = (struct node*)malloc(sizeof(struct node));
    new->left = $2.nd;
    new->right = $3.nd;
    new->token = "functions";
    $$.nd = mknode($1.nd, new, "program");
    head = $$.nd;
    }
    {printf("Programa Executado!")}
;

headers: INCLUDE headers { add('H'); } { $$.nd = mknode(NULL, NULL, $1.name); }
;

functions: functions function
| 
;

function: datatype ID { add('F'); } '(' parameters ')' '{' body return '}'
;



parameters: datatype ID { add('V'); }',' parameters
| datatype ID { add('V'); }
| 
;

main: datatype MAIN { add('F'); }{
    $$.nd = mknode($2.name);
}
;

vector: datatype ID '[' VET_TAM ']' '=' value
| 
;

class: CLASS TK_CLASS { add('L'); } '{' class_body_attr class_body_methods '}'
;

class_body_attr: datatype ID { add('V'); } init ';' class_body_attr
| 
;

class_body_methods: datatype ID { add('F'); }  '(' parameters ')' '{' body return '}' class_body_methods
| 
;

/*private:
| 
;

public:
| 
;
*/

datatype: INT { insert_type(); }
| FLOAT { insert_type(); }
| CHAR { insert_type(); }
| VOID { insert_type(); }
;


body: WHILE { add('K'); } '(' condition ')' '{' body '}' { 
    struct node *temp = mknode($4.nd, NULL, "CONDITION"); 
    $$.nd = mknode(temp2, $7.nd, $1.name); 
    } body
| IF { add('K'); } '(' condition ')' '{' body '}' else { 
    struct node *temp = mknode($4.nd, $7.nd, "TEMP"); 	
    $$.nd = mknode(temp, $9.nd, "if-else"); 
    } body
| statement ';' body
| printf ';' body
| scanf ';' body
|
;

printf: PRINTFF { add('K'); } '(' value ')' ';' { 
    $$.nd = mknode(NULL, $4.nd, "printf"); 
    } 
;

scanf: SCANFF { add('K'); } '(' '&' ID')' ';' { 
    $$.nd = mknode(NULL, NULL, "scanf"); 
    } 
;

else: ELSE { add('K'); } '{' body '}' { $$.nd = mknode(NULL, $4.nd, $1.name); }
| { $$.nd = NULL; }
;

condition: value relop value { $$.nd = mknode($1.nd, $3.nd, $2.name); }
| TRUE { add('K'); $$.nd = NULL; }
| FALSE { add('K'); $$.nd = NULL; }
| { $$.nd = NULL; }
;

statement: datatype ID { add('V'); } init { $2.nd = mknode(NULL, NULL, $2.name); $$.nd = mknode($2.nd, $4.nd, "declaration"); }
| ID '=' expression { $1.nd = mknode(NULL, NULL, $1.name); $$.nd = mknode($1.nd, $3.nd, "="); }
| ID relop expression { $1.nd = mknode(NULL, NULL, $1.name); $$.nd = mknode($1.nd, $3.nd, $2.name); }
| ID UNARY { $1.nd = mknode(NULL, NULL, $1.name); $2.nd = mknode(NULL, NULL, $2.name); $$.nd = mknode($1.nd, $2.nd, "ITERATOR"); }
| UNARY ID { $1.nd = mknode(NULL, NULL, $1.name); $2.nd = mknode(NULL, NULL, $2.name); $$.nd = mknode($1.nd, $2.nd, "ITERATOR"); }
;

init: '=' value { $$.nd = $2.nd; }
| { $$.nd = mknode(NULL, NULL, "NULL"); }
;

expression: expression arithmetic expression { $$.nd = mknode($1.nd, $3.nd, $2.name); }
| value { $$.nd = $1.nd; }
;

arithmetic: ADD 
| SUBTRACT 
| MULTIPLY
| DIVIDE
;

relop: LT
| GT
| LE
| GE
| EQ
| NE
;

value: NUMBER { add('C'); $$.nd = mknode(NULL, NULL, $1.name); }
| FLOAT_NUM { add('C'); $$.nd = mknode(NULL, NULL, $1.name); }
| CHARACTER { add('C'); $$.nd = mknode(NULL, NULL, $1.name); }
| STR { add('C'); $$.nd = mknode(NULL, NULL, $1.name); }
| INT { add('C'); $$.nd = mknode(NULL, NULL, $1.name); }
| ID { $$.nd = mknode(NULL, NULL, $1.name); }
;

return: RETURN { add('K'); } value ';' { $$.nd = mknode($1.nd, $3.nd, "RETURN"); }
| { $$.nd = NULL, NULL, "SEM_RETORNO"; }
;

%%

int main(int argc, char* argv[]) {

    if(argc==2){
        yyin=fopen(argv[1],"r");
    }

    yyparse();
    printf("\n\n \t\t\t\t\t\t ANALISE LEXICA \n\n");
	printf("\nSYMBOL   DATATYPE   TYPE   LINE NUMBER \n");
	printf("_______________________________________\n\n");
	int i=0;
	for(i=0; i<count; i++) {
		printf("%s\t%s\t%s\t%d\t\n", symbolTable[i].id_name, symbolTable[i].data_type, symbolTable[i].type, symbolTable[i].line_no);
	}
	for(i=0;i<count;i++){
		free(symbolTable[i].id_name);
		free(symbolTable[i].type);
	}
	printf("\n\n");
	printf("\t\t\t\t\t\t ANALISE SINTATICA \n\n");
	printTree(head); 
	printf("\n\n");
}

int search(char *type) {
	int i;
	for(i=count-1; i>=0; i--) {
		if(strcmp(symbolTable[i].id_name, type)==0) {
			return -1;
			break;
		}
	}
	return 0;
}

void add(char c) {
    q=search(yytext);
	if(q==0) {
		if(c=='H') {
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup(type);
			symbolTable[count].line_no=countn;
			symbolTable[count].type=strdup("Header");
			count++;
		}
		else if(c=='K') {
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup("N/A");
			symbolTable[count].line_no=countn;
			symbolTable[count].type=strdup("Keyword\t");
            symbolTable[count].value=strdup("Value");
			count++;
		}
		else if(c=='V') {
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup(type);
			symbolTable[count].line_no=countn;
			symbolTable[count].type=strdup("Variable");
            symbolTable[count].value=strdup("Value");
			count++;
		}
		else if(c=='C') {
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup("CONST");
			symbolTable[count].line_no=countn;
			symbolTable[count].type=strdup("Constant");
			count++;
		}
        else if(c=='F') {
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup(type);
			symbolTable[count].line_no=countn;
			symbolTable[count].type=strdup(Function);
			count++;
		}
        else if(c=='L') {
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup(type);
			symbolTable[count].line_no=countn;
			symbolTable[count].type=strdup("Class");
			count++;
		}
    }
}

struct node* mknode(struct node *left, struct node *right, char *token) {	
	struct node *newnode = (struct node *)malloc(sizeof(struct node));
	char *newstr = (char *)malloc(strlen(token)+1);
	strcpy(newstr, token);
	newnode->left = left;
	newnode->right = right;
	newnode->token = newstr;
	return(newnode);
}

void printTree(struct node* tree) {
	printf("\n\n Árvore de Análise Sintática: \n\n");
	printInorder(tree);
	printf("\n\n");
}

void printInorder(struct node *tree) {
	int i;
	if (tree->left) {
		printInorder(tree->left);
	}
	printf("%s, ", tree->token);
	if (tree->right) {
		printInorder(tree->right);
	}
}

void insert_type() {
	strcpy(type, yytext);
}

void yyerror(const char* msg) {
    fprintf(stderr, "%s\n", msg);
}