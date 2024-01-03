public class OpportunityHandler {
    public static void dataAtual(List<Opportunity> listOpp) {
        for(Opportunity opp : listOpp) {
        	opp.CloseDate = Date.today().addDays(3);   
        }    
    }
}