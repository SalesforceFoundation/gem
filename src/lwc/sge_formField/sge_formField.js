/**
 * Created by bdvorachek on 2019-06-11.
 */

import {LightningElement, api} from 'lwc';

export default class SGE_FormField extends LightningElement {
    @api field = {};

    get labelClassName() {
        return this.field.required ? 'show-required slds-form-element__label' : 'slds-form-element__label';
    }


    @api
    isValid() {
        if(this.field.required) {
            return this.value !== null && typeof this.value !== 'undefined' && this.value !== '';
        }

        return true;
    }

    @api
    get fieldObject() {
        const field = this.getRawField();
        let data = {};
        data[field.fieldName] = field.value;
        return data;
    }

    get value() {
        const field = this.getRawField();
        return field.value;
    }

    getRawField() {
        return this.template.querySelector('lightning-input-field');
    }
}