import { LightningElement, api } from 'lwc';

export default class PaginacaoSolicitacoesFerias extends LightningElement {
    totalRecords;
    currentPage = 1;
    recordSize = 6;
    totalPage = 0;
    temPaginas = false;
    paginas;

    get records() {
        return this.visibleRecords;
    }

    @api 
    set records(data) {
        if(data) {
            this.totalRecords = data;

            this.paginas = [];
            
            this.totalPage = Math.ceil(data.length / this.recordSize);
            
            console.log('this.paginas => ', this.paginas);
            for(let i = 1; i <= this.totalPage ; i++) {
                if(!this.paginas.includes(i))
                    this.paginas.push(i);
            }
            
            this.temPaginas = true;
            
            this.updateRecords();
        }
    }

    get disablePrevious(){ 
        return !(this.currentPage <= 1);
    }

    get disableNext(){ 
        return !(this.currentPage >= this.totalPage);
    }

    previousHandler() {
        if(this.currentPage > 1) {
            this.currentPage -= 1;
            this.removeAddClassLi();
            this.updateRecords();
        }
    }

    nextHandler() {
        if(this.currentPage < this.totalPage) {
            this.currentPage += 1;
            this.removeAddClassLi();
            this.updateRecords();
        }
    }

    removeAddClassLi() {
        let elementosLi = this.template.querySelectorAll('li');

        for (let i = 0; i < elementosLi.length; i++) {
   
            if(elementosLi[i].textContent != this.currentPage) {
                elementosLi[i].classList.remove('currentPage');         
            } else {
                elementosLi[i].classList.add('currentPage')
            }
        }
    }


    mudarPaginaSelecionada(element) {
        let valorElement = Number(element.currentTarget.dataset.value);
    
        if(this.currentPage != valorElement) {
            this.currentPage = valorElement;
            this.updateRecords();
        }

        this.removeAddClassLi();
    }

    updateRecords() {
        const start = (this.currentPage - 1) * this.recordSize;
        const end = this.recordSize * this.currentPage;

        this.visibleRecords = this.totalRecords.slice(start, end);

        this.dispatchEvent(new CustomEvent('update', {
            detail: {
                records: this.visibleRecords
            }
        }))
    }


}