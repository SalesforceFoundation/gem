import { LightningElement, track, api } from 'lwc';
import { getOpportunityLayout, getDataImportFields } from 'c/sge_service';

export default class SGE_DynamicForm extends LightningElement {
    @track layout = {};
    @track activeSections;
    @track ready = false;
    fieldMappings;

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

        getDataImportFields().then(response => {
           this.fieldMappings = response;
           console.log(JSON.stringify(this.fieldMappings));
        });
    }

    /**
     * @returns {*} Object where keys are field API names, and values are the value in the field.
     */
    @api
    get values() {
        const sections = this.template.querySelectorAll('c-sge_formsection');
        let data = {};
        if(sections !== null && typeof sections !== 'undefined') {
            sections.forEach(section => {
                data = {...data, ...section.values};
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