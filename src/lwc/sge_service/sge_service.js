import readOpportunityLayout from '@salesforce/apex/SGE_GiftEntryService.readOpportunityLayout';
import getDataImportFieldMappings from '@salesforce/apex/SGE_GiftEntryService.getDataImportFieldMappings';

const getOpportunityLayout = () => {
    return new Promise((resolve, reject) => {
        readOpportunityLayout()
            .then(resolve)
            .catch(error => {
                console.error(JSON.stringify(error));
            });
    });
};

const getDataImportFields = () => {
    return new Promise((resolve, reject) => {
        getDataImportFieldMappings()
            .then(resolve)
            .catch(error => {
                console.error(JSON.stringify(error));
            });
    });
};

export { getOpportunityLayout, getDataImportFields }