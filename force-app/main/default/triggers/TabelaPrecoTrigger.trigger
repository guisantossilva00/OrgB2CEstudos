trigger TabelaPrecoTrigger on TabelaPrecos__c (after insert, after update) {
    if(Trigger.isUpdate) {
        // if(Trigger.isAfter) {
        //     Set<Id> idTabelaPreco = new Set<Id>();
            
        //     for(TabelaPrecos__c tb : Trigger.new) {
        //         idTabelaPreco.add(tb.Id);
        //     }
            
        //     List<TabelaPrecos__c> tabelaPreco = [SELECT Id, (SELECT Id, Representante__c, TabelaPrecos__c FROM CatalogosPrecosRepresentantes__r) FROM TabelaPrecos__c WHERE Id IN: idTabelaPreco];       
        //     List<TabelaPrecos__Share> tabelaSharing  = new List<TabelaPrecos__Share>();
            
        //     for(TabelaPrecos__c tb : tabelaPreco) {
        //         List<CatalogoPrecoRepresentantes__c> catPreRep = tb.CatalogosPrecosRepresentantes__r;
                
        //         for(CatalogoPrecoRepresentantes__c catRep : catPreRep) {                    
        //             TabelaPrecos__Share tabelaPrecosShare  = new TabelaPrecos__Share();
                    
        //             tabelaPrecosShare.ParentId = tb.Id;
        //             tabelaPrecosShare.UserOrGroupId = catRep.Representante__c;
        //             tabelaPrecosShare.AccessLevel = 'Edit';
        //             tabelaPrecosShare.RowCause = Schema.TabelaPrecos__Share.RowCause.Manual;
        //             tabelaSharing.add(tabelaPrecosShare);                    
        //         }
        //     }
            
        //    insert tabelaSharing;        
        // }
    }
}