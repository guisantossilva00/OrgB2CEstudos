import { LightningElement, api } from 'lwc';

export default class ComunicacaoFilhoComValor extends LightningElement {
    @api valorVindoDoPai;

    apagarInputPai() {
        const evento = new CustomEvent('limpainput'); 

        this.dispatchEvent(evento);
    }
}