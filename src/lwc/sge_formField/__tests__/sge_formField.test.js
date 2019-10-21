import { createElement } from 'lwc';
import SGE_FormField from 'c/sge_formField';
import { getOpportunityLayout } from 'c/sge_service';

jest.mock('c/sge_service');

describe('c-sge_form-field', () => {

    afterEach(clearDOM);

    it('should load', () => {
        const element = createElement('c-sge_form-field', { is: SGE_FormField });
        element.sobject = {};
        document.body.appendChild(element);
    });

    it('should return a field object with a name and value', () => {
        const element = createElement('c-sge_form-field', { is: SGE_FormField });
        element.sobject = {};
        element.field = {
            'typeName': 'DOUBLE',
            'required': false,
            'name': 'Test_Number_Field__c',
            'label': 'Test Number Field',
            'helpText': null
        };

        document.body.appendChild(element);

        // set value on the lightning-input-field
        const field = element.shadowRoot.querySelector('lightning-input-field');
        field.value = 10.00;

        return flushPromises().then(() => {
            // check for updated value on the sge_form-field component
            const value = element.fieldObject;
            expect(value).toMatchSnapshot();
        });
    });

    it('should work when the value is undefined', () => {
        const element = createElement('c-sge_form-field', { is: SGE_FormField });
        element.sobject = {};
        element.field = {
            'typeName': 'DOUBLE',
            'required': false,
            'name': 'Test_Number_Field__c',
            'label': 'Test Number Field',
            'helpText': null
        };

        document.body.appendChild(element);

        return flushPromises().then(() => {
            // check for updated value on the sge_form-field component
            const value = element.fieldObject;
            expect(value.hasOwnProperty('Test_Number_Field__c'));
            expect(value['Test_Number_Field__c']).toBeNull();
        });
    });

    it('should fail', () => { expect(true).toBe(false); })
});