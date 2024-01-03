public class AccountTriggerHandler {
    private static final String USERNAME = 'projetofinal@itlindos.com';
    private static final String PASSWORD =  '@projetoitlindos23TngV0hwpUm5YWRltXuh5NQrmX';
    private static final String CLIENT_ID = '3MVG9Xl3BC6VHB.bitt1K0EKqBxsST3AN_zrdlP_TKrkzHwnUZ7DBH1Q6iPD5Y1xLGZVjrkDRWoTfFAk5CXvQ';
    private static final String CLIENT_SECRET = '501AC8B7750D7445BFA692E37F04E60FC4EDE10062113169B21CCAC0DC7ECAEC';
    private static final String URL = 'https://itlindoscom-dev-ed.develop.my.salesforce.com/services/oauth2/token?grant_type=password&client_id='+CLIENT_ID+'&client_secret='+CLIENT_SECRET+'&username='+USERNAME+'&password='+PASSWORD;

    public static void enviarContaApi(List<Account> listAccount) {
        for(Account conta : listAccount) {
            if(conta.AutoGestao__c == true) {
                postAcount(conta.Id);
            }
        }
    }
    
    public static String conectionOrgReturnToken(){
        HttpRequest req = new HttpRequest();
        req.setEndPoint(URL);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        
        Http http  = new Http();
        
        HttpResponse res = http.send(req);
        Map<String ,Object> mapRetorno = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());

        return (String)mapRetorno.get('access_token');
    }
    
    @Future(Callout=true)
    public static void postAcount(String idConta) {
        String bearToken = conectionOrgReturnToken();
        
        Account conta = [SELECT Id, Name, CNPJ__c, AutoGestao__c, Website FROM Account WHERE Id =: idConta];
        
        Http http  = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndPoint('https://itlindoscom-dev-ed.develop.my.salesforce.com/services/apexrest/api/v1/conta');
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization','Bearer ' + bearToken);
        req.setBody('{'+
                        '"cnpj": "' 		+ conta.CNPJ__c 					+ '",'+
                    	'"autoGestao": '	+ conta.AutoGestao__c				+ ',' +
                        '"nome": "' 		+ conta.Name 						+ '",'+
                        '"site": "' 		+ conta.Website 					+ '"' +
                    '}');
        HttpResponse response = http.send(req);
        
        System.debug(response.getStatusCode());
        System.debug(response.getBody());
    }

    public static void testOld(List<Account> listaNovosValoresConta, Map<Id, Account> mapValoresAntigosConta) {
        for(Account novoValorConta : listaNovosValoresConta) {
            System.debug('Valor novo => ' + novoValorConta.Rating);
            
            Account valorAntigoConta = mapValoresAntigosConta.get(novoValorConta.Id);
            
            System.debug('Valor antigo => ' + valorAntigoConta.Rating);
        }
    }
}