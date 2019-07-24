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
    @api sobject;
    @api disableinputs;
    @api field = {};
    @track value;

    connectedCallback() {
        this.value = this.sobject[this.field.name];
    }

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

    @api
    get fieldObject() {
        const field = this.getRawField();
        let data = {};
        data[this.field.name] = field.value;
        return data;
    }

    getRawField() {
        return this.template.querySelector('lightning-input-field');
    }
}