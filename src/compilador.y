
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
int nivel_destino, deslocamento_destino, operacao = -1;
int sign = 0;
int novas_vars, num_vars, nivel, deslocamento;
char info_comando[23], novo_comando[33];

int yylex();
int yyerror();
int geraCodigo();

void geraCRVL() {
	strcpy(novo_comando, "CRVL \0");
	sprintf(info_comando, "%d, %d", nodo_tds->nivel, nodo_tds->deslocamento);
	strcat(novo_comando, info_comando);
	geraCodigo(NULL, novo_comando);
}

void geraSinal(int sign) {
	if (sign)
		geraCodigo(NULL, "INVR \0");
}

void geraOperacao(int op) {
	switch (op) {
		case 0: //=
			geraCodigo(NULL, "CMIG \0");
			break;
		case 1: //<>
			geraCodigo(NULL, "CMDG \0");
			break;
		case 2: //<
			geraCodigo(NULL, "CMME \0");
			break;
		case 3: //<=
			geraCodigo(NULL, "CMEG \0");
			break;
		case 4: //>
			geraCodigo(NULL, "CMMA \0");
			break;
		case 5: //>=
			geraCodigo(NULL, "CMAG \0");
			break;
		case 6: //+
			geraCodigo(NULL, "SOMA \0");
			break;
		case 7: //-
			geraCodigo(NULL, "SUBT \0");
			break;
		case 8: //*
			geraCodigo(NULL, "MULT \0");
			break;
		case 9: ///
			geraCodigo(NULL, "DIVI \0");
			break;
		case 10: //&&
			geraCodigo(NULL, "CONJ \0");
			break;
		case 11: //||
			geraCodigo(NULL, "DISJ \0");
			break;
		case 12: //!
			geraCodigo(NULL, "NEGA \0");
			break;
		default:
			break;
	}
	operacao = -1;
}

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES 
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT NUMERO
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
							retira(&tds, num_vars);
							strcpy(novo_comando, "DMEM \0");
							sprintf(info_comando, "%d", num_vars);
							strcat(novo_comando, info_comando);
							geraCodigo(NULL, novo_comando);
             geraCodigo (NULL, "PARA"); 
             }
;

bloco       : 
              parte_declara_vars
              { 
              }
              comando_composto 
              ;




parte_declara_vars:  var  {
								strcpy(novo_comando, "AMEM \0");
								sprintf(info_comando, "%d", num_vars);
								strcat(novo_comando, info_comando);
								geraCodigo(NULL, novo_comando);
									}
;


var         : { } VAR declara_vars
            | declara_vars
;

declara_vars: declara_vars declara_var 
            | declara_var 
;

declara_var : { novas_vars = 0; } 
              lista_id_var DOIS_PONTOS 
              tipo 
              PONTO_E_VIRGULA { num_vars += novas_vars; }
;

tipo        : INTEGER { atualizar_tipos(&tds, novas_vars, INTEIRO); }
							| BOOLEAN { atualizar_tipos(&tds, novas_vars, BOOLEANO); }
;

lista_id_var: lista_id_var VIRGULA IDENT 
              {
								novas_vars++;
								nodo_tds = var_simples_nodo(token, nivel, deslocamento);
								insere(&tds, nodo_tds);
								deslocamento++;
							}
            | IDENT {
								novas_vars++;
								nodo_tds = var_simples_nodo(token, nivel, deslocamento);
								insere(&tds, nodo_tds);
								deslocamento++;
							}
;

lista_idents: lista_idents VIRGULA IDENT  
            | IDENT
;


comando_composto: T_BEGIN comandos T_END 
;

comandos: comandos comando | comando
;

comando: numero_ou_vazio comando_sem_rotulo
;

numero_ou_vazio: numero | regra_vazia
;

comando_sem_rotulo: atribuicao | chama_procedimento | desvio | comando_composto | comando_condicional | comando_repetitivo
									;


//regra 19
atribuicao: 
					variavel {
						nivel_destino = nodo_tds->nivel;
						deslocamento_destino = nodo_tds->deslocamento;
					}
					ATRIBUICAO expressao {
					strcpy(novo_comando, "ARMZ \0");
					sprintf(info_comando, "%d, %d", nivel_destino, deslocamento_destino);
					strcat(novo_comando, info_comando);
					geraCodigo(NULL, novo_comando);
				}
				PONTO_E_VIRGULA
;

//regra 25 (aqui n precisa empilhar nada, ela so serve pra chamar as outras)
expressao: expressao_simples
				 	 | expressao_simples relacao expressao_simples { geraOperacao(operacao); }
;

//regra 26
relacao: IGUAL { operacao = 0; }
			  | DIFERENTE { operacao = 1; }
				| MENOR { operacao = 2; }
				| MENOR_OU_IGUAL { operacao = 3; }
				| MAIOR { operacao = 4; }
				| MAIOR_OU_IGUAL { operacao = 5; }
; 

//regra 27
//co: colchetes, ch: chaves, pa: parenteses
//TODO: 
//		DONE +- do co_add_sub (seta uma variavel "sign" ou sla)
//		fazer a expressao simples contra o primeiro termo
//		DONE +-or do pa_add_sub_or (seta a variavel "op")
//		DONE ver se ajusto ch_expressao_simples (e todos os outros ch_) caso seja 0+ em vez de 1+ ocorrências
//		DONE colocar a operação do ch_expressao_simples na pilha ([topo da pilha MEPA] (+,-,|) termo)	
expressao_simples: co_add_sub termo { geraSinal(sign); } ch_expressao_simples { geraOperacao(operacao); }
;

co_add_sub: ADICAO { sign = 0; } | SUBTRACAO { sign = 1; } | regra_vazia
;

//TODO
ch_expressao_simples: co_expressao_simples pa_add_sub_or termo { geraOperacao(operacao); }
;

co_expressao_simples: co_expressao_simples pa_add_sub_or termo { geraOperacao(operacao); } | regra_vazia
;

pa_add_sub_or: ADICAO { operacao = 6; } | SUBTRACAO { operacao = 7;} | OR { operacao = 11;}
;

//regra 28
termo: fator  ch_termo
;

ch_termo: { printf("\n\nantes\n"); } co_termo { printf("\n\naqui\n\n"); } pa_mult_div_and fator { geraOperacao(operacao); }
;

co_termo: pa_mult_div_and fator { geraOperacao(operacao); } co_termo | regra_vazia { printf("\ntegrafazvai\n"); }
;

pa_mult_div_and: MULTIPLICACAO { operacao = 8; }
							 	 | DIVISAO_INTEIRA { operacao = 9; }
								 | AND { operacao = 10; }
;

//regra 29
fator: variavel { geraCRVL(); geraOperacao(operacao); }
		 	 | numero
			 | chama_funcao
			 | ABRE_PARENTESES expressao FECHA_PARENTESES
			 | NOT { operacao = 12; } fator
;

//regra 30
variavel: IDENT {
						nodo_tds = busca(&tds, token);
						if (!nodo_tds) {
							fprintf(stderr, "Variável não encontrada");
							exit(1);
						}
					}
;

//regra 31 (TODO)
chama_funcao: FUNCTION;

//regra 32
numero: NUMERO {
			strcpy(novo_comando, "CRCT \0");
			strcat(novo_comando, token);
			geraCodigo(NULL, novo_comando);
			};

regra_vazia:;

chama_procedimento: PROCEDURE;
desvio: GOTO;
comando_repetitivo: WHILE;
comando_condicional: IF;


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
   novas_vars = num_vars = nivel = deslocamento = 0;
   yyin=fp;
   yyparse();
   return 0;
}

