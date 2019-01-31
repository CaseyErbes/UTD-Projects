typedef enum { typeNum, typeId, typeBoolLit, typePunctuation, typeKeyword, typeBuiltin, typeParens, typeTerm, typeSimpleExpression, typeExpression, typeWriteInt, typeWhileStatement, typeElseClause, typeIfStatement, typeAssign, typeStatement, typeStatementSequence, typeDeclarations, typeProgram } nodeEnum;

/* numbers */
typedef struct {
nodeEnum type; /* type of node */
long value; /* value of number */
} numNodeType;

/* identifiers */
typedef struct {
nodeEnum type; /* type of node */
char *s; /* subscript to ident array */
int b; /* boolean */
} idNodeType;

/* boolLits */
typedef struct {
nodeEnum type; /* type of node */
char *b; /* subscript to boolLit array */
} boolLitNodeType;

/* punctuation */
typedef struct {
nodeEnum type; /* type of node */
char *punct; /* subscript to punctuation array */
} punctuationNodeType;

/* keywords */
typedef struct {
nodeEnum type; /* type of node */
char *k; /* subscript to keyword array */
} keywordNodeType;

/* builtins */
typedef struct {
nodeEnum type; /* type of node */
char *b; /* subscript to builtin char array */
} builtinNodeType;

/* parens around expressions */
typedef struct {
nodeEnum type; /* type of node */
union nodeTypeTag *lp;
union nodeTypeTag *exp;
union nodeTypeTag *rp;
int b; /* boolean */
} parensNodeType;

/* terms */
typedef struct {
nodeEnum type; /* type of node */
union nodeTypeTag *f1;
union nodeTypeTag *op;
union nodeTypeTag *f2;
int b; /* boolean */
} termNodeType;

/* simple expressions */
typedef struct {
nodeEnum type; /* type of node */
union nodeTypeTag *t1;
union nodeTypeTag *op;
union nodeTypeTag *t2;
int b; /* boolean */
} simpleExpressionNodeType;

/* expressions */
typedef struct {
nodeEnum type; /* type of node */
union nodeTypeTag *s1;
union nodeTypeTag *op;
union nodeTypeTag *s2;
int b; /* boolean */
} expressionNodeType;

/* writeInt */
typedef struct {
nodeEnum type; /* type of node */
union nodeTypeTag *wInt;
union nodeTypeTag *exp;
} writeIntNodeType;

/* whileStatement */
typedef struct {
nodeEnum type; /* type of node */
union nodeTypeTag *kWhile;
union nodeTypeTag *exp;
union nodeTypeTag *kDo;
union nodeTypeTag *ss;
union nodeTypeTag *kEnd;
} whileStatementNodeType;

/* elseClause */
typedef struct {
nodeEnum type; /* type of node */
union nodeTypeTag *kElse;
union nodeTypeTag *ss;
} elseClauseNodeType;

/* ifStatement */
typedef struct {
nodeEnum type; /* type of node */
union nodeTypeTag *kIf;
union nodeTypeTag *exp;
union nodeTypeTag *kThen;
union nodeTypeTag *ss;
union nodeTypeTag *ec;
union nodeTypeTag *kEnd;
} ifStatementNodeType;

/* assign */
typedef struct {
nodeEnum type; /* type of node */
union nodeTypeTag *id;
union nodeTypeTag *assgn;
union nodeTypeTag *exp;
union nodeTypeTag *bRI;
} assignNodeType;

/* statement */
typedef struct {
nodeEnum type; /* type of node */
union nodeTypeTag *s;
} statementNodeType;

/* statementSequence */
typedef struct {
nodeEnum type; /* type of node */
union nodeTypeTag *s;
union nodeTypeTag *sc;
union nodeTypeTag *ss;
} statementSequenceNodeType;

/* declarations */
typedef struct {
nodeEnum type; /* type of node */
union nodeTypeTag *kVar;
union nodeTypeTag *id;
union nodeTypeTag *kAs;
union nodeTypeTag *t;
union nodeTypeTag *sc;
union nodeTypeTag *decs;
} declarationsNodeType;

/* program */
typedef struct {
nodeEnum type; /* type of node */
union nodeTypeTag *kProg;
union nodeTypeTag *decs;
union nodeTypeTag *kBegin;
union nodeTypeTag *ss;
union nodeTypeTag *kEnd;
} programNodeType;

typedef union nodeTypeTag {
nodeEnum type; /* type of node */
numNodeType num; /* constants */
idNodeType id; /* identifiers */
boolLitNodeType boolLit; /* boolLits */
punctuationNodeType punctuation; /* punctuation */
keywordNodeType keyword; /* keywords */
builtinNodeType builtin; /* builtins */
parensNodeType parens; /* parens */
termNodeType term; /* terms */
simpleExpressionNodeType simpleExpression; /* expressions */
expressionNodeType expression; /* expressions */
writeIntNodeType writeInt; /* writeInt */
whileStatementNodeType whileStatement; /* whileStatement */
elseClauseNodeType elseClause; /* elseClause */
ifStatementNodeType ifStatement; /* ifStatement */
assignNodeType assign; /* assign */
statementNodeType statement; /* statement */
statementSequenceNodeType statementSequence; /* statementSequence */
declarationsNodeType declarations; /* declarations */
programNodeType program; /* program */
} nodeType;
