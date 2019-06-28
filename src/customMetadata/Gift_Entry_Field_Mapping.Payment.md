<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Payment</label>
    <protected>false</protected>
    <values>
        <field>Controlling_Field__c</field>
        <value xsi:type="xsd:string">npe01__Payment_Method__c</value>
    </values>
    <values>
        <field>Controlling_Object__c</field>
        <value xsi:type="xsd:string">npe01__OppPayment__c</value>
    </values>
    <values>
        <field>Dependent_Field_List__c</field>
        <value xsi:type="xsd:string">{
&quot;Cash&quot;: {
    &quot;npe01__OppPayment__c&quot;: [
      &quot;npe01__Payment_Date__c&quot;
    ]
  },
  &quot;Credit Card&quot;: {
    &quot;npe01__OppPayment__c&quot;: [
      &quot;npe01__Check_Reference_Number__c&quot;,
      &quot;npe01__Payment_Date__c&quot;
    ]
  },
&quot;Check&quot;: {
    &quot;npe01__OppPayment__c&quot;: [
      &quot;npe01__Check_Reference_Number__c&quot;,
      &quot;npe01__Payment_Date__c&quot;
    ]
  }
}</value>
    </values>
</CustomMetadata>
