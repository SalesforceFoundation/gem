import json
from cumulusci.tasks.salesforce import BaseSalesforceApiTask


class CheckExistingRecordTypes(BaseSalesforceApiTask):
    task_options = {
        "sobject": {
            "description": "SObject for which record types will be retrieved",
            "required": True,
        }
    }

    def _run_task(self):
        sobject = self.options["sobject"]
        describe_results = getattr(self.sf, sobject).describe()
        record_types = [
            rt for rt in describe_results["recordTypeInfos"] if not rt["master"]
        ]
        return len(record_types) == 0
