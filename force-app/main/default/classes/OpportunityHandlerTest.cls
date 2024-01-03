@isTest
public class OpportunityHandlerTest {
    
	@isTest
    static void dataAtualTest() {
        Opportunity newOpp = new Opportunity();
        
        newOpp.Name = 'Oportunidade teste';
        newOpp.CloseDate = Date.today().addDays(23);
        newOpp.StageName = 'Prospecting';
        
        insert newOpp;   
        
        Opportunity testeOpp = [SELECT Id, CloseDate FROM Opportunity WHERE Id =: newOpp.Id];
        
        Assert.areEqual(Date.today(), testeOpp.CloseDate);
        //Assert.areNotEqual(Date.today(), testeOpp.CloseDate);
    }
}