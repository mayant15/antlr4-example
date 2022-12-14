lexer grammar TLexer;

// These are all supported lexer sections:

// Lexer file header. Appears at the top of h + cpp files. Use e.g. for copyrights.
@lexer::header {/* lexer header section */}

// Appears before any #include in h + cpp files.
@lexer::preinclude {/* lexer precinclude section */}

// Follows directly after the standard #includes in h + cpp files.
@lexer::postinclude {
/* lexer postinclude section */
#ifndef _WIN32
#pragma GCC diagnostic ignored "-Wunused-parameter"
#endif
}

// Directly preceds the lexer class declaration in the h file (e.g. for additional types etc.).
@lexer::context {/* lexer context section */}

// Appears in the public part of the lexer in the h file.
@lexer::members {/* public lexer declarations section */}

// Appears in the private part of the lexer in the h file.
@lexer::declarations {/* private lexer declarations/members section */}

// Appears in line with the other class member definitions in the cpp file.
@lexer::definitions {/* lexer definitions section */}

channels { COMMENTS_CHANNEL }

Return: 'return';
Continue: 'continue';
Function: 'func';
VAL: 'val';

INT: DIGIT+;
fragment DIGIT: [0-9];

ID: LETTER (LETTER | '0'..'9')*;
fragment LETTER : [a-zA-Z\u0080-\u{10FFFF}];

EQUAL: '=';
LessThan: '<';
GreaterThan:  '>';
LessThanEqualTo: '<=';
GreaterThanEqualTo: '>=';

PLUS: '+';
MINUS: '-';
STAR: '*';
DIVIDE: '/';
POW: '^';

LPAREN: '(';
RPAREN: ')';
OpenCurly: '{';
CloseCurly: '}';
QuestionMark: '?';

Colon: ':';
SEMICOLON: ';';

String: '"' .*? '"';

Comment : '#' ~[\r\n]* '\r'? '\n' -> channel(COMMENTS_CHANNEL);
WS: [ \t\r\n]+ -> skip;

