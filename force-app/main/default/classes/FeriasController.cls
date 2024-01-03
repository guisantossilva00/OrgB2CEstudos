public with sharing class FeriasController {

    @AuraEnabled(cacheable=true)
    public static List<SolicitacaoFerias__c> getSolicitacoresFerias(String filtroStatus, String palavraChave) {
        String status = '%' + filtroStatus + '%';
        String chave = '%' + palavraChave + '%';

        return [
            SELECT Id, Name, GestorImediato__c, GestorImediato__r.Name, NomeColaborador__c, NomeColaborador__r.Name, Status__c, CreatedDate
            FROM SolicitacaoFerias__c
            WHERE Status__c LIKE: status AND (
            NomeColaborador__r.Name LIKE: chave OR
            GestorImediato__r.Name LIKE: chave OR
            Name LIKE: chave )
            ORDER BY CreatedDate DESC
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Colaborador__c> getColaborador(String palavraChave) {
        String chave = '%' + palavraChave + '%';

        return [
            SELECT Id, Name
            FROM Colaborador__c
            WHERE Name LIKE: chave
            LIMIT 5
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Colaborador__c> getGestor(String palavraChave) {
        String chave = '%' + palavraChave + '%';

        return [
            SELECT Id, Name
            FROM Colaborador__c
            WHERE Name LIKE: chave AND Gestor__c = true
            LIMIT 5
        ];
    }

    @AuraEnabled
    public static void criarSolicitacao(SolicitacaoWrapper solicitacao){
        try {

            SolicitacaoFerias__c novaSolicitacao = new SolicitacaoFerias__c(); 

            novaSolicitacao.NomeColaborador__c = solicitacao.idColaborador;
            novaSolicitacao.Cargo__c = solicitacao.cargo;
            novaSolicitacao.Local__c = solicitacao.local;
            novaSolicitacao.GestorImediato__c = solicitacao.idGestor;
            novaSolicitacao.TipoFerias__c = solicitacao.tipoFerias;
            
            insert novaSolicitacao;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true) 
    public static List<SoliciatacoesFeriasWrapper> getSolicitacoesPorGestor() {
        List<SoliciatacoesFeriasWrapper> wrapList = new List<SoliciatacoesFeriasWrapper>();

        List<Colaborador__c> listGestorSolicitacoes = [SELECT Id, Name, 
                                        (
                                            SELECT Id, Name, GestorImediato__c, GestorImediato__r.Name, NomeColaborador__c, NomeColaborador__r.Name, Status__c, CreatedDate
                                            FROM SolicitacesFerias__r
                                            ORDER BY CreatedDate DESC
                                        )
                                        FROM Colaborador__c 
                                        WHERE Gestor__c = true
                                        ORDER BY Name ASC];

        if(!listGestorSolicitacoes.isEmpty()) {
            for(Colaborador__c gestor : listGestorSolicitacoes) {
                wrapList.add(new SoliciatacoesFeriasWrapper(gestor, gestor.SolicitacesFerias__r));
            } 
        }

        return wrapList;
    }

    public class SolicitacaoWrapper {
        @AuraEnabled
        public Id  idColaborador {get;set;}
        @AuraEnabled
        public String cargo {get;set;}
        @AuraEnabled
        public String local {get;set;}
        @AuraEnabled
        public Id idGestor {get;set;}
        @AuraEnabled
        public String tipoFerias {get;set;}
    }

    public class SoliciatacoesFeriasWrapper {
        @AuraEnabled
        public Colaborador__c colaboradorRecord {get;set;}

        @AuraEnabled
        public List<SolicitacaoFerias__c> solicitacoesList {get;set;}

        @auraEnabled
        public Integer sizeTotal;

        public SoliciatacoesFeriasWrapper(Colaborador__c colaboradorRecord, List<SolicitacaoFerias__c> solicitacoesList) {
            this.colaboradorRecord = colaboradorRecord;
            this.solicitacoesList = solicitacoesList;
            this.sizeTotal = solicitacoesList.size() + 1;
        }
        
    }
}