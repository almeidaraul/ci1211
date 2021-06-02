#include <stdlib.h>
#include <string.h>

typedef enum t_parametro {
	VARSIMPLES,
	PARFORMAL,
	PROCEDIMENTO
} t_parametro;

typedef enum t_var {
	INTEIRO,
	BOOLEANO,
	INDEFINIDO
} t_var;

typedef enum t_passagem {
	PARAMETRO,
	REFERENCIA
} t_passagem;

typedef struct nodo_simbolo {
	char *ident, *rotulo;
	t_parametro cat;
	int nivel, deslocamento;
	t_var tipo;
	t_passagem passagem;
	struct nodo_simbolo *proximo;
} nodo_simbolo;

typedef struct t_tds {
	int tamanho;
	nodo_simbolo *cabeca;
} t_tds;

void insere(t_tds* tds, nodo_simbolo* elemento);
nodo_simbolo *busca(t_tds* t, char* ident);
t_tds* retira(t_tds* t, int n);
int tds_vazia(t_tds* tds);
void inicializaTDS(t_tds* tds);
void encerraTDS(t_tds* t);
nodo_simbolo *var_simples_nodo(char *token, int nivel, int deslocamento);
