import { LightningElement, api, wire, track } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import getProdutos from '@salesforce/apex/CatalogoController.getProdutos';
import getPrecoProduto from '@salesforce/apex/CatalogoController.getPrecoProduto';
import insertProdutos from '@salesforce/apex/CatalogoController.insertProdutos';

export default class Modal extends NavigationMixin(LightningElement) {
    erro;
    refreshGetProdutos;
    precoProduto;
    sortBy;
    sortDirection;
    @api idOportunidade;
    palavraChave = '';
    
    @track produtosDados = [];
    @track produtosDadosAuxiliar = [];
    @track idProdutos = [];
    @track preSelecionados = [];
    @track preSelecionadosAuxiliar = [];
    @track produtosSelecionados = [];
 
    input = true;
    getPreco = true;
    listaProdutos = true;
    disabledButton = true;
    modalBuscaPreco = false;
    buscaListaProdutos = false;
    listaProdutosSelecionados = false;

    produtosColunas = [ 
        { label: 'Nome Produto', fieldName: 'Name', sortable: true }, 
        { label: 'Código do Produto', fieldName: 'ProductCode' }, 
        { label: 'Família do Produto', fieldName: 'Family' },
        { label: 'Descrição do Produto', fieldName: 'Description' },
    ]; 

    buscaPrecoColunas = [ 
        { label: 'Nome da Tabela', fieldName: 'Name', sortable: true }, 
        { label: 'Preço do Produto', fieldName: 'Preco' }, 
    ]; 

    @wire(getProdutos, {palavraChave: '$palavraChave'})
    retornoPricebook(results) {
        let {error, data} = results;
        this.refreshGetProdutos = results;
        if(data) {
            let dadosPreparados = [];
            data.map(result => {
                let preparandoDados = {};
                preparandoDados.Name = result.Name;
                preparandoDados.ProductCode = result.ProductCode;
                preparandoDados.Family = result.Family;
                preparandoDados.Description = result.Description;
                preparandoDados.Id = result.Id;
                preparandoDados.TemDesconto  = true;
                dadosPreparados.push(preparandoDados);
            });
            
            this.preSelecionados = this.preSelecionadosAuxiliar;
            this.produtosDadosAuxiliar = dadosPreparados;
            this.produtosDados = dadosPreparados;
            this.erro = undefined;
        } else if(error) {
            this.erro = error;
            this.produtosDados = undefined;
        }
    }

    getValuePesquisa(event) {
        // this.palavraChave = event.target.value;

        let palavraInput = event.target.value.toLowerCase();
        this.buscaListaProdutos = true;
        if(palavraInput.length > 1) {
            this.produtosDadosAuxiliar = this.produtosDados.filter(result => (result.Name.toLowerCase().includes(palavraInput))); 
        } else {
            this.produtosDadosAuxiliar = this.produtosDados;
            this.buscaListaProdutos = !this.buscaListaProdutos;
        }
    }
    
    temSelecionado(event) {
        const selectedRows = event.detail.selectedRows; 
        const action = event.detail.config.action;
        
        if(action == 'rowSelect' || action == 'selectAllRows') {
            for(let i = 0; i < selectedRows.length; i++) {
                if(!this.preSelecionadosAuxiliar.includes(selectedRows[i].Id)){
                    this.preSelecionadosAuxiliar.push(selectedRows[i].Id);  
                }
            }
        } else if (action == 'rowDeselect') {
            let indiceProdutosId = this.preSelecionadosAuxiliar.findIndex(produto => produto == event.detail.config.value);
            this.preSelecionadosAuxiliar.splice(indiceProdutosId, 1);
        } else if (action == 'deselectAllRows') {
            this.preSelecionadosAuxiliar = [];
        }
        
        if(this.preSelecionadosAuxiliar.length > 0) {
            this.disabledButton = false;
        } else {
            this.disabledButton = true;
        }
        refreshApex(this.refreshGetProdutos)
    }

    getProdutosSelecionados() {
        this.parteSelecionar();
        let selecionados = this.template.querySelector("lightning-datatable").getSelectedRows();
        this.produtosSelecionados = this.produtosDados.filter(result => (this.preSelecionados.includes(result.Id)));
    }

    parteSelecionar() {
        this.listaProdutos = !this.listaProdutos ;
        this.listaProdutosSelecionados = !this.listaProdutosSelecionados;
        this.disabledButton = true;
        this.getPreco = true;
        this.palavraChave = '';                     
        this.produtosSelecionados.map(result => {
                result.PrecoVenda = undefined;
                result.Moeda = undefined; 
                result.TemDesconto = true;                        
                result.Quantity = undefined;                        
                result.PrecoFinal = undefined;   
                result.Desconto = undefined; 
        });

        if(this.preSelecionados.length > 0) {
            this.disabledButton = false;
        } else {
            this.disabledButton = true;
        }
    }

    async buscaPrecoProduto(event) {
        let idProduto = event.currentTarget.dataset.id;

        let result = await getPrecoProduto({idProduto : idProduto});

        this.precoProduto = result;

        if(this.precoProduto.length == 1) {
            for (let i = 0; i < this.precoProduto.length; i++) {
                this.produtosSelecionados.map(result => {
                    if(result.Id == this.precoProduto[i].Produto__c){
                        result.PrecoVenda = this.precoProduto[i].Preco__c;
                        result.Moeda = this.precoProduto[i].CurrencyIsoCode;     
                        result.PrecoFinal = this.precoProduto[i].Preco__c;  
                        result.Desconto =  this.calculaPorcetagemVenda(result.PrecoVenda, result.PrecoFinal);
                        
                        if(this.precoProduto[i].TabelaPrecos__r.TemDesconto__c == true) {              
                            result.TemDesconto = false;
                        } else {
                            result.TemDesconto = true;
                        }
                    } 
                });                
            }
    
            this.getPreco = false;
        } else if(this.precoProduto.length == 0) {
            let inputsBtn = Array.from(this.template.querySelectorAll(`[data-id="${idProduto}"]`)).filter(result => (result.tagName != 'LIGHTNING-BUTTON-ICON'));
            inputsBtn.forEach(result => {result.disabled = true; console.log(result);}) 

            let produto = this.produtosSelecionados.filter(result => (result.Id == idProduto));
            this.showToastNaoTemPreco(produto[0]);
            this.getPreco = false;
        } else {
            this.abrirFecharModal();
        }        
    }

    savePrecoProduto() {
        let selecionados = this.template.querySelectorAll('input[name="precoTabela"]');

        for (let i = 0; i < selecionados.length; i++) {
            if (selecionados[i].checked){
                this.produtosSelecionados.map(result => {
                    if(result.Id == selecionados[i].value){
                        result.PrecoVenda = selecionados[i].dataset.preco;
                        result.Moeda = selecionados[i].dataset.currency;     
                        result.PrecoFinal = selecionados[i].dataset.preco;  
                        result.Desconto =  this.calculaPorcetagemVenda(result.PrecoVenda, result.PrecoFinal);

                        if(selecionados[i].dataset.desconto == 'true') {                     
                            result.TemDesconto = false;
                        } else {
                            result.TemDesconto = true;
                        }
                    } 
                });                   
            }
        }

        this.getPreco = false;
        this.abrirFecharModal();
    }

    getValueQuantity(event){
        let idProdutoInput = event.currentTarget.dataset.id;
        let quantidade = event.currentTarget.value;

        this.produtosSelecionados.map(result => {
            if(result.Id == idProdutoInput){
                result.Quantity = quantidade;
            } 
        });
    }

    getValueDesconto(event){
        let idProdutoInput = event.currentTarget.dataset.id;
        let porcentagem = event.currentTarget.value;

        this.produtosSelecionados.map(result => {
            if(result.Id == idProdutoInput){
                let total = this.calculaDescontoPorPorcetagem(result.PrecoVenda, porcentagem);

                result.PrecoFinal = total;
                result.Desconto =  porcentagem;
            } 
        });
    }

    getValuePrecoFinal(event){
        let idProdutoInput = event.currentTarget.dataset.id;
        let precoFinal = event.currentTarget.value;

        this.produtosSelecionados.map(result => {
            if(result.Id == idProdutoInput){
                let total = this.calculaPorcetagemVenda(result.PrecoVenda, precoFinal);

                result.Desconto =  total;
                result.PrecoFinal = precoFinal;
            } 
        });
    }

    calculaPorcetagemVenda(precoVenda, precoFinal) {
        return (((precoVenda - precoFinal) * 100) / precoVenda).toFixed(2);
    }

    calculaDescontoPorPorcetagem(precoVenda, porcentagem) {
        return (precoVenda - (precoVenda * porcentagem) / 100).toFixed(2);
    }

    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validar');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });

        return isValid;
    }

    insertProduto() {
        if(this.isInputValid()) {
            let dadosPreparados = [];
            let idsProdutos = [];
            for(let produto of this.produtosSelecionados) {

                if(produto.PrecoFinal == undefined) {
                    dadosPreparados = [];
                    break;
                } else {
                    let preparandoDados = {};
                    preparandoDados.Quantity = produto.Quantity;
                    preparandoDados.Product2Id = produto.Id;
                    preparandoDados.UnitPrice = produto.PrecoFinal.replace('.', ',');
                    preparandoDados.PricebookEntryId = produto.Id;
                    preparandoDados.OpportunityId = this.idOportunidade;
                    idsProdutos.push(preparandoDados.Product2Id);
                    dadosPreparados.push(preparandoDados);
                }
            }

            if(dadosPreparados.length > 0) {
                insertProdutos({produtosSelecionados : dadosPreparados, idProdutos: idsProdutos, idOpp: this.idOportunidade}).then(produto => {
                    if(produto != null) {
                        this.voltarOpp();
                    }
                });
                this.showToastSuccess(dadosPreparados.length);
            } else {
                this.showToastError();
            }
        }
    }

    deleteProduto(event) {
        let idProduto = event.currentTarget.dataset.id;

        let indiceProdutosSelecionados = this.produtosSelecionados.findIndex(produto => produto.Id == idProduto);
        this.produtosSelecionados.splice(indiceProdutosSelecionados, 1);

        let indiceProdutosId = this.preSelecionados.findIndex(produto => produto == idProduto);
        this.preSelecionados.splice(indiceProdutosId, 1);

        if(this.produtosSelecionados.length == 0 ) {
            this.parteSelecionar();
        }
    }

    voltarOpp() {
        if(this.listaProdutosSelecionados){
            this.parteSelecionar();
        }
        
        this.preSelecionados = [];

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'Opportunity',
                recordId: this.idOportunidade,
                actionName: 'view',
            }
        });
    }

    showToastError() {
        const event = new ShowToastEvent({
            title: 'Produtos Sem Preço',
            message: `Tem produtos que o preço não foi escolhido.` ,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    showToastNaoTemPreco(produto) {
        const event = new ShowToastEvent({
            title: 'Produtos Não tem Preço',
            message: `Não foi possivel buscar o preço do ${produto.Name}.` ,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    showToastSuccess(quantidade) {
        let StringProduto = quantidade > 1 ? 'Produtos' : 'Produto';
        const event = new ShowToastEvent({
            title: 'Sucesso!',
            message: `${quantidade} ${StringProduto} adicionado com sucesso!`,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    abrirFecharModal() {
        this.modalBuscaPreco = !this.modalBuscaPreco;
    }

    doSorting(event) {
        console.log('event.detail ', event.detail);
        this.sortBy = event.detail.fieldName === 'PricebookEntryURL' ? 'Name' : event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;

        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        console.log('fieldname ', fieldname);
        let parseData = JSON.parse(JSON.stringify(this.produtosDados));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.produtosDados = parseData;
    }    
}