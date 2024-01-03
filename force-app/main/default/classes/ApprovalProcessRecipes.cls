public class ApprovalProcessRecipes {
    public Boolean startApprovalProcess(Id recordId, String approvalProcessName, Id userId) {
        Approval.ProcessSubmitRequest processSubmitRequest = new Approval.ProcessSubmitRequest();
        
        processSubmitRequest.setObjectId(recordId);
        processSubmitRequest.setComments('Submitted for approval by apex code');
        processSubmitRequest.setProcessDefinitionNameOrId(approvalProcessName);
        processSubmitRequest.setSubmitterId(userId);
        processSubmitRequest.setSkipEntryCriteria(true);
        
        Approval.ProcessResult result = Approval.process(processSubmitRequest);
        
        return result.isSuccess();
    }
    
    public Boolean startApprovalProcess(Id recordId, String approvalProcessName) {
        Id userId = UserInfo.getUserId();
        
        return startApprovalProcess(recordId, approvalProcessName, userId);
    }

    /*
        * Approval Class => https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_approval.htm
        * ProcessRequest Class => https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_ProcessRequest.htm
        * ProcessResult Class => https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_ProcessResult.htm
        * ProcessSubmitRequest Class => https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_ProcessSubmitRequest.htm
        * ProcessWorkitemRequest Class => https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_ProcessWorkitemRequest.htm
    */

    // Este método inviará a oportunidade para aprovação
    public void submitForApproval(Opportunity opp) {

        // Use o ProcessSubmitRequest para enviar um registro para aprovação.
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();

        // Define os comentários a serem incluídos na solicitação de aprovação.
        req1.setComments('Enviando solicitação de aprovação automaticamente usando Trigger');

        // Define o ID do registro a ser enviado para aprovação.
        req1.setObjectId(opp.id);

        // Se a próxima etapa do seu processo de aprovação for outro processo de aprovação do Apex, especifique exatamente uma ID de usuário como o próximo aprovador. Caso contrário, você não pode especificar um ID de usuário e este método deve sernulo.
        req1.setNextApproverIds(null); // Opcional

        // Configura o nome ou ID do desenvolvedor da definição de processo a ser avaliada.
        //req1.setProcessDefinitionNameOrId(approvalProcessName);  // Opcional

        // Approval.process => Envia uma nova solicitação de aprovação e aprova ou rejeita solicitações de aprovação existentes.
        // Depois de enviar um registro para aprovação, use o Approval.ProcessResult para processar os resultados de um processo de aprovação.
        Approval.ProcessResult result = Approval.process(req1);

        // Os IDs dos novos itens enviados para o processo de aprovação. 
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        
        // Define o ID da solicitação de aprovação que está sendo aprovada, rejeitada ou removida.
        // req2.setWorkitemId(newWorkItemIds.get(0));
    }

    // Este método aprovará a oportunidade
    public void approveRecord(Opportunity opp) {

        // Use o ProcessWorkitemRequest para processar uma solicitação de aprovação após ela ser enviada.
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();

        // Define os comentários a serem incluídos na solicitação de aprovação.
        req.setComments('Aprovando solicitação usando Trigger');

        // Define o tipo de ação a ser executada para processar uma solicitação de aprovação.
        // Os valores válidos são: Approve, Reject, or Removed.
        req.setAction('Approve'); // Approve para Aprovar

        // Configura o nome ou ID do desenvolvedor da definição de processo a ser avaliada.
        req.setNextApproverIds(null); // Opcional

        // método para obter o WorkitemId do ID do objeto fornecido.
        Id workItemId = getWorkItemId(opp.id);

        if(workItemId == null) {
            opp.addError('Ocorreu um erro na trigger');
        } else {
            // Define o ID da solicitação de aprovação que está sendo aprovada, rejeitada ou removida.
            req.setWorkitemId(workItemId);

            // Envie o pedido de aprovação
            Approval.ProcessResult result =  Approval.process(req);
        }
    }
    public void rejectRecord(Opportunity opp) {
        // Use o ProcessWorkitemRequest para processar uma solicitação de rejeição após ela ser enviada.
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();

        // Define os comentários a serem incluídos na solicitação de aprovação.
        req.setComments('Solicitação rejeitada usando Trigger');

        // Define o tipo de ação a ser executada para processar uma solicitação de aprovação.
        // Os valores válidos são: Approve, Reject, or Removed.
        req.setAction('Reject'); // Reject para reprovar
 
        // método para obter o WorkitemId do ID do objeto fornecido.
        Id workItemId = getWorkItemId(opp.id); 

        if(workItemId == null) {
            opp.addError('Ocorreu um erro na trigger');
        } else {
            req.setWorkitemId(workItemId);

            // Envie o pedido de reprovação
            Approval.ProcessResult result =  Approval.process(req);
        }
    }

    // Método que retorna o id ProcessInstanceWorkitem 
    public Id getWorkItemId(Id targetObjectId) {
        Id retVal = null;

        // Selecionar id do ProcessInstanceWorkitem pelo TargetObjectId do ProcessInstance
        List<ProcessInstanceWorkitem> processWorkItem = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: targetObjectId];

        if(!processWorkItem.isEmpty())  {
            retVal  =  processWorkItem.get(0).Id;
        }

        return retVal;
    }
}