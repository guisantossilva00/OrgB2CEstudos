import { LightningElement } from 'lwc';

export default class ComunicacapPaiComValor extends LightningElement {
    valorInputPai;

    getValorNome(event) {
        this.valorInputPai = event.target.value;
    }

    limpaInput() {
        this.valorInputPai = '';
    }
}