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
* @group Settings
* @group-content ../../ApexDocContent/Settings.htm
* @description Test class for Custom Fields section of Single Gift Entry form
*/
@isTest
private class SGE_GiftEntryService_TEST {
    static final String mockLayoutJSON = '{"fullName":"Opportunity-SGE Custom Fields","summaryLayout":{"summaryLayoutStyle":"Default_x","summaryLayoutItems":null,"sizeZ":null,"sizeY":0,"sizeX":4,"masterLabel":"00h1D000000r0El"},"showSubmitAndAttachButton":false,"showSolutionSection":null,"showRunAssignmentRulesCheckbox":false,"showKnowledgeComponent":null,"showInteractionLogPanel":false,"showHighlightsPanel":false,"showEmailCheckbox":false,"runAssignmentRulesDefault":null,"relatedObjects":["AccountId"],"relatedLists":null,"relatedContent":null,"quickActionList":null,"platformActionList":{"fullName":null,"relatedSourceEntity":null,"platformActionListItems":[{"subtype":null,"sortOrder":0,"actionType":"StandardButton","actionName":"Edit"},{"subtype":null,"sortOrder":10,"actionType":"CustomButton","actionName":"npsp__Manage_Soft_Credits"},{"subtype":null,"sortOrder":1,"actionType":"QuickAction","actionName":"npsp__NewContact"},{"subtype":null,"sortOrder":2,"actionType":"QuickAction","actionName":"New_Household_Account"},{"subtype":null,"sortOrder":3,"actionType":"QuickAction","actionName":"npsp__New_Campaign"},{"subtype":null,"sortOrder":4,"actionType":"StandardButton","actionName":"Delete"},{"subtype":null,"sortOrder":5,"actionType":"StandardButton","actionName":"Clone"},{"subtype":null,"sortOrder":6,"actionType":"StandardButton","actionName":"ChangeOwnerOne"},{"subtype":null,"sortOrder":7,"actionType":"StandardButton","actionName":"ChangeRecordType"},{"subtype":null,"sortOrder":8,"actionType":"StandardButton","actionName":"PrintableView"},{"subtype":null,"sortOrder":9,"actionType":"CustomButton","actionName":"npsp__Email_Acknowledgment"}],"actionListContext":"Record"},"multilineLayoutFields":null,"miniLayout":null,"layoutSections":[{"style":"TwoColumnsLeftToRight","layoutColumns":[{"reserved":null,"layoutItems":[{"width":null,"showScrollbars":null,"showLabel":null,"scontrol":null,"reportChartComponent":null,"page_x":null,"height":null,"field":"Name","emptySpace":null,"customLink":null,"component":null,"canvas":null,"behavior":"Required","analyticsCloudComponent":null},{"width":null,"showScrollbars":null,"showLabel":null,"scontrol":null,"reportChartComponent":null,"page_x":null,"height":null,"field":"AccountId","emptySpace":null,"customLink":null,"component":null,"canvas":null,"behavior":"Required","analyticsCloudComponent":null},{"width":null,"showScrollbars":null,"showLabel":null,"scontrol":null,"reportChartComponent":null,"page_x":null,"height":null,"field":"CloseDate","emptySpace":null,"customLink":null,"component":null,"canvas":null,"behavior":"Required","analyticsCloudComponent":null}]},{"reserved":null,"layoutItems":[{"width":null,"showScrollbars":null,"showLabel":null,"scontrol":null,"reportChartComponent":null,"page_x":null,"height":null,"field":"StageName","emptySpace":null,"customLink":null,"component":null,"canvas":null,"behavior":"Required","analyticsCloudComponent":null},{"width":null,"showScrollbars":null,"showLabel":null,"scontrol":null,"reportChartComponent":null,"page_x":null,"height":null,"field":"Probability","emptySpace":null,"customLink":null,"component":null,"canvas":null,"behavior":"Edit","analyticsCloudComponent":null}]}],"label":"hidden - do not edit this section","editHeading":true,"detailHeading":true,"customLabel":true},{"style":"TwoColumnsLeftToRight","layoutColumns":[{"reserved":null,"layoutItems":[{"width":null,"showScrollbars":null,"showLabel":null,"scontrol":null,"reportChartComponent":null,"page_x":null,"height":null,"field":"npsp__Ask_Date__c","emptySpace":null,"customLink":null,"component":null,"canvas":null,"behavior":"Edit","analyticsCloudComponent":null},{"width":null,"showScrollbars":null,"showLabel":null,"scontrol":null,"reportChartComponent":null,"page_x":null,"height":null,"field":"npsp__In_Kind_Type__c","emptySpace":null,"customLink":null,"component":null,"canvas":null,"behavior":"Edit","analyticsCloudComponent":null}]},{"reserved":null,"layoutItems":[{"width":null,"showScrollbars":null,"showLabel":null,"scontrol":null,"reportChartComponent":null,"page_x":null,"height":null,"field":"npsp__Fair_Market_Value__c","emptySpace":null,"customLink":null,"component":null,"canvas":null,"behavior":"Edit","analyticsCloudComponent":null}]}],"label":"Some Section","editHeading":true,"detailHeading":true,"customLabel":true},{"style":"CustomLinks","layoutColumns":[{"reserved":null,"layoutItems":null},{"reserved":null,"layoutItems":null},{"reserved":null,"layoutItems":null}],"label":"Custom Links","editHeading":false,"detailHeading":false,"customLabel":false}],"headers":null,"feedLayout":null,"excludeButtons":["Submit"],"emailDefault":null,"customConsoleComponents":null,"customButtons":["npsp__Email_Acknowledgment","npsp__Manage_Soft_Credits"]}';
    /**
     * Test retrieving a layout. Content of the layout will be empty in an unmodified org.
     */
    @isTest
    static void testRetrieveLayout() {
        SGE_GiftEntryService.Layout layout = SGE_GiftEntryService.readOpportunityLayout();
        System.assertEquals('Opportunity', layout.sObjectName, 'Got wrong sObject type');
        System.assertNotEquals(null, layout.sections, 'Expected an empty array of sections');
    }

    @isTest
    static void testConstructLayout() {
        Metadata.Layout mLayout = (Metadata.Layout)JSON.deserialize(mockLayoutJSON, Metadata.Layout.class);
        SGE_GiftEntryService.Layout layout = new SGE_GiftEntryService.Layout(Schema.Opportunity.SObjectType, mLayout);

        System.assertEquals(1, layout.sections.size(), 'Incorrect number of sections found');
        System.assertEquals('Some Section', layout.sections[0].label, 'Got wrong section label');
        System.assertEquals('npsp__Ask_Date__c', layout.sections[0].columns[0].fields[0].name, 'Field not found or wrong order');
        System.assertNotEquals(null, layout.sections[0].key, 'Expected first section to have a key');
        System.assertNotEquals(null, layout.sections[0].columns[0].key = 'Expected column to have a key');
    }


    @isTest
    static void testThrowsWhenNotFound() {
        Boolean exceptionCaught = false;
        try {
            SGE_GiftEntryService.Layout layout = SGE_GiftEntryService.readOpportunityLayoutByName('An Invalid Layout');
        } catch(AuraHandledException ex) {
            exceptionCaught = true;
        }

        System.assertEquals(true, exceptionCaught, 'Expected to tach an exception');
    }
}