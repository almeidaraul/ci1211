#include "tabelaDeSimbolos.h"

void insere(t_tds* tds, nodo_simbolo* elemento) {
	elemento->proximo = &tds->cabeca;
	tds->cabeca = &elemento;
	tds->tamanho++;
}

nodo_simbolo *busca(t_tds* t, char* ident) {
	nodo_simbolo* n = t->cabeca;
	int i = 0;
	while ((i < t->tamanho) && (!strcmp(ident, n->ident)))
		n = n->proximo;
	return n->proximo;
}

t_tds* retira(t_tds* t, int n) {
	t_tds* u = (t_tds*) malloc(sizeof(t_tds));

	int qtd = t->tamanho > n ? n : t->tamanho;
	while (qtd--) {
		insere(u, t->cabeca);
		t->cabeca = t->cabeca->proximo;
	}
	return u;
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
		t->tamanho--;
		n = t->cabeca;
		free(n);
	}
	free(t);
}

nodo_simbolo *var_simples_nodo(char *token, int nivel, int deslocamento) {
	nodo_simbolo *n = (nodo_simbolo*) malloc(sizeof(nodo_simbolo));
	n->ident = token;
	n->nivel = nivel;
	n->deslocamento = deslocamento;
	return n;
}
