global class SMP_DDServiceBankAccountModel {

    public ProcessMessageResult ProcessMessageResult;

    public class ProcessMessageResult {
        public Boolean AccountCodeOK = false;
        public String AccountNumber;
        public String BankAddress1;
        public String BankAddress2;
        public String BankAddress3;
        public String BankAddress4;
        public String BankAddressPostCode;
        public String BankAddressTown;
        public String BankName;
        public String BranchTitle;
        public Boolean CreditsAllowedOK = false;
        public Boolean DirectDebitInstructionOK = false;
        public Boolean DirectDebitsOK = false;
        public String Error;
        public String SortCode;
        public Boolean SortCodeOK = false;
        public String Telephone;
    }

    public SMP_DDServiceBankAccountModel(){
        ProcessMessageResult = new ProcessMessageResult();
    }

    public static SMP_DDServiceBankAccountModel parse(String json)
    {
        System.debug('#### Parsing SMP_DDServiceBankAccountModel');
        System.debug('#### json: '+json);

        return (SMP_DDServiceBankAccountModel) System.JSON.deserialize(json, SMP_DDServiceBankAccountModel.class);
    }

    public String compileBankAddress()
    {
        String address = '';

        if(String.isNotBlank(ProcessMessageResult.BankAddress1)){
            address = ProcessMessageResult.BankAddress1;            
        }

        if(String.isNotBlank(ProcessMessageResult.BankAddress2)){            
            address += ', ' + ProcessMessageResult.BankAddress2;
        }

        if(String.isNotBlank(ProcessMessageResult.BankAddress3)){            
            address += ', ' + ProcessMessageResult.BankAddress3;
        } 

        if(String.isNotBlank(ProcessMessageResult.BankAddress4)){            
            address += ', ' + ProcessMessageResult.BankAddress4;
        }

        System.Debug('#### address: ' + address);
        return address;
    }

    public void copyFieldsToDirectDebitRecord(Income_Direct_Debit__c directDebit)
    {
        directDebit.DD_Account_Number_OK__c = ProcessMessageResult.AccountCodeOK;
        directDebit.DD_Sort_Code_OK__c = ProcessMessageResult.SortCodeOK; 
        directDebit.DD_OK__c = ProcessMessageResult.DirectDebitsOK;
        directDebit.DD_Bank_Name__c = ProcessMessageResult.BankName;
        directDebit.DD_Branch_Name__c = ProcessMessageResult.BranchTitle;
        directDebit.DD_Bank_Address__c =  compileBankAddress();
        directDebit.DD_Bank_City__c = ProcessMessageResult.BankAddressTown;
        directDebit.DD_Bank_Postcode__c = ProcessMessageResult.BankAddressPostCode;
        directDebit.DD_Bank_Phone__c = ProcessMessageResult.Telephone;         
    }
}