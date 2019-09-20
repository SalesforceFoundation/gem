from cumulusci.core.utils import process_list_arg
from cumulusci.tasks.salesforce import BaseSalesforceApiTask


class CheckExistingRecordTypes(BaseSalesforceApiTask):
    task_options = {
        "sobject": {
            "description": "SObject for which record types will be retrieved",
            "required": True,
        },
        "ignored_record_types": {
            "description": "Developer names for record types to ignore."
        },
    }

    def _run_task(self):
        sobject = self.options["sobject"]
        describe_results = getattr(self.sf, sobject).describe()
        record_types = [
            rt for rt in describe_results["recordTypeInfos"] if not rt["master"]
        ]

        if "ignored_record_types" in self.options:
            ignored_names = process_list_arg(self.options["ignored_record_types"])
            record_types = [
                rt for rt in record_types if rt["developerName"] not in ignored_names
            ]

        recordtypes_exist = len(record_types) > 0
        return recordtypes_exist
