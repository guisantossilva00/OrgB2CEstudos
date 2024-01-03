public class ClassB {
    public static void setPerfilOportunidade(List<Opportunity> listOpp) {        
        List<Opportunity> listOppUpdate = new List<Opportunity>();
        
        for(Opportunity opp : listOpp) {           
            if(opp.Amount > 0 && opp.Amount <= 20000) {
                opp.Perfil__c = 'Baixo';
            } else if (opp.Amount > 20000 && opp.Amount <= 50000) {
                opp.Perfil__c = 'Médio';
            } else if(opp.Amount > 50000) {
                opp.Perfil__c = 'Alto';
            } else {
                opp.Perfil__c = '';
            }
            
            listOppUpdate.add(opp);
        }
        
        update listOppUpdate;
    }
}