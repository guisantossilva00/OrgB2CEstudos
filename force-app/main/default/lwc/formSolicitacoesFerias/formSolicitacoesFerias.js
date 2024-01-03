import { LightningElement, wire } from 'lwc';
import getColaborador from '@salesforce/apex/FeriasController.getColaborador';
import getGestor from '@salesforce/apex/FeriasController.getGestor';
import criarSolicitacao from '@salesforce/apex/FeriasController.criarSolicitacao';

export default class FormSolicitacoesFerias extends LightningElement {
    pesquisaColaborador = false;
    pesquisaGestor = false;

    colaboradores;
    gestores;
    erro;

    palavraChave = '';
    palavraChaveGestor = '';

    colabora = {
        Id: '',
        Name: ''
    }

    gestor = {
        Id: '',
        Name: ''
    }
    
    eventoTabelaFormSolicitacao() {
        const event = new CustomEvent('voltartabelasolicitacao');

        this.dispatchEvent(event);
    }

    async changeInputColaborador(event) {
        let palavraInput = event.target.value;

        if(palavraInput.length > 1) {
            this.colaboradores = await getColaborador({palavraChave: palavraInput});
            this.pesquisaColaborador = true;
        } else{
            this.pesquisaColaborador = false;
        }   
    }

    async changeInputGestor(event) {
        let palavraInput = event.target.value;

       if(palavraInput.length > 1) {
           this.gestores = await getGestor({palavraChave: palavraInput});
           this.pesquisaGestor = true;
       } else{
            this.pesquisaGestor = false;
       }
    }

    selecionaColaborador(event) {
        let nome = event.target.dataset.name;
        let id = event.target.dataset.id;

        const inputColaborador = this.template.querySelector('input[name="nome-colaborador"]');

        this.colabora.Name = nome;
        this.colabora.Id = id;
        inputColaborador.value = nome;
    
        this.pesquisaColaborador = false;
    }

    selecionaGestor(event) {
        let nome = event.target.dataset.name;
        let id = event.target.dataset.id;

        const inputGestor = this.template.querySelector('input[name="nome-gestor"]');
      
        this.gestor.Name = nome;
        this.gestor.Id = id;
        inputGestor.value = nome;

        this.pesquisaGestor = false;
    }

    criarSolicitacaoFerias() {
        const inputCargo = this.template.querySelector('[name="cargo"]');
        const inputLocal = this.template.querySelector('[name="local"]');
        const inputTipoFerias = this.template.querySelector('[name="tipo-ferias"]');
     

        criarSolicitacao({
            idColaborador: this.colabora.Id, 
            cargo: inputCargo, 
            local: inputLocal, 
            idGestor: this.gestor.Id, 
            tipoFerias: inputTipoFerias
        }).then(() => {

        }).catch(erro => {

        });
    }
}