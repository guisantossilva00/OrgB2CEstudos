trigger OpportunityTrigger on Opportunity (before insert) {
    if(Trigger.isInsert && Trigger.isBefore) {
		OpportunityHandler.dataAtual(Trigger.new);
    }    
}