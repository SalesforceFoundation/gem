/**
 * Created by bdvorachek on 2019-06-11.
 */

import {LightningElement, api, track} from 'lwc';

export default class SGE_FormField extends LightningElement {
    @api field = {};

    get className() {
        return this.field.required ? 'fake-require' : '';
    }


    @api
    get isValid() {
        if(this.field.required) {
            return this.value !== null && typeof this.value !== 'undefined' && this.value !== '';
        }

        return true;
    }

    @api
    get value() {
        const field = this.template.querySelector("[data-type='field']");
        let data = {};
        data[field.name] = field.value;
        return data;
    }
}