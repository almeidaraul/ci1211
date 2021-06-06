#include "tabelaDeSimbolos.h"

void insere(t_tds* tds, nodo_simbolo* elemento) {
	elemento->proximo = tds->cabeca; //&
	tds->cabeca = elemento; //&
	tds->tamanho++;
}

nodo_simbolo *busca(t_tds* t, char* ident) {
	nodo_simbolo* n = t->cabeca;
	int i = 0;
	while ((i < t->tamanho) && (!strcmp(ident, n->ident))) {
		n = n->proximo;
		i++;
	}
	return n;
}

t_tds* retira(t_tds* t, int n) {
	//t_tds* u = (t_tds*) malloc(sizeof(t_tds));

	int qtd = t->tamanho > n ? n : t->tamanho;
	nodo_simbolo *aux;
	while (qtd--) {
		aux = t->cabeca;
		//insere(u, t->cabeca);
		t->cabeca = t->cabeca->proximo;
		free(aux);
		t->tamanho--;
	}
	//return u;
	return NULL;
}

int tds_vazia(t_tds* tds) { return tds->tamanho == 0; }

void inicializaTDS(t_tds* tds) {
	tds = (t_tds*) malloc(sizeof(t_tds));
	tds->tamanho = 0;
	tds->cabeca = NULL;
}

void encerraTDS(t_tds* t) {
	nodo_simbolo* n;
	while (t->tamanho > 0) {
		printf("cabecaaa %d\n", t->cabeca);
		printf("cabeca: %d, proximo: %d\n", t->cabeca, t->cabeca->proximo);
		t->tamanho--;
		n = t->cabeca;
		t->cabeca = t->cabeca->proximo;
		free(n);
	}
	free(t);
}

nodo_simbolo *var_simples_nodo(char *token, int nivel, int deslocamento) {
	nodo_simbolo *n = (nodo_simbolo*) malloc(sizeof(nodo_simbolo));
	n->ident = malloc(sizeof(token));
	strcpy(n->ident, token);
	n->nivel = nivel;
	n->deslocamento = deslocamento;
	n->cat = VARSIMPLES;
	n->tipo = INDEFINIDO;
	return n;
}

void atualizar_tipos(t_tds *t, int qtd, t_var tipo) {
	nodo_simbolo* n = t->cabeca;
	while (n && qtd--) {
		n->tipo = tipo;
		n = n->proximo;
	}
}
