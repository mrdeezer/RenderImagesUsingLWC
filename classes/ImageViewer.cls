public without sharing class ImageViewer {
    @AuraEnabled
    public static ImageDetailsWrapper getImageURL(Id filterId, Boolean filterByLinkedEntity){
        try {
            List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
            if(!filterByLinkedEntity) {
                contentDocumentLinks = [SELECT ContentDocument.FileExtension, ContentDocument.LatestPublishedVersion.Title, ContentDocument.ContentModifiedDate, ContentDocument.LatestPublishedVersion.VersionData, ContentDocument.Description
                    FROM ContentDocumentLink
                    WHERE ContentDocumentId = : filterId
                    LIMIT 1];
            } else {
                contentDocumentLinks = [SELECT ContentDocument.FileExtension, ContentDocument.LatestPublishedVersion.Title, ContentDocument.ContentModifiedDate, ContentDocument.LatestPublishedVersion.VersionData, ContentDocument.Description
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = : filterId
                    LIMIT 1];
            }
            

            String base64Data;
            if(!contentDocumentLinks.isEmpty()) {
                ContentDocumentLink cdl = contentDocumentLinks[0];
                base64Data = 'data:image/' + cdl.ContentDocument.FileExtension + ';charset=utf-8;base64, ';
                base64Data += EncodingUtil.base64Encode(cdl.ContentDocument.LatestPublishedVersion.VersionData);
            }
            ImageDetailsWrapper obj = new ImageDetailsWrapper();
            obj.imageURL = base64Data;
            obj.imageType = contentDocumentLinks[0].ContentDocument.FileExtension;
            obj.imageDescription = contentDocumentLinks[0].ContentDocument.Description;
            obj.imageUploadDate = String.valueOf(contentDocumentLinks[0].ContentDocument.ContentModifiedDate);
            obj.imageTitle = contentDocumentLinks[0].ContentDocument.LatestPublishedVersion.Title;
            return obj;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ImageDetailsWrapper {
        @AuraEnabled
        public String imageURL;
        @AuraEnabled
        public String imageType;
        @AuraEnabled
        public String imageDescription;
        @AuraEnabled
        public String imageUploadDate;
        @AuraEnabled
        public String imageTitle;
    }

    // @AuraEnabled
    // public static string getRecentImageURL(String recordId){
    //     try {
    //         List<Id> linkedEntityIds = new List<Id>();
    //         conDocIds.add(recordId);
    //         List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocument.FileExtension, ContentDocument.LatestPublishedVersion.Title, ContentDocument.LatestPublishedVersion.VersionData
    //                 FROM ContentDocumentLink
    //                 WHERE LinkedEntityId IN : linkedEntityIds
    //                 LIMIT 1];

    //         String base64Data;
    //         if(!contentDocumentLinks.isEmpty()) {
    //             ContentDocumentLink cdl = contentDocumentLinks[0];
    //             base64Data = 'data:image/' + cdl.ContentDocument.FileExtension + ';charset=utf-8;base64, ';
    //             base64Data += EncodingUtil.base64Encode(cdl.ContentDocument.LatestPublishedVersion.VersionData);
    //         }
    //         System.debug('base64Data '+base64Data);
    //         return base64Data;
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }
}