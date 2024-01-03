public class OpportunityGetCatalogosFlow {

    public class Entrada {
        @InvocableVariable(required=true)
        public String recordIdOpp;
    }
    
    public class Saida {
        @InvocableVariable(required=true)
        public Integer catalogoPreco;
    }
    
    
    
}