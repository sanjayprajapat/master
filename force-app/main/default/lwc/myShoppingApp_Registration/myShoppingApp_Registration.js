import { LightningElement, track, api, wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import MyShoppingApp_Login_Style from '@salesforce/resourceUrl/MyShoppingApp_Login_Style';
import MyShoppingAppResources from '@salesforce/resourceUrl/MyShoppingAppResources';
import getMyCustomData from '@salesforce/apex/MyShoppingApp_RegistrationController.getMyCustomData';
import registerUser from '@salesforce/apex/MyShoppingApp_RegistrationController.registerUser';
import { NavigationMixin } from 'lightning/navigation';

export default class MyShoppingApp_Registration extends NavigationMixin(LightningElement) {

    @track sideImage = MyShoppingAppResources + '/LoginPageImage.jpg';
    @track bgStyling = 'background: ${sideImage} no-repeat;background-position: center;background-size: cover;';
    @track showSuccess = false;
    @track showError = false;
    @track errorMessage;
    @track buttonEnable = false;
    @track isProduction = false;
    @track baseURL;
    @track orgId;
    @api showSpinner = false;
    @track showModal = false;

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
    //after Creating constructore of Js First ConnectedCallback Will Be Called
    connectedCallback() {
        this.fetchMyCustomData();
    }
    fetchMyCustomData() {
        this.toggleSpinner();
        getMyCustomData({
        })
            //Promise method to get data from server
            .then(result => {
                if (result) {
                    this.toggleSpinner();
                    console.log("Result in getMyCustomData ", result);
                    var baseURL = result.split("===")[0];
                    var orgId = result.split("===")[2].substring(0, 15);
                    var isProduction = result.split("===")[3];
                    if (isProduction == 'true') {
                        this.isProduction = isProduction;
                    }
                    this.baseURL = baseURL;
                    this.orgId = result.split("===")[2];
                }
            })
            .catch(error => {
                this.toggleSpinner();
                this.showError = true;
                this.errorMessage = JSON.stringify(error);
            });
    }    
    onKeyUp(event) {
        if (event.keyCode === 13) {
            if (this.checkValidation(event)) {
                this.createAccount();
            }
        }
    }
    checkValidation(event) {
        this.showError = false;
        var isValidFirstName = false;
        var isValidLastName = false;
        var isValidEmail = false;
        var isValidForRegistration = false;
        var isValidCheckBox = false;
        var firstname = this.template.querySelector('[data-id="firstname"]').value;
        var lastname = this.template.querySelector('[data-id="lastname"]').value;
        var emailaddress = this.template.querySelector('[data-id="emailAddress"]').value;
        var checkBox = this.template.querySelector('[data-id="myCheck"]').checked;
        var firstnameInput = this.template.querySelector('[data-id="firstname"]');
        var lastnameInput = this.template.querySelector('[data-id="lastname"]');
        var emailaddressInput = this.template.querySelector('[data-id="emailAddress"]');
        var checkBoxShape = this.template.querySelector('[data-id="myCheck"]');

        //var emailAddress = component.find("username").get("v.value");       
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

        if (event.target.name == 'EmailAdd' || event.target.name == 'CreateAccount') {
            console.log("event.target.name ===" + event.target.name);
            if (!emailaddress) {
                console.log("in Email if");
                emailaddressInput.setCustomValidity('Please provide your Email Address');
                emailaddressInput.reportValidity();
                isValidEmail = false;
            }
            else {
                console.log("in Email else");
                if (!emailaddress.match(regExpEmailformat)) {
                    console.log("in Email regex if");
                    emailaddressInput.setCustomValidity('Please provide valid Email Address');
                    emailaddressInput.reportValidity();
                    isValidEmail = false;
                }
                else {
                    console.log("in Email regex else");
                    isValidEmail = true;
                    emailaddressInput.setCustomValidity(''); //do not get any message
                    emailaddressInput.reportValidity();

                }
            }
        }
        if (event.target.name == 'FirstName' || event.target.name == 'CreateAccount') {
            if (!firstname) {
                firstnameInput.setCustomValidity('Please provide your First Name'); //do not get any message
                firstnameInput.reportValidity();
                isValidFirstName = false;
            }
            else {
                isValidFirstName = true;
                firstnameInput.setCustomValidity(''); //do not get any message
                firstnameInput.reportValidity();
            }
        }

        if (event.target.name == 'LastName' || event.target.name == 'CreateAccount') {
            if (!lastname) {
                lastnameInput.setCustomValidity('Please provide your Last Name'); //do not get any message
                lastnameInput.reportValidity();
                isValidLastName = false;
            }
            else {
                isValidLastName = true;
                lastnameInput.setCustomValidity(''); //do not get any message
                lastnameInput.reportValidity();
            }
        }

        if (event.target.name == 'TCcheck' || event.target.name == 'CreateAccount') {
            if (!checkBox) {
                checkBoxShape.setCustomValidity('Please accept Terms and Conditions'); //do not get any message
                checkBoxShape.reportValidity();
                isValidCheckBox = false;
            }
            else {
                isValidCheckBox = true;
                checkBoxShape.setCustomValidity(''); //do not get any message
                checkBoxShape.reportValidity();

            }
        }

        if (isValidLastName && isValidFirstName && isValidEmail && isValidCheckBox) {
            isValidForRegistration = true;
        }
        return isValidForRegistration;

    }
    termsChanged() {
        var checkBox = this.template.querySelector('[data-id="myCheck"]');
        if (checkBox.checked) {
            checkBox.setCustomValidity('');
            checkBox.reportValidity();
            this.buttonEnable = true;
        }
        else {
            checkBox.setCustomValidity('Please Accept Terms and Conditions');
            checkBox.reportValidity();
            this.buttonEnable = false;
        }
    }    
    createAccount(event) {
        this.showSuccess = false;
        this.showError = false;
        if (this.checkValidation(event)) {
            this.toggleSpinner();
            var fname = this.template.querySelector('[data-id="firstname"]').value;
            var lname = this.template.querySelector('[data-id="lastname"]').value;
            var emailAdd = this.template.querySelector('[data-id="emailAddress"]').value;
            console.log("firstname ===" + fname);
            console.log("LastName ===" + lname);
            console.log("EmailAddress ===" + emailAdd);

            registerUser({
                "firstName": fname,
                "lastName": lname,
                "emailAddress": emailAdd
            })
                //Promise method to get data from server
                .then(result => {
                    if (result) {
                        if (result.status == 'Error') {
                            this.toggleSpinner();
                            this.errorMessage = result.message;
                            this.showError = true;
                        }
                        else if (result.status == 'Success') {
                            this.toggleSpinner();
                            this.successMessage = this.stripHtml(result.message);
                            this.showSucces = true;
                        }
                    }
                })
                .catch(error => {
                    this.toggleSpinner();
                    this.showError = true;
                    this.errorMessage = JSON.stringify(error);
                });
        }
    }
    navigateToLogin() {
        this[NavigationMixin.Navigate]({
            "type": "standard__namedPage",
            "attributes": {
                "pageName": 'login'
            }
        });
    }
    navigateToSalesforce() {
        var checkBox = this.template.querySelector('[data-id="myCheck"]');
        if (checkBox.checked) {
            checkBox.setCustomValidity('');
            checkBox.reportValidity();

            var isProduction = this.isProduction;
            var orgId = this.orgId;
            var baseURL = this.baseURL;
            var newLocation;
            if (isProduction) {
                newLocation = "https://login.salesforce.com/services/auth/sso/" + orgId + "/Salesforce?community=" + encodeURIComponent(baseURL) + "%2F10kconnect&startURL=%2F10kconnect%2F";
            } else {
                newLocation = "https://test.salesforce.com/services/auth/sso/" + orgId + "/Salesforce?community=" + encodeURIComponent(baseURL) + "%2F10kconnect&startURL=%2F10kconnect%2F";
            }
            if (newLocation) {
                this[NavigationMixin.Navigate]({
                    "type": "standard__webPage",
                    "attributes": {
                        "url": newLocation
                    }
                });
            }

        }
        else {
            checkBox.setCustomValidity('Please accept Terms and Conditions');
            checkBox.reportValidity();
        }
    }
    genrateUniqueNumber() {
        var minm = 10000;
        var maxm = 99999;
        return Math.floor(Math.random() * (maxm - minm + 1)) + minm;
    }
    stripHtml(html) {
        // Create a new div element
        var temporalDivElement = document.createElement("div");
        // Set the HTML content with the providen
        temporalDivElement.innerHTML = html;
        // Retrieve the text property of the element (cross-browser support)
        return temporalDivElement.textContent || temporalDivElement.innerText || "";
    }
    detectBrowser() {
        var sBrowser, sUsrAg = navigator.userAgent;
        if (sUsrAg.indexOf("Chrome") > -1) {
            sBrowser = "Google Chrome";
        } else if (sUsrAg.indexOf("Safari") > -1) {
            sBrowser = "Apple Safari";
        } else if (sUsrAg.indexOf("Opera") > -1) {
            sBrowser = "Opera";
        } else if (sUsrAg.indexOf("Firefox") > -1) {
            sBrowser = "Mozilla Firefox";
        } else if (sUsrAg.indexOf("MSIE") > -1) {
            sBrowser = "Microsoft Internet Explorer";
        } else {
            sBrowser = "unknown";
        }
        return sBrowser;
    }   
    // change isLoaded to the opposite of its current value
    toggleSpinner() {
        this.showSpinner = !this.showSpinner;
    }
    toggleModal(){
        this.showModal = !this.showModal;
        setTimeout(()=>this.template.querySelector('c-my-shopping-app_-terms-and-conditions').openModal());
        
    }
    
}