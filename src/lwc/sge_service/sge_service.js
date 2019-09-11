import readOpportunityLayout from '@salesforce/apex/SGE_GiftEntryService.readOpportunityLayout';
import readAllocationSettings from '@salesforce/apex/SGE_GiftEntryService.readAllocationSettings';

const getOpportunityLayout = () => {
    return new Promise((resolve, reject) => {
        readOpportunityLayout()
            .then((result) => {
                resolve(result);
            })
            .catch(error => {
                console.error(JSON.stringify(error));
            });
    });
};

const getAllocationSettings = () => {
    return new Promise((resolve, reject) => {
       readAllocationSettings()
           .then(resolve)
           .catch(error => {
               console.error(JSON.stringify(error));
           });
    });
};

export { getOpportunityLayout, getAllocationSettings }