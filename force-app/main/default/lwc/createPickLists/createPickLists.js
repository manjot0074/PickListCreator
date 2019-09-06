import { LightningElement, track } from 'lwc';

import getPickListValues from '@salesforce/apex/CreatePickListController.getPickListValues';
import createPickListForObject from '@salesforce/apex/CreatePickListController.createPickListForObject';
import addPickListForField from '@salesforce/apex/CreatePickListController.addPickListForField';

export default class CreatePickLists extends LightningElement {
    @track pickListValues;
    @track isRequesting;
    connectedCallback(){
        this.loadPickListValues();
    }
    loadPickListValues() {
        getPickListValues()
        .then(result =>  {
            this.pickListValues = result;
        })
        .catch(error => {
            this.template.querySelector('c-notification-library').showToast(
                'success',
                'PickList values are added'
            );
        })
    }
    callAddPicklist(event) {
        if(event.detail.fieldName != null) {
            this.isRequesting = true;
            addPickListForField({
                objectName: event.detail.objectName, 
                fieldName: event.detail.fieldName
            })
            .then(result => {
                this.isRequesting = false;
                this.template.querySelector('c-notification-library').showToast(
                    'success',
                    'PickList values are added'
                );
            })
            .catch (error => {
                this.isRequesting = false;
                this.template.querySelector('c-notification-library').showToast(
                    'error',
                    error.body.message
                );
            });
        } else {
            this.isRequesting = true;
            createPickListForObject({objectName: event.detail.objectName})
            .then(result => {
                this.isRequesting = false;
                this.template.querySelector('c-notification-library').showToast(
                    'success',
                    'PickList values are added'
                );
            })
            .catch (error => {
                this.isRequesting = false;
                this.template.querySelector('c-notification-library').showToast(
                    'error',
                    error.body.message
                );
            });
        }
    }
}