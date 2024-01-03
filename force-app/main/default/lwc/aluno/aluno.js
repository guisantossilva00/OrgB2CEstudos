import { LightningElement, track } from 'lwc';

export default class Aluno extends LightningElement {
    @track aluno = [
        {
            nome: '',
            sala: '',
            turma: ''
        },
    ];

    listaAlunos = [
        {
            id: '1',
            nome: 'João'
        },
        {
            id: '2',
            nome: 'Lucas'
        },
        {
            id: '3',
            nome: 'Pedro'
        },
        {
            id: '4',
            nome: 'Paulo'
        },
        {
            id: '5',
            nome: 'Ana'
        }
    ]

    liberar = false;

    obterNomeAluno(event) {
        this.aluno.nome = event.target.value;

        if(this.aluno.nome.length > 2 ) {
            this.liberar = true;
        } else {
            this.liberar = false;
        }
    }

    obterSalaAluno(event) {
        this.aluno.sala = event.target.value;
    }

    obterTurmaAluno(event) {
        this.aluno.turma = event.target.value;
    }
}