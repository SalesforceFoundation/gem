import {LightningElement, api, wire} from 'lwc';
import readOpportunityLayout from '@salesforce/apex/SGE_GiftEntryService.readOpportunityLayout';

const getOpportunityLayout = () => {
    return new Promise((resolve, reject) => {
        readOpportunityLayout()
            .then(resolve)
            .catch(error => console.error(JSON.stringify(error)));
    });
}

export { getOpportunityLayout }