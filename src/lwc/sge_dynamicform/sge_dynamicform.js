import {LightningElement, track, api} from 'lwc';
import {getOpportunityLayout} from 'c/layoutService';

export default class SGE_DynamicForm extends LightningElement {
    @track layout;
    @track activeSections;

    connectedCallback() {
        getOpportunityLayout().then(response => {
            this.layout = response;
            this.activeSections = this.layout.sections.map(s => s.label);
        });
    }

    @api
    get values() {
        const fields = this.template.querySelectorAll("[data-type='field']");
        let data = {};
        if(fields !== null && typeof fields !== 'undefined') {
            fields.forEach(field => {
                data[field.fieldName] = field.value;
                console.log(JSON.parse(JSON.stringify(field)));
            });
        }
        return data;
    }

    handleClick(event) {
        const fields = this.template.querySelectorAll("[data-type='field']");
        let data = {};
        if(fields !== null && typeof fields !== 'undefined') {
            fields.forEach(field => {
                data[field.fieldName] = field.value;
                console.log(JSON.parse(JSON.stringify(field)));
            });
        }
        console.log(JSON.parse(JSON.stringify(fields)));
        console.log(JSON.parse(JSON.stringify(data)));
    }

    get ready() {
        return this.layout !== null && typeof this.layout !== 'undefined';
    }

}