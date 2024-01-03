public class Produto {
	public Integer idProduto = 0;
    public String nome;
    public String categoria;
    
    public Produto() {
        this.idProduto++;
        System.debug('Definindo idProduto');
    }
    
    public void definindoNomeProduto(String nome) {
        System.debug('Definindo nome para o produto');
        this.nome = nome;
    }
    
    public String pegandoNomeProduto() {
        System.debug('Pegando o nome');
        return this.nome;
    }    
}