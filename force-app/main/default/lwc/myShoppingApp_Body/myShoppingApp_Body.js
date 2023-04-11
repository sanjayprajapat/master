import { LightningElement, wire, track, api } from "lwc";
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import myShoppingAppHeader from '@salesforce/resourceUrl/myShoppingAppHeader';
import myShoppingApp_bodyResources from '@salesforce/resourceUrl/myShoppingApp_bodyResources';
import { NavigationMixin } from 'lightning/navigation';
import getAllProductList from '@salesforce/apex/MyShoppingApp_Body_Controller.getAllProductList';
import isguest from '@salesforce/user/isGuest';

export default class MyShoppingApp_Body extends NavigationMixin(LightningElement) {
    @track topOffers = myShoppingApp_bodyResources + '/topOffers.png';
    @track grocery = myShoppingApp_bodyResources + '/Grocery.png';
    @track mobile = myShoppingApp_bodyResources + '/mobile.png';
    @track fashion = myShoppingApp_bodyResources + '/fashion.png';
    @track electronic = myShoppingApp_bodyResources + '/Electronic.png';
    @track beautyToysAndMore = myShoppingApp_bodyResources + '/beautyToysAndMore.png';
    @track slide1 = myShoppingApp_bodyResources + '/slide1.jpg';
    @track slide2 = myShoppingApp_bodyResources + '/slide2.jpg';
    @track slide3 = myShoppingApp_bodyResources + '/slide3.jpg';
    @track slide4 = myShoppingApp_bodyResources + '/slide4.jpg';
    @track prefixURL = '/sfc/servlet.shepherd/version/download/';
    @track productList;
    @track productMapWithImage;
    @track isGuest = isguest;

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
        this.getAllProductList();
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

    getAllProductList() {
        getAllProductList({
            'isGuest':this.isGuest,
        })
            //Promise method to get data from server
            .then(result => {
                if (result) {
                    console.log('result in Body == ',result);
                    this.productMapWithImage = this.convertObjectToMap(result.mapOfProductAndImage);
                    var listOfProductTemp = [];
                    result.listOfProducts.forEach((product, index) => {
                        if (this.productMapWithImage && this.productMapWithImage.get(product.Id)) {
                            product["imageUrlList"] = this.productMapWithImage.get(product.Id);
                            if (this.productMapWithImage.get(product.Id).length >= 0) {
                                product["singleImg"] = this.productMapWithImage.get(product.Id)[0];
                            }
                            if(product.Product_Description__c){
                                product["descriptionList"] = product.Product_Description__c.trim().split(',');
                            }
                        }
                        listOfProductTemp.push(product);
                    });
                    this.productList = listOfProductTemp;
                }
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            });
    }
}