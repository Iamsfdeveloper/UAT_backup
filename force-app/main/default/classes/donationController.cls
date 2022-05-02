public class donationController {
    @AuraEnabled
    public static donationWrapper doInit(){
        donationWrapper wrapper = new donationWrapper();
        wrapper.userType =userInfo.getUserType();
        if(userInfo.getUserType() =='Guest')
            wrapper.isGuestUser = true;
        else
            wrapper.isGuestUser = false;
        return wrapper;
    }
    
    public class donationWrapper{
        @AuraEnabled 
        public Boolean isGuestUser {get;set;} 
         @AuraEnabled 
        public String userType {get;set;} 
    }
}