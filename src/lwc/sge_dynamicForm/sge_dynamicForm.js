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
 * @description This is the top-level component for the dynamic fields portion of the Single Gift Entry form
 **/
import { LightningElement, track, api } from 'lwc';
import { getOpportunityLayout } from 'c/sge_service';

export default class SGE_DynamicForm extends LightningElement {
    @api sobject = {};
    @api disableinputs = false;
    @track sections = [];
    @track ready = false;

    /**
     * Mark sections as active, alert parent component when custom fields are present.
     */
    connectedCallback() {
        getOpportunityLayout().then(response => {
            if(response !== null && typeof response !== 'undefined' && Array.isArray(response.sections)) {
                this.sections = response.sections;
                this.ready = true;
                if (this.hasCustomFields()) {
                    this.dispatchEvent(new CustomEvent('load', {detail: {hasFields: true}}));
                }
            }
        });
    }

    /**
     * Get the field names and values from the dynamic fields section.
     *
     * @returns {*} Object where keys are Opportunity field API names, and values are the value in the field.
     */
    @api
    get values() {
        const sections = this.template.querySelectorAll('c-sge_form-section');
        let oppData = {};
        if(sections !== null && typeof sections !== 'undefined') {
            sections.forEach(section => {
                oppData = { ...oppData, ...(section.values) };
            });
        }

        return oppData;
    }

    @api
    loadRecordValues() {
        this.resetInputs(true);
        return true;
    }

    @api
    rerenderInputs() {
        this.resetInputs(false);
        return true;
    }

    resetInputs(loadingValues){
        const sections = this.template.querySelectorAll("c-sge_form-section");
        if(sections !== null && typeof sections !== 'undefined') {
            sections.forEach(section => {
                section.resetAllInputs(loadingValues);
            });
        }
    }

    /**
     * Check for fields that are required but not filled in.
     *
     * @returns {Array} List of fields that are required but not filled in.
     */
    @api
    get invalidFields() {
        const sections = this.template.querySelectorAll("c-sge_form-section");
        let invalidFields = [];
        sections.forEach(section => {
            const fields = section.getInvalidFields();
            invalidFields.push(...fields);
        });

        return invalidFields;
    }

    /**
     * Check if there are custom fields present in the Single Gift Entry Customization layout
     *
     * @returns {boolean} TRUE when there is at least one field inside of any column or section
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