import { LightningElement, track, wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import customStyle from '@salesforce/resourceUrl/shoppingAppSideMenuStyleNew';
import myResources from '@salesforce/resourceUrl/MyShoppingAppResources_2';
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext, publish } from 'lightning/messageService';
import MyShoppingAppMessageChannel from "@salesforce/messageChannel/MyShoppingAppMessageChannel__c";
import getUserDetails from '@salesforce/apex/MyShoppingAppSideMenu_Controller.getUserDetails';
import isguest from '@salesforce/user/isGuest';
export default class MyShoppingAppSideMenu extends LightningElement {
    @track headerImage;
    @track headerSideImage;
    @wire(MessageContext)
    messageContext;
    subscription = null;
    receivedMessage;
    //headerImage = myResources + '/10K_Landscape_Options-71.png';
    //headerSideImage = myResources + '/shoppingAppSideImage.jpg';
    @track userObject;
    @track smallPhoto;
    @track fullPhoto;
    @track userName;
    @track isGuest = isguest;

    renderedCallback() {

        Promise.all([
            //loadScript(this, customSR + '/jquery.min.js'),
            loadStyle(this, customStyle),
        ])
            .then(() => {
                console.log('Files loaded.');
            })
            .catch(error => {
                alert(error.body.message);
            });
    }
    getUserDetails() {
        getUserDetails({

        })
            //Promise method to get data from server
            .then(result => {
                if (result) {
                    console.log("Result === ", result);
                    this.smallPhoto = result.SmallPhotoUrl;
                    this.fullPhoto = result.FullPhotoUrl;
                    this.userName = result.Name;
                }
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            });
    }
    connectedCallback() {
        this.subscribeMC();
        if (!this.isGuest) {
            this.getUserDetails();
        }
        else {
            this.smallPhoto = myResources + '/10K_Landscape_Options-71.png';
            this.fullPhoto = myResources + '/10K_Landscape_Options-71.png';
            this.userName = 'Guest User';

        }

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
    closeSideMenu() {
        const payload = {
            isOpen: false,
            componentName: 'miniSideBar'
        };
        publish(this.messageContext, MyShoppingAppMessageChannel, payload);
    }

}