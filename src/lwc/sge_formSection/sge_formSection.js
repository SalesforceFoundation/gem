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
    'AS IS' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
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
 * @description This component represents a single section within the custom fields layout for Single Gift Entry
 **/
import {LightningElement, api, track} from 'lwc';

export default class SGE_FormSection extends LightningElement {
    @api section;
    @api sobject;
    @api disableinputs;
    @track expanded = true;

    /**
     * @returns {*} Object where keys are field API names, and values are the value in the field.
     */
    @api
    get values() {
        const fields = this.template.querySelectorAll('c-sge_form-field');
        let oppData = {};
        if(fields !== null && typeof fields !== 'undefined') {
            fields.forEach(field => {
                oppData = { ...oppData, ...(field.fieldObject) };
            });
        }
        return oppData;
    }

    /**
     * Get a list of fields that are required, but are null/undefined or otherwise blank in the dynamic form
     * @returns {Array} of invalid fields. If all fields are ok, the array is empty.
     */
    @api
    getInvalidFields() {
        const fields = this.template.querySelectorAll('c-sge_form-field');
        let invalidFields = [];

        fields.forEach(f => {
            if(!f.isValid()) {
                invalidFields.push(f);
            }
        });

        return invalidFields;
    }

    /**
     * Get the icon that should display next to the twistable section header
     * @returns {string} containing the icon name from SLDS
     */
    get iconName() {
        return this.expanded ? 'utility:chevrondown' : 'utility:chevronright';
    }

    /**
     * Get the css classname for the body of the twistable section, show/hide when closed/open
     * @returns {string} 'slds-hidden' when the section is closed
     */
    get sectionClassName() {
        return this.expanded ? '' : 'slds-hidden';
    }

    /**
     * When twistable section header is clicked, collapse/expand it
     * @param event
     */
    toggleExpand(event) {
        event.preventDefault();
        this.expanded = !this.expanded;
    }
}