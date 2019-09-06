import { LightningElement, api } from 'lwc';

export default class ObjectPickLists extends LightningElement {
    @api objectpicklist;
    createPicklistForField(event) {
        var fieldname = event.target.name;
        var objectName = this.objectpicklist.objectname;
        const selectEvent = new CustomEvent('addpicklist', { 
            detail : {
                fieldName: fieldname,
                objectName : objectName
            }
        });
        this.dispatchEvent(selectEvent);
    }
    createPicklistForObject() {
        var objectName = this.objectpicklist.objectname;
        const selectEvent = new CustomEvent('addpicklist', { 
            detail : {
                objectName : objectName
            }
        });
        this.dispatchEvent(selectEvent);
    }

}