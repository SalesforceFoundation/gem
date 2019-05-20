@isTest
public with sharing class DynamicFieldDisplayController_TEST {
    @isTest
    public static void testDynamicFieldDisplayController() {

        Test.startTest();
        DynamicFieldDisplayController.GiftEntryFieldMappingWrapper wrapper = DynamicFieldDisplayController.getCustomMetadataRecord('Payment');

        System.assert(wrapper.controllingObject == 'npe01__OppPayment__c', 'The actual controlling object is: ' + wrapper.controllingObject);
        System.assert(wrapper.controllingField == 'npe01__Payment_Method__c', 'The actual controlling field is: ' + wrapper.controllingField);
        System.assert(wrapper.dependentFieldList.size() == 3, 'The actual dependent field list size is: ' + wrapper.dependentFieldList.size());
        System.assert(wrapper.dependentFieldList.containsKey('Check'), 'The default does not contain Check');
        System.assert(wrapper.dependentFieldList.containsKey('Cash'), 'The default does not contain Check');
        System.assert(wrapper.dependentFieldList.containsKey('Credit Card'), 'The default does not contain Check');
        Test.stopTest();

    }

    public Gift_Entry_Field_Mapping__mdt getCustomMetadataRecordInstance() {
        Gift_Entry_Field_Mapping__mdt paymentRecord = new Gift_Entry_Field_Mapping__mdt();
        paymentRecord.DeveloperName = 'Payment';
        paymentRecord.Dependent_Field_List__c = getTestDependentFieldListString();
        paymentRecord.Controlling_Object__c = 'Payment';
        paymentRecord.Controlling_Field__c = 'Payment Method';

        return paymentRecord;


    }

    public String getTestDependentFieldListString() {
        Map<String, Map<String, List<String>>> dependentFieldListStructure = new Map<String, Map<String, List<String>>>();

        List<String> fieldList = new List<String>();
        fieldList.add('npe01__Payment_Amount__c');
        fieldList.add('npe01__Payment_Method__c');
        fieldList.add('npe01__Check_Reference_Number__c');
        fieldList.add('npe01__Paid__c');

        Map<String, List<String>> objectToFieldList = new Map<String, List<String>>();
        objectToFieldList.put('npe01__OppPayment__c', fieldList);

        dependentFieldListStructure.put('Check', objectToFieldList);

        String JSONDepedentFieldList = JSON.serialize(dependentFieldListStructure);

        return JSONDepedentFieldList;
    }
}
