import { LightningElement, wire} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import FontAwesome from '@salesforce/resourceUrl/FontAwesome';
import getSolicitacoresFerias from '@salesforce/apex/FeriasController.getSolicitacoresFerias';
import getSolicitacoesPorGestor from '@salesforce/apex/FeriasController.getSolicitacoesPorGestor';

import fundoFerias from '@salesforce/resourceUrl/fundoFerias'

export default class SolicitacoesFerias extends LightningElement {
    fundoFerias = fundoFerias;
    disabledBTN = false;
    solicitacoesFerias;
    groupSolicitacoesFerias;
    visibleSolicitacoesFerias;

    filtroStatus = '';
    palavraChave = '';

    tabelaFormSolicitacao = true;
    modalFiltroPesquisa = false;

    @wire(getRecord, { recordId: Id, fields: [ProfileName] })
    userDetails({ error, data }) {
        if (error) {
            // this.error = error;
            console.log(error);
        } else if (data) {
            // if (data.fields.Name.value != null) {
                //     this.userName = data.fields.Name.value;
                // }
                // if (data.fields.UserRole.value != null) {
                    //     this.userRoleName = data.fields.UserRole.value.fields.Name.value;
                    // }
                    console.log(this.disabledBTN);
                    
                    if (data.fields.Profile.value.fields.Name.value == 'Administrador do sistema') {
                        this.disabledBTN = true;
                        console.log('entrou aqui');
                        console.log(this.disabledBTN);
            }
            // if (data.fields.Manager.value != null) {
            //     this.userManagerName = data.fields.Manager.value.fields.Name.value;
            // }
        }
    }

    connectedCallback() {
        Promise.all([
            loadStyle(this, FontAwesome + '/css/all.css')
            ]).then(() => {
                console.log('loaded!');
            }).catch((error) => {
                console.log('error -> ' + error);
        });

        this.removeAddClassFiltro(this.filtroStatus == '' ? 'Todos' : this.filtroStatus);
    }

    @wire(getSolicitacoresFerias, {filtroStatus: '$filtroStatus', palavraChave: '$palavraChave'})
    wireGetSolicitacoresFerias({error, data}) {
        if(data) {
            this.solicitacoesFerias = data;
            this.erro = undefined;
        } else if(error) {
            this.erro = error;
            this.solicitacoesFerias = undefined;
        }
    }

    @wire(getSolicitacoesPorGestor)
    wireGetSolicitacoesPorGestor({error, data}) {
        if(data) {
            this.groupSolicitacoesFerias = data;

            this.erro = undefined;
        } else if(error) {
            console.error(error);
            this.erro = error;
            this.groupSolicitacoesFerias = undefined;
        }
    }

    updateHandler(event) {
        this.visibleSolicitacoesFerias = [...event.detail.records];
    }

    getFiltroStatus(event) {
        let status = event.currentTarget.dataset.status;
        
        this.removeAddClassFiltro(status);

        this.filtroStatus = status == 'Todos' ? '' : status;
        this.abrirFiltroPesquisa();
    }

    changeInputPesquisa(event) {
        let palavraInput = event.target.value

        this.palavraChave = palavraInput.length > 1 ? palavraInput : '';

    }

    removeAddClassFiltro(status) {
        if(this.modalFiltroPesquisa) {
            const iconeCheckexcluir  = this.template.querySelector('.fa-check');
            iconeCheckexcluir.remove();
        }

        let elementosLi = this.template.querySelectorAll('li');

        let iconeCheck = document.createElement('i');
        iconeCheck.classList.add('fa-solid');
        iconeCheck.classList.add('fa-check');

        for (let i = 0; i < elementosLi.length; i++) {

            if(!elementosLi[i].textContent.includes(status)) {
                elementosLi[i].classList.remove('filtro-selecionado');

            } else {
                elementosLi[i].classList.add('filtro-selecionado');
                elementosLi[i].appendChild(iconeCheck);
            }
        }
    }

    abrirFiltroPesquisa() {
        this.modalFiltroPesquisa = !this.modalFiltroPesquisa;
    }
    
    changeTabelaFormSolicitacao(){
        this.tabelaFormSolicitacao = !this.tabelaFormSolicitacao;
    }
}