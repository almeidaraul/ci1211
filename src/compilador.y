
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
//TODO: atribuir o valor no topo da pilha a IDENT (no endereço léxico certo)
atribuicao: 
					variavel ATRIBUICAO expressao {
					strcpy(novo_comando, "ARMZ \0");
					sprintf(info_comando, "%d, %d", nodo_tds->nivel, nodo_tds->deslocamento);
					strcat(novo_comando, info_comando);
					geraCodigo(NULL, novo_comando);
				}
				PONTO_E_VIRGULA
;

//regra 24
lista_expressoes: expressao | lista_expressoes VIRGULA expressao
;

//regra 25 (aqui n precisa empilhar nada, ela so serve pra chamar as outras)
expressao: expressao_simples
				 	 | expressao_simples relacao expressao_simples
;

//regra 26
//TODO: fazer a operação entre os dois ultimos elementos da pilha
relacao: IGUAL | DIFERENTE | MENOR | MENOR_OU_IGUAL | MAIOR | MAIOR_OU_IGUAL
; 

//regra 27
//co: colchetes, ch: chaves, pa: parenteses
//TODO: +- do co_add_sub (seta uma variavel "sign" ou sla)
//		fazer a expressao simples contra o primeiro termo
//		+-or do pa_add_sub_or (seta a variavel "op")
//		ver se ajusto ch_expressao_simples (e todos os outros ch_) caso seja 0+ em vez de 1+ ocorrências
//		colocar a operação do ch_expressao_simples na pilha ([topo da pilha MEPA] (+,-,|) termo)	
expressao_simples: co_add_sub termo ch_expressao_simples
;

co_add_sub: ADICAO | SUBTRACAO | regra_vazia
;

ch_expressao_simples: ch_expressao_simples pa_add_sub_or termo | regra_vazia
;

pa_add_sub_or: ADICAO | SUBTRACAO | OR
;

//regra 28
//TODO: multiplicar, dividir ou ANDar o último valor da pilha (a pilha da MEPA, não a TDS) pelo novo fator (na regra ch_termo)
//isso talvez implique em expandir a ch_termo em vez de usar a pa_mult_div_and (ou simplesmente guarda uma variável "op" pra saber o que fazer, ou faz umas funções e a variável op é um ponteiro pra função)
termo: fator ch_termo
;

ch_termo: ch_termo pa_mult_div_and fator | regra_vazia
;

pa_mult_div_and: MULTIPLICACAO | DIVISAO_INTEIRA | AND;

//regra 29
//TODO: negar o valor do fator carregado (no caso do NOT fator)
fator: variavel { geraCRVL(); }
		 	 | numero
			 | chama_funcao
			 | ABRE_PARENTESES expressao FECHA_PARENTESES
			 | NOT fator
;

//regra 30
//TODO: carregar valor da variavel
variavel: IDENT {
						nodo_tds = busca(&tds, token);
						if (!nodo_tds) {
							fprintf(stderr, "Variável não encontrada");
							exit(1);
						}
					} | {} IDENT {
					nodo_tds = busca(&tds, token);
					if (!nodo_tds) {
						fprintf(stderr, "Variável não encontrada");
						exit(1);
					}
				} lista_expressoes_ou_vazia
;

lista_expressoes_ou_vazia: lista_expressoes | regra_vazia
;

//regra 31 (TODO)
chama_funcao: FUNCTION;

//regra 32
numero: NUMERO {
			strcpy(novo_comando, "CRTC \0");
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

