import { LightningElement,api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import MyShoppingAppModalStyling from '@salesforce/resourceUrl/MyShoppingAppModalStyling';

export default class MyShoppingApp_TermsAndConditions extends LightningElement {

    @api showModal = false;   

    @api
    openModal() {
        this.showModal = true;
    }

    @api
    closeModal() {
        this.showModal = false;
    }
    renderedCallback() {
        Promise.all([
            loadStyle(this, MyShoppingAppModalStyling),
        ])
            .then(() => {
                console.log('Files loaded.');
            })
            .catch(error => {
                alert(error.body.message);
            });
    }
}