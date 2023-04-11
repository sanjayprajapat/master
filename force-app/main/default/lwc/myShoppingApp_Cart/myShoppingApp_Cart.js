import { LightningElement, api, wire, track } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import MyShoppingAppModalStyling from '@salesforce/resourceUrl/MyShoppingAppModalStyling';
import { MessageContext, publish } from 'lightning/messageService';
import MyShoppingAppMessageChannel from "@salesforce/messageChannel/MyShoppingAppMessageChannel__c";
import getCartItem from '@salesforce/apex/MyShoppingApp_Cart_Controller.getCartItems';
import updateCart from '@salesforce/apex/MyShoppingApp_Cart_Controller.updateCart';
import isguest from '@salesforce/user/isGuest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import deleteCartItemRecord from '@salesforce/apex/MyShoppingApp_Cart_Controller.deleteCartItemRecord';

export default class MyShoppingApp_Cart extends LightningElement {

    @wire(MessageContext)
    messageContext;
    @track isguestUser = isguest;
    @track cartItemsList;
    @track productMapWithImage;
    @track totalToPay = 0;
    @track isValidToPay = true;

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

    closeModal() {
        const payload = {
            isOpen: false,
            componentName: 'myShoppingApp_Cart'
        };
        publish(this.messageContext, MyShoppingAppMessageChannel, payload);
        location.reload();
        return false;
    }
    connectedCallback() {
        if (!this.isguestUser) {
            this.getCartItemHandler();
        }
    }
    convertObjectToMap(obj) {
        const keys = Object.keys(obj);
        const map = new Map();
        for (let i = 0; i < keys.length; i++) {
            //inserting new key value pair inside map
            map.set(keys[i], obj[keys[i]]);
        };
        return map;
    }
    getCartItemHandler() {
        getCartItem({
        })
            //Promise method to get data from server
            .then(result => {
                console.log("Result in cart ===", result);
                this.productMapWithImage = this.convertObjectToMap(result.mapOfDocuments);
                var listOfItemTemp = [];
                result.listOfCartItems.forEach((item, index) => {
                    if (this.productMapWithImage && this.productMapWithImage.get(item.Product__c)) {
                        if (this.productMapWithImage.get(item.Product__c).length >= 0) {
                            item["singleImg"] = this.productMapWithImage.get(item.Product__c)[0];
                        }
                    }
                    if (item.Product__r.Discount_Up_to__c != undefined && item.Product__r.Discount_Up_to__c > 0) {
                        var total = item.Product__r.Price__c - item.Product__r.Discount_Up_to__c;
                        item["total"] = total;
                        this.totalToPay = this.totalToPay + total;
                    }
                    else {
                        item["total"] = item.Product__r.Price__c;
                        this.totalToPay = this.totalToPay + item.Product__r.Price__c;
                    }
                    if (!item.Product__r.Quantity__c && item.Product__r.Quantity__c <= 0) {
                        this.isValidToPay = false;
                    }
                    listOfItemTemp.push(item);
                });
                this.cartItemsList = listOfItemTemp;
                console.log("cartItemsList in cart ===", this.cartItemsList);
            })
            .catch(error => {
                this.showToastHelper('', JSON.stringify(error), 'ERROR');
            });
    }
    showToastHelper(title, message, type) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: type,
        });
        this.dispatchEvent(event);
    }
    addItems(event) {
        var cartItem = event.currentTarget.name;
        this.cartItemsList.forEach((item, index) => {
            if (item.Id == cartItem.Id) {
                item.Quantity__c = item.Quantity__c + 1;
                if (item.Quantity__c == 3) {
                    event.currentTarget.classList.add("disableButton");
                    event.currentTarget.disabled = true;
                }
                //this.updateCartHandler(item); 
                return false;
            }
        });

    }
    removeItems(event) {
        var cartItem = event.currentTarget.name;
        this.cartItemsList.forEach((item, index) => {
            if (item.Id == cartItem.Id) {
                item.Quantity__c = item.Quantity__c - 1;
                if (item.Quantity__c < 3) {
                    let target = this.template.querySelector(`[data-id="${item.Id}"]`);
                    target.classList.remove("disableButton");
                    target.disabled = false;
                }

                // this.updateCartHandler(item);                 
                return false;
            }
        });

    }
    updateCartHandler(cartItem) {
        console.log('cartItem', cartItem);
        updateCart({
            'cartItem': cartItem
        })
            //Promise method to get data from server
            .then(result => {
                console.log("Result in cart ===", result);
            })
            .catch(error => {
                this.showToastHelper('', JSON.stringify(error), 'ERROR');
            });
    }
    proceedToPayHandler() {
        if (this.isValidToPay == false) {
            this.showToastHelper('', 'Somethings are not available in stock.Please remove from your cart.', 'ERROR');
        }
        else {
            this.showToastHelper('', 'Order Placed', 'SUCCESS');
        }
    }
    removeItemFromCart(event) {
        var cartItem = event.currentTarget.name;
        if (cartItem) {
            deleteCartItemRecord({
                'recordId': cartItem.Id
            })
                //Promise method to get data from server
                .then(result => {
                    console.log("Result in cart ===", result);
                    this.showToastHelper('', 'Item Removed', 'SUCCESS');
                    this.getCartItemHandler();
                    const payload = {
                        isRemoved: true,                       
                    };
                    publish(this.messageContext, MyShoppingAppMessageChannel, payload);
                })
                .catch(error => {
                    this.showToastHelper('', JSON.stringify(error), 'ERROR');
                });
        }

    }

}