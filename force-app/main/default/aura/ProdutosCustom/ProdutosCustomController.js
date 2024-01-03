({
	doInit : function(component, event, helper) {
        let pageRef = component.get("v.pageReference");
        let idOpp = pageRef.state.c__idOpp;
       	component.set("v.idOpp",idOpp);
		
		//component.find('modal').setParametros(idOpp);
	}
})