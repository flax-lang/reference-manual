// flax-grammar.g4
// Copyright (c) 2019, zhiayang
// Licensed under the Apache License Version 2.0.

// parser rules

grammar flax_grammar;

expression
	:   (EXCLAMATION | PLUS | MINUS | TILDE | AMPERSAND | ASTERISK | ELLIPSIS) expression
	|   expression (AS | IS) (expression | MUTABLE | (EXCLAMATION MUTABLE))
	|   expression (ASTERISK | DIVIDE | PERCENT)        expression
	|   expression (PLUS | MINUS)                       expression
	|   expression (AMPERSAND)                          expression
	|   expression (CARET)                              expression
	|   expression (PIPE)                               expression
	|   expression (LANGLE | RANGLE | LESS_EQUALS |
					GREATER_EQUALS | EQUALS_TO |
					NOT_EQUALS)                         expression

	|   expression (ELLIPSIS | HALF_OPEN_ELLIPSIS)      expression
	|   expression (LOGICAL_AND)                        expression
	|   expression (LOGICAL_OR)                         expression
	|   expression (EQUAL | PLUS_EQ | MINUS_EQ |
					MULTIPLY_EQ | DIVIDE_EQ | MOD_EQ |
					AMPERSAND_EQ | PIPE_EQ | CARET_EQ)  expression

	|   LPAREN expression RPAREN
	|   functionCall
	|   scopeExpr

	|   scopedIdentifier
	|   identifier
	|   literal
	;

statement
	:   expression  (SEMICOLON | NEWLINE)
	|   deferStmt
	|   varDefn
	|   ifStmt
	;

varDefn
	:   (VAR | LET) identifier (COLON type)? (EQUAL expression)?
	;

deferStmt
	:   DEFER expression
	;

ifStmt
	:   IF (varDefn SEMICOLON)* expression
		bracedBlock
		(ELSE IF (varDefn SEMICOLON)* expression bracedBlock)*
		(ELSE bracedBlock)?
	;

identifier
	:   IDENTIFIER
	;

scopedIdentifier
	:   DOUBLE_COLON? identifier ((DOUBLE_COLON | CARET) identifier)*
	;

polyArgList
	:   LANGLE (identifier (COLON scopedIdentifier)?) (COMMA identifier (COLON scopedIdentifier)?)* RANGLE
	;

ffiFuncDecl
	:   (PUBLIC | PRIVATE | INTERNAL)? FFI FUNC IDENTIFIER funcIshDecl (AS STRING_LITERAL)?
	;

parameterList
	:   LPAREN ((identifier COLON type (EQUAL expression)?) (COMMA identifier COLON type (EQUAL expression)?)*)? RPAREN
	;

funcIshDecl
	:   polyArgList? parameterList (RIGHT_ARROW type)?
	;

bracedBlock
	:   LBRACE statement* RBRACE
	;

funcDefn
	:   (ATTR_NOMANGLE | ATTR_ENTRY | PUBLIC | PRIVATE | INTERNAL)+
		FUNC IDENTIFIER funcIshDecl
		bracedBlock
	;

classDefn
	:   CLASS identifier polyArgList? (COLON scopedIdentifier (COMMA scopedIdentifier)*)? LBRACE
		((
			(VAR | LET) nameWithType (EQUAL expression)?
		|   STATIC? funcDefn
		|   'init' parameterList (COLON 'super' argumentList)?
			bracedBlock
		|   typeDefn
		) (NEWLINE | SEMICOLON))*
		RBRACE
	;

structDefn
	:   STRUCT identifier polyArgList? LBRACE
		((
			nameWithType
		|   funcDefn
		) (NEWLINE | SEMICOLON))*
		RBRACE
	;

unionDefn
	:   UNION identifier polyArgList? LBRACE
		(
			identifier (COLON type)? (NEWLINE | SEMICOLON)
		)*
		RBRACE
	;

rawUnionDefn
	:   ATTR_RAW UNION identifier polyArgList? LBRACE
		(
			identifier COLON type (NEWLINE | SEMICOLON)
		)+
		RBRACE
	;

enumDefn
	:   ENUM identifier polyArgList? (COLON type)? LBRACE
		(
			identifier (EQUAL expression)? (NEWLINE | SEMICOLON)
		)+
		RBRACE
	;

typeDefn
	:   enumDefn
	|   classDefn
	|   unionDefn
	|   structDefn
	|   rawUnionDefn
	;


type
	:   AMPERSAND MUTABLE? type
	|   LSQUARE type RSQUARE
	|   LSQUARE type COLON (NUMBER | ELLIPSIS)? RSQUARE
	|   LPAREN type (COMMA type)* RPAREN
	|   FUNC LPAREN type (COMMA type)* RPAREN RIGHT_ARROW type
	|   scopedIdentifier (EXCLAMATION LANGLE ((identifier COLON)? type) (COMMA (identifier COLON)? type) RANGLE)?
	|   typeDefn
	;

nameWithType
	:   identifier COLON type
	;

argumentList
	:   LPAREN (((identifier COLON)? expression) (COMMA (identifier COLON)? expression)*)? RPAREN
	;

functionCall
	:   scopedIdentifier argumentList
	;

scopeExpr
	:   scopeExpr PERIOD identifier
	|   scopedIdentifier
	;

commaSepExprs
	:   expression (COMMA expression)+
	;

literal
	:   STRING_LITERAL
	|   CHARACTER_LITERAL
	|   NUMBER
	|   LPAREN commaSepExprs RPAREN
	|   LSQUARE (AS type COLON) commaSepExprs RSQUARE
	|   TRUE | FALSE
	;








// lexer rules

// keywords
DO:         'do';
IF:         'if';
AS:         'as';
IS:         'is';
FFI:        'ffi';
AS_EXLAIM:  'as!';
VAR:        'var';
LET:        'let';
FOR:        'for';
NULL:       'null';
TRUE:       'true';
ELSE:       'else';
ENUM:       'enum';
FREE:       'free';
CLASS :     'class';
USING:      'using';
FALSE:      'false';
DEFER:      'defer';
WHILE:      'while';
ALLOC:      'alloc';
UNION:      'union';
BREAK:      'break';
TYPEID:     'typeid';
STRUCT:     'struct';
PUBLIC:     'public';
EXPORT:     'export';
IMPORT:     'import';
TYPEOF:     'typeof';
RETURN:     'return';
SIZEOF:     'sizeof';
STATIC:     'static';
PRIVATE:    'private';
MUTABLE:    'mutable';
VIRTUAL:    'virtual';
FUNC:       ('fn'|'ƒ');
INTERNAL:   'internal';
CONTINUE:   'continue';
OVERRIDE:   'override';
PROTOCOL:   'protocol';
OPERATOR:   'operator';
NAMESPACE:  'namespace';
TYPEALIAS:  'typealias';
EXTENSION:  'extension';
IDENTIFIER: [a-zA-Z_]+[a-zA-Z0-9]*;

LBRACE:             '{';
RBRACE:             '}';
LPAREN:             '(';
RPAREN:             ')';
LSQUARE:            '[';
RSQUARE:            ']';
LANGLE:             '<';
RANGLE:             '>';
PLUS:               '+';
MINUS:              '-';
ASTERISK:           '*';
DIVIDE:             ('/'|'÷');
SQUOTE:             '\'';
DQUOTE:             '"';
PERIOD:             '.';
COMMA:              ',';
COLON:              ':';
EQUAL:              '=';
QUESTION:           '?';
EXCLAMATION:        '!';
SEMICOLON:          ';';
AMPERSAND:          '&';
PERCENT:            '%';
PIPE:               '|';
DOLLAR:             '$';
LOGICAL_OR:         '||';
LOGICAL_AND:        '&&';
AT:                 '@';
POUND:              '#';
TILDE:              '~';
CARET:              '^';
LEFT_ARROW:         '<-';
RIGHT_ARROW:        '->';
// FAT_LEFT_ARROW:  '<=';
FAT_RIGHT_ARROW:    '=>';
EQUALS_TO:          '==';
NOT_EQUALS:         ('!='|'≠');
LESS_EQUALS:        ('<='|'≤');
GREATER_EQUALS:     ('>='|'≥');
DOUBLE_PLUS:        '++';
DOUBLE_MINUS:       '--';
PLUS_EQ:            '+=';
MINUS_EQ:           '-=';
MULTIPLY_EQ:        '*=';
DIVIDE_EQ:          '/=';
MOD_EQ:             '%=';
AMPERSAND_EQ:       '&=';
PIPE_EQ:            '|=;';
CARET_EQ:           '^=';
ELLIPSIS:           '...';
HALF_OPEN_ELLIPSIS: '..<';
DOUBLE_COLON:       '::';

STRING_LITERAL:     '"' .*? '"';
CHARACTER_LITERAL:  '\'' ('\\' ('\\'|'\''|'n'|'b'|'a'|'r'|'t') | .) '\'';
NEWLINE:            '\n';
COMMENT
	:   '//' .*? NEWLINE
	|   '/*' (COMMENT|.*?) '*/'
	;

NUMBER
	:   ('0b'|'0B') [0-1]+
	|   ('0x'|'0X') [0-9a-fA-F]+
	|   [0-9]*('.'?)[0-9]+ (('e'|'E')[0-9]+)?
	;

ATTR_RAW:           '@raw';
ATTR_ENTRY:         '@entry';
ATTR_NOMANGLE:      '@nomangle';
ATTR_OPERATOR:      '@operator';
ATTR_PLATFORM:      '@platform';

DIRECTIVE_RUN:      '#run';
DIRECTIVE_IF:       '#if';











