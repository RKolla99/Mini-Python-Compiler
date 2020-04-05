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
    COLON = 271,
    GT = 272,
    LT = 273,
    GE = 274,
    LE = 275,
    EE = 276,
    NE = 277,
    TRUE = 278,
    FALSE = 279,
    OP = 280,
    CP = 281,
    OB = 282,
    CB = 283,
    NUMBER = 284,
    ID = 285,
    STRING = 286,
    ENDFILE = 287,
    EQL = 288,
    PL = 289,
    MN = 290,
    ML = 291,
    DV = 292,
    NOT = 293,
    AND = 294,
    OR = 295
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
#define COLON 271
#define GT 272
#define LT 273
#define GE 274
#define LE 275
#define EE 276
#define NE 277
#define TRUE 278
#define FALSE 279
#define OP 280
#define CP 281
#define OB 282
#define CB 283
#define NUMBER 284
#define ID 285
#define STRING 286
#define ENDFILE 287
#define EQL 288
#define PL 289
#define MN 290
#define ML 291
#define DV 292
#define NOT 293
#define AND 294
#define OR 295

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 58 "parser.y" /* yacc.c:1909  */
 
	char* text;
	char* num;
	char* str;

#line 140 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
