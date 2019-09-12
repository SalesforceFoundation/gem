import { LightningElement, api, wire, track } from 'lwc';
import ALLOCATION_OBJECT from '@salesforce/schema/npsp__Allocation__c';
import ALLOCATION_AMOUNT_FIELD from '@salesforce/schema/npsp__Allocation__c.npsp__Amount__c';
import GAU_OBJECT from '@salesforce/schema/npsp__General_Accounting_Unit__c';
import GAU_NAME_FIELD from '@salesforce/schema/npsp__General_Accounting_Unit__c.Name';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import { getAllocationSettings } from 'c/sge_service';



export default class SGE_DefaultGAU extends LightningElement {
    @api totalAmount = 0;
    @api allocatedAmount = 0;
    @api editMode = false;

    @track defaultGAUEnabled = false;
    @track defaultGAUId;

    @wire(getRecord, {recordId: '$defaultGAUId', fields: [GAU_NAME_FIELD]})
    defaultGAU;

    @wire(getObjectInfo, { objectApiName: GAU_OBJECT })
    gauObjectInfo;

    @wire(getObjectInfo, { objectApiName: ALLOCATION_OBJECT })
    allocationObjectInfo;

    connectedCallback() {
        // determine if default GAU exists
        getAllocationSettings().then(settings => {
            if (settings.npsp__Default_Allocations_Enabled__c && settings.npsp__Default__c) {
                this.defaultGAUId = settings.npsp__Default__c;
                this.defaultGAUEnabled = true;
            }
        });
    }

    get remainderAmount() {
        if(isNumber(this.totalAmount)) {
            if(isNumber(this.allocatedAmount)) {
                return this.totalAmount - this.allocatedAmount;
            } else {
                return this.totalAmount;
            }
        }

        return 0;
    }

    get amountFieldLabel() {
        if (this.allocationObjectInfo.data) {
            return this.allocationObjectInfo.data.fields[ALLOCATION_AMOUNT_FIELD.fieldApiName].label;
        }
    }

    get defaultGAUName() {
        if(this.defaultGAU.data && this.defaultGAUEnabled) {
            return this.defaultGAU.data.fields.Name.value;
        } else {
            return '';
        }
    }

    get gauObjectLabel() {
        if(this.gauObjectInfo.data && this.defaultGAUEnabled) {
            return this.gauObjectInfo.data.label;
        }
    }

    get showDefaultGAU() {
        return !this.editMode && this.defaultGAUEnabled;
    }
}

const isNumber = val => !(Array.isArray(val) && (val - parseFloat(val)) +1 >= 0);