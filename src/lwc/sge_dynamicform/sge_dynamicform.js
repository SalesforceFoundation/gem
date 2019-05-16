import { LightningElement, track, api } from 'lwc';
import { getOpportunityLayout } from 'c/layoutService';

export default class SGE_DynamicForm extends LightningElement {
    @track layout;
    @track activeSections;
    @track ready = false;

    /**
     * Mark sections as active, alert parent component when data is present.
     */
    connectedCallback() {
        getOpportunityLayout().then(response => {
            this.layout = response;
            if(this.layout !== null && typeof this.layout !== 'undefined' && Array.isArray(this.layout.sections)) {
                this.activeSections = this.layout.sections.map(s => s.label);
                this.ready = true;
                if (this.hasCustomFields()) {
                    this.dispatchEvent(new CustomEvent('load', {detail: {hasFields: true}}));
                }
            }
        });
    }

    /**
     * @returns {*} Object where keys are field API names, and values are the value in the field.
     */
    @api
    get values() {
        const fields = this.template.querySelectorAll("[data-type='field']");
        let data = {};
        if(fields !== null && typeof fields !== 'undefined') {
            fields.forEach(field => {
                data[field.fieldName] = field.value;
            });
        }
        return data;
    }

    /**
     * TRUE when there is at least one field inside of any column or section
     * @returns {boolean}
     */
    hasCustomFields() {
        let layoutHasFields = false;
        if(this.ready) {
            this.layout.sections.forEach(section => {
               const columns = section.columns;
               if(Array.isArray(columns)) {
                   columns.forEach(column => {
                       if(Array.isArray(column.fields) && column.fields.length > 0) {
                           layoutHasFields = true;
                       }
                   });
               }
            });
        }
        return layoutHasFields;
    }

}