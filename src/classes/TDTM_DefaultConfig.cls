
public with sharing class TDTM_DefaultConfig {

    public List<hed.TDTM_Global_API.TdtmToken> getDefaultTdtmConfigTokens() {
        List<hed.TDTM_Global_API.TdtmToken> tokens = new List<hed.TDTM_Global_API.TdtmToken>();
        //this.populateTokensList(tokens);
        return tokens;
    }

    public List<npsp__Trigger_Handler__c> getDefaultTdtmConfigRecords() {
        return this.tokensToRecords(this.getDefaultTdtmConfigTokens());
    }

    private List<npsp__Trigger_Handler__c> tokensToRecords(List<hed.TDTM_Global_API.TdtmToken> tokens) {
        List<npsp__Trigger_Handler__c> records = new List<npsp__Trigger_Handler__c>();
        for (hed.TDTM_Global_API.TdtmToken token : tokens) {
            records.add(
                    new npsp__Trigger_Handler__c(
                            npsp__Active__c = token.active,
                            npsp__Asynchronous__c = token.async,
                            npsp__Class__c = token.className,
                            npsp__Load_Order__c = token.loadOrderDec,
                            npsp__Object__c = token.targetObject,
                            //@TODO: field hed__Owned_by_Namespace__c and its related logic needs to be added to NPSP.
                            npsp__Trigger_Action__c = token.actions,
                            npsp__User_Managed__c = token.userManaged
                            //@TODO: field npsp__Usernames_to_Exclude__c and its related logic needs to be added to HEDA.
                    ));
        }
        return records;
    }

    private List<hed.TDTM_Global_API.TdtmToken> recordsToTokens(List<npsp__Trigger_Handler__c> records) {
        List<hed.TDTM_Global_API.TdtmToken> tokens = new List<hed.TDTM_Global_API.TdtmToken>();
        for (npsp__Trigger_Handler__c record : records) {
            tokens.add(
                    new hed.TDTM_Global_API.TdtmToken(
                            record.npsp__Class__c,
                            record.npsp__Object__c,
                            record.npsp__Trigger_Action__c,
                            record.npsp__Load_Order__c,
                            record.npsp__Active__c,
                            record.npsp__Asynchronous__c,
                            '', //@TODO: field hed__Filter_Field__c and its related logic needs to be added to NPSP.
                            '', //@TODO: field hed__Filter_Value__c and its related logic needs to be added to NPSP.
                            record.npsp__User_Managed__c,
                            'npsp' //@TODO: field hed__Owned_by_Namespace__c and its related logic needs to be added to NPSP.
                            //@TODO: field npsp__Usernames_to_Exclude__c and its related logic needs to be added to HEDA.
                    ));
        }
        return tokens;
    }

    //Sets the Default TDTM configuration. @TODO: Should we store it here in code, or get it from Glue class?
    //--> I think we should get the default one from NPSP, the default one from HEDA and merge them together!
    /*private void populateTokensList(List<hed.TDTM_Global_API.TdtmToken> tokens) {
        tokens.add(new hed.TDTM_Global_API.TdtmToken(
                className = ,
                targetObject,
                actions,
                loadOrder,
                active,
                async,
                filterField,
                filterValue,
                userManaged,
                ownedByNamespace
        ));
    }*/
}