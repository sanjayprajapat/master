import { LightningElement, wire, track } from "lwc";
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import myShoppingAppHeader from '@salesforce/resourceUrl/myShoppingAppHeader';
import {subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext, publish } from "lightning/messageService";  
import MyShoppingAppMessageChannel from "@salesforce/messageChannel/MyShoppingAppMessageChannel__c";
import getUserDetailsController from '@salesforce/apex/MyShoppingApp_Header_Controller.getUserDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import isguest from '@salesforce/user/isGuest';
import { NavigationMixin } from 'lightning/navigation';

export default class MyShoppingApp_Header extends NavigationMixin(LightningElement) {
    @wire(MessageContext)
    messageContext;
    subscription = null;
    receivedMessage;

    @track userResponse = {};
    @track isGuestUser = isguest;
    @track isItemsInCart;
    renderedCallback() {

        Promise.all([
            //loadScript(this, customSR + '/jquery.min.js'),
            loadStyle(this, myShoppingAppHeader),
        ])
            .then(() => {
                console.log('Files loaded.');
            })
            .catch(error => {
                alert(error.body.message);
            });
    }
    connectedCallback() {
        this.subscribeMC();       
        if( !this.isGuestUser){
            this.getUserDetails();
        }        
       // this.isGuestUser = isguest;       
    }
    disconnectedCallback() {
        this.unsubscribeMC();
    }
    subscribeMC() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(
            this.messageContext,
            MyShoppingAppMessageChannel,
            message => {                
                this.handleMessage(message);
                if(message.isAdded == true){
                    this.userResponse.countOfCartItems =  this.userResponse.countOfCartItems + 1;
                    this.isItemsInCart = true;
                }
                if(message.isRemoved == true && this.userResponse.countOfCartItems){
                    this.userResponse.countOfCartItems =  this.userResponse.countOfCartItems - 1;
                    this.isItemsInCart = true;
                }
            },
            { scope: APPLICATION_SCOPE }
        );
    }

    unsubscribeMC() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleMessage(message) {
        this.receivedMessage = message
            ? JSON.stringify(message, null, "\t")
            : "no message payload";
    }
    openSideMenu() {  
        const payload = {
            isOpen : true,
            componentName : 'miniSideBar'
        };
        publish(this.messageContext, MyShoppingAppMessageChannel, payload);
    }
    openCart() {  
        const payload = {
            isOpen : true,
            componentName : 'myShoppingApp_Cart'
        };
        publish(this.messageContext, MyShoppingAppMessageChannel, payload);
    } 

    getUserDetails() {
        getUserDetailsController({
        })
            //Promise method to get data from server
            .then(result => {
                console.log("Result iin Header ===",result);
                if (result) {
                    this.userResponse = result;
                    console.log('total cart items == '+result.countOfCartItems); 
                    console.log('List cart items == '+result.listOfCartItems);  
                    if(result.countOfCartItems && result.countOfCartItems > 0){
                        this.isItemsInCart = true;
                    }                  
                }
            })
            .catch(error => {
                this.showToastHelper('',JSON.stringify(error) , 'ERROR');
            });
    }
    showToastHelper(title , message , type) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: type,           
        });
        this.dispatchEvent(event);
    }
    navigateToLogin() {
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": '/login'
            }
        });
    }
    

}