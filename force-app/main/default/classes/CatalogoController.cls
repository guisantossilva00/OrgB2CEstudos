public without sharing class CatalogoController {
    public boolean displayPopup {get; set;}     

    public void closePopup() {        
        displayPopup = false;    
    }     

    public void showPopup() {        
        displayPopup = true;    
    }

    @AuraEnabled(cacheable=true)
    public static String getUserId() {
        return UserInfo.getUserId();
    }
    @AuraEnabled(cacheable=true)
    public static List<TabelaPrecos__c> getPricebooks() {
        Set<Id> setIdTabelaPreco = new Set<Id>();
        Set<Id> teste = new Set<Id>();
        List<ProcessInstanceWorkitem> instanceWork = new List<ProcessInstanceWorkitem>();
        Map<Id, List<ProcessInstanceWorkitem>> testemap = new Map<Id, List<ProcessInstanceWorkitem>>(); 
        Id userId = UserInfo.getUserId();
        String userName = UserInfo.getName();

        // if (userName != 'Gerente Vendas') {
        GroupMember groupGroupMember = [SELECT Id , UserOrGroupId , GroupId , Group.Type , Group.DeveloperName FROM GroupMember WHERE Group.Type = 'Queue' AND Group.DeveloperName = 'Gerentes' AND UserOrGroupId =: userId ];
            
            // instanceWork = [SELECT Id, ProcessInstanceId, ProcessInstance.ProcessDefinition.State, ProcessInstance.TargetObjectId, ProcessInstance.Status, ActorId FROM ProcessInstanceWorkitem WHERE ActorId =: userId OR ActorId =: groupGroupMember.GroupId];
        // } else {
            instanceWork = [SELECT Id, ProcessInstanceId, ProcessInstance.ProcessDefinition.State, ProcessInstance.TargetObjectId, ProcessInstance.Status, ActorId FROM ProcessInstanceWorkitem];
        // }

        for(ProcessInstanceWorkitem work : instanceWork) {
            List<ProcessInstanceWorkitem> listInstanceWork = new List<ProcessInstanceWorkitem>();

            teste.add(work.ProcessInstanceId);
            if(!testemap.containsKey(work.ProcessInstanceId)){
                listInstanceWork.add(work);
                testemap.put(work.ProcessInstanceId, listInstanceWork);
            } else { 
                listInstanceWork = testemap.get(work.ProcessInstanceId);
                listInstanceWork.add(work);
                testemap.put(work.ProcessInstanceId, listInstanceWork);
            }
        }
        List<ProcessInstanceNode> testeInstanceNode = [SELECT NodeStatus , ProcessNode.Name , ProcessNode.DeveloperName , ProcessInstanceId FROM ProcessInstanceNode WHERE ProcessInstanceId IN: testemap.keySet()];

        for(ProcessInstanceNode node : testeInstanceNode) {
            List<ProcessInstanceWorkitem> listInstanceWork = testemap.get(node.ProcessInstanceId);
            for(ProcessInstanceWorkitem work : listInstanceWork ) {
                Schema.SObjectType sObjectType  = work.ProcessInstance.TargetObjectId.getSObjectType();
                if(node.ProcessNode.Name == 'Desconto Brasil' && userName == 'Gerente Vendas' || (work.ActorId == userId || work.ActorId == groupGroupMember.GroupId) ) {
                    if(String.valueOf(sObjectType) == 'TabelaPrecos__c') {
                        setIdTabelaPreco.add(work.ProcessInstance.TargetObjectId);
                    }                    
                }
            }
        }
        List<TabelaPrecos__c> listPricebook = [SELECT Id, Name, Status__c, Mercado__c FROM TabelaPrecos__c WHERE Id IN: setIdTabelaPreco ];

        return listPricebook;
    } 

    @AuraEnabled(cacheable=true)
    public static List<Product2> getProdutos(String palavraChave) {
        // Pricebook2 catalogoStandar = [SELECT Id, Name FROM Pricebook2 WHERE Name = 'Standard'];
        String pesquisa = '%' + palavraChave + '%';
        List<Product2> lisProduct = [SELECT Id, Name, ProductCode , Family , Description , isActive FROM Product2 WHERE isActive = true AND (Name LIKE: pesquisa OR ProductCode LIKE: pesquisa)];

       return lisProduct;
    } 

    @AuraEnabled
    public static void insertPricebooks(List<Pricebook2> listPricebook) {
        for(Pricebook2 pricebook : listPricebook) {
            pricebook.Status__c = 'Aprovado';
        }
        update listPricebook;
    }

    @AuraEnabled
    public static String approveRecord(List<TabelaPrecos__c> tabPreco)
    {
        try {
            for(TabelaPrecos__c tab : tabPreco) {
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setAction('Approve');
                //req.setNextApproverIds(new Id[] {opp.Next_Approver__c});
                Id workItemId = getWorkItemId(tab.id); 
        
                if(workItemId == null) {
                    tab.addError('Error Occured in Trigger');
                } else {
                    req.setWorkitemId(workItemId);
                    // Submit the request for approval
                    Approval.ProcessResult result =  Approval.process(req);
                }
            }

            // Id userId = UserInfo.getUserId();
            // GroupMember groupGroupMember = [SELECT Id , UserOrGroupId , GroupId , Group.Type , Group.DeveloperName FROM GroupMember WHERE Group.Type = 'Queue' AND Group.DeveloperName = 'Gerentes' AND UserOrGroupId =: userId ];
    
            // List<ProcessInstanceWorkitem> instanceWork = [SELECT Id , ProcessInstanceId , ProcessInstance.ProcessDefinition.State , ProcessInstance.TargetObjectId , ProcessInstance.Status, ActorId FROM ProcessInstanceWorkitem WHERE ActorId =: userId OR ActorId =: groupGroupMember.GroupId];
            // if(!instanceWork.isEmpty()) {
            //     approveRecord(tabPreco);
            // }
        return 'certo';
    } catch (Exception ex) {
        return ex.getMessage();
    }
    }

    public static Id getWorkItemId(Id targetObjectId) {
        Id retVal = null;

        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p
            where p.ProcessInstance.TargetObjectId =: targetObjectId]) 
        {
            retVal  =  workItem.Id;
        }

        return retVal;
    }

    @AuraEnabled(cacheable=true)
    public static List<CatalogoPrecoItem__c> getPrecoProduto(String idProduto) {
        List<CatalogoPrecoItem__c> tabelaItem = [SELECT Id, Produto__c, TabelaPrecos__c, TabelaPrecos__r.Name, TabelaPrecos__r.TemDesconto__c, Preco__c, CurrencyIsoCode  FROM CatalogoPrecoItem__c WHERE Produto__c =: idProduto];
        
        return tabelaItem;
    }

    @AuraEnabled
    public static String insertProdutos(List<OpportunityLineItem> produtosSelecionados, List<String> idProdutos, String idOpp) {
        try {

            Opportunity oppAtual = [SELECT Id, Pricebook2Id, CurrencyIsoCode FROM Opportunity WHERE Id =: idOpp];

            Pricebook2 catalogoStandar = [SELECT Id, Name FROM Pricebook2 WHERE Name = 'Standard'];

            Map<String, List<String>> mapProdutoPriceEntry =  new Map<String, List<String>>();

            List<PricebookEntry> listPricebookEntry = [SELECT Id, Pricebook2Id, Product2Id, CurrencyIsoCode FROM PricebookEntry WHERE Product2Id IN: idProdutos AND Pricebook2Id =: catalogoStandar.Id];
            
            for(PricebookEntry priceEntry : listPricebookEntry){
                String[] listPriceEntryCurrencyIso = new String[2];

                listPriceEntryCurrencyIso[0] = priceEntry.Id;
                listPriceEntryCurrencyIso[1] = priceEntry.CurrencyIsoCode;

                mapProdutoPriceEntry.put(priceEntry.Product2Id, listPriceEntryCurrencyIso);
            }

            oppAtual.Pricebook2Id = catalogoStandar.Id;

            update oppAtual;

            List<OpportunityLineItem> listOppItem = new List<OpportunityLineItem>();
            
            for(OpportunityLineItem produto : produtosSelecionados) {
                OpportunityLineItem newpro = new OpportunityLineItem();

                List<String> listPriceEntryCurrencyIso = mapProdutoPriceEntry.get(produto.Product2Id);
                
                newpro.Product2Id = produto.Product2Id;
                newpro.Quantity = produto.Quantity;
                newpro.OpportunityId = produto.OpportunityId;
                newpro.UnitPrice = produto.UnitPrice;
                newpro.PricebookEntryId = listPriceEntryCurrencyIso[0];
                
                listOppItem.add(newpro);
            }
            
            insert listOppItem;
            
            return 'certo';
        } catch (Exception ex) {
            return ex.getMessage();
        } 
    }
}