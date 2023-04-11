public without sharing class MetadataDeploy implements Metadata.DeployCallback{
    
    public List<FieldWrapper> listField{get;set;}
    public class FieldWrapper
    {
        public String fieldName {get; set;}
        public String fieldAPIName {get; set;}
    }
    
    public static String updateCustomMetadata()
    {
        try {
            Google_Token__mdt tcm = getMetaDataRecords()[0]; //retrieving custom metadata records, using the first.
            Id customMetadataId = tcm.Id;
            system.debug('CustomMetadata Id ' + customMetadataId);
            Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
            customMetadata.fullName = 'Google_Token.Test_Sanjay'; //custom metadata name
            customMetadata.label = 'Test Sanjay';           
            Metadata.CustomMetadataValue customField1 = new Metadata.CustomMetadataValue(); //the values you're changing/updating
            customField1.field = 'scope__c'; //the custom field API Name that you're wanting to insert/update a value of
            customField1.value = 'testing';
            customMetadata.values.add(customField1);//add the changes to list of changes to be deployed            
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            mdContainer.addMetadata(customMetadata);
            
            MetadataDeploy callback = new MetadataDeploy();            
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);           
            return 'Success';
            
        }
        catch (Exception e) {
            return e.getMessage();
        }
    }
    public static list<Google_Token__mdt> getMetaDataRecords()
    {
        list<Google_Token__mdt> tcm = [Select Id, label FROM Google_Token__mdt];
        return tcm;
    }
    
    
    // find all sObjects available in the organization
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if(result.status == Metadata.DeployStatus.SUCCEEDED)
        {
            //success
            System.debug(' ===>'+ result);
        }else{
            //not success
            System.debug(' ===> fail '+ result);
        }
        
    }
}