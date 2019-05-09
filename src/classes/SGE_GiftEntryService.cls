public with sharing class SGE_GiftEntryService {
    private static final String LAYOUT_NAME = 'SGE Custom Fields';

    /**
     * Read an opportunity layout for use in the SGE form
     *
     * @return  A SGE_GiftEntryService.Layout containing information about all writeable custom fields
     */
    @AuraEnabled(cacheable=true)
    public static SGE_GiftEntryService.Layout readOpportunityLayout() {
        return readOpportunityLayoutByName(LAYOUT_NAME);
    }

    /**
     * Read an opportunity layout for use in the SGE form
     *
     * @param layoutName    Name of the layout to read
     *
     * @return  A SGE_GiftEntryService.Layout containing information about all writeable custom fields in the specified layout
     */
    private static SGE_GiftEntryService.Layout readOpportunityLayoutByName(String layoutName) {
        List<String> layouts = new List<String>{'Opportunity-' + layoutName};
        Metadata.Metadata rawMetadata;

        try {
            rawMetadata = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, layouts)[0];
        } catch(Exception ex) {
            throw new AuraHandledException('No Opportunity layout named ' + layoutName + ' found');
        }
        Metadata.Layout layout = (Metadata.Layout)rawMetadata;

        return new SGE_GiftEntryService.Layout(Schema.Opportunity.SObjectType, layout);
    }

    private static SGE_GiftEntryService.Layout readOpportunityFieldSetByName(String fieldSetName) {
        FieldSet gemFieldSet = Schema.SObjectType.Opportunity.fieldSets.getMap().get(fieldSetName);

        return new SGE_GiftEntryService.Layout(gemFieldSet);
    }

    public class Layout {
        @AuraEnabled public List<Section> sections;
        @AuraEnabled public String sObjectName;
        public Layout(Schema.SObjectType sObjectType, Metadata.Layout layout) {
            this.sObjectName = sObjectType.getDescribe().getName();
            this.sections = new List<Section>();
            for(Metadata.LayoutSection section : layout.layoutSections) {
                if(section.editHeading && section.label.toLowerCase() != 'hidden - do not edit this section') {
                    this.sections.add(new Section(sObjectType, section));
                }
            }
        }

        public Layout(FieldSet gemFieldSet) {
            this.sObjectName = gemFieldSet.getSObjectType().getDescribe().getName();
            this.sections = new List<Section>();
            this.sections.add(new Section(gemFieldSet)); //fieldset layout only has one section
        }
    }

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

        public Section(FieldSet gemFieldSet) {
            this.key = gemFieldSet.getName() + 'section';
            this.columns = new List<Column>();
            List<Schema.FieldSetMember> leftFields = new List<Schema.FieldSetMember>();
            List<Schema.FieldSetMember> rightFields = new List<Schema.FieldSetMember>();
            List<Schema.FieldSetMember> allFields = gemFieldSet.getFields();
            for(Integer i = 0; i < allFields.size(); i++) {
               if(Math.mod(i, 2) == 0) {
                   leftFields.add(allFields[i]);
               } else {
                   rightFields.add(allFields[i]);
               }
            }

            this.columns.add(new Column(leftFields));
            this.columns.add(new Column(rightFields));
        }
    }

    public class Column extends HashKey {
        @AuraEnabled public List<Field> fields;

        public Column(Schema.SObjectType sObjectType, Metadata.LayoutColumn column) {
            super(column);
            this.fields = new List<Field>();
            this.key = String.valueOf(System.hashCode(column));
            if(column.layoutItems != null) {
                for (Metadata.LayoutItem item : column.layoutItems) {
                    if (isRenderable(item)) {
                        this.fields.add(new Field(sObjectType, item));
                    }
                }
            }
        }

        public Column(List<Schema.FieldSetMember> members) {

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

    public class Field {
        @AuraEnabled public String label;
        @AuraEnabled public String name;
        @AuraEnabled public String helpText;

        public Field(Schema.SObjectType sObjectType, Metadata.LayoutItem item) {
            this(sObjectType.getDescribe().fields.getMap().get(item.field).getDescribe());
        }

        public Field(Schema.DescribeFieldResult describeFieldResult) {
            this.label = describeFieldResult.getLabel();
            this.name = describeFieldResult.getName();
            this.helpText = describeFieldResult.getInlineHelpText();
        }
    }

    abstract class HashKey {
        @AuraEnabled public String key;
        public HashKey(Object anyObject) {
            this.key = String.valueOf(System.hashCode(anyObject));
        }

        public HashKey() {}
    }
}