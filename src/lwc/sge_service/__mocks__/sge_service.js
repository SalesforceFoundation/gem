
const SUCCESS = {
    "sObjectName": "Opportunity",
    "sections": [{
        "key": "1798336604",
        "label": "Some Section",
        "columns": [{
            "key": "596148284",
            "fields": [{
                "name": "npsp__Ask_Date__c",
                "label": "Ask Date",
                "helpText": "The date the donor was asked for this Donation. This may be different from the date you received it."
            }, {
                "name": "npsp__In_Kind_Type__c",
                "label": "In-Kind Type",
                "helpText": "The type of In-Kind Gift, for example, Goods or Services."
            }]
        }, {
            "key": "780860961",
            "fields": [{
                "name": "npsp__Fair_Market_Value__c",
                "label": "Fair Market Value",
                "helpText": "The Fair Market Value of an In-Kind gift."
            }]
        }]
    }]
};

// resolve to success by default
export const getOpportunityLayout = jest.fn().mockResolvedValue(SUCCESS);
