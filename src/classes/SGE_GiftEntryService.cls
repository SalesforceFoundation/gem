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
* @group
* @group-content
* @description This class handles the custom fields section of the Single Gift Entry form
**/
public with sharing class SGE_GiftEntryService {
    private static final String LAYOUT_NAME = 'SGE Custom Fields';
    private static final String HIDDEN_LAYOUT_SECTION_NAME = 'hidden - do not edit this section';
    /**
     * Read an opportunity layout for use in the SGE form
     *
     * @return  A SGE_GiftEntryService.Layout containing information about all writeable custom fields
     */
    @AuraEnabled(cacheable=true)
    public static SGE_GiftEntryService.Layout readOpportunityLayout() {
        return readOpportunityLayoutByName(LAYOUT_NAME);
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getDataImportFieldMappings() {
        List<String> dataImportFields = npsp.BDI_DataImportService.listStrDataImportFields;
        return npsp.BDI_DataImportService.mapFieldsForDIObject('Opportunity', 'Opportunity', dataImportFields);
    }

    /**
     * Read an opportunity layout for use in the SGE form
     *
     * @param layoutName    Name of the layout to read
     *
     * @return  A SGE_GiftEntryService.Layout containing information about all writeable custom fields in the specified layout
     */
    @TestVisible
    private static SGE_GiftEntryService.Layout readOpportunityLayoutByName(String layoutName) {
        List<String> layouts = new List<String>{'Opportunity-' + layoutName};
        Metadata.Metadata rawMetadata;

        try {
            rawMetadata = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, layouts)[0];
        } catch(Exception ex) {
            throw new AuraHandledException('No Opportunity layout named ' + layoutName + ' found');
        }
        Metadata.Layout layout = (Metadata.Layout)rawMetadata;

        SGE_GiftEntryService.Layout sgeLayout = new SGE_GiftEntryService.Layout(Schema.Opportunity.SObjectType, layout);

        return sgeLayout;
    }

    /**
     * Class representing a simple page layout
     */
    public class Layout {
        @AuraEnabled public List<Section> sections;
        @AuraEnabled public String sObjectName;

        public Layout(Schema.SObjectType sObjectType, Metadata.Layout layout) {
            this.sObjectName = sObjectType.getDescribe().getName();
            this.sections = new List<Section>();
            for(Metadata.LayoutSection section : layout.layoutSections) {
                if(section.editHeading && section.label.toLowerCase() != HIDDEN_LAYOUT_SECTION_NAME) {
                    this.sections.add(new Section(sObjectType, section));
                }
            }
        }
    }

    /**
     * Class representing a section within a page layout
     */
    public class Section extends HashKey {
        @AuraEnabled public String label;
        @AuraEnabled public List<Column> columns;

        public Section(Schema.SObjectType sObjectType, Metadata.LayoutSection section) {
            super(section);
            this.label = section.label;
            this.columns = new List<Column>();
            for(Metadata.LayoutColumn column : section.layoutColumns) {
                columns.add(new Column(sObjectType, column));
            }
        }
    }

    /**
     * Class representing a column within a page layout
     */
    public class Column extends HashKey {
        @AuraEnabled public List<Field> fields;

        public Column(Schema.SObjectType sObjectType, Metadata.LayoutColumn column) {
            super(column);
            this.fields = new List<Field>();
            if(column.layoutItems != null) {
                for (Metadata.LayoutItem item : column.layoutItems) {
                    if (isRenderable(item)) {
                        this.fields.add(new Field(sObjectType, item));
                    }
                }
            }
        }

        /**
         * Check to make sure this is input-able field. We don't want to render formula fields etc...
         *
         * @param item  Field to check
         *
         * @return      TRUE when field can receive input
         */
        private Boolean isRenderable(Metadata.LayoutItem item) {
            Boolean editable = item.behavior == Metadata.UiBehavior.Edit || item.behavior == Metadata.UiBehavior.Required;
            return editable && item.field != null;
        }
    }

    /**
     * Class representing a field on a page layout
     */
    public class Field {
        @AuraEnabled public String label;
        @AuraEnabled public String name;
        @AuraEnabled public String helpText;
        @AuraEnabled public Boolean required;
        @AuraEnabled public String typeName;

        public Field(Schema.SObjectType sObjectType, Metadata.LayoutItem item) {
            this(UTIL_Describe.getFieldDescribe(sObjectType.getDescribe().getName(), item.field));
            this.required = item.behavior == Metadata.UiBehavior.Required;
        }

        public Field(Schema.DescribeFieldResult describeFieldResult) {
            this.label = describeFieldResult.getLabel();
            this.name = describeFieldResult.getName();
            this.helpText = describeFieldResult.getInlineHelpText();
            this.typeName = describeFieldResult.getType().name();
        }
    }

    /**
     * Lightning web components require a key for individual members of a collection.
     * Normally that'd be the Id of the SObject or some other built-in unique identifier.
     * Since most of the metadata here doesn't have a unique Id, we generate one.
     */
    abstract class HashKey {
        @AuraEnabled public String key;
        public HashKey(Object anyObject) {
            this.key = String.valueOf(System.hashCode(anyObject));
        }

        public HashKey() {}
    }
}