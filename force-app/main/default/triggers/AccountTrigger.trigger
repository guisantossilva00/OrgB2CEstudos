trigger AccountTrigger on Account (after update, after insert) {
    if(Trigger.isUpdate && Trigger.isAfter) {        
            AccountTriggerHandler.enviarContaApi(Trigger.new);
    }
    if(Trigger.isInsert && Trigger.isAfter) {        
            AccountTriggerHandler.enviarContaApi(Trigger.new);
    }
}