public with sharing class FileUploadHandler {
    @AuraEnabled
    public static String uploadImage(String fileName, String base64, String recordId){
        try {
          ContentVersion cv = createContentVersion(base64, filename);
          ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
          if (cv == null || cdl == null) { return null; }
          return cdl.ContentDocumentId;
        } catch (Exception e) {
          System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = 'Image'+DateTime.Now()+'.jpg';
        cv.PathOnClient = 'Image'+DateTime.Now()+'.jpg';
        cv.Description = 'latest Contact Image';
        try {
          insert cv;
          return cv;
        } catch(DMLException e) {
          System.debug(e);
          return null;
        }
      }

        private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
            if (contentVersionId == null || recordId == null) { return null; }
              ContentDocumentLink cdl = new ContentDocumentLink();
              cdl.ContentDocumentId = [
                SELECT ContentDocumentId 
                FROM ContentVersion 
                WHERE Id =: contentVersionId
              ].ContentDocumentId;
              cdl.LinkedEntityId = recordId;
              cdl.ShareType = 'V';
          try {
            insert cdl;
            return cdl;
          } catch(DMLException e) {
            System.debug(e);
            return null;
          }
        }
}