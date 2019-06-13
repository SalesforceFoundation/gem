import { LightningElement, track, api } from 'lwc';
import { getOpportunityLayout, getDataImportFields } from 'c/sge_service';

export default class SGE_DynamicForm extends LightningElement {
    @track sections = [];
    @track activeSections;
    @track ready = false;
    fieldMappings = {};

    /**
     * Mark sections as active, alert parent component when data is present.
     */
    connectedCallback() {
        getOpportunityLayout().then(response => {
            if(response !== null && typeof response !== 'undefined' && Array.isArray(response.sections)) {
                this.sections = response.sections;
                this.activeSections = this.sections.map(s => s.label);
                this.ready = true;
                if (this.hasCustomFields()) {
                    this.dispatchEvent(new CustomEvent('load', {detail: {hasFields: true}}));
                }
            }
        });

        getDataImportFields().then(response => {
           this.fieldMappings = response;
        });
    }

    /**
     * @returns {*} Object where keys are field API names, and values are the value in the field.
     */
    @api
    get values() {
        const sections = this.template.querySelectorAll('c-sge_formsection');
        let oppData = {};
        if(sections !== null && typeof sections !== 'undefined') {
            sections.forEach(section => {
                oppData = {...oppData, ...section.values};
            });
        }

        const mappings = this.getFlippedMappings();
        let diData = {};

        for(let oppFieldName in oppData) {
            const diFieldName = mappings[oppFieldName];
            diData[diFieldName] = oppData[oppFieldName];
        }

        return diData;
    }

    @api
    get isValid() {
        const sections = this.template.querySelectorAll("c-sge_formsection");
        if(Array.isArray(sections)) {
            const isValid = sections.reduce((field, acc) => {
                return acc && field.isValid();
            }, true);

            return !this.hasCustomFields() || isValid;
        }

        return true;
    }

    getFlippedMappings() {
        let flippedMappings = {};
        Object.entries(this.fieldMappings).forEach(([k,v]) => {
            flippedMappings[v] = k;
        });
        return flippedMappings;
    }

    /**
     * TRUE when there is at least one field inside of any column or section
     * @returns {boolean}
     */
    hasCustomFields() {
        let layoutHasFields = false;
        if(this.ready) {
            this.sections.forEach(section => {
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