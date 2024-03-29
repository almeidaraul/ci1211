/* -------------------------------------------------------------------
 *            Arquivo: compilaodr.h
 * -------------------------------------------------------------------
 *              Autor: Bruno Muller Junior
 *               Data: 08/2007
 *      Atualizado em: [15/03/2012, 08h:22m]
 *
 * -------------------------------------------------------------------
 *
 * Tipos, protótipos e vaiáveis globais do compilador
 *
 * ------------------------------------------------------------------- */

#define TAM_TOKEN 16

typedef enum simbolos { 
  simb_program, simb_var, simb_begin, simb_end, simb_abre_colchetes, simb_fecha_colchetes, simb_if, simb_then, simb_else, simb_while, simb_do, simb_or, simb_and, simb_not, simb_mod, simb_igual, simb_menor, simb_maior, simb_menor_ou_igual, simb_maior_ou_igual, simb_diferente,
	simb_integer, simb_boolean,
  simb_identificador, simb_numero, simb_label, simb_procedure,
  simb_ponto, simb_virgula, simb_ponto_e_virgula, simb_dois_pontos,
  simb_atribuicao, simb_abre_parenteses, simb_fecha_parenteses, simb_function, simb_goto, simb_adicao, simb_subtracao, simb_multiplicacao, simb_divisao, simb_divisao_inteira
} simbolos;



/* -------------------------------------------------------------------
 * variáveis globais
 * ------------------------------------------------------------------- */

extern simbolos simbolo, relacao;
extern char token[TAM_TOKEN];
extern int nivel_lexico;
extern int desloc;
extern int nl;


simbolos simbolo, relacao;
char token[TAM_TOKEN];



