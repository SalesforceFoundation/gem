/**
 * Created by bdvorachek on 10/7/19.
 */

import { LightningElement } from 'lwc';

export default class SGEEditDonorFooter extends LightningElement {

    saveClick() {
        this.dispatchEvent(new CustomEvent('save'));
    }

    cancelClick() {
        this.dispatchEvent(new CustomEvent('cancel'));
    }
}