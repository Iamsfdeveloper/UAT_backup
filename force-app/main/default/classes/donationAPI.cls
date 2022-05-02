@RestResource(urlMapping='/donation/v1/*')
global without Sharing class donationAPI {
    @HttpPost
    global static void doPost(){
       List<Basket__c > donationsToInsert = new List<Basket__c>();
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        
        try{
           
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            Map<String,Object> request =(Map<String,Object>)JSON.deserializeUntyped(req.requestBody.toString());
            List<Object> newDonationList = (List<Object>)request.values()[0];
            for(Object obj:newDonationList){
                Basket__c temp = new Basket__c();
                Map<String,Object> tempMap = (Map<String,Object>)obj;
                List<Object> baskestDetails = (List<Object>)tempMap.values()[0];
                Map<String,Object> baskestDetailsMap = (Map<String,Object>)baskestDetails[0];
                temp.Donor_Details__c = JSON.serialize(baskestDetailsMap.get('Supporter'), true);
                Map<String,Object> baskestgroupMap  = (Map<String,Object>)baskestDetailsMap.get('Basket');
                temp.CurrencyIsoCode = String.valueOf(baskestgroupMap.get('CurrencyISOCode'));
                temp.Basket_Details__c = JSON.serialize(baskestDetailsMap.get('Basket'), true);
                temp.Payment_Details__c = JSON.serialize(baskestDetailsMap.get('PaymentMethods'), true);
                //Todo Change API Name of the feild Basket_External_Id__c => CheckoutId__c
                temp.Basket_External_Id__c = String.valueOf(baskestDetailsMap.get('CheckoutId'));
                
                temp.BasketId__c = String.valueOf(baskestDetailsMap.get('BasketId'));
                temp.Status__c = String.valueOf(baskestDetailsMap.get('Status'));
                String transactionTimeUtc = baskestDetailsMap.get('TransactionTimeUtc').toString();
                temp.Donation_Date_Time__c = DateTime.valueOf(transactionTimeUtc.replace('T', ' '));
                temp.Regional_Office_Code__c = String.valueOf(baskestDetailsMap.get('SiteCode'));
                temp.Basket_Source__c = 'Website';
                donationsToInsert.add(temp);
            }
            if(donationsToInsert.size()>0)
                upsert donationsToInsert Basket_External_Id__c;
            gen.writeFieldName('JsonResponse');
            gen.writeStartArray();
            for(Basket__c d:donationsToInsert){
                gen.writeStartObject();
                    gen.writeStringField('BasketId', d.Basket_External_Id__c);
                    gen.writeStringField('DonationId', d.Id);
                gen.writeEndObject();
            }
            gen.writeEndArray();
            gen.writeBooleanField ('IsError', false);
            gen.writeStringField('ErrorMessage', '');
            gen.writeStringField ('HttpResponseCode ', 'OK');
            gen.writeEndObject();
            gen.close();
            res.responseBody = Blob.valueOf(gen.getAsString());

        }catch(Exception ex){
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeBooleanField ('IsError', true);
            gen.writeStringField('ErrorMessage', ex.getMessage()+'-'+ex.getStackTraceString());
            gen.writeStringField ('HttpResponseCode ', 'Redirect');
            gen.writeEndObject();
            gen.close();
            res.statusCode = 417;
            res.responseBody = Blob.valueOf(gen.getAsString());
        }
        
         
        
        
        
        
    }
}