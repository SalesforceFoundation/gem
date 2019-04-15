public with sharing class SGE_GiftEntryService {

    @AuraEnabled(cacheable=true)
    public static SGE_GiftEntryService.Layout readOpportunityLayout() {
        return readOpportunityLayoutByName('Gift_Entry');
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
                this.sections.add(new Section(section));
            }
        }
    }

    public class Section {
        @AuraEnabled public String label;
        @AuraEnabled public List<Column> columns;

        public Section(Metadata.LayoutSection section) {
            this.label = section.label;
            this.columns = new List<Column>();
            for(Metadata.LayoutColumn column : section.layoutColumns) {
                columns.add(new Column(column));
            }
        }
    }

    public class Column {
        @AuraEnabled public List<Field> fields;
        public Column(Metadata.LayoutColumn column) {
            this.fields = new List<Field>();
            for(Metadata.LayoutItem item : column.layoutItems) {
                if(item.behavior == Metadata.UiBehavior.Edit || item.behavior == Metadata.UiBehavior.Required) {
                    //this.fields.add(new Field(item.field));
                }
            }
        }
    }

    public class Field {
        @AuraEnabled public String label;
        @AuraEnabled public String name;
        @AuraEnabled public String sObjectType;
        @AuraEnabled public String helpText;

        public Field( Schema.SObjectField field) {
            this(field.getDescribe());
        }

        public Field(Schema.DescribeFieldResult describeFieldResult) {
            this.label = describeFieldResult.getLabel();
            this.name = describeFieldResult.getName();
            this.helpText = describeFieldResult.getInlineHelpText();
        }
    }
}