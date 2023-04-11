import { LightningElement, track, api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import MyShoppingApp_Login_Style from '@salesforce/resourceUrl/MyShoppingApp_Login_Style';
import MyShoppingAppResources from '@salesforce/resourceUrl/MyShoppingAppResources';
import { NavigationMixin } from 'lightning/navigation';
import submitForgot from '@salesforce/apex/MyShoppingApp_LoginController.forgotPassword';

export default class MyShoppingApp_ForgotPassword extends NavigationMixin(LightningElement) {
    @track showError = false;
    @track errorMessage;
    @api showSpinner = false;
    @track userNameText;
    @track isSubmited = false;

    onKeyUp(event) {
        //checks for "enter" key
        if (event.keyCode === 13) {
            if (this.checkValidation(event)) {
                this.submitForgotPassword(event);
            }
        }
    }
    resendEmailHandler(event) {
        this.isSubmited = false;
        this.showError = false;
        this.errorMessage = '';
    }

    submitForgotPassword(event) {
        this.userNameText = this.template.querySelector('[data-id="username"]').value;      
        this.showError = false;
        this.errorMessage = '';
        if (this.checkValidation(event)) {
            this.toggleSpinner();

            //Call Apex Method
            submitForgot({
                "username":  this.userNameText,
                "checkEmailUrl": '',
            })
                //Promise method to get data from server
                .then(result => {
                    if (result == 'success') {
                        this.toggleSpinner();
                        this.isSubmited = true;
                    }
                    else {
                        this.toggleSpinner();
                        this.showError = true;
                        this.errorMessage = result;
                    }
                })
                .catch(error => {
                    this.toggleSpinner();
                    this.showError = true;
                    this.errorMessage = JSON.stringify(error);
                });
        }
    }

    renderedCallback() {
        Promise.all([
            loadStyle(this, MyShoppingApp_Login_Style),
        ])
            .then(() => {
                console.log('Files loaded.');
            })
            .catch(error => {
                alert(error.body.message);
            });
    }
    // change isLoaded to the opposite of its current value
    toggleSpinner() {
        this.showSpinner = !this.showSpinner;
    }
    checkValidation(event) {
        var isValidUser = false;
        var username = this.template.querySelector('[data-id="username"]').value;
        var usernameInput = this.template.querySelector('[data-id="username"]');
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        if (event.target.name == 'uName' || event.target.name == 'submit') {
            if (!username) {
                usernameInput.setCustomValidity('Please Provide Your Email Address');
                usernameInput.reportValidity();
                isValidUser = false;
            }
            else {
                console.log("enter in elsein email");
                if (!username.match(regExpEmailformat)) {
                    usernameInput.setCustomValidity('Please provide valid Email Address');
                    usernameInput.reportValidity();
                    isValidUser = false;
                }
                else {
                    isValidUser = true;
                    usernameInput.setCustomValidity(''); //do not get any message
                    usernameInput.reportValidity();
                }
            }
        }
        return isValidUser;

    }
    navigateToRegister() {
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": '/SelfRegister'
            }
        });
    }
    navigateToLogin() {
        this[NavigationMixin.Navigate]({
            "type": "standard__namedPage",
            "attributes": {
                "pageName": 'login'
            }
        });
    }
}