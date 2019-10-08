/*
    © 2019, Salesforce.org.
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.

    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.

    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
 * @author Salesforce.org
 * @date 2019
 * @group
 * @group-content
 * @description This component represents a single field within the custom fields layout for Single Gift Entry
 **/
import {LightningElement, api, track} from 'lwc';

export default class SGE_FormField extends LightningElement {
    @api
    get sobject(){
        return this._sobject;
    }
    set sobject(value){
        this.setAttribute('sobject', value);
        this._sobject = value;
        this.value = this.sobject[this.field.name];
    }
    @api disableInputs;
    @api field = {};
    @track value;
    @track renderInput = true;

    /**
     * Load the default field value into the actual value attribute
     */
    connectedCallback() {
        this.setDefaultVal();
    }

    /**
     * Class name for indicating when a given field is required.
     * @returns {string}
     */
    get labelClassName() {
        return this.field.required ? 'show-required slds-form-element__label' : 'slds-form-element__label';
    }

    /**
     * TRUE when a field is required and filled in, or not required at all.
     * @returns {boolean}
     */
    @api
    isValid() {
        if(this.field.required) {
            return this.value !== null && typeof this.value !== 'undefined' && this.value !== '';
        }

        return true;
    }

    /**
     * @returns {object} Object with a single key/value pair where the key is the field name
     */
    @api
    get fieldObject() {
        const field = this.getRawField();
        let data = {};
        data[this.field.name] = field.value;
        return data;
    }

    @api
    resetToDefault(loadingValues) {
        this.renderInput = false;
        setTimeout(() => {
            this.renderInput = true;
            if(loadingValues){
                this.loadValueFromObject();
            } else {
                this.setDefaultVal();
            }
        });
    }

    loadValueFromObject() {
        let fieldVal = this.sobject[this.field.name];
        // If the picklist value is blank, we need to change what the field gets set to
        if(this.field.typeName === 'PICKLIST' && !fieldVal){
            fieldVal = '';
        }
        this.value = fieldVal;
    }

    setDefaultVal() {
        let defaultVal = null;
        if(this.field.typeName === 'PICKLIST'){
            defaultVal = '';
        }
        if(this.field.hasOwnProperty('defaultValue')){
            defaultVal = this.field.defaultValue;
        } else if(this.field.hasOwnProperty('defaultValueFormula')){
            defaultVal = this.field.defaultValueFormula;
        }
        this.value = defaultVal;
    }

    get value() {
        const field = this.getRawField();
        return field.value;
    }

    getRawField() {
        return this.template.querySelector('lightning-input-field');
    }
}