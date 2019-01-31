%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "bison_headers.h"

/* prototypes */
void genCode(nodeType *prog);
void handleStmntSeq(nodeType *sSeq);
void handleExpr(nodeType *expr);
nodeType *program(nodeType *kProg, nodeType *decs, nodeType *kBegin, nodeType *ss, nodeType *kEnd);
nodeType *declarations(nodeType *kVar, nodeType *id, nodeType *kAs, nodeType *t, nodeType *sc, nodeType *decs);
nodeType *statementSequence(nodeType *s, nodeType *sc, nodeType *ss);
nodeType *statement(nodeType *s);
nodeType *assign(nodeType *id, nodeType *assign, nodeType *exp, nodeType *bRI);
nodeType *ifStatement(nodeType *kIf, nodeType *exp, nodeType *kThen, nodeType *ss, nodeType *ec, nodeType *kEnd);
nodeType *elseClause(nodeType *kElse, nodeType *ss);
nodeType *whileStatement(nodeType *kWhile, nodeType *exp, nodeType *kDo, nodeType *ss, nodeType *kEnd);
nodeType *writeInt(nodeType *wInt, nodeType *exp);
nodeType *expression(nodeType *s1, nodeType *op, nodeType *s2);
nodeType *simpleExpression(nodeType *t1, nodeType *op, nodeType *t2);
nodeType *term(nodeType *f1, nodeType *op, nodeType *f2);
nodeType *parens(nodeType *lp, nodeType *exp, nodeType *rp);
nodeType *builtin(char *b);
nodeType *keyword(char *k);
nodeType *punctuation(char *pnct);
nodeType *boolLit(char *b);
nodeType *num(long l);
nodeType *declId(char *s);
nodeType *id(char *s);
void freeNode(nodeType *p);
int yylex(void);
void yyerror(char *s);

const int MAX_SYMBOLS = 50;
int currSymbols = 0;
char *symbolTable[MAX_SYMBOLS];
char *typeTable[MAX_SYMBOLS];

int useIO = 0;
int useBool = 0;

%}

/* symbols */
%union
{
	int	ival;
	long 	lval;
	char	*sval;
	nodeType *nPtr;
};

%token <lval> NUMBER
%token <sval> BOOL_LITERAL
%token <sval> IDENTIFIER
%token <sval> LEFT_PAREN
%token <sval> RIGHT_PAREN
%token <sval> ASSIGN
%token <sval> SEMICOLON
%token <sval> OPERATION_2
%token <sval> OPERATION_3
%token <sval> OPERATION_4
%token <sval> KEYWORD_IF
%token <sval> KEYWORD_THEN
%token <sval> KEYWORD_ELSE
%token <sval> KEYWORD_BEGIN
%token <sval> KEYWORD_END
%token <sval> KEYWORD_WHILE
%token <sval> KEYWORD_DO
%token <sval> KEYWORD_PROGRAM
%token <sval> KEYWORD_VAR
%token <sval> KEYWORD_AS
%token <sval> KEYWORD_INT
%token <sval> KEYWORD_BOOL
%token <sval> BUILTIN_WRITEINT
%token <sval> BUILTIN_READINT

%type <nPtr> program declarations type statementSequence statement assignment ifStatement elseClause whileStatement writeInt expression simpleExpression term factor

%%

program: KEYWORD_PROGRAM declarations KEYWORD_BEGIN statementSequence KEYWORD_END { genCode(program(keyword($1), $2, keyword($3), $4, keyword($5))); };

declarations: { $$ = NULL; }
	| KEYWORD_VAR IDENTIFIER KEYWORD_AS type SEMICOLON declarations { $$ = declarations(keyword($1), declId($2), keyword($3), $4, punctuation($5), $6); };

type: KEYWORD_BOOL { $$ = keyword($1); useBool = 1; }
	| KEYWORD_INT { $$ = keyword($1); };

statementSequence: { $$ = NULL; }
	| statement SEMICOLON statementSequence { $$ = statementSequence($1, punctuation($2), $3); };

statement: writeInt { $$ = statement($1); }
	| whileStatement { $$ = statement($1); }
	| ifStatement { $$ = statement($1); }
	| assignment { $$ = statement($1); };

assignment: IDENTIFIER ASSIGN BUILTIN_READINT { $$ = assign(id($1), punctuation($2), NULL, builtin($3)); useIO = 1; }
	| IDENTIFIER ASSIGN expression { $$ = assign(id($1), punctuation($2), $3, NULL); };

ifStatement: KEYWORD_IF expression KEYWORD_THEN statementSequence elseClause KEYWORD_END { $$ = ifStatement(keyword($1), $2, keyword($3), $4, $5, keyword($6)); };

elseClause: { $$ = NULL; }
	| KEYWORD_ELSE statementSequence { $$ = elseClause(keyword($1), $2); };

whileStatement: KEYWORD_WHILE expression KEYWORD_DO statementSequence KEYWORD_END { $$ = whileStatement(keyword($1), $2, keyword($3), $4, keyword($5)); };

writeInt: BUILTIN_WRITEINT expression { $$ = writeInt(builtin($1), $2); };

expression: simpleExpression OPERATION_4 simpleExpression { $$ = expression($1, punctuation($2), $3); }
	| simpleExpression { $$ = expression($1, NULL, NULL); };

simpleExpression: term { $$ = simpleExpression($1, NULL, NULL); }
	| term OPERATION_3 term { $$ = simpleExpression($1, punctuation($2), $3); };

term: factor { $$ = term($1, NULL, NULL); }
	| factor OPERATION_2 factor { $$ = term($1, punctuation($2), $3); };

factor: LEFT_PAREN expression RIGHT_PAREN  { $$ = parens(punctuation($1), $2, punctuation($3)); }
	| BOOL_LITERAL { $$ = boolLit($1); }
	| NUMBER { $$ = num($1); }
	| IDENTIFIER { $$ = id($1); };

%%

void genCode(nodeType *prog) {
	if(useIO == 1) {
		printf("#include <stdio.h>\n");
	}
	if(useBool == 1) {
		printf("#include <stdbool.h>\n");
	}
	if(useIO == 1 || useBool == 1) {
		printf("\n");
	}
	printf("int main() {\n");

        int i;
	for(i=currSymbols-1;i>-1;i--) {
		printf("%s %s;\n", strdup(typeTable[i]), strdup(symbolTable[i]));
		if(i == 0) {
			printf("\n");
		}
	}
	
	nodeType *sSeq = prog->program.ss;
	handleStmntSeq(sSeq);

	printf("\n");
	printf("return 0;\n");
	printf("}\n");
}

void handleStmntSeq(nodeType *sSeq) {
	while(sSeq != NULL) {
                nodeType *stmnt = sSeq->statementSequence.s->statement.s;
		if(stmnt->statement.type == typeAssign) {
			if(stmnt->assign.bRI != NULL) {
				printf("scanf(\"%%d\", &%s);\n", strdup(stmnt->assign.id->id.s));
			} else {
				printf("%s = ", strdup(stmnt->assign.id->id.s));
				nodeType *assignExpr = stmnt->assign.exp;
				handleExpr(assignExpr);
				printf(";\n");
			}
		} else if(stmnt->statement.type == typeIfStatement) {
			printf("if(");
			nodeType *ifExpr = stmnt->ifStatement.exp;
			handleExpr(ifExpr);
			printf(") {\n");
			nodeType *ifStmntSeq = stmnt->ifStatement.ss;
			handleStmntSeq(ifStmntSeq);
			printf("}");
			nodeType *elseClause = stmnt->ifStatement.ec;
			if(elseClause != NULL) {
			    printf(" else {\n");
			    nodeType *elseStmntSeq = elseClause->elseClause.ss;
			    handleStmntSeq(elseStmntSeq);
			    printf("}");
			}
			printf("\n");
		} else if(stmnt->statement.type == typeWhileStatement) {
			printf("while(");
			nodeType *whileExpr = stmnt->whileStatement.exp;
			handleExpr(whileExpr);
			printf(") {\n");
			nodeType *whileStmntSeq = stmnt->whileStatement.ss;
			handleStmntSeq(whileStmntSeq);
			printf("}\n");
		} else if(stmnt->statement.type == typeWriteInt) {
			printf("printf(\"%%d\\n\", ");
			nodeType *wrExpr = stmnt->writeInt.exp;
			handleExpr(wrExpr);
			printf(");\n");
		}
		sSeq = sSeq->statementSequence.ss;
	}
}

void handleExpr(nodeType *expr) {
	nodeType *s1 = expr->expression.s1;
	nodeType *s1t1 = s1->simpleExpression.t1;
	nodeType *s1t1f1 = s1t1->term.f1;
	nodeType *s1t1f2 = s1t1->term.f2;
	if(s1t1f1->parens.type == typeParens) {
		printf("(");
		nodeType *parensExpr = s1t1f1->parens.exp;
		handleExpr(parensExpr);
		printf(")");
	} else if(s1t1f1->id.type == typeId) {
		printf("%s", s1t1f1->id.s);
	} else if(s1t1f1->id.type == typeBoolLit) {
		printf("%s", s1t1f1->boolLit.b);
	} else {
		printf("%ld", s1t1f1->num.value);
	}
	if(s1t1f2 != NULL) {
		nodeType *op2 = s1t1->term.op;
		if(strcmp(op2->punctuation.punct, "mod") == 0) {
			printf(" %% ");
		} else if(strcmp(op2->punctuation.punct, "div") == 0) {
			printf(" / ");
		} else {
			printf(" %s ", op2->punctuation.punct);
		}
		if(s1t1f2->parens.type == typeParens) {
			printf("(");
			nodeType *parensExpr = s1t1f2->parens.exp;
			handleExpr(parensExpr);
			printf(")");
		} else if(s1t1f2->id.type == typeId) {
			printf("%s", s1t1f2->id.s);
		} else if(s1t1f2->id.type == typeBoolLit) {
			printf("%s", s1t1f2->boolLit.b);
		} else {
			printf("%ld", s1t1f2->num.value);
		}
	}
	nodeType *s1t2 = s1->simpleExpression.t2;
	if(s1t2 != NULL) {
		nodeType *op3 = s1->simpleExpression.op;
		printf(" %s ", op3->punctuation.punct);
		nodeType *s1t2f1 = s1t2->term.f1;
		nodeType *s1t2f2 = s1t2->term.f2;
		if(s1t2f1->parens.type == typeParens) {
			printf("(");
			nodeType *parensExpr = s1t2f1->parens.exp;
			handleExpr(parensExpr);
			printf(")");
		} else if(s1t2f1->id.type == typeId) {
			printf("%s", s1t2f1->id.s);
		} else if(s1t2f1->id.type == typeBoolLit) {
			printf("%s", s1t2f1->boolLit.b);
		} else {
			printf("%ld", s1t2f1->num.value);
		}
		if(s1t2f2 != NULL) {
			nodeType *op2 = s1t2->term.op;
			if(strcmp(op2->punctuation.punct, "mod") == 0) {
				printf(" %% ");
			} else if(strcmp(op2->punctuation.punct, "div") == 0) {
				printf(" / ");
			} else {
				printf(" %s ", op2->punctuation.punct);
			}
			if(s1t2f2->parens.type == typeParens) {
				printf("(");
				nodeType *parensExpr = s1t2f2->parens.exp;
				handleExpr(parensExpr);
				printf(")");
			} else if(s1t2f2->id.type == typeId) {
				printf("%s", s1t2f2->id.s);
			} else if(s1t2f2->id.type == typeBoolLit) {
				printf("%s", s1t2f2->boolLit.b);
			} else {
				printf("%ld", s1t2f2->num.value);
			}
		}
	}
	nodeType *s2 = expr->expression.s2;
	if(s2 != NULL) {
		nodeType *op4 = expr->expression.op;
		if(strcmp(op4->punctuation.punct, "=") == 0) {
                	printf(" == ");
                } else {
                	printf(" %s ", op4->punctuation.punct);
                }
		nodeType *s2t1 = s2->simpleExpression.t1;
		nodeType *s2t1f1 = s2t1->term.f1;
		nodeType *s2t1f2 = s2t1->term.f2;
		if(s2t1f1->parens.type == typeParens) {
			printf("(");
			nodeType *parensExpr = s2t1f1->parens.exp;
			handleExpr(parensExpr);
			printf(")");
		} else if(s2t1f1->id.type == typeId) {
			printf("%s", s2t1f1->id.s);
		} else if(s2t1f1->id.type == typeBoolLit) {
			printf("%s", s2t1f1->boolLit.b);
		} else {
			printf("%ld", s2t1f1->num.value);
		}
		if(s2t1f2 != NULL) {
			nodeType *op2 = s2t1->term.op;
			if(strcmp(op2->punctuation.punct, "mod") == 0) {
                                printf(" %% ");
                        } else if(strcmp(op2->punctuation.punct, "div") == 0) {
                                printf(" / ");
                        } else {
                                printf(" %s ", op2->punctuation.punct);
                        }
			if(s2t1f2->parens.type == typeParens) {
				printf("(");
				nodeType *parensExpr = s2t1f2->parens.exp;
				handleExpr(parensExpr);
				printf(")");
			} else if(s2t1f2->id.type == typeId) {
				printf("%s", s2t1f2->id.s);
			} else if(s2t1f2->id.type == typeBoolLit) {
				printf("%s", s2t1f2->boolLit.b);
			} else {
				printf("%ld", s2t1f2->num.value);
			}
		}
		nodeType *s2t2 = s2->simpleExpression.t2;
		if(s2t2 != NULL) {
			nodeType *op3 = s2->simpleExpression.op;
			printf(" %s ", op3->punctuation.punct);
			nodeType *s2t2f1 = s2t2->term.f1;
			nodeType *s2t2f2 = s2t2->term.f2;
			if(s2t2f1->parens.type == typeParens) {
				printf("(");
				nodeType *parensExpr = s2t2f1->parens.exp;
				handleExpr(parensExpr);
				printf(")");
			} else if(s2t2f1->id.type == typeId) {
				printf("%s", s2t2f1->id.s);
			} else if(s2t2f1->id.type == typeBoolLit) {
				printf("%s", s2t2f1->boolLit.b);
			} else {
				printf("%ld", s2t2f1->num.value);
			}
			if(s2t2f2 != NULL) {
				nodeType *op2 = s2t2->term.op;
				if(strcmp(op2->punctuation.punct, "mod") == 0) {
					printf(" %% ");
				} else if(strcmp(op2->punctuation.punct, "div") == 0) {
					printf(" / ");
				} else {
					printf(" %s ", op2->punctuation.punct);
				}
				if(s2t2f2->parens.type == typeParens) {
					printf("(");
					nodeType *parensExpr = s2t2f2->parens.exp;
					handleExpr(parensExpr);
					printf(")");
				} else if(s2t2f2->id.type == typeId) {
					printf("%s", s2t2f2->id.s);
				} else if(s2t2f2->id.type == typeBoolLit) {
					printf("%s", s2t2f2->boolLit.b);
				} else {
					printf("%ld", s2t2f2->num.value);
				}
			}
		}
        }
	return;
}

nodeType *program(nodeType *kProg, nodeType *decs, nodeType *kBegin, nodeType *ss, nodeType *kEnd) {
   nodeType *p;
   /* allocate node */
   if ((p = malloc(sizeof(programNodeType))) == NULL)
      yyerror("out of memory");
   /* copy information */
   p->type = typeProgram;
   p->program.kProg = kProg;
   p->program.decs = decs;
   p->program.kBegin = kBegin;
   p->program.ss = ss;
   p->program.kEnd = kEnd;
   return p;
}

nodeType *declarations(nodeType *kVar, nodeType *declId, nodeType *kAs, nodeType *t, nodeType *sc, nodeType *decs) {
   int i;
   char *s = strdup(declId->id.s);
   char *cType = strdup(t->keyword.k);
   for(i=0;i<currSymbols;i++) {
      if(strcmp(symbolTable[i], s) == 0) {
         typeTable[i] = strdup(cType);
         break;
      }
   }
   nodeType *p;
   /* allocate node */
   if ((p = malloc(sizeof(declarationsNodeType))) == NULL)
      yyerror("out of memory");
   /* copy information */
   p->type = typeDeclarations;
   p->declarations.kVar = kVar;
   p->declarations.id = declId;
   p->declarations.kAs = kAs;
   p->declarations.t = t;
   p->declarations.sc = sc;
   p->declarations.decs = decs;
   return p;
}

nodeType *statementSequence(nodeType *s, nodeType *sc, nodeType *ss) {
   nodeType *p;
   /* allocate node */
   if ((p = malloc(sizeof(statementSequenceNodeType))) == NULL)
      yyerror("out of memory");
   /* copy information */
   p->type = typeStatementSequence;
   p->statementSequence.s = s;
   p->statementSequence.sc = sc;
   p->statementSequence.ss = ss;
   return p;
}

nodeType *statement(nodeType *s) {
   nodeType *p;
   /* allocate node */
   if ((p = malloc(sizeof(statementNodeType))) == NULL)
      yyerror("out of memory");
   /* copy information */
   p->type = typeStatement;
   p->statement.s = s;
   return p;
}

nodeType *assign(nodeType *id, nodeType *assgn, nodeType *exp, nodeType *bRI) {
   if (bRI != NULL) {
	if(id->id.b == 1) {
	    yyerror("typeError - invalid assignment of int to bool");
	}
   } else if(exp->expression.b == 0) {
	if(id->id.b == 1) {
	    yyerror("typeError - invalid assignment of int to bool");
	}
   } else {
	if(id->id.b == 0) {
	    yyerror("typeError - invalid assignment of bool to int");
	}
   }
   nodeType *p;
   /* allocate node */
   if ((p = malloc(sizeof(assignNodeType))) == NULL)
      yyerror("out of memory");
   /* copy information */
   p->type = typeAssign;
   p->assign.id = id;
   p->assign.assgn = assgn;
   p->assign.exp = exp;
   p->assign.bRI = bRI;
   return p;
}

nodeType *ifStatement(nodeType *kIf, nodeType *exp, nodeType *kThen, nodeType *ss, nodeType *ec, nodeType *kEnd) {
   if(exp->expression.b < 1) {
       yyerror("typeError - if statement requires valid boolean expression");
   }
   nodeType *p;
   /* allocate node */
   if ((p = malloc(sizeof(ifStatementNodeType))) == NULL)
      yyerror("out of memory");
   /* copy information */
   p->type = typeIfStatement;
   p->ifStatement.kIf = kIf;
   p->ifStatement.exp = exp;
   p->ifStatement.kThen = kThen;
   p->ifStatement.ss = ss;
   p->ifStatement.ec = ec;
   p->ifStatement.kEnd = kEnd;
   return p;
}

nodeType *elseClause(nodeType *kElse, nodeType *ss) {
   nodeType *p;
   /* allocate node */
   if ((p = malloc(sizeof(elseClauseNodeType))) == NULL)
      yyerror("out of memory");
   /* copy information */
   p->type = typeElseClause;
   p->elseClause.kElse = kElse;
   p->elseClause.ss = ss;
   return p;
}

nodeType *whileStatement(nodeType *kWhile, nodeType *exp, nodeType *kDo, nodeType *ss, nodeType *kEnd) {
   if(exp->expression.b < 1) {
       yyerror("typeError - while statement requires valid boolean expression");
   }
   nodeType *p;
   /* allocate node */
   if ((p = malloc(sizeof(whileStatementNodeType))) == NULL)
      yyerror("out of memory");
   /* copy information */
   p->type = typeWhileStatement;
   p->whileStatement.kWhile = kWhile;
   p->whileStatement.exp = exp;
   p->whileStatement.kDo = kDo;
   p->whileStatement.ss = ss;
   p->whileStatement.kEnd = kEnd;
   return p;
}

nodeType *writeInt(nodeType *wInt, nodeType *exp) {
   if(exp->expression.b == 1) {
	yyerror("typeError - cannot give boolean expression to writeInt");
   }
   nodeType *p;
   /* allocate node */
   if ((p = malloc(sizeof(writeIntNodeType))) == NULL)
      yyerror("out of memory");
   /* copy information */
   p->type = typeWriteInt;
   p->writeInt.wInt = wInt;
   p->writeInt.exp = exp;
   return p;
}

nodeType *expression(nodeType *s1, nodeType *op, nodeType *s2) {
   int b = s1->simpleExpression.b;
   int bExp = 0;
   if(s2 != NULL) {
        b = b == 1 ? b : s2->simpleExpression.b;
        if(strcmp(op->punctuation.punct, "<") == 0 || strcmp(op->punctuation.punct, "<=") == 0 || strcmp(op->punctuation.punct, ">") == 0 || strcmp(op->punctuation.punct, ">=") == 0) {
	    if(b == 1) {
                yyerror("typeError - invalid use of boolean type");
	    }
        }
        bExp = 1;
   }
   bExp = bExp == 1 ? bExp : b;
   nodeType *p;
   /* allocate node */
   if ((p = malloc(sizeof(expressionNodeType))) == NULL)
      yyerror("out of memory");
   /* copy information */
   p->type = typeExpression;
   p->expression.s1 = s1;
   p->expression.op = op;
   p->expression.s2 = s2;
   p->expression.b = bExp;
   return p;
}

nodeType *simpleExpression(nodeType *t1, nodeType *op, nodeType *t2) {
   int b = t1->term.b;
   if(t2 != NULL) {
        b = b == 1 ? b : t2->term.b;
	if(b == 1) {
	    yyerror("typeError - invalid use of boolean type");
	}
   }
   nodeType *p;
   /* allocate node */
   if ((p = malloc(sizeof(simpleExpressionNodeType))) == NULL)
      yyerror("out of memory");
   /* copy information */
   p->type = typeSimpleExpression;
   p->simpleExpression.t1 = t1;
   p->simpleExpression.op = op;
   p->simpleExpression.t2 = t2;
   p->simpleExpression.b = b;
   return p;
}

nodeType *term(nodeType *f1, nodeType *op, nodeType *f2) {
   int b = 0;
   if(f1->parens.type == typeParens) {
	b = f1->parens.b;
   } else if(f1->id.type == typeId) {
	b = f1->id.b;
   } else if(f1->id.type == typeBoolLit) {
	b = 1;
   }
   if(f2 != NULL) {
	if(f2->parens.type == typeParens) {
            b = b == 1 ? b : f2->parens.b;
	} else if(f2->id.type == typeId) {
            b = b == 1 ? b : f2->id.b;
	} else if(f2->boolLit.type == typeBoolLit) {
	    b = 1;
	}
	if(b == 1) {
	    yyerror("typeError - invalid use of boolean type");
	}
   }

   nodeType *p;
   /* allocate node */
   if ((p = malloc(sizeof(termNodeType))) == NULL)
      yyerror("out of memory");
   /* copy information */
   p->type = typeTerm;
   p->term.f1 = f1;
   p->term.op = op;
   p->term.f2 = f2;
   p->term.b = b;
   return p;
}

nodeType *parens(nodeType *lp, nodeType *exp, nodeType *rp) {
   nodeType *p;
   /* allocate node */
   if ((p = malloc(sizeof(parensNodeType))) == NULL)
      yyerror("out of memory");
   /* copy information */
   p->type = typeParens;
   p->parens.lp = lp;
   p->parens.exp = exp;
   p->parens.rp = rp;
   p->parens.b = exp->expression.b;
   return p;
}

nodeType *builtin(char *b) {
   nodeType *p;
   /* allocate node */
   if ((p = malloc(sizeof(builtinNodeType))) == NULL)
      yyerror("out of memory");
   /* copy information */
   p->type = typeBuiltin;
   p->builtin.b = b;
   return p;
}

nodeType *keyword(char *k) {
   nodeType *p;
   /* allocate node */
   if ((p = malloc(sizeof(keywordNodeType))) == NULL)
      yyerror("out of memory");
   /* copy information */
   p->type = typeKeyword;
   p->keyword.k = k;
   return p;
}

nodeType *punctuation(char *punct) {
   nodeType *p;
   /* allocate node */
   if ((p = malloc(sizeof(punctuationNodeType))) == NULL)
      yyerror("out of memory");
   /* copy information */
   p->type = typePunctuation;
   p->punctuation.punct = punct;
   return p;
}

nodeType *boolLit(char *b) {
   nodeType *p;
   /* allocate node */
   if ((p = malloc(sizeof(boolLitNodeType))) == NULL)
      yyerror("out of memory");
   /* copy information */
   p->type = typeBoolLit;
   p->boolLit.b = b;
   return p;
}

nodeType *num(long l) {
   if(l < 0 || l > 2147483647) {
      char err[100];
      sprintf(err, "numeric error - %ld is out of acceptable integer range", l);
      yyerror(err);
   }
   nodeType *p;
   /* allocate node */
   if ((p = malloc(sizeof(numNodeType))) == NULL)
      yyerror("out of memory");
   /* copy information */
   p->type = typeNum;
   p->num.value = l;
   return p;
}

nodeType *declId(char *s) {
   int i;
   int bFound = 0;
   for(i=0;i<currSymbols;i++) {
      if(strcmp(symbolTable[i], s) == 0) {
         bFound = 1;
	 break;
      }
   }
   if(bFound == 1) {
      char err[100];
      sprintf(err, "variable %s was already declared earlier", s);
      yyerror(err);
   } else {
      symbolTable[currSymbols] = strdup(s);
      currSymbols++;
   }
   nodeType *p;
   /* allocate node */
   if ((p = malloc(sizeof(idNodeType))) == NULL)
      yyerror("out of memory");
   /* copy information */
   p->type = typeId;
   p->id.s = s;
   return p;
}

nodeType *id(char *s) {
   int i;
   int bFound = 0;
   int b = 0;
   for(i=0;i<currSymbols;i++) {
      if(strcmp(symbolTable[i], s) == 0) {
        bFound = 1;
	if(strcmp(typeTable[i], "int") == 0) {
	    b = 0;
	} else {
	    b = 1;
	}
        break;
      }
   }
   if(bFound == 0) {
      char err[100];
      sprintf(err, "variable %s has not been declared", s);
      yyerror(err);
   }
   nodeType *p;
   /* allocate node */
   if ((p = malloc(sizeof(idNodeType))) == NULL)
      yyerror("out of memory");
   /* copy information */
   p->type = typeId;
   p->id.s = s;
   p->id.b = b;
   return p;
}

void freeNode(nodeType *p) {
   if (!p) return;
   free(p);
}

void yyerror(char *s) {
  printf("yyerror\t:\t%s\n",s);
  exit(0);
}

int main(void) {
  yyparse();
  return 0;
}
