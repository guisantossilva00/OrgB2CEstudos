@isTest
public class ExerciciosApexTeste {
    
	@isTest 
    static void somarDezTeste() {
        Integer valorRetorno = ExerciciosApex.somarDez(20);
                    
		System.assertEquals(30, valorRetorno);
    }
}