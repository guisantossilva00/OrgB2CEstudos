public class Exercicios {
    public static String criaConta(String nomeConta, String classificacao, String telefone, String sobrenome){
        Account contaNova = new Account();
        
        contaNova.Name = nomeConta;
        contaNova.Rating = classificacao;
        contaNova.Phone = telefone;
        
        insert contaNova;
        
        Contact novoContato =  new Contact();
        
		novoContato.LastName = sobrenome;
		novoContato.AccountId = contaNova.Id;
        
        insert novoContato;
        
        return novoContato.Id;       
    }
}