import { LightningElement } from 'lwc';
import {
  subscribe,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext
} from "lightning/messageService";


/**
  * @slot header
  * @slot sidebar
  */
export default class ShoppingAppBaseCustomLayout extends LightningElement {}