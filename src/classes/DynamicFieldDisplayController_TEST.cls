/*
    © 2019, Salesforce.org.
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.

    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.

    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.org
* @date 2019
* @group Gift Entry
* @group-content ../../ApexDocContent/GiftEntry.htm
* @description Tests specific to Dynamic Field Display and Gift Entry Field Mapping. 
*/
@isTest
public with sharing class DynamicFieldDisplayController_TEST {

    private final static String paymentLabel = 'Payment';

    @isTest
    public static void testDynamicFieldDisplayController() {

        List<String> checkFieldList = new List<String>{'npe01__Check_Reference_Number__c'};
        List<String> cashFieldList = new List<String>{'npe01__Payment_Amount__c', 
            'npe01__Paid__c',
            'bad_field',
            ''};
        List<String> creditFieldList = new List<String>{'npe01__Payment_Amount__c', 
            'npe01__Payment_Method__c',
            'npe01__Payment_Method__c',
            '',
            'npe01__Paid__c'};

        Map<String, List<String>> checkObjectToFieldList = new Map<String, List<String>>{
            'npe01__OppPayment__c' => checkFieldList
        };
        Map<String, List<String>> cashObjectToFieldList = new Map<String, List<String>>{
            'npe01__OppPayment__c' => cashFieldList
        };
        Map<String, List<String>> creditObjectToFieldList = new Map<String, List<String>>{
            'npe01__OppPayment__c' => creditFieldList
        };

        Map<String, Map<String, List<String>>> controlValueToObjectList = new Map<String, Map<String, List<String>>>();

        controlValueToObjectList.put('Check', checkObjectToFieldList);
        controlValueToObjectList.put('Cash', cashObjectToFieldList);
        controlValueToObjectList.put('Credit Card', creditObjectToFieldList);
        controlValueToObjectList.put('Test Bad Map', null);

        Gift_Entry_Field_Mapping__mdt fieldMappingRecord = getTestFieldMapRecordInstance(controlValueToObjectList);
        GiftEntryFieldMappingWrapper fieldMapWrapper;

        try {
            fieldMapWrapper = new GiftEntryFieldMappingWrapper(fieldMappingRecord);
            System.assert(false, 'Because of the Bad Map, the JSON parsing should fail');
        } catch(Exception e) {
            System.assert(true);
            System.assert(e.getMessage().contains(Label.Error_Gift_Field_Mapping), 
                'The exception did not match what was expected: ' + Label.Error_Gift_Field_Mapping);
            System.assert(e.getMessage().contains(paymentLabel), 'The exception did not include the record name: ' + paymentLabel);
        }

        controlValueToObjectList.remove('Test Bad Map');
        fieldMappingRecord = getTestFieldMapRecordInstance(controlValueToObjectList);
        
        fieldMapWrapper = new GiftEntryFieldMappingWrapper(fieldMappingRecord);
        
        Test.startTest();
        
        System.assert(fieldMapWrapper.controllingObject == 'npe01__OppPayment__c', 'The actual controlling object is: ' + fieldMapWrapper.controllingObject);
        System.assert(fieldMapWrapper.controllingField == 'npe01__Payment_Method__c', 'The actual controlling field is: ' + fieldMapWrapper.controllingField);
        System.assert(fieldMapWrapper.dependentFieldList.size() == 3, 'The actual dependent field list size is: ' + fieldMapWrapper.dependentFieldList.size());
        System.assert(fieldMapWrapper.dependentFieldList.containsKey('Check'), 'The default does not contain Check');
        System.assert(fieldMapWrapper.dependentFieldList.containsKey('Cash'), 'The default does not contain Cash');
        System.assert(fieldMapWrapper.dependentFieldList.containsKey('Credit Card'), 'The default does not contain Credit Card');
        
        // This should test that a properly setup JSON section is parsed correctly 
        Integer checkFieldSize = fieldMapWrapper.dependentFieldList.get('Check').get('npe01__OppPayment__c').size();
        System.assert(checkFieldSize == 1, 'The actual Check field size is: ' + checkFieldSize);    

        // This should test that a blank field and duplicate field get ignored
        Integer creditCardFieldSize = fieldMapWrapper.dependentFieldList.get('Credit Card').get('npe01__OppPayment__c').size();
        System.assert(creditCardFieldSize == 3, 'The actual Credit Card field size is: ' + creditCardFieldSize);
        
        // This should test that a blank field and a bad field both get ignored
        Integer cashFieldSize = fieldMapWrapper.dependentFieldList.get('Cash').get('npe01__OppPayment__c').size();
        System.assert(cashFieldSize == 2, 'The actual Cash field size is: ' + cashFieldSize);
        
        Test.stopTest();

    }

    public static Gift_Entry_Field_Mapping__mdt getTestFieldMapRecordInstance(
        Map<String, Map<String, List<String>>> controlValueToObjectList) {

        Gift_Entry_Field_Mapping__mdt fieldMappingRecord = new Gift_Entry_Field_Mapping__mdt();
        
        fieldMappingRecord.DeveloperName = paymentLabel;
        fieldMappingRecord.Controlling_Object__c = 'npe01__OppPayment__c';
        fieldMappingRecord.Controlling_Field__c = 'npe01__Payment_Method__c';
        fieldMappingRecord.Dependent_Field_List__c = JSON.serialize(controlValueToObjectList);

        return fieldMappingRecord;
    }

}
