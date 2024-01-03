public class AgendadorPerfilOportunidade implements Schedulable {
    public void execute(SchedulableContext ctx) {
        List<Opportunity> listOpp = [SELECT Id, Amount, Perfil__c FROM Opportunity];
        
        ClassB.setPerfilOportunidade(listOpp);
    }
}