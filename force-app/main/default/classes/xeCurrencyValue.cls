public class xeCurrencyValue {
    private static string ACCOUNT_ID ='iamsfdeveloper206114937';
    private static String API_KEY = '1i7pv2mlb94e57gas75kdggti0';
    
    private static String getBase64Encode(){
        return EncodingUtil.base64Encode(Blob.valueOf(ACCOUNT_ID+':'+API_KEY));
    }
	//https://xecdapi.xe.com/v1/convert_from.json/?from=USD&to=CAD,EUR&amount=110.23
	
    public Static void getXEValue(){
        List<CurrencyType> supportedCurrencies = [SELECT Id, IsoCode, ConversionRate, DecimalPlaces, IsActive, IsCorporate FROM CurrencyType];
        String toCurrencyISOCode = '';
        String fromCurrencyISOCode ='';
        Integer toCurrencyCount =0;
        for(CurrencyType ct:supportedCurrencies){
            if(ct.IsCorporate)
              fromCurrencyISOCode =  ct.IsoCode;
            else if(ct.IsActive){
                toCurrencyCount++;
                if(toCurrencyCount>1)
                 toCurrencyISOCode +=',';  
                toCurrencyISOCode += ct.IsoCode;
            }
			
                
        }
        makeCallout(fromCurrencyISOCode,toCurrencyISOCode);
       
    }
    public static void makeCallout(String fromCurrencyISOCode, String toCurrencyISOCode){
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Basic '+getBase64Encode());
        request.setMethod('GET');
        request.setEndpoint('https://xecdapi.xe.com/v1/convert_from.json/?from='+fromCurrencyISOCode+'&to='+toCurrencyISOCode+'&amount=1.00');
        Http http = new Http();
        HttpResponse response = http.send(request);
        currencyISOWrapper obj = currencyISOWrapper.parse(response.getBody());
        System.debug('obj===>'+obj);
        System.debug('response===>'+response.getBody());
        makeCalloutTOUpdateCurrencyType(obj);
        
    }
    public static void makeCalloutTOUpdateCurrencyType(currencyISOWrapper obj) {
        
        for(currencyISOWrapper.To temp : obj.To){
            System.debug('obj '+temp);
            if(temp !=null){
                Http h = new Http (); 
                HttpRequest req = new HttpRequest (); 
                req.setEndpoint ( URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v53.0/sobjects/CurrencyType/' ); 
                req.setMethod ( 'POST' ); 
                req.setBody ( '{ "IsoCode" : '+temp.quotecurrency+', "DecimalPlaces" : 2, "ConversionRate" : '+temp.mid+', "IsActive" : "true" }' ); 
                req.setHeader ( 'Authorization' , 'OAuth ' + UserInfo.getSessionId()); 
                req.setHeader ( 'Content-Type' , 'application/json' ); 
                HttpResponse res = h . send ( req );
            }
        }
    }
}