public with sharing class SGE_GiftEntryService {
    private static final String LAYOUT_NAME = 'Gift Entry';

    @AuraEnabled(cacheable=true)
    public static SGE_GiftEntryService.Layout readOpportunityLayout() {
        return readOpportunityLayoutByName(LAYOUT_NAME);
    }

    private static SGE_GiftEntryService.Layout readOpportunityLayoutByName(String layoutName) {
        Metadata.Metadata metadata = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, new List<String>{
                'Opportunity-' + layoutName
        })[0];

        Metadata.Layout layout = (Metadata.Layout)metadata;

        return new SGE_GiftEntryService.Layout(Schema.Opportunity.SObjectType, layout);
    }

    public class Layout {
        @AuraEnabled public List<Section> sections;
        public Layout(Schema.SObjectType sObjectType, Metadata.Layout layout) {
            this.sections = new List<Section>();
            for(Metadata.LayoutSection section : layout.layoutSections) {
                if(section.editHeading && section.label.toLowerCase() != 'hidden') {
                    this.sections.add(new Section(sObjectType, section));
                }
            }
        }
    }

    public class Section extends HashKey {
        @AuraEnabled public String label;
        @AuraEnabled public List<Column> columns;
        @AuraEnabled public String key;

        public Section(Schema.SObjectType sObjectType, Metadata.LayoutSection section) {
            super(section);
            this.label = section.label;
            this.columns = new List<Column>();
            for(Metadata.LayoutColumn column : section.layoutColumns) {
                columns.add(new Column(sObjectType, column));
            }
        }
    }

    public class Column extends HashKey {
        @AuraEnabled public List<Field> fields;
        @AuraEnabled public String key;
        public Column(Schema.SObjectType sObjectType, Metadata.LayoutColumn column) {
            super(column);
            this.fields = new List<Field>();
            this.key = String.valueOf(System.hashCode(column));
            for(Metadata.LayoutItem item : column.layoutItems) {
                if(isRenderable(item)) {
                    this.fields.add(new Field(sObjectType, item));
                }
            }
        }

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
    }
}