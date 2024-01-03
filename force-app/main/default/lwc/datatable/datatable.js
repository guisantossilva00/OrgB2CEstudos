import { LightningElement, wire } from 'lwc';
import getContatos from '@salesforce/apex/ContactController.getContatos';
import getInfoCovid from '@salesforce/apex/ContactController.getInfoCovid';

export default class Datatable extends LightningElement {
    colunas = [
        { label: 'UF', fieldName: 'uf'},
        { label: 'Estado', fieldName: 'state'},
        { label: 'Casos', fieldName: 'cases'},
        { label: 'Mortes', fieldName: 'deaths'},
    ];

    dadosContato;
    erro;

    @wire(getInfoCovid)
    wireGetInfoCovid({error, data}) {
        console.log(data);
        if(data) {
            this.dadosContato = data;
            this.erro = undefined;
        } else if(error) {
            console.log(error);
            this.erro = error;
            this.dadosContato = undefined;
        }
    }

    getSelecionado(event) {
        const selecionados = event.detail.selectedRows;

        for(let i = 0; i < selecionados.length; i++) {
            console.log('Você selecionou: ' + selecionados[i].Id);
        }
    }
}