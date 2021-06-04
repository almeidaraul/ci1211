%{


#include<stdio.h>
#include<string.h>

#include "compilador.h"
#include "compilador.tab.h"

//#define IMPRIME(STR) {};
#define IMPRIME(STR) printf("%s    # %s \n", STR, token);

int nl = 1;  

%}

pulo_linha [\n]

descarte [\t ]+

ident [a-zAZ][a-zAZ1-9]*

numero [0-9]+

comentario "(*".*"*)"

%%

{pulo_linha} {nl++;} 

{descarte}

{comentario}

program { simbolo  = simb_program;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("program ");
          return PROGRAM;
 }

var      { simbolo = simb_var;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("var  ");
          return VAR;
 }

begin { simbolo = simb_begin;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("begin ");
          return T_BEGIN;
 }

end { simbolo = simb_end;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("end  ");
          return T_END;
 }

label { simbolo = simb_label;
        strncpy (token, yytext, TAM_TOKEN);
        IMPRIME(" label ");
        return LABEL;
        }


:= { simbolo = simb_atribuicao;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME(" atribuicao  ");
          return ATRIBUICAO;  
 }

\; { simbolo = simb_ponto_e_virgula;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME(" pt_virgula  ");
          return PONTO_E_VIRGULA;
 }

\: { simbolo = simb_dois_pontos;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME(" dois pontos ");
          return DOIS_PONTOS;
 }

\, { simbolo = simb_virgula;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME(" virgula  ");
          return VIRGULA;
 }


\. { simbolo = simb_ponto;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME(" ponto  ");
          return PONTO; 
    }

\(  { simbolo = simb_abre_parenteses;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME(" abre_parenteses  ");
          return ABRE_PARENTESES;
    }

\)  { simbolo = simb_fecha_parenteses;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME(" fecha_parenteses ");
          return FECHA_PARENTESES;
 }

integer { simbolo = simb_integer;
           strncpy (token, yytext, TAM_TOKEN);
           IMPRIME("integer ");
           return INTEGER;
}

boolean { simbolo = simb_boolean; 
              strncpy(token, yytext, TAM_TOKEN);
              IMPRIME("boolean ");
              return BOOLEAN;
}

{ident} { simbolo = simb_identificador; 
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME(" ident  ");
          return IDENT;
        }

procedure { simbolo = simb_procedure;
       strncpy (token, yytext, TAM_TOKEN);
       IMPRIME(" procedure ");
       return PROCEDURE;
       }

function { simbolo = simb_function;
       strncpy (token, yytext, TAM_TOKEN);
       IMPRIME(" function ");
       return FUNCTION;
       }

goto { simbolo = simb_goto;
       strncpy (token, yytext, TAM_TOKEN);
       IMPRIME(" goto ");
       return GOTO;
       }

\+ { simbolo = simb_adicao;
       strncpy (token, yytext, TAM_TOKEN);
       IMPRIME(" adicao ");
       return ADICAO;
       }

\- { simbolo = simb_subtracao;
       strncpy (token, yytext, TAM_TOKEN);
       IMPRIME(" subtracao ");
       return SUBTRACAO;
       }

\* { simbolo = simb_multiplicacao;
       strncpy (token, yytext, TAM_TOKEN);
       IMPRIME(" multiplicacao ");
       return MULTIPLICACAO;
       }

\/ { simbolo = simb_divisao;
       strncpy (token, yytext, TAM_TOKEN);
       IMPRIME(" divisao ");
       return DIVISAO;
       }

\div { simbolo = simb_divisao_inteira;
       strncpy (token, yytext, TAM_TOKEN);
       IMPRIME(" divisao_inteira ");
       return DIVISAO_INTEIRA;
       }
      
\[ { simbolo = simb_abre_colchetes;
       strncpy (token, yytext, TAM_TOKEN);
       IMPRIME(" abre_colchetes ");
       return ABRE_COLCHETES;
       }

\] { simbolo = simb_fecha_colchetes;
       strncpy (token, yytext, TAM_TOKEN);
       IMPRIME(" fecha_colchetes ");
       return FECHA_COLCHETES;
       }

if { simbolo = simb_if;
       strncpy (token, yytext, TAM_TOKEN);
       IMPRIME(" if ");
       return IF;
       }

then { simbolo = simb_then;
       strncpy (token, yytext, TAM_TOKEN);
       IMPRIME(" then ");
       return THEN;
       }

else { simbolo = simb_else;
       strncpy (token, yytext, TAM_TOKEN);
       IMPRIME(" else ");
       return ELSE;
       }

while { simbolo = simb_while;
       strncpy (token, yytext, TAM_TOKEN);
       IMPRIME(" while ");
       return WHILE;
       }

do { simbolo = simb_do;
       strncpy (token, yytext, TAM_TOKEN);
       IMPRIME(" do ");
       return DO;
       }

or { simbolo = simb_or;
       strncpy (token, yytext, TAM_TOKEN);
       IMPRIME(" or ");
       return OR;
       }

and { simbolo = simb_and;
       strncpy (token, yytext, TAM_TOKEN);
       IMPRIME(" and ");
       return AND;
       }

not { simbolo = simb_not;
       strncpy (token, yytext, TAM_TOKEN);
       IMPRIME(" not ");
       return NOT;
       }

mod { simbolo = simb_mod;
       strncpy (token, yytext, TAM_TOKEN);
       IMPRIME(" mod ");
       return MOD;
       }

\= { simbolo = simb_igual;
       strncpy (token, yytext, TAM_TOKEN);
       IMPRIME(" igual ");
       return IGUAL;
       }

\< { simbolo = simb_menor;
       strncpy (token, yytext, TAM_TOKEN);
       IMPRIME(" menor ");
       return MENOR;
       }

\> { simbolo = simb_maior;
       strncpy (token, yytext, TAM_TOKEN);
       IMPRIME(" maior ");
       return MAIOR;
       }

\<= { simbolo = simb_menor_ou_igual;
			strncpy (token, yytext, TAM_TOKEN);
			IMPRIME(" menor ou igual ");
			return MENOR_OU_IGUAL;
		}

\>= { simbolo = simb_maior_ou_igual;
			strncpy (token, yytext, TAM_TOKEN);
			IMPRIME(" maior ou igual ");
			return MAIOR_OU_IGUAL;
		}

\<> { simbolo = simb_diferente;
			strncpy (token, yytext, TAM_TOKEN);
			IMPRIME(" diferente ");
			return DIFERENTE;
		}

%%

