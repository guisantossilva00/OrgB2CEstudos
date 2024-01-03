import { LightningElement } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import FontAwesome from '@salesforce/resourceUrl/FontAwesome';

export default class TelaAprovacaoItemOportunidade extends LightningElement {
    filho = false;

    connectedCallback() {
        Promise.all([
            loadStyle(this, FontAwesome + '/css/all.css')
            ]).then(() => {
                console.log('loaded!');
            }).catch((error) => {
                console.log('error -> ' + error);
        });
    }

    mostrarFilho() {
        this.filho = !this.filho;
    }
}