import { LightningElement, api, track } from "lwc";
import getImageURL from "@salesforce/apex/ImageViewer.getImageURL";
import {
  subscribe,
  unsubscribe,
  createMessageContext,
  releaseMessageContext
} from "lightning/messageService";
import fileUploadMsgChannel from "@salesforce/messageChannel/FileUpload__c";

export default class ImageFromContentDocument extends LightningElement {
  @api recordId;
  @track receivedMessage = "";
  subscription = null;
  context = createMessageContext();
  contentDocImage;
  showLoader = false;
  filterByLinkedEntity = true;
  imageType = '';
  imageDescription = '';
  imageUploadDate = '';
  imageTitle = '';
  connectedCallback() {
    this.subscribeMC();
  }

  getRecord() {
    getImageURL({
      filterId: this.receivedMessage,
      filterByLinkedEntity: this.filterByLinkedEntity
    })
      .then((result) => {
        console.log(result);
        this.contentDocImage = result.imageURL;
        this.imageDescription = result.imageDescription;
        this.imageUploadDate = result.imageUploadDate;
        this.imageTitle = result.imageTitle;
        this.imageType = result.imageType;
        this.showLoader = false;
      })
      .catch((error) => {
        console.log(error);
      });
  }

  get resizedImageUrl() {
    if (this.contentDocImage) {
      return this.contentDocImage;
    }
    return null;
  }

  subscribeMC() {
    this.receivedMessage = this.recordId;
    console.log("this.receivedMessage " + this.receivedMessage);
    this.getRecord();
    if (this.subscription) {
      return;
    }
    this.subscription = subscribe(
      this.context,
      fileUploadMsgChannel,
      (message) => {
        this.displayMessage(message);
      }
    );
  }

  unsubscribeMC() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  displayMessage(message) {
    this.receivedMessage = message ? message.recordId : "no message payload";
    this.showLoader = true;
    this.filterByLinkedEntity = false;
    this.getRecord();
  }

  disconnectedCallback() {
    releaseMessageContext(this.context);
  }
}
