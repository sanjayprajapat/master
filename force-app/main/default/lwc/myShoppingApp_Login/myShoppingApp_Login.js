import { LightningElement, track, api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import MyShoppingApp_Login_Style from '@salesforce/resourceUrl/MyShoppingApp_Login_Style';
import MyShoppingAppResources from '@salesforce/resourceUrl/MyShoppingAppResources';
import { NavigationMixin } from 'lightning/navigation';
import submitLogin from '@salesforce/apex/MyShoppingApp_LoginController.login';
import getMyCustomData from '@salesforce/apex/MyShoppingApp_LoginController.getMyCustomData';
import getIsUsernamePasswordEnabled from '@salesforce/apex/MyShoppingApp_LoginController.getIsUsernamePasswordEnabled';
import getIsSelfRegistrationEnabled from '@salesforce/apex/MyShoppingApp_LoginController.getIsSelfRegistrationEnabled';
import getForgotPasswordUrl from '@salesforce/apex/MyShoppingApp_LoginController.getForgotPasswordUrl';
import getSelfRegistrationUrl from '@salesforce/apex/MyShoppingApp_LoginController.getSelfRegistrationUrl';




export default class MyShoppingApp_Login extends NavigationMixin(LightningElement) {

    @track sideImage = MyShoppingAppResources + '/LoginPageImage.jpg';
    @track bgStyling = 'background: ${sideImage} no-repeat;background-position: center;background-size: cover;';
    @track showError = false;
    @track errorMessage;
    @track communityUsername;
    @track communityPassword;
    @track startUrl = '/s/';
    @track isProduction = false;
    @track baseURL;
    @track orgId;
    @api showSpinner = false;

    @track isUsernamePasswordEnabled;
    @track isSelfRegistrationEnabled;
    @track communityForgotPasswordUrl;
    @track communitySelfRegisterUrl;

    //after Creating constructore of Js First ConnectedCallback Will Be Called
    connectedCallback() {
        this.fetchMyCustomData();
        this.fetchIsUsernamePasswordEnabled();
        this.fetchIsSelfRegistrationEnabled();
        this.fetchIsSCommunityForgotPasswordUrl();
        this.fetchCommunitySelfRegisterUrl();
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
    fetchMyCustomData() {
        getMyCustomData({
        })
            //Promise method to get data from server
            .then(result => {
                if (result) {                   
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
                this.showError = true;
                this.errorMessage = JSON.stringify(error);
            });
    }
    fetchIsUsernamePasswordEnabled() {
        getIsUsernamePasswordEnabled({
        })
            //Promise method to get data from server
            .then(result => {
                if (result) {
                    this.isUsernamePasswordEnabled = result;
                }
            })
            .catch(error => {
                this.showError = true;
                this.errorMessage = JSON.stringify(error);
            });
    }
    fetchIsSelfRegistrationEnabled() {
        getIsSelfRegistrationEnabled({
        })
            //Promise method to get data from server
            .then(result => {
                if (result) {
                    this.isSelfRegistrationEnabled = result;
                }
            })
            .catch(error => {
                this.showError = true;
                this.errorMessage = JSON.stringify(error);
            });
    }
    fetchIsSCommunityForgotPasswordUrl() {
        getForgotPasswordUrl({
        })
            //Promise method to get data from server
            .then(result => {
                if (result) {
                    this.communityForgotPasswordUrl = result;
                }
            })
            .catch(error => {
                this.showError = true;
                this.errorMessage = JSON.stringify(error);
            });
    }
    fetchCommunitySelfRegisterUrl() {
        getSelfRegistrationUrl({
        })
            //Promise method to get data from server
            .then(result => {
                if (result) {
                    this.communitySelfRegisterUrl = result;
                }
            })
            .catch(error => {
                this.showError = true;
                this.errorMessage = JSON.stringify(error);
            });
    }
    onKeyUp(event) {
        //checks for "enter" key
        if (event.keyCode === 13) {
            if (this.checkValidation(event)) {
                this.loginToCommunity();
            }
        }
    }
    loginToCommunity(event) {
        if (this.checkValidation(event)) {
            this.toggleSpinner();
            var checkBox = this.template.querySelector('[data-id="inputcheck"]');
            var username = this.template.querySelector('[data-id="username"]').value;
            var password = this.template.querySelector('[data-id="password"]').value;

            if (checkBox.checked) {
                this.newCookie('userName', username, 365);     // add a new cookie as shown at left for every
                this.newCookie('isRemembered', true);
            } else {
                this.newCookie('userName', '');     // add a new cookie as shown at left for every               
                this.newCookie('isRemembered', false);
            }
            //this.startUrl = decodeURIComponent(this.startUrl);
            //if (this.isProduction) {
           //     this.startUrl = '/s/';
            //}
            //Call Apex Method
            submitLogin({
                "uName": username,
                "pass": password,
                "startUrl123": this.startUrl,
            })
                //Promise method to get data from server
                .then(result => {
                    console.log("Result after log in == ",result);
                    if (result.status == 'SUCCESS') {
                        this.toggleSpinner();
                        var url = new URL(result.returnUrl);
                        var retURL = url.searchParams.get("retURL");  
                        console.log("return url == "+retURL);  
                        window.location.href =    retURL;                 
                        /*this[NavigationMixin.Navigate]({
                            "type": "standard__webPage",
                            "attributes": {
                                "url":retURL
                            }
                        });*/                        
                    }
                    else if (result.status == 'FAILED') {                      
                        this.toggleSpinner();
                        this.showError = true;
                        this.errorMessage = result.message;
                        this[NavigationMixin.Navigate]({
                            "type": "standard__webPage",
                            "attributes": {
                                "url": result.returnUrl
                            }
                        });
                    }
                    else {
                        this.toggleSpinner();
                        this.showError = true;
                        this.errorMessage = result.message;
                    }
                })
                .catch(error => {
                    this.toggleSpinner();
                    this.showError = true;
                    this.errorMessage = JSON.stringify(error);
                });
        }
    }
    newCookie(name, value, days) {
        days = 365;   // the number at the left reflects the number of days for the cookie to last
        // modify it according to your needs
        if (days) {
            var date = new Date();
            date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
            var expires = "; expires=" + date.toGMTString();
        }
        else var expires = "";
        document.cookie = name + "=" + value + expires + "; path=/";
    }
    readCookie(name) {
        var nameSG = name + "=";
        var nuller = '';
        if (document.cookie.indexOf(nameSG) == -1)
            return nuller;

        var ca = document.cookie.split(';');
        for (var i = 0; i < ca.length; i++) {
            var c = ca[i];
            while (c.charAt(0) == ' ') c = c.substring(1, c.length);
            if (c.indexOf(nameSG) == 0) return c.substring(nameSG.length, c.length);
        }
        return null;
    }
    checkValidation(event) {
        this.showError = false;
        var isValidUser = false;
        var isValidPass = false;
        var isValidForLogin = false;
        var username = this.template.querySelector('[data-id="username"]').value;
        var password = this.template.querySelector('[data-id="password"]').value;
        var usernameInput = this.template.querySelector('[data-id="username"]');
        var passwordInput = this.template.querySelector('[data-id="password"]');

        //var emailAddress = component.find("username").get("v.value");       
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        if (event.target.name == 'uName' || event.target.name == 'signIn') {
            if (!username) {
                usernameInput.setCustomValidity('Please Provide Your Email Address');
                usernameInput.reportValidity();
                isValidUser = false;
            }
            else {                
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
        if (event.target.name == 'pass' || event.target.name == 'signIn') {            
            if (!password) {
                passwordInput.setCustomValidity('Please Provide Your Password'); //do not get any message
                passwordInput.reportValidity();
                isValidPass = false;
            }
            else {
                isValidPass = true;
                passwordInput.setCustomValidity(''); //do not get any message
                passwordInput.reportValidity();
            }
        }
        if (isValidUser && isValidPass) {
            isValidForLogin = true;
        }
        return isValidForLogin;

    }
    navigateToRegister() {
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": '/SelfRegister'
            }
        });
    }
    navigateToSalesforce() {
        var isProduction = this.isProduction;
        var orgId = this.orgId;
        var baseURL = this.baseURL;
        var newLocation;
        if (isProduction)
            newLocation = "https://login.salesforce.com/services/auth/sso/" + orgId + "/Salesforce?community=" + encodeURIComponent(baseURL) + "%2F10kconnect&startURL=%2F10kconnect%2F";
        else
            newLocation = "https://test.salesforce.com/services/auth/sso/" + orgId + "/Salesforce?community=" + encodeURIComponent(baseURL) + "%2F10kconnect&startURL=%2F10kconnect%2F";

        if (newLocation) {
            this[NavigationMixin.Navigate]({
                "type": "standard__webPage",
                "attributes": {
                    "url": newLocation
                }
            });
        }
    }
    navigateToForgot() {
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": '/ForgotPassword'
            }
        });
    }
    // change isLoaded to the opposite of its current value
    toggleSpinner() {
        this.showSpinner = !this.showSpinner;
    }
}