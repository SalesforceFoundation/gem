import {LightningElement, api, track} from 'lwc';

export default class SGE_Formsection extends LightningElement {
    @api section;
    @track expanded = true;

    /**
     * @returns {*} Object where keys are field API names, and values are the value in the field.
     */
    @api
    get values() {
        const fields = this.template.querySelectorAll("c-sge_form-field");
        let oppData = {};
        if(fields !== null && typeof fields !== 'undefined') {
            fields.forEach(field => {
                oppData = { ...oppData, ...(field.value) };
            });
        }
        return oppData;
    }

    @api
    get isValid() {
        const fields = this.template.querySelectorAll("c-sge_form-field");
        const isValid = fields.reduce((field, acc) => {
            return acc && field.isValid();
        }, true);

        return isValid;
    }

    get iconName() {
        return this.expanded ? 'utility:chevrondown' : 'utility:chevronright';
    }

    toggleExpand(event) {
        event.preventDefault();
        this.expanded = !this.expanded;
    }

    /**
     * TRUE when there is at least one field inside of any column or section
     * @returns {boolean}
     */
    hasCustomFields() {
        let layoutHasFields = false;
        const columns = section.columns;
        if (Array.isArray(columns)) {
            columns.forEach(column => {
                if (Array.isArray(column.fields) && column.fields.length > 0) {
                    layoutHasFields = true;
                }
            });
        }
    }
}