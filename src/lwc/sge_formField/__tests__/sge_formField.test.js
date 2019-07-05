import { createElement } from 'lwc';
import SGE_FormField from 'c/sge_formField';
import { getOpportunityLayout } from 'c/sge_service';

jest.mock('c/sge_service');

describe('c-sge_form-field', () => {

    afterEach(clearDOM);

    it('should load', () => {
        const element = createElement('c-sge_form-field', { is: SGE_FormField });

        document.body.appendChild(element);
    });
});