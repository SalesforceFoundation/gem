import { createElement } from 'lwc';
import DynamicForm from 'c/sge_dynamicform';

describe('c-dynamicform', () => {
   it('should load', () => {
       const element = createElement('c-sge-dynamicform', { is: DynamicForm });
       document.body.appendChild(element);
       const div = element.shadowRoot.querySelector('lightning-accordion');
       console.log(document.body);
   });
});