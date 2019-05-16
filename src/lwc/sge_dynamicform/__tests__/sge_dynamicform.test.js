import { createElement } from 'lwc';
import DynamicForm from 'c/sge_dynamicform';
import { getOpportunityLayout } from 'c/layoutService';

jest.mock('c/layoutService');


describe('c-dynamicform', () => {

    function flushPromises() {
        return new Promise(resolve => setImmediate(resolve));
    }

    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('should load', () => {
        const element = createElement('c-sge-dynamicform', { is: DynamicForm });
        document.body.appendChild(element);
        const accordion = element.shadowRoot.querySelector('lightning-accordion');
        expect(accordion).toBeDefined();
    });

    it('should be empty until ready', () => {
        getOpportunityLayout.mockImplementationOnce(() => new Promise(() => {}));

        const element = createElement('c-sge-dynamicform', { is: DynamicForm });
        document.body.appendChild(element);

        return flushPromises().then(() => {
            const fields = element.shadowRoot.querySelectorAll("[data-type='field']");
            expect(fields.length).toBe(0);
        });
    });

    it('should load with mock response', () => {
        const element = createElement('c-sge-dynamicform', { is: DynamicForm });
        document.body.appendChild(element);
        const div = element.shadowRoot.querySelector('lightning-accordion');
        expect(div.childNodes.length).toBe(0);
        expect(getOpportunityLayout).toHaveBeenCalledTimes(1);
    });

    describe('getValues', () => {
        it('should work when values are present', () => {
            const element = createElement('c-sge-dynamicform', { is: DynamicForm });
            document.body.appendChild(element);

            return flushPromises().then(() => {
                const fairMarketValue = element.shadowRoot.querySelector("lightning-input-field[data-id='npsp__Fair_Market_Value__c']");
                fairMarketValue.value = 10.00;


                return flushPromises().then(() => {
                   const { values } =  element;
                   console.log(values);

                   expect(values.npsp__Fair_Market_Value__c).toBe(10.00);
                });
            });
        });

        it('should work when values are blank or empty', () => {
            const element = createElement('c-sge-dynamicform', { is: DynamicForm });
            document.body.appendChild(element);

            return flushPromises().then(() => {
                const fields = element.shadowRoot.querySelectorAll("[data-type='field']");
                expect(fields.length).toBe(3);
                const { values } = element;
                expect(values).toMatchSnapshot();
            });
        });
    });
});