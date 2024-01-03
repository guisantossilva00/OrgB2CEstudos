import { LightningElement, track } from 'lwc';

export default class ContadorClique extends LightningElement {
    @track contador = 0;

    contarQuantidadeClique() {
        // console.log('Clicou e abriu a função');
        // console.log('Valor Antes => ' + this.contador);

        this.contador = this.contador + 1;

        // console.log('Valor Depois => ' + this.contador);
    }
}