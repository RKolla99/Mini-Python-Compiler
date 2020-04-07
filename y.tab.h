/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    NOCHANGE = 258,
    NEWLINE = 259,
    DEDENT = 260,
    INDENT = 261,
    IMPORT = 262,
    WHILE = 263,
    IF = 264,
    ELIF = 265,
    ELSE = 266,
    IN = 267,
    PASS = 268,
    BREAK = 269,
    RETURN = 270,
    DEF = 271,
    COLON = 272,
    GT = 273,
    LT = 274,
    GE = 275,
    LE = 276,
    EE = 277,
    NE = 278,
    TRUE = 279,
    FALSE = 280,
    OP = 281,
    CP = 282,
    OB = 283,
    CB = 284,
    NUMBER = 285,
    ID = 286,
    STRING = 287,
    COMMA = 288,
    ENDFILE = 289,
    EQL = 290,
    PL = 291,
    MN = 292,
    ML = 293,
    DV = 294,
    NOT = 295,
    AND = 296,
    OR = 297,
    LOWER_THAN_EL = 298
  };
#endif
/* Tokens.  */
#define NOCHANGE 258
#define NEWLINE 259
#define DEDENT 260
#define INDENT 261
#define IMPORT 262
#define WHILE 263
#define IF 264
#define ELIF 265
#define ELSE 266
#define IN 267
#define PASS 268
#define BREAK 269
#define RETURN 270
#define DEF 271
#define COLON 272
#define GT 273
#define LT 274
#define GE 275
#define LE 276
#define EE 277
#define NE 278
#define TRUE 279
#define FALSE 280
#define OP 281
#define CP 282
#define OB 283
#define CB 284
#define NUMBER 285
#define ID 286
#define STRING 287
#define COMMA 288
#define ENDFILE 289
#define EQL 290
#define PL 291
#define MN 292
#define ML 293
#define DV 294
#define NOT 295
#define AND 296
#define OR 297
#define LOWER_THAN_EL 298

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 101 "parser.y" /* yacc.c:1909  */
 
	char* text;
	char* num;
	char* str;
    int depth;

#line 147 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
