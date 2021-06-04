
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
nodo_simbolo *nodo_tds;
int num_vars, nivel, deslocamento;
char total_vars[12], novo_comando[33];

int yylex();
int yyerror();
int geraCodigo();

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES 
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT 
%token ATRIBUICAO
%token LABEL FUNCTION GOTO PROCEDURE
%token SUBTRACAO MULTIPLICACAO DIVISAO ADICAO
%token MAIOR IGUAL MOD NOT MAIOR_OU_IGUAL MENOR_OU_IGUAL MENOR
%token DIVISAO_INTEIRA ABRE_COLCHETES FECHA_COLCHETES IF THEN
%token ELSE WHILE DO OR AND DIFERENTE
%token INTEGER BOOLEAN

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

tipo        : INTEGER { atualizar_tipos(&tds, num_vars, INTEIRO); }
							| BOOLEAN { atualizar_tipos(&tds, num_vars, BOOLEANO); }
;

lista_id_var: lista_id_var VIRGULA IDENT 
              {
								num_vars++;
								nodo_tds = var_simples_nodo(token, nivel, deslocamento);
								insere(&tds, nodo_tds);
								deslocamento++;
							}
            | IDENT {
								num_vars++;
								nodo_tds = var_simples_nodo(token, nivel, deslocamento);
								insere(&tds, nodo_tds);
								deslocamento++;
							}
;

lista_idents: lista_idents VIRGULA IDENT  
            | IDENT
;


comando_composto: T_BEGIN comandos T_END 

comandos:
				{
					nodo_tds = busca(&tds, token);
					if (!nodo_tds) {
						fprintf(stderr, "Variável não encontrada");
						exit(1);
					}
				} comando_atribuicao
;

comando_atribuicao: IDENT ATRIBUICAO expressao
;

//regra 24
lista_expressoes: expressao | lista_expressoes VIRGULA expressao
;

//regra 25
expressao: expressao_simples
				 	 | expressao_simples relacao expressao_simples
;

//regra 26
relacao: IGUAL | DIFERENTE | MENOR | MENOR_OU_IGUAL | MAIOR | MAIOR_OU_IGUAL
; 

//regra 27
//co: colchetes, ch: chaves, pa: parenteses
expressao_simples: co_add_sub termo ch_expressao_simples
;

co_add_sub: ADICAO | SUBTRACAO | regra_vazia
;

ch_expressao_simples: pa_add_sub_or termo
											| ch_expressao_simples pa_add_sub_or termo
;

pa_add_sub_or: ADICAO | SUBTRACAO | OR
;

//regra 28
termo: fator ch_termo
;

ch_termo: pa_mult_div_and fator ch_termo | regra_vazia
;

pa_mult_div_and: MULTIPLICACAO | DIVISAO_INTEIRA | AND;

//regra 29
fator: variavel | numero | chama_funcao | ABRE_PARENTESES expressao FECHA_PARENTESES | NOT fator
;

//regra 30
variavel: IDENT | IDENT lista_expressoes
;

//regra 31 (TODO)
chama_funcao: variavel;

//regra 32
numero: digito | numero digito;

//regra 33 (TODO)
digito: chama_funcao

regra_vazia:;


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

