import { LightningElement, api, track ,wire} from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import myShoppingAppHeader from '@salesforce/resourceUrl/myShoppingAppHeader';
import addToCart from '@salesforce/apex/ProductCard_One_Controller.addToCart';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import isguest from '@salesforce/user/isGuest';
import { NavigationMixin } from 'lightning/navigation';
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext, publish } from 'lightning/messageService';
import MyShoppingAppMessageChannel from "@salesforce/messageChannel/MyShoppingAppMessageChannel__c";


export default class ProductCard_One extends NavigationMixin(LightningElement) {
    @api product;
    @api singleProductImage;   
    @track isGuest = isguest;
    @api isButtonDisable = false;
    @track isOutOfStock = false;
    @track buttonLabel;

    @wire(MessageContext)
    messageContext;
    subscription = null;
    receivedMessage;

    renderedCallback() {
        Promise.all([
            loadStyle(this, myShoppingAppHeader),
        ])
            .then(() => {
                console.log('Files loaded in Body.');
            })
            .catch(error => {
                alert(error.body.message);
            });
    }
    connectedCallback() {
        this.subscribeMC();
        if (this.product && this.product.Carts__r && this.product.Carts__r.length > 0) {
            this.isButtonDisable = true;
            this.buttonLabel = 'Added';
        }
        console.log('Product quantity ===============>'+this.product.Quantity__c);
        if(!this.product.Quantity__c){
            this.isOutOfStock = true;
            this.isButtonDisable = true; 
            this.buttonLabel = 'Add to cart';
        }
    }
    addToCartHandler() {
        if (!this.isGuest) {
            if (!this.isButtonDisable) {

                addToCart({
                    "product": this.product,
                })
                    //Promise method to get data from server
                    .then(result => {
                        if (result == 'SUCCESS') {    
                            this.isButtonDisable = true; 
                            this.buttonLabel = 'Added';                      
                            this.showToast('', 'SUCCESS', 'Added to cart');                            
                            const payload = {
                                isAdded: true,                                
                            };
                            publish(this.messageContext, MyShoppingAppMessageChannel, payload);
                        }
                    })
                    .catch(error => {
                        console.log('Error = ' + JSON.stringify(error));
                        this.showToast('', 'ERROR', JSON.stringify(error));
                    });

            }
        }
        else {
            this.navigateToLogin();
        }

    }
    showToast(title, type, message) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: type,
        });
        this.dispatchEvent(evt);
    }
    navigateToLogin() {
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": '/login'
            }
        });
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

}