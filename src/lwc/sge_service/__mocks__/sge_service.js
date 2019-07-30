
const SUCCESS = {
    "sObjectName":"Opportunity",
    "sections":[
        {
            "key":"1460808361",
            "label":"Test Section",
            "columns":[
                {
                    "key":"816643058",
                    "fields":[
                        {
                            "typeName":"STRING",
                            "required":true,
                            "name":"Test_Text_Field__c",
                            "label":"Test Text Field",
                            "helpText":null
                        },
                        {
                            "typeName":"PICKLIST",
                            "required":false,
                            "name":"Test_Picklist__c",
                            "label":"Test Picklist",
                            "helpText":null
                        },
                        {
                            "typeName":"REFERENCE",
                            "required":false,
                            "name":"Test_Lookup_Field__c",
                            "label":"Test Lookup Field",
                            "helpText":null
                        },
                        {
                            "typeName":"TEXTAREA",
                            "required":false,
                            "name":"Test_Rich_Text__c",
                            "label":"Test Rich Text",
                            "helpText":null
                        },
                        {
                            "typeName":"PHONE",
                            "required":false,
                            "name":"Test_Phone_Field__c",
                            "label":"Test Phone Field",
                            "helpText":null
                        }
                    ]
                },
                {
                    "key":"211909545",
                    "fields":[
                        {
                            "typeName":"DATE",
                            "required":false,
                            "name":"Test_Date_Field__c",
                            "label":"Test Date Field",
                            "helpText":null
                        },
                        {
                            "typeName":"TEXTAREA",
                            "required":false,
                            "name":"Test_Long_Text_Area__c",
                            "label":"Test Long Text Area",
                            "helpText":null
                        },
                        {
                            "typeName":"PERCENT",
                            "required":false,
                            "name":"Test_Percent_Field__c",
                            "label":"Test Percent Field",
                            "helpText":null
                        },
                        {
                            "typeName":"BOOLEAN",
                            "required":false,
                            "name":"Test_Checkbox_Field__c",
                            "label":"Test Checkbox Field",
                            "helpText":null
                        },
                        {
                            "typeName":"DOUBLE",
                            "required":false,
                            "name":"Test_Number_Field__c",
                            "label":"Test Number Field",
                            "helpText":null
                        }
                    ]
                }
            ]
        }
    ]
};

// resolve to success by default
export const getOpportunityLayout = jest.fn().mockResolvedValue(SUCCESS);