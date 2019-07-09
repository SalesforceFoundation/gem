import { createElement } from 'lwc';
import SGE_DynamicForm from 'c/sge_dynamicForm';
import { getOpportunityLayout } from 'c/sge_service';

jest.mock('c/sge_service');


describe('c-sge_dynamic-form', () => {

    afterEach(clearDOM);

    it('should load', () => {
        const element = createElement('c-sge_dynamic-form', { is: SGE_DynamicForm });
        element.sobject = {};
        document.body.appendChild(element);
        const accordion = element.shadowRoot.querySelector('lightning-accordion');
        expect(accordion).toBeDefined();
    });

    it('should be empty until ready', () => {
        getOpportunityLayout.mockImplementationOnce(() => new Promise(() => {}));

        const element = createElement('c-sge_dynamicform', { is: SGE_DynamicForm });
        document.body.appendChild(element);

        return flushPromises().then(() => {
            const fields = element.shadowRoot.querySelectorAll("[data-type='field']");
            expect(fields.length).toBe(0);
        });
    });

    it('should load with mock response', () => {
        const element = createElement('c-sge_dynamic-form', { is: SGE_DynamicForm });
        document.body.appendChild(element);
        return flushPromises().then(() => {
            const div = element.shadowRoot.querySelector('c-sge_form-section');
            expect(div.childNodes.length).toBe(0);
            expect(getOpportunityLayout).toHaveBeenCalledTimes(1);
        })
    });

});