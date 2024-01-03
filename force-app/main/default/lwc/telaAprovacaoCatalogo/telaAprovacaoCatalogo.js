import { LightningElement, wire } from 'lwc';
import getPricebooks from '@salesforce/apex/CatalogoController.getPricebooks';
import { refreshApex } from '@salesforce/apex';
import approveRecord from '@salesforce/apex/CatalogoController.approveRecord';
import getUserId from '@salesforce/apex/CatalogoController.getUserId';

export default class TelaAprovacaoCatalogo extends LightningElement {
    erro;
    catalogoDados = [];
    idCatalogos = [];
    refreshGetPricebooks;

    mudou=false;

    troca() {
        this.mudou = !this.mudou;
    }

    catalogoColunas = [ 
        { label: 'Catalogo', fieldName: 'Name' }, 
        {label: 'Mercado', fieldName: 'Mercado__c' }, 
        { label: 'Status', fieldName: 'Status__c' },
        // { label: 'Válido desde', fieldName: 'ValidTo', type: 'date', typeAttributes: {
        //     day: 'numeric',
        //     month: 'short',
        //     year: 'numeric',
        //     hour: '2-digit',
        //     minute: '2-digit',
        //     second: '2-digit',
        //     hour12: false
        // }},
        // { label: 'Válido até', fieldName: 'ValidFrom', type: 'date', typeAttributes: {
        //     day: 'numeric',
        //     month: 'short',
        //     year: 'numeric',
        //     hour: '2-digit',
        //     minute: '2-digit',
        //     second: '2-digit',
        //     hour12: false
        // }}
    ]; 

    @wire(getPricebooks)
    retornoPricebook(results) {
        let {error, data} = results;
        this.refreshGetPricebooks = results;
        if(data) {
            this.catalogoDados = data;
            console.log(' this.catalogoDados => ' +  this.catalogoDados);
            this.erro = undefined;
        } else if(error) {
            this.erro = error;
            this.catalogos = undefined;
        }
    }
    @wire(getUserId)
    retornogetUserId

    catalogosSelecionados(event){
        let selecionados = event.detail.selectedRows;
        for(let i = 0; i < selecionados.length; i++) {
            if(!this.idCatalogos.includes(selecionados[i].CatalogoId)) {
                this.idCatalogos.push(selecionados[i].CatalogoId);       
            }
        }
        console.log(this.idCatalogos[0]);
    }

    aprovarCatalogos(){
        let selecionados = this.template.querySelector("lightning-datatable").getSelectedRows();
        approveRecord({tabPreco: selecionados}).then((result) => {
            console.log(result);
           return refreshApex(this.refreshGetPricebooks);
        });
    }
}