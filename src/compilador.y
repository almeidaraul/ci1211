
// Testar se funciona corretamente o empilhamento de parâmetros
// passados por valor ou por referência.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"
#include "tabelaDeSimbolos.h"

t_tds tds;
nodo_simbolo *novo_nodo;
int num_vars, nivel, deslocamento;
char total_vars[12], novo_comando[33];

int yylex();
int yyerror();
int geraCodigo();

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES 
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT ATRIBUICAO
%token LABEL FUNCTION GOTO PROCEDURE
%token SUBTRACAO MULTIPLICACAO DIVISAO ADICAO
%token MAIOR IGUAL MOD NOT MAIOR_OU_IGUAL MENOR_OU_IGUAL MENOR
%token DIVISAO_INTEIRA ABRE_COLCHETES FECHA_COLCHETES IF THEN
%token ELSE WHILE DO OR AND DIFERENTE

%%

programa    :{ 
             geraCodigo (NULL, "INPP"); 
             }
             PROGRAM IDENT 
             ABRE_PARENTESES lista_idents FECHA_PARENTESES PONTO_E_VIRGULA
             bloco PONTO {
             geraCodigo (NULL, "PARA"); 
             }
;

bloco       : 
              parte_declara_vars
              { 
              }

              comando_composto 
              ;




parte_declara_vars:  var 
;


var         : { } VAR declara_vars
            |
;

declara_vars: declara_vars declara_var 
            | declara_var 
;

declara_var : { num_vars = 0; } 
              lista_id_var DOIS_PONTOS 
              tipo 
              {
								strcpy(novo_comando, "AMEM \0");
								sprintf(total_vars, "%d", num_vars);
								strcat(novo_comando, total_vars);
								geraCodigo(NULL, novo_comando);
              }
              PONTO_E_VIRGULA
;

tipo        : IDENT
;

lista_id_var: lista_id_var VIRGULA IDENT 
              {
								num_vars++;
								novo_nodo = var_simples_nodo(token, nivel, deslocamento);
								insere(&tds, novo_nodo);
								deslocamento++;
							}
            | IDENT {
								num_vars++;
								novo_nodo = var_simples_nodo(token, nivel, deslocamento);
								insere(&tds, novo_nodo);
								deslocamento++;
							}
;

lista_idents: lista_idents VIRGULA IDENT  
            | IDENT
;


comando_composto: T_BEGIN comandos T_END 

comandos:    
;


%%

int main (int argc, char** argv) {
   FILE* fp;
   extern FILE* yyin;

   if (argc<2 || argc>2) {
         printf("usage compilador <arq>a %d\n", argc);
         return(-1);
      }

   fp=fopen (argv[1], "r");
   if (fp == NULL) {
      printf("usage compilador <arq>b\n");
      return(-1);
   }


/* -------------------------------------------------------------------
 *  Inicia a Tabela de Símbolos
 * ------------------------------------------------------------------- */

   inicializaTDS(&tds);
   num_vars = nivel = deslocamento = 0;
   yyin=fp;
   yyparse();

   return 0;
}

