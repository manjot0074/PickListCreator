import { LightningElement, api, track } from 'lwc';

export default class NotificationLibrary extends LightningElement {
    @track message;
    @track notificationClass;
    @track showNotiifcation;
    timeoutId;
    @api 
    showToast(theme, message) {
        var self = this;
        if(this.showNotiifcation){
            clearTimeout(this.timeoutId); 
        }
        this.notificationClass = 'slds-notify slds-notify_alert slds-theme_alert-texture slds-theme_'+theme;
        this.message = message;
        this.showNotiifcation = true;
        this.timeoutId = window.setTimeout( function() {
            self.showNotiifcation = false;
        }, 5000);
    }
    closeNotification(){
        clearTimeout(this.timeoutId);
        this.showNotiifcation = false;
    }
}