import { LightningElement ,track,api} from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import myShoppingAppHeader from '@salesforce/resourceUrl/myShoppingAppHeader';
import MyShoppingAppResources from '@salesforce/resourceUrl/MyShoppingAppResources';

export default class MyShoppingApp_Footer extends LightningElement {

    @track locationIcon = MyShoppingAppResources + '/location.svg';
    @track phoneIcon = MyShoppingAppResources + '/phone.svg';
    @track messageIcon = MyShoppingAppResources + '/email.svg';
    @track facebookIcon = MyShoppingAppResources + '/facebook1.svg';
    @track twitterIcon = MyShoppingAppResources + '/twitter1.svg';
    @track instaIcon = MyShoppingAppResources + '/instagram1.svg';    

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
}