
public with sharing class Glue {

    //Copies NPSP's TDTM records to HEDA's TDTM object, and deactivates those in NPSP.
    public void tdtmTransfer() {
        //Get NPSP's TDTM records
        List<npsp__Trigger_Handler__c> npspHandlers = [
                    select
                        npsp__Active__c,
                        npsp__Asynchronous__c,
                        npsp__Class__c,
                        npsp__Load_Order__c,
                        npsp__Object__c,
                        npsp__Trigger_Action__c,
                        npsp__User_Managed__c,
                        npsp__Usernames_to_Exclude__c
                    from npsp__Trigger_Handler__c
                    limit 50000];


        List<hed__Trigger_Handler__c> newHedaHandlers = new List<hed__Trigger_Handler__c>();
        for(npsp__Trigger_Handler__c npspHandler : npspHandlers) {

            //Copy NPSP's TDTM records to HEDA's Trigger Handler table
            newHedaHandlers.add(
                    new hed__Trigger_Handler__c(
                    hed__Active__c = npspHandler.npsp__Active__c,
                    hed__Asynchronous__c = npspHandler.npsp__Asynchronous__c,
                    hed__Class__c = npspHandler.npsp__Class__c,
                    hed__Load_Order__c = npspHandler.npsp__Load_Order__c,
                    hed__Object__c = npspHandler.npsp__Object__c,
                    hed__Owned_by_Namespace__c = 'npsp',
                    hed__Trigger_Action__c = npspHandler.npsp__Trigger_Action__c,
                    hed__User_Managed__c = npspHandler.npsp__User_Managed__c
                    //@TODO: this field and its relate logic needs to be added to HEDA.
                    //, hed__Usernames_to_Exclude__c = npspHandler.npsp__Usernames_to_Exclude__c
            ));

            //Deactivate NPSP's TDTM records in NPSP's Trigger Handler table
            npspHandler.npsp__Active__c = false;
        }

        insert newHedaHandlers;
        update npspHandlers;
    }

    //Turns off those handlers that are not needed because we are using the equivalent ones from the other package.
    public void tdtmDeduplicate() {
        List<hed__Trigger_Handler__c> hedaDups = [
                select
                        hed__Active__c
                from hed__Trigger_Handler__c
                where hed__Class__c in (
                        //Deactivate NPSP handlers
                        'ACCT_IndividualAccounts_TDTM',
                        'ADDR_Account_TDTM',
                        'ADDR_Addresses_TDTM',
                        'ADDR_Contact_TDTM',
                        'ADDR_Validator_TDTM',
                        'AFFL_Affiliations_TDTM',
                        'AFFL_Affiliations_TDTM',
                        'AFFL_Affiliations_TDTM',
                        'REL_Relationships_Con_TDTM',
                        'REL_Relationships_TDTM'
                        //Deactivate HEDA handlers?
                )
                and hed__Object__c in (
                        'Contact',
                        'Account',
                        'Address__c',
                        'Contact',
                        'Address__c',
                        'Account',
                        'Contact',
                        'npe5__Affiliation__c',
                        'Contact',
                        'npe4__Relationship__c'
                )
                and hed__Owned_by_Namespace__c in (
                        'npsp',
                        'npsp',
                        'npsp',
                        'npsp',
                        'npsp',
                        'npsp',
                        'npsp',
                        'npsp',
                        'npsp',
                        'npsp'
                )
        ];

        for(hed__Trigger_Handler__c dupe : hedaDups) {
            dupe.hed__Active__c = false;
        }
        update hedaDups;
    }

}