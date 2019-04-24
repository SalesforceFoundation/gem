import {LightningElement, track} from 'lwc';
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

    get ready() {
        return this.layout !== null && typeof this.layout !== 'undefined';
    }

}