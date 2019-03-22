public with sharing class SGE_GiftEntryService {

    public static SGE_GiftEntryService.Layout readOpportunityLayout() {
        return null;
    }

    public class Layout {
        public List<Section> sections;
        public Layout(Schema.SObjectType sObjectType, Metadata.Layout layout) {
            this.sections = new List<Section>();
            for(Metadata.LayoutSection section : layout.layoutSections) {
                this.sections.add(new Section(section));
            }
        }
    }

    public class Section {
        public String label;
        public List<Column> columns;

        public Section(Metadata.LayoutSection section) {
            this.label = section.label;
            this.columns = new List<Column>();
            for(Metadata.LayoutColumn column : section.layoutColumns) {
                columns.add(new Column(column));
            }
        }
    }

    public class Column {
        public List<Field> fields;
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
        public String label;
        public String name;
        public String sObjectType;
        public String helpText;

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