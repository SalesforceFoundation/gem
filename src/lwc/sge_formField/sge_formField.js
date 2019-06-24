/**
 * Created by bdvorachek on 2019-06-11.
 */

import {LightningElement, api} from 'lwc';

export default class SGE_FormField extends LightningElement {
    @api sobject;
    @api disableinputs;
    @api field = {};

    get labelClassName() {
        return this.field.required ? 'show-required slds-form-element__label' : 'slds-form-element__label';
    }

    @api
    get fieldValue() {
        return this.sobject[this.field.name];
    }

    handleValueChange(event){
        let inputValue = event.target.value;
        let sobjectClone = JSON.parse(JSON.stringify(this.sobject));
        sobjectClone[this.field.name] = inputValue;
        this.sobject = {...sobjectClone};
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
        data[this.field.name] = field.value;
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