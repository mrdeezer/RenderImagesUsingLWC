import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import uploadImage from "@salesforce/apex/FileUploadHandler.uploadImage";
import {
  publish,
  createMessageContext,
  releaseMessageContext
} from "lightning/messageService";
import fileUploadMsgChannel from "@salesforce/messageChannel/FileUpload__c";

export default class UploadContactPhoto extends LightningElement {
  @api recordId;
  imageData;
  context = createMessageContext();
  fileId;
  handleFileUpload(event) {
    const file = event.target.files[0];
    var reader = new FileReader();
    reader.onload = () => {
      var base64 = reader.result.split(",")[1];
      this.imageData = {
        filename: "test.jpg",
        base64: base64,
        recordId: this.recordId
      };
    };
    reader.readAsDataURL(file);
  }

  handleUpload(event) {
    const { fileName, base64, recordId } = this.imageData;
    uploadImage({ fileName, base64, recordId })
        .then(result => {
            this.imageData = null;
            let title = 'Photo uploaded successfully!!';
            this.toast(title);
            this.fileId = result;
            this.publishMC();
        })
        .catch(error => {
            console.log(error);
        });
}
  toast(title) {
    const toastEvent = new ShowToastEvent({
      title,
      variant: "success"
    });
    this.dispatchEvent(toastEvent);
  }

  publishMC() {
    const message = {
      recordId: this.fileId
    };
    publish(this.context, fileUploadMsgChannel, message);
  }
}