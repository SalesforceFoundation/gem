import { createElement } from 'lwc';
import SGE_FormField from 'c/sge_formField';
import { getOpportunityLayout } from 'c/sge_service';

jest.mock('c/sge_service');

describe('c-sge_form-section', () => {

    it('should load', () => {
        const element = createElement('c-sge_form-section', { is: SGE_FormField });
        element.sobject = {};

        getOpportunityLayout().then(response => {
            element.section = response.sections[0];
            document.body.appendChild(element);

            const field = element.shadowRoot.querySelector('c-sge_form-field');
            expect(field).toBeDefined();
        });

    });

})