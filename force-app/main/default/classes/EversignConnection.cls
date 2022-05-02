public class EversignConnection {
    
    Static String YOUR_ACCESS_KEY  = 'b6308c6ce5fe66d6302ed2dde3d616ef';
    Static String businessId = '377444';
    Static String OBJECT_FIELD_TYPE = 'Object Field';
    Static String ROLE_TYPE = 'Role';
    Static String VALUE_TYPE = 'Value';
    Static String FORMULA_TYPE = 'Formula';
    
    Static Map<String,String> mapTemplateNameId = new Map<String,String>{Label.Field_Office_Funding_Agreement_Template => 	Label.Field_Office_Funding_Agreement_TemplateId ,
        																 Label.Partner_Funding_Agreement_Template  => Label.Partner_Funding_Agreement_TemplateId};
	
          
     public static void getDocuments(Id conceptNoteId) { 
        
        Concept_Note__c objConceptNote = [SELECT Id,Eversign_FO_Document_Id__c FROM Concept_Note__c WHERE Id=:conceptNoteId];
         
        HttpRequest request = new HttpRequest();
       	request.setEndpoint('https://api.eversign.com/api/document?access_key='+YOUR_ACCESS_KEY+'&business_id='+businessId+'&document_hash='+objConceptNote.Eversign_FO_Document_Id__c);
        request.setMethod('GET');

        
        Http http = new Http();
        HTTPResponse res = http.send(request);
        System.debug('***:-'+res.getBody());
        EversignResponse everRes  = (EversignResponse)JSON.deserialize(res.getBody(),EversignResponse.class);
        
         if (everRes.is_draft == 1) {
             
             objConceptNote.Field_Office_Agreement_Status__c = 'Draft';
         }
         else if (everRes.is_completed == 1) {
             
             objConceptNote.Field_Office_Agreement_Status__c = 'Completed';
         }
         else if (everRes.is_archived == 1) {
             
             objConceptNote.Field_Office_Agreement_Status__c = 'Archived';
         }
         else if (everRes.is_deleted == 1) {
             
             objConceptNote.Field_Office_Agreement_Status__c = 'Deleted';
         }
         else {
             
             objConceptNote.Field_Office_Agreement_Status__c = 'In Progress';
         }
         
        
         
        
        Map<String,Set<Id>> mapDocIdByFund = new Map<String,Set<Id>>(); 
        for (Fund_Allocation__c objFundAllo : [SELECT Id,Eversign_Partner_Document_Id__c ,Concept_Note__c FROM Fund_Allocation__c WHERE Concept_Note__c =:conceptNoteId]) {
             
            if (mapDocIdByFund.containsKey(objFundAllo.Eversign_Partner_Document_Id__c )) {
                
                mapDocIdByFund.get(objFundAllo.Eversign_Partner_Document_Id__c ).add(objFundAllo.Id);
            }
            else {
                
                mapDocIdByFund.put(objFundAllo.Eversign_Partner_Document_Id__c , new Set<Id>{objFundAllo.Id});
            }
        }
         
         List<Fund_Allocation__c> lstFundAll = new List<Fund_Allocation__c>();
         for (String DocuId : mapDocIdByFund.keyset()) {
             
             request = new HttpRequest();
             request.setEndpoint('https://api.eversign.com/api/document?access_key='+YOUR_ACCESS_KEY+'&business_id='+businessId+'&document_hash='+DocuId);
             request.setMethod('GET');
             
             
             http = new Http();
             res = http.send(request);
             System.debug('***:-'+res.getBody());
             everRes  = (EversignResponse)JSON.deserialize(res.getBody(),EversignResponse.class);
             
             String status = 'In Progress' ;
             
             if (everRes.is_draft == 1) {
                 
                 status = 'Draft';
             }
             else if (everRes.is_completed == 1) {
                 
                 status = 'Completed';
             }
             else if (everRes.is_archived == 1) {
                 
                 status = 'Archived';
             }
             else if (everRes.is_deleted == 1) {
                 
                 status = 'Deleted';
             }
             
             for (Id fundAlloId : mapDocIdByFund.get(DocuId)) {
                 
                 lstFundAll.add(new Fund_Allocation__c(Id = fundAlloId,Partner_Agreement_Signature_Status__c = status)); 
             }
         }
         
         if (!lstFundAll.isEmpty()) {
             
             update lstFundAll;
         }
         
         update objConceptNote;
        
    }                                                                         
    
    public static void getTemplates() {
        
        HttpRequest request = new HttpRequest();
       	request.setEndpoint('https://api.eversign.com/api/document?access_key='+YOUR_ACCESS_KEY+'&business_id='+businessId+'&document_hash=015637d1e6c7473bbb595dd0ab35a6e2');
        request.setMethod('GET');

        //System.debug('***:-'+strReqBody);
        
        Http http = new Http();
        HTTPResponse res = http.send(request);
        System.debug('***:-'+res.getBody());
        
    }
    
    public static void createTemplate() {
        
        HttpRequest request = new HttpRequest();
       	request.setEndpoint('https://api.eversign.com/api/document?access_key='+YOUR_ACCESS_KEY+'&business_id='+businessId);
        request.setMethod('POST');
		String strReqBody = '{"sandbox": 0,"is_template": 1,"is_draft": 0,"title": "HA Funding Agreement FO V8 Template v1.docx","message": "","use_signer_order": 1,"reminders": 0,"require_all_signers": 0,"files":[ {"name": "HA Funding Agreement FO V8 Template v1.docx","file_url": "https://humanappeal--phase2dev2.my.salesforce.com/sfc/p/3M0000000Z0p/a/3M0000008aHC/0sHvVBs82tN3iNvxmHmHARiFv4S2fTOOsQdaafdh7zc","file_id": "","file_base64": "" }],"signers":[ {"id":1,"name":"","email":"","role":"For Human Appeal","order":1,"required":1 }, {"id":2,"name":"","email":"","role":"For Partner","order":2,"required":1 }, {"id":3,"name":"","email":"","role":"Approved By","order":3,"required":1, }],"recipients":[],"fields":[ [{"merge":1,"identifier":"Partner_Name_1","name":"Partner_Name_1","options":"","group":"","value":"","type":"note","x":242.34539839858,"y":132.52242107831,"page":1,"width":120,"height":15,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Project_Name_1","name":"Project_Name_1","options":"","group":"","value":"","type":"note","x":263.53059412811,"y":149.47442685383,"page":1,"width":113,"height":15,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Partner_Name_2","name":"Partner_Name_2","options":"","group":"","value":"","type":"note","x":71.599341192171,"y":222.82050264384,"page":1,"width":107,"height":14,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Registered_Country","name":"Registered_Country","options":"","group":"","value":"","type":"note","x":304.20616992883,"y":224.51636566788,"page":1,"width":108,"height":15,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Location","name":"Location","options":"","group":"","value":"","type":"note","x":71.804572775801,"y":237.62618177955,"page":1,"width":109,"height":14,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Partner_Name_3_1","name":"Partner_Name_3_1","options":"","group":"","value":"","type":"note","x":464.79657393238,"y":274.12698358618,"page":1,"width":84,"height":14,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Partner_Name_3_2","name":"Partner_Name_3_2","options":"","group":"","value":"","type":"note","x":64.409615391459,"y":285.26933361136,"page":1,"width":61,"height":15,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Project_Name_2","name":"Project_Name_2","options":"","group":"","value":"","type":"note","x":379.63208709964,"y":288.11785353456,"page":1,"width":104,"height":14,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Project_Reference","name":"Project_Reference","options":"","group":"","value":"","type":"note","x":161.04720978648,"y":488.32905734609,"page":1,"width":108,"height":17,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Project_Duration","name":"Project_Duration","options":"","group":"","value":"","type":"note","x":156.00910542705,"y":505.53279278925,"page":1,"width":108,"height":16,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Start_Date","name":"Start_Date","options":"","group":"","value":"","type":"note","x":171.83179848754,"y":522.80277288178,"page":1,"width":115,"height":17,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"End_Date","name":"End_Date","options":"","group":"","value":"","type":"note","x":301.24024252669,"y":523.52483955999,"page":1,"width":120,"height":16,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Direct_Beneficiaries","name":"Direct_Beneficiaries","options":"","group":"","value":"","type":"note","x":170.38855702847,"y":602.74681574972,"page":1,"width":107,"height":18,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Indirect_Beneficiaries","name":"Indirect_Beneficiaries","options":"","group":"","value":"","type":"note","x":385.36533069395,"y":602.74681574972,"page":1,"width":110,"height":18,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Partner_Name_3","name":"Partner_Name_3","options":"","group":"","value":"","type":"note","x":187.64787117438,"y":633.62344682425,"page":1,"width":117,"height":18,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Fund_Allocated","name":"Fund_Allocated","options":"","group":"","value":"","type":"note","x":288.17162491103,"y":714.38229887952,"page":1,"width":101,"height":16,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Number_Of_Installments","name":"Number_Of_Installments","options":"","group":"","value":"","type":"note","x":202.45102669039,"y":232.08150462672,"page":2,"width":106,"height":16,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Expendable_Equipment_Amount","name":"Expendable_Equipment_Amount","options":"","group":"","value":"","type":"note","x":267.35717010676,"y":433.65072375047,"page":2,"width":108,"height":15,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Withhold","name":"Withhold","options":"","group":"","value":"","type":"note","x":184.31120284698,"y":469.47583013345,"page":4,"width":170,"height":15,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Vary_Specify_Timeframe","name":"Vary_Specify_Timeframe","options":"","group":"","value":"","type":"note","x":325.61645836299,"y":98.996004028705,"page":6,"width":107,"height":14,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Vary_Budget_by_more_than","name":"Vary_Budget_by_more_than","options":"","group":"","value":"","type":"note","x":274.98384056939,"y":113.55657796173,"page":6,"width":106,"height":14,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Behalf_Of_HA","name":"Behalf_Of_HA","options":"","group":"","value":"","type":"note","x":141.51710747331,"y":180.01321021654,"page":9,"width":141,"height":18,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Partner_Name_4","name":"Partner_Name_4","options":"","group":"","value":"","type":"note","x":375.82537224199,"y":155.84716212388,"page":9,"width":108,"height":18,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Behalf_Of_Partner","name":"Behalf_Of_Partner","options":"","group":"","value":"","type":"note","x":345.74239430605,"y":179.16527870452,"page":9,"width":118,"height":17,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Date","name":"Date","options":"","group":"","value":"","type":"note","x":98.723012099644,"y":678.59693928616,"page":9,"width":122,"height":17,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Prepared_By","name":"Prepared_By","options":"","group":"","value":"","type":"note","x":291.08458932384,"y":677.32504201813,"page":9,"width":129,"height":18,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Project_Title","name":"Project_Title","options":"","group":"","value":"","type":"note","x":186.42972241993,"y":720.56954913131,"page":9,"width":320,"height":18,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Project_Code","name":"Project_Code","options":"","group":"","value":"","type":"note","x":186.85342633452,"y":741.34387117588,"page":9,"width":319,"height":18,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"signature_jOXYq7kVRbt0uh","name":"Signature","options":"","group":"","value":"","type":"signature","x":159.73637580071,"y":200.69478975198,"page":9,"width":111,"height":27,"signer":1,"validation_type":"","required":1,"readonly":0,"text_size":"","text_color":"","text_style":"","text_font":""},{"merge":0,"identifier":"date_signed_w0IUygX91JqEKS","name":"Date_signed","options":"","group":"","value":"","type":"date_signed","x":138.97488398577,"y":235.03601598892,"page":9,"width":60,"height":17,"signer":1,"validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"signature_ejSiiNmtKWpC6o","name":"Signature","options":"","group":"","value":"","type":"signature","x":364.80907046263,"y":201.11875550799,"page":9,"width":115,"height":27,"signer":2,"validation_type":"","required":1,"readonly":0,"text_size":"","text_color":"","text_style":"","text_font":""},{"merge":0,"identifier":"date_signed_69pWMnw9H91onx","name":"Date_signed","options":"","group":"","value":"","type":"date_signed","x":344.89498647687,"y":234.61205023291,"page":9,"width":60,"height":17,"signer":2,"validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Location_Of_Project","name":"Location_Of_Project","options":"","group":"","value":"","type":"note","x":183.88749893238,"y":72.855865384615,"page":10,"width":112,"height":17,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Project_Country","name":"Project_Country","options":"","group":"","value":"","type":"note","x":303.79570676157,"y":73.279831140627,"page":10,"width":133,"height":17,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Funds_Allocated_By","name":"Funds_Allocated_By","options":"","group":"","value":"","type":"note","x":186.00601850534,"y":112.28468069369,"page":10,"width":113,"height":20,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Number_Of_Instalments_Table","name":"Number_Of_Instalments_Table","options":"","group":"","value":"","type":"note","x":187.27713024911,"y":144.08211239456,"page":10,"width":113,"height":20,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Number_Of_Reports","name":"Number_Of_Reports","options":"","group":"","value":"","type":"note","x":185.58231459075,"y":177.15144136346,"page":10,"width":217,"height":19,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Type_Of_Report_1","name":"Type_Of_Report_1","options":"","group":"","value":"","type":"note","x":112.70524128114,"y":244.13803081329,"page":10,"width":129,"height":25,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Type_Of_Report_2","name":"Type_Of_Report_2","options":"","group":"","value":"","type":"note","x":112.70524128114,"y":278.1215359436,"page":10,"width":129,"height":25,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Type_Of_Report_3","name":"Type_Of_Report_3","options":"","group":"","value":"","type":"note","x":113.55264911032,"y":311.61483066851,"page":10,"width":129,"height":25,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Type_Of_Report_4","name":"Type_Of_Report_4","options":"","group":"","value":"","type":"note","x":114.4000569395,"y":344.68415963742,"page":10,"width":129,"height":25,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Type_Of_Report_5","name":"Type_Of_Report_5","options":"","group":"","value":"","type":"note","x":118.21339217082,"y":379.02538587435,"page":10,"width":129,"height":25,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Report_Due_1","name":"Report_Due_1","options":"","group":"","value":"","type":"note","x":264.81494661922,"y":244.62824121868,"page":10,"width":96,"height":23,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Notes_5","name":"Notes_5","options":"","group":"","value":"","type":"note","x":388.96019359431,"y":379.02538587435,"page":10,"width":129,"height":25,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Notes_4","name":"Notes_4","options":"","group":"","value":"","type":"note","x":388.11278576512,"y":345.53209114944,"page":10,"width":129,"height":25,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Notes_3","name":"Notes_3","options":"","group":"","value":"","type":"note","x":388.96019359431,"y":312.03879642452,"page":10,"width":129,"height":25,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Notes_2","name":"Notes_2","options":"","group":"","value":"","type":"note","x":387.26537793594,"y":278.54550169961,"page":10,"width":129,"height":25,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Notes_1","name":"Notes_1","options":"","group":"","value":"","type":"note","x":387.26537793594,"y":245.05220697469,"page":10,"width":129,"height":25,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Report_Due_2","name":"Report_Due_2","options":"","group":"","value":"","type":"note","x":265.23865053381,"y":278.1215359436,"page":10,"width":96,"height":23,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Report_Due_3","name":"Report_Due_3","options":"","group":"","value":"","type":"note","x":266.08605836299,"y":312.03879642452,"page":10,"width":103,"height":25,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Report_Due_4","name":"Report_Due_4","options":"","group":"","value":"","type":"note","x":266.50976227758,"y":345.10812539343,"page":10,"width":103,"height":25,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Report_Due_5","name":"Report_Due_5","options":"","group":"","value":"","type":"note","x":263.96753879004,"y":379.44935163037,"page":10,"width":106,"height":24,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Amount_1","name":"Amount_1","options":"","group":"","value":"","type":"note","x":111.01042562278,"y":469.33009190482,"page":10,"width":129,"height":25,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Payment_Actual_Date_1","name":"Payment_Actual_Date_1","options":"","group":"","value":"","type":"note","x":384.7231544484,"y":469.33009190482,"page":10,"width":129,"height":25,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Amount_2","name":"Amount_2","options":"","group":"","value":"","type":"note","x":111.43412953737,"y":500.27959209367,"page":10,"width":129,"height":25,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Amount_3","name":"Amount_3","options":"","group":"","value":"","type":"note","x":111.43412953737,"y":530.8051265265,"page":10,"width":129,"height":25,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Amount_4","name":"Amount_4","options":"","group":"","value":"","type":"note","x":111.85783345196,"y":562.60255822737,"page":10,"width":129,"height":25,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Amount_5","name":"Amount_5","options":"","group":"","value":"","type":"note","x":111.43412953737,"y":593.55205841622,"page":10,"width":129,"height":25,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Amount_6","name":"Amount_6","options":"","group":"","value":"","type":"note","x":110.58672170819,"y":624.92552436107,"page":10,"width":129,"height":25,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Payment_Actual_Date_2","name":"Payment_Actual_Date_2","options":"","group":"","value":"","type":"note","x":385.99426619217,"y":499.85562633766,"page":10,"width":129,"height":25,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Payment_Actual_Date_3","name":"Payment_Actual_Date_3","options":"","group":"","value":"","type":"note","x":385.14685836299,"y":531.22909228251,"page":10,"width":129,"height":25,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Payment_Actual_Date_4","name":"Payment_Actual_Date_4","options":"","group":"","value":"","type":"note","x":386.41797010676,"y":562.60255822737,"page":10,"width":129,"height":25,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Payment_Actual_Date_5","name":"Payment_Actual_Date_5","options":"","group":"","value":"","type":"note","x":387.26537793594,"y":593.55205841622,"page":10,"width":129,"height":25,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Payment_Actual_Date_6","name":"Payment_Actual_Date_6","options":"","group":"","value":"","type":"note","x":385.99426619217,"y":624.50155860506,"page":10,"width":129,"height":25,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Currency_table","name":"Currency_table","options":"","group":"","value":"","type":"note","x":131.77191743772,"y":443.0442150321,"page":10,"width":102,"height":17,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Payment_Due_Date_1","name":"Payment_Due_Date_1","options":"","group":"","value":"","type":"note","x":263.96753879004,"y":468.4821603928,"page":10,"width":103,"height":24,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Payment_Due_Date_2","name":"Payment_Due_Date_2","options":"","group":"","value":"","type":"note","x":265.6623544484,"y":500.70355784968,"page":10,"width":103,"height":24,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Payment_Due_Date_3","name":"Payment_Due_Date_3","options":"","group":"","value":"","type":"note","x":265.23865053381,"y":531.65305803852,"page":10,"width":103,"height":24,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Payment_Due_Date_4","name":"Payment_Due_Date_4","options":"","group":"","value":"","type":"note","x":264.39124270463,"y":563.02652398338,"page":10,"width":103,"height":24,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Payment_Due_Date_5","name":"Payment_Due_Date_5","options":"","group":"","value":"","type":"note","x":266.08605836299,"y":593.97602417223,"page":10,"width":103,"height":24,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Payment_Due_Date_6","name":"Payment_Due_Date_6","options":"","group":"","value":"","type":"note","x":266.08605836299,"y":625.7734558731,"page":10,"width":103,"height":24,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Behalf_Approval","name":"Behalf_Approval","options":"","group":"","value":"","type":"note","x":134.31414092527,"y":691.84586916153,"page":10,"width":117,"height":16,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Approval_Given_By","name":"Approval_Given_By","options":"","group":"","value":"","type":"note","x":102.96005124555,"y":710.92432818205,"page":10,"width":116,"height":15,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"signature_NaqjyhMqPwsgfW","name":"Signature","options":"","group":"","value":"","type":"signature","x":122.45043131673,"y":731.60590771749,"page":10,"width":88,"height":28,"signer":3,"validation_type":"","required":1,"readonly":0,"text_size":"","text_color":"","text_style":"","text_font":""},{"merge":0,"identifier":"date_signed_Omf5A6o5SR98a6","name":"Date_signed","options":"","group":"","value":"","type":"date_signed","x":242.35863914591,"y":729.48607893743,"page":10,"width":60,"height":17,"signer":3,"validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Project_Code_Insert","name":"Project_Code_Insert","options":"","group":"","value":"","type":"note","x":189.81935373665,"y":108.57498032859,"page":11,"width":157,"height":18,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"},{"merge":0,"identifier":"Project_Name_Insert","name":"Project_Name_Insert","options":"","group":"","value":"","type":"note","x":190.66676156584,"y":129.34930237316,"page":11,"width":169,"height":18,"signer":"OWNER","validation_type":"","required":0,"readonly":0,"text_size":10,"text_color":"#000000","text_style":"","text_font":"arial"} ]],"meta":[]}';
		CreateTemplate Jsonstr = (CreateTemplate)JSON.deserialize(strReqBody, CreateTemplate.class);
        String strReqBodyq = JSON.serialize(Jsonstr); 
        request.setBody(strReqBodyq);
        //System.debug('***:-'+strReqBody);
        
        Http http = new Http();
        HTTPResponse res = http.send(request);
        System.debug('***:-'+res.getBody());
        
    }
    
    public static Concept_Note__c createAgreementFODocument(String templateName, Id recordId) {
        
        
        HttpRequest request = new HttpRequest();
        request.setTimeout(120000);
       	request.setEndpoint('https://api.eversign.com/api/document?access_key='+YOUR_ACCESS_KEY+'&business_id='+businessId);
        request.setMethod('GET');
        CreateDocumentRequest reqBody = new CreateDocumentRequest();
        reqBody.sandbox = 0;
        reqBody.template_id = mapTemplateNameId.get(templateName);
        reqBody.message = 'Please sign the Agreement';
        reqBody.custom_requester_name = '';
        reqBody.custom_requester_email = '';
        reqBody.redirect = '';
        reqBody.redirect_decline = '';
        reqBody.client = '';
        reqBody.expires = '';
        reqBody.embedded_signing_enabled = 0;
        
        List<Eversign_Document_Field_Mapping__mdt> EversignFieldMapping = [SELECT Id,Object_Name__c,Type__c,Template_Name__c, 
                                                                           Saleforce_Reference__c,Eversign_Document_Field_Identifier__c	
                                                                           FROM Eversign_Document_Field_Mapping__mdt 
                                                                           WHERE Template_Name__c =:templateName];
        
        
        Map<String,List<Eversign_Document_Field_Mapping__mdt>> mapMappingByType = new Map<String,List<Eversign_Document_Field_Mapping__mdt>>();
        
        Set<String> setConceptNoteFields = new Set<String>();
        Set<String> setReportScheduleFields = new Set<String>();
        Set<String> setFundScheduleFields = new Set<String>();
        
        String strQueryCN = 'SELECT ';
        String strQueryRS = 'SELECT ';
        String strQueryFS = 'SELECT ';
        
        
        for (Eversign_Document_Field_Mapping__mdt objEverSign : EversignFieldMapping) {
            
            if (objEverSign.Type__c == OBJECT_FIELD_TYPE && objEverSign.Object_Name__c == 'Concept_Note__c' 
                && !setConceptNoteFields.contains(objEverSign.Saleforce_Reference__c)) {
                
                    strQueryCN = strQueryCN+objEverSign.Saleforce_Reference__c+', ';
                	setConceptNoteFields.add(objEverSign.Saleforce_Reference__c);
            }
            else if (objEverSign.Type__c == OBJECT_FIELD_TYPE && objEverSign.Object_Name__c == 'Report_Schedule__c' 
                && !setReportScheduleFields.contains(objEverSign.Saleforce_Reference__c)) {
                
                    strQueryRS = strQueryRS+objEverSign.Saleforce_Reference__c+', ';
                	setReportScheduleFields.add(objEverSign.Saleforce_Reference__c);
            }
            else if (objEverSign.Type__c == OBJECT_FIELD_TYPE && objEverSign.Object_Name__c == 'Fund_Transfer_Schedule__c' 
                && !setFundScheduleFields.contains(objEverSign.Saleforce_Reference__c)) {
                    
                    strQueryFS = strQueryFS+objEverSign.Saleforce_Reference__c+', ';
                	setFundScheduleFields.add(objEverSign.Saleforce_Reference__c);   
            }

            if (mapMappingByType.containsKey(objEverSign.Type__c)) {
                
                mapMappingByType.get(objEverSign.Type__c).add(objEverSign);
            }
            else {
                
                mapMappingByType.put(objEverSign.Type__c,new List<Eversign_Document_Field_Mapping__mdt>{objEverSign});
            }
        }

        
        Recipient recip = new Recipient();
        recip.name = 'Kalpesh Outlook';
        recip.email = 'kalpesh.thakur07@outlook.com';
        recip.language = 'en';
        //reqBody.recipients = new List<Recipient>{recip};
        
        List<Field> lstfields = new List<Field>();    

        strQueryCN = strQueryCN.removeEnd(', ');
        strQueryCN = strQueryCN+' FROM Concept_Note__c WHERE Id=\''+recordId+'\'';
        System.debug('****:--'+strQueryCN);
        Concept_Note__c objConcept = Database.Query(strQueryCN);
        System.debug('**objConcept**:-'+objConcept);
        
        strQueryRS = strQueryRS+'Concept_Note__c FROM Report_Schedule__c WHERE Concept_Note__c=\''+objConcept.Id+'\'';
        System.debug('****:--'+strQueryRS);
        List<Report_Schedule__c> lstReportSch = Database.Query(strQueryRS);
        System.debug('**lstReportSch**:-'+lstReportSch);
        
        strQueryFS = strQueryFS+'Concept_Note__c FROM Fund_Transfer_Schedule__c WHERE Concept_Note__c=\''+objConcept.Id+'\'';
        System.debug('****:--'+strQueryFS);
        List<Fund_Transfer_Schedule__c> lstFundSch = Database.Query(strQueryFS);
        System.debug('**lstFundSch**:-'+lstFundSch);

        Map<Id,String> userIdsRole = new Map<Id,String>();
      
        for (Eversign_Document_Field_Mapping__mdt objEverSign : EversignFieldMapping) {
            
            if (objEverSign.Object_Name__c == 'Concept_Note__c'&& objEverSign.Type__c == OBJECT_FIELD_TYPE && objEverSign.Saleforce_Reference__c == 'Implementation_Partner__r.BillingAddress') {
                
                List<String> lstRelationFields = objEverSign.Saleforce_Reference__c.split('\\.');
                System.debug('****:--'+objEverSign.Saleforce_Reference__c+lstRelationFields);
                Field fieldMap = new Field();
                fieldMap.identifier = objEverSign.Eversign_Document_Field_Identifier__c;
                Address addr = objConcept.Implementation_Partner__r.BillingAddress;
                fieldMap.value  = addr.getStreet()+','+addr.getCity()+','+addr.getState()+','+addr.getPostalCode()+','+addr.getCountry(); 
                lstfields.add(fieldMap);
            }
            else if (objEverSign.Saleforce_Reference__c.contains('.') && objEverSign.Object_Name__c == 'Concept_Note__c' && objEverSign.Type__c == OBJECT_FIELD_TYPE) {
                
                List<String> lstRelationFields = objEverSign.Saleforce_Reference__c.split('\\.');
                System.debug('****:--'+objEverSign.Saleforce_Reference__c+lstRelationFields);
                Field fieldMap = new Field();
                fieldMap.identifier = objEverSign.Eversign_Document_Field_Identifier__c;
                fieldMap.value  = String.valueOf(objConcept.getSobject(lstRelationFields[0]).get(lstRelationFields[1])); 
                lstfields.add(fieldMap);
                
            }
            else if (objEverSign.Object_Name__c == 'Concept_Note__c'&& objEverSign.Type__c == OBJECT_FIELD_TYPE) {
                
                Field fieldMap = new Field();
                fieldMap.identifier = objEverSign.Eversign_Document_Field_Identifier__c;
                fieldMap.value = String.valueOf(objConcept.get(objEverSign.Saleforce_Reference__c));
                lstfields.add(fieldMap);
            }
			else if (objEverSign.Object_Name__c == 'Report_Schedule__c' && objEverSign.Type__c == OBJECT_FIELD_TYPE) {
                
                Integer i = 1;
                for (Report_Schedule__c objReportSchedule : lstReportSch) {
                    
                    Field fieldMap = new Field();
                    fieldMap.identifier = objEverSign.Eversign_Document_Field_Identifier__c+'_'+i;
                	fieldMap.value = String.valueOf(objReportSchedule.get(objEverSign.Saleforce_Reference__c));
                    lstfields.add(fieldMap);
                    i++;
                }
            }    
            else if (objEverSign.Object_Name__c == 'Fund_Transfer_Schedule__c' && objEverSign.Type__c == OBJECT_FIELD_TYPE) {
                
                Integer i = 1;
                for (Fund_Transfer_Schedule__c objFundSchedule : lstFundSch) {
                    
                    Field fieldMap = new Field();
                    fieldMap.identifier = objEverSign.Eversign_Document_Field_Identifier__c+'_'+i;
                	fieldMap.value = String.valueOf(objFundSchedule.get(objEverSign.Saleforce_Reference__c));
                    lstfields.add(fieldMap);
                    i++;
                }
            }  
            else if (objEverSign.Type__c == ROLE_TYPE && objEverSign.Object_Name__c == 'Concept_Note__c') {
                
                userIdsRole.put(String.valueOf(objConcept.get(objEverSign.Saleforce_Reference__c)), objEverSign.Eversign_Document_Field_Identifier__c);
            }
            else if (objEverSign.Type__c == VALUE_TYPE) {
                
                Field fieldMap = new Field();
                fieldMap.identifier = objEverSign.Eversign_Document_Field_Identifier__c;
                fieldMap.value = objEverSign.Saleforce_Reference__c;
                lstfields.add(fieldMap);
            }
            else if (objEverSign.Type__c == FORMULA_TYPE) {
                
                Field fieldMap = new Field();
                fieldMap.identifier = objEverSign.Eversign_Document_Field_Identifier__c;
                
                if (objEverSign.Saleforce_Reference__c == 'Today') {
                    
                    fieldMap.value = String.valueOf(Date.today());
                }
                
                lstfields.add(fieldMap);
                
            }
        }
        
        List<Signer> lstSigner = new List<Signer>();
        List<Recipient> lstRecipient = new List<Recipient>();
        
        Map<Id,User> mapUser = new Map<Id,User>([SELECT Id,Name,UserName,Email FROM User WHERE Id=:userIdsRole.keySet()]);
        
        for (Eversign_Document_Field_Mapping__mdt objEverSign : EversignFieldMapping) {
            
			if (objEverSign.Type__c == ROLE_TYPE) {
                
                User objUser = mapUser.get(String.valueOf(objConcept.get(objEverSign.Saleforce_Reference__c)));
                Signer signUser = new Signer();
                signUser.role = objEverSign.Eversign_Document_Field_Identifier__c;
                signUser.name = objUser.Name;
                signUser.email = objUser.Email;
                signUser.pin = '';
                signUser.message = '';
                signUser.deliver_email = ''; 
                signUser.language = 'en';
                lstSigner.add(signUser);
                
                Recipient repUser = new Recipient();
                repUser.role = objEverSign.Eversign_Document_Field_Identifier__c;
                repUser.name = objUser.Name;
                repUser.email = objUser.Email; 
                repUser.language = 'en';
                lstRecipient.add(repUser);
                
            }
        }
           
        
        reqBody.signers = lstSigner;

        reqBody.fields = lstfields;
        
        reqBody.recipients = lstRecipient;
        
        reqBody.title = objConcept.Implementation_Partner__r.Name+'FO Funding Agreement';
        
        String strReqBody = JSON.serialize(reqBody); 
        
        strReqBody = strReqBody.replace(' 00:00:00', '');
        
        request.setBody(strReqBody);
        System.debug('***:-'+strReqBody);
        
        Http http = new Http();
        HTTPResponse res = http.send(request);
        System.debug('***:-'+res.getBody());
        EversignResponse everRes  = (EversignResponse)JSON.deserialize(res.getBody(),EversignResponse.class);
        objConcept.Eversign_FO_Document_Id__c = everRes.document_hash;
        objConcept.Field_Office_Agreement_Status__c = 'In Progress';
        return objConcept;
        
    }
    
    
    public static List<Fund_Allocation__c> createAgreementPartnerDocument(String templateName, Id recordId) {
        
        
        HttpRequest request = new HttpRequest();
        request.setTimeout(120000);
       	request.setEndpoint('https://api.eversign.com/api/document?access_key='+YOUR_ACCESS_KEY+'&business_id='+businessId);
        request.setMethod('GET');
        CreateDocumentRequest reqBody = new CreateDocumentRequest();
        reqBody.sandbox = 0;
        reqBody.template_id = mapTemplateNameId.get(templateName);
        reqBody.message = 'Please sign the Agreement';
        reqBody.custom_requester_name = '';
        reqBody.custom_requester_email = '';
        reqBody.redirect = '';
        reqBody.redirect_decline = '';
        reqBody.client = '';
        reqBody.expires = '';
        reqBody.embedded_signing_enabled = 0;
        
        List<Eversign_Document_Field_Mapping__mdt> EversignFieldMapping = [SELECT Id,Object_Name__c,Type__c,Template_Name__c, 
                                                                           Saleforce_Reference__c,Eversign_Document_Field_Identifier__c	
                                                                           FROM Eversign_Document_Field_Mapping__mdt 
                                                                           WHERE Template_Name__c =:templateName];
        
        
        Map<String,List<Eversign_Document_Field_Mapping__mdt>> mapMappingByType = new Map<String,List<Eversign_Document_Field_Mapping__mdt>>();
        
        Set<String> setConceptNoteFields = new Set<String>();
        Set<String> setReportScheduleFields = new Set<String>();
        Set<String> setFundScheduleFields = new Set<String>();
        Set<String> setFundAllocationFields = new Set<String>();
        
        String strQueryCN = 'SELECT ';
        String strQueryRS = 'SELECT ';
        String strQueryDS = 'SELECT ';
        String strQueryFA = 'SELECT ';
        
        
        for (Eversign_Document_Field_Mapping__mdt objEverSign : EversignFieldMapping) {
            
            if (objEverSign.Type__c == OBJECT_FIELD_TYPE && objEverSign.Object_Name__c == 'Concept_Note__c' 
                && !setConceptNoteFields.contains(objEverSign.Saleforce_Reference__c)) {
                
                    strQueryCN = strQueryCN+objEverSign.Saleforce_Reference__c+', ';
                	setConceptNoteFields.add(objEverSign.Saleforce_Reference__c);
            }
            else if (objEverSign.Type__c == OBJECT_FIELD_TYPE && objEverSign.Object_Name__c == 'Report_Schedule__c' 
                && !setReportScheduleFields.contains(objEverSign.Saleforce_Reference__c)) {
                
                    strQueryRS = strQueryRS+objEverSign.Saleforce_Reference__c+', ';
                	setReportScheduleFields.add(objEverSign.Saleforce_Reference__c);
            }
            else if (objEverSign.Type__c == OBJECT_FIELD_TYPE && objEverSign.Object_Name__c == 'Donor_Payment_Schedule__c' 
                && !setFundScheduleFields.contains(objEverSign.Saleforce_Reference__c)) {
                    
                    strQueryDS = strQueryDS+objEverSign.Saleforce_Reference__c+', ';
                	setFundScheduleFields.add(objEverSign.Saleforce_Reference__c);   
            } 
            else if (objEverSign.Type__c == OBJECT_FIELD_TYPE && objEverSign.Object_Name__c == 'Fund_Allocation__c' 
                && !setFundAllocationFields.contains(objEverSign.Saleforce_Reference__c)) {
                    
                    strQueryFA = strQueryFA+objEverSign.Saleforce_Reference__c+', ';
                	setFundAllocationFields.add(objEverSign.Saleforce_Reference__c);   
            }    

            if (mapMappingByType.containsKey(objEverSign.Type__c)) {
                
                mapMappingByType.get(objEverSign.Type__c).add(objEverSign);
            }
            else {
                
                mapMappingByType.put(objEverSign.Type__c,new List<Eversign_Document_Field_Mapping__mdt>{objEverSign});
            }
        }

        
         
        List<Field> lstfields = new List<Field>();    

        strQueryCN = strQueryCN.removeEnd(', ');
        strQueryCN = strQueryCN+' FROM Concept_Note__c WHERE Id=\''+recordId+'\'';
        System.debug('****:--'+strQueryCN);
        Concept_Note__c objConcept = Database.Query(strQueryCN);
        System.debug('**objConcept**:-'+objConcept);
        
        strQueryRS = strQueryRS+'Concept_Note__c FROM Report_Schedule__c WHERE Concept_Note__c=\''+objConcept.Id+'\'';
        System.debug('****:--'+strQueryRS);
        List<Report_Schedule__c> lstReportSch = Database.Query(strQueryRS);
        System.debug('**lstReportSch**:-'+lstReportSch);
        
        strQueryFA = strQueryFA+'Concept_Note__c FROM Fund_Allocation__c WHERE Concept_Note__c=\''+objConcept.Id+'\'';
        System.debug('****:--'+strQueryFA);
        List<Fund_Allocation__c> lstFundAll = Database.Query(strQueryFA);
        System.debug('**lstFundAll**:-'+lstFundAll);
        
        
        strQueryDS = strQueryDS+'Concept_Note__c,Fund_Allocation__c FROM Donor_Payment_Schedule__c WHERE Concept_Note__c=\''+objConcept.Id+'\'';
        System.debug('****:--'+strQueryDS);
        List<Donor_Payment_Schedule__c> lstDonorSch = Database.Query(strQueryDS);
        System.debug('**lstFundSch**:-'+lstDonorSch);
        /*
        Map<Id,List<Donor_Payment_Schedule__c>> mapDonorTransferByAllocation = new Map<Id,List<Donor_Payment_Schedule__c>>();
        
        for (Donor_Payment_Schedule__c objDonorSchedule : lstDonorSch) {
            
        	if (mapDonorTransferByAllocation.containsKey(objDonorSchedule.Funds_Allocation__c)) {
            	
                mapDonorTransferByAllocation.get(objDonorSchedule.Funds_Allocation__c).add(objDonorSchedule);
            }
            else {
                
                mapDonorTransferByAllocation.put(objDonorSchedule.Funds_Allocation__c,new List<Donor_Payment_Schedule__c>{objDonorSchedule});
            }
        }*/

        Map<Id,String> userIdsRole = new Map<Id,String>();
        
        Map<Id,List<Field>> mapfieldMapAllo = new  Map<Id,List<Field>>();
        
        Map<Id,Set<Id>> mapUserByAllo = new Map<Id,Set<Id>>();
      
        for (Eversign_Document_Field_Mapping__mdt objEverSign : EversignFieldMapping) {
            
            if (objEverSign.Object_Name__c == 'Concept_Note__c'&& objEverSign.Type__c == OBJECT_FIELD_TYPE && objEverSign.Saleforce_Reference__c == 'Implementation_Partner__r.BillingAddress') {
                
                List<String> lstRelationFields = objEverSign.Saleforce_Reference__c.split('\\.');
                System.debug('****:--'+objEverSign.Saleforce_Reference__c+lstRelationFields);
                Field fieldMap = new Field();
                fieldMap.identifier = objEverSign.Eversign_Document_Field_Identifier__c;
                Address addr = objConcept.Implementation_Partner__r.BillingAddress;
                fieldMap.value  = addr.getStreet()+','+addr.getCity()+','+addr.getState()+','+addr.getPostalCode()+','+addr.getCountry(); 
                lstfields.add(fieldMap);
            }
            else if (objEverSign.Saleforce_Reference__c.contains('.') && objEverSign.Object_Name__c == 'Concept_Note__c' && objEverSign.Type__c == OBJECT_FIELD_TYPE) {
                
                List<String> lstRelationFields = objEverSign.Saleforce_Reference__c.split('\\.');
                System.debug('****:--'+objEverSign.Saleforce_Reference__c+lstRelationFields);
                Field fieldMap = new Field();
                fieldMap.identifier = objEverSign.Eversign_Document_Field_Identifier__c;
                fieldMap.value  = String.valueOf(objConcept.getSobject(lstRelationFields[0]).get(lstRelationFields[1])); 
                lstfields.add(fieldMap);
                
            }
            else if (objEverSign.Object_Name__c == 'Concept_Note__c'&& objEverSign.Type__c == OBJECT_FIELD_TYPE) {
                
                Field fieldMap = new Field();
                fieldMap.identifier = objEverSign.Eversign_Document_Field_Identifier__c;
                fieldMap.value = String.valueOf(objConcept.get(objEverSign.Saleforce_Reference__c)); 
                lstfields.add(fieldMap);
            }
			else if (objEverSign.Object_Name__c == 'Report_Schedule__c' && objEverSign.Type__c == OBJECT_FIELD_TYPE) {
                
                Integer i = 1;
                for (Report_Schedule__c objReportSchedule : lstReportSch) {
                     
                    Field fieldMap = new Field();
                    fieldMap.identifier = objEverSign.Eversign_Document_Field_Identifier__c+'_'+i;
                	fieldMap.value = String.valueOf(objReportSchedule.get(objEverSign.Saleforce_Reference__c));
                    lstfields.add(fieldMap);
                    i++;
                }
            }    
            else if (objEverSign.Object_Name__c == 'Donor_Payment_Schedule__c' && objEverSign.Type__c == OBJECT_FIELD_TYPE) {
                
                Integer i = 1;
                for (Donor_Payment_Schedule__c objDonorSchedule : lstDonorSch) {
                    
                    Field fieldMap = new Field();
                    fieldMap.identifier = objEverSign.Eversign_Document_Field_Identifier__c+'_'+i;
                	fieldMap.value = String.valueOf(objDonorSchedule.get(objEverSign.Saleforce_Reference__c));
                    
                    if (mapfieldMapAllo.containsKey(objDonorSchedule.Fund_Allocation__c)) {
                     
                        mapfieldMapAllo.get(objDonorSchedule.Fund_Allocation__c).add(fieldMap);
                    }
                    else {
                        
                        mapfieldMapAllo.put(objDonorSchedule.Fund_Allocation__c,new List<Field>{fieldMap});
                    }                    
                    i++;
                }
            } 
            else if (objEverSign.Object_Name__c == 'Fund_Allocation__c' && objEverSign.Type__c == ROLE_TYPE) {
                
                Integer i = 1;
                for (Fund_Allocation__c objFundAllocation : lstFundAll) {
                    
                    String userId = String.valueOf(objFundAllocation.get(objEverSign.Saleforce_Reference__c));
                    userIdsRole.put(userId, objEverSign.Eversign_Document_Field_Identifier__c);
                    
                    if (mapUserByAllo.containsKey(userId)) {
                        
                        mapUserByAllo.get(userId).add(objFundAllocation.Id);
                    }
                    else {
                        
                        mapUserByAllo.put(userId,new Set<Id>{objFundAllocation.Id});
                    }
                }
            } 
            else if (objEverSign.Type__c == ROLE_TYPE) {
                
                userIdsRole.put(String.valueOf(objConcept.get(objEverSign.Saleforce_Reference__c)), objEverSign.Eversign_Document_Field_Identifier__c);
            }
            else if (objEverSign.Type__c == VALUE_TYPE) {
                
                Field fieldMap = new Field();
                fieldMap.identifier = objEverSign.Eversign_Document_Field_Identifier__c;
                fieldMap.value = objEverSign.Saleforce_Reference__c;
                lstfields.add(fieldMap);
            }
            else if (objEverSign.Type__c == FORMULA_TYPE) {
                
                Field fieldMap = new Field();
                fieldMap.identifier = objEverSign.Eversign_Document_Field_Identifier__c;
                
                if (objEverSign.Saleforce_Reference__c == 'Today') {
                    
                    fieldMap.value = String.valueOf(Date.today());
                }
                
                lstfields.add(fieldMap);
                
            }
        }
        
        List<Signer> lstSigner = new List<Signer>();
        List<Recipient> lstRecipient = new List<Recipient>();
        
        List<HttpRequest> listHttpRequest = new List<HttpRequest>();
        
        Map<Id,User> mapUser = new Map<Id,User>([SELECT Id,Name,UserName,Email FROM User WHERE Id=:userIdsRole.keySet()]);
        
        for (Eversign_Document_Field_Mapping__mdt objEverSign : EversignFieldMapping) {
            
			if (objEverSign.Type__c == ROLE_TYPE && objEverSign.Object_Name__c == 'Concept_Note__c') {
                
                User objUser = mapUser.get(String.valueOf(objConcept.get(objEverSign.Saleforce_Reference__c)));
                Signer signUser = new Signer();
                signUser.role = objEverSign.Eversign_Document_Field_Identifier__c;
                signUser.name = objUser.Name;
                signUser.email = objUser.Email;
                signUser.pin = '';
                signUser.message = '';
                signUser.deliver_email = ''; 
                signUser.language = 'en';
                lstSigner.add(signUser);
                
                Recipient repUser = new Recipient();
                repUser.role = objEverSign.Eversign_Document_Field_Identifier__c;
                repUser.name = objUser.Name;
                repUser.email = objUser.Email; 
                repUser.language = 'en';
                lstRecipient.add(repUser);
                
            }
        }
       	
        reqBody.signers = lstSigner;
        
        System.Debug('Signers**Before:--'+lstSigner);

        reqBody.fields = lstfields;
        
        reqBody.recipients = lstRecipient;
       
        List<Fund_Allocation__c> lstUpdate = new List<Fund_Allocation__c>();
        Map<Id,CreateDocumentRequest> mapRequestBodyById = new Map<Id,CreateDocumentRequest>();
        
        String strOrgRequest = JSON.serialize(reqBody);
        
        for(Eversign_Document_Field_Mapping__mdt objEverSign : EversignFieldMapping) {
            
            if (objEverSign.Type__c == ROLE_TYPE && objEverSign.Object_Name__c == 'Fund_Allocation__c') {
                
                for (Fund_Allocation__c objFundAllocation : lstFundAll) {
                    
                    User objUser = mapUser.get(String.valueOf(objFundAllocation.get(objEverSign.Saleforce_Reference__c)));
                    
                    List<Field> fieldMapAllo = new List<Field>();
                    
                    if (objEverSign.Saleforce_Reference__c.contains('.') && objEverSign.Object_Name__c == 'Fund_Allocation__c' && objEverSign.Type__c == OBJECT_FIELD_TYPE) {
                
                             List<String> lstRelationFields = objEverSign.Saleforce_Reference__c.split('\\.');
                             System.debug('****:--'+objEverSign.Saleforce_Reference__c+lstRelationFields);
                             Field fieldMap = new Field();
                             fieldMap.identifier = objEverSign.Eversign_Document_Field_Identifier__c;
                             fieldMap.value  = String.valueOf(objFundAllocation.getSobject(lstRelationFields[0]).get(lstRelationFields[1])); 
                             fieldMapAllo.add(fieldMap);
                             
                     }
                     else if (objEverSign.Object_Name__c == 'Fund_Allocation__c'&& objEverSign.Type__c == OBJECT_FIELD_TYPE) {
                            
                            Field fieldMap = new Field();
                            fieldMap.identifier = objEverSign.Eversign_Document_Field_Identifier__c;
                            fieldMap.value = String.valueOf(objFundAllocation.get(objEverSign.Saleforce_Reference__c));
                            fieldMapAllo.add(fieldMap);
                     }
                    
                    if (mapRequestBodyById.containsKey(objUser.Id)) {
                        
                        mapRequestBodyById.get(objUser.Id).fields.addAll(mapfieldMapAllo.get(objFundAllocation.Id));
                        mapRequestBodyById.get(objUser.Id).fields.addAll(fieldMapAllo);
                    }
                    else {
                    
                        CreateDocumentRequest reqBodyPartner = new CreateDocumentRequest();
                        reqBodyPartner = (CreateDocumentRequest)JSON.deserialize(strOrgRequest,CreateDocumentRequest.class);
                        reqBodyPartner.fields.addAll(mapfieldMapAllo.get(objFundAllocation.Id));
                        reqBodyPartner.fields.addAll(fieldMapAllo);
                        reqBodyPartner.title = objFundAllocation.Donor_Signatory__r.Name+' Partner Funding Agreement';
                        
                        
                        Signer signUser = new Signer();
                        signUser.role = objEverSign.Eversign_Document_Field_Identifier__c;
                        signUser.name = objUser.Name;
                        signUser.email = objUser.Email;
                        signUser.pin = '';
                        signUser.message = '';
                        signUser.deliver_email = ''; 
                        signUser.language = 'en';
                        reqBodyPartner.signers.add(signUser);
                        
                        Recipient repUser = new Recipient();
                        repUser.role = objEverSign.Eversign_Document_Field_Identifier__c;
                        repUser.name = objUser.Name;
                        repUser.email = objUser.Email; 
                        repUser.language = 'en';
                        reqBodyPartner.recipients.add(repUser);
                        
                        System.debug('**After in loop**:-'+reqBodyPartner.signers);
                        System.debug('**After in loop _Orih**:-'+reqBody.signers);
                        mapRequestBodyById.put(objUser.Id, reqBodyPartner);
                    
                    }
                }
            }
        }
        
        for (Id userId : mapRequestBodyById.keySet()) { 
                	
            HttpRequest requestPartner = new HttpRequest();
            requestPartner = request;
            String strReqBody = JSON.serialize(mapRequestBodyById.get(userId)); 
            
            strReqBody = strReqBody.replace(' 00:00:00', '');
            
            requestPartner.setBody(strReqBody);
            System.debug('***:-'+strReqBody);
            Http http = new Http();
            HTTPResponse res = http.send(requestPartner);
            System.debug('***:-'+res.getBody());
            
            EversignResponse everRes  = (EversignResponse)JSON.deserialize(res.getBody(),EversignResponse.class);
            
            for (Id alloId : mapUserByAllo.get(userId)) {
                
                if (everRes.document_hash != null) {
                    
                    lstUpdate.add(new Fund_Allocation__c(Id=alloId,Eversign_Partner_Document_Id__c=everRes.document_hash, Partner_Agreement_Signature_Status__c = 'In Progress'));
                }
                
            }
        }
        
        return lstUpdate;
    }
    
       
    public class EversignResponse {
        
        String document_hash;
        String requester_email;
        String custom_requester_name;
        String custom_requester_email;
        Integer is_draft;
        Integer is_template;
        Integer is_completed;
        Integer is_archived;
        Integer is_deleted;
        Integer is_trashed;
        Integer is_cancelled;
        Integer is_expired;
    }
    
        
        
    public class CreateDocumentRequest {
        
        public Integer sandbox;
        public String template_id;
        public String title;
        public String message;
        public String custom_requester_name;
        public String custom_requester_email;
        public String redirect;
        public String redirect_decline;
        public String client;
        public String expires;
        public Integer embedded_signing_enabled;
        public List<Signer> signers;
        public List<Recipient> recipients;
        public List<Field> fields;
        
        
    }
    
    public class Signer {
        public String role;
        public String name;
        public String email;
        public String pin;
        public String signer_authentication_sms_enabled;
        public String signer_authentication_phone_number;
        public String message;
        public String deliver_email;
        public String language;
    }
    
    public class Recipient {
        public String role;
        public String name;
        public String email;
        public String language;
    }
    
    public class Field {
        public String identifier;
        public String value;
    }
    
    public class CreateTemplate {
        public Integer sandbox;
        public Integer is_template;
        public Integer  is_draft;
        public String title;
        public String message ;
        public Integer reminders ;
        public Integer require_all_signers ;
        public List<Files> files;
        public List<Signers> signers;
        public List<Recipient> recipients;
        public List<Meta> meta;
        public List<FieldData> fields; 
  
    }
    
    public class Files {
        public String name;
        public String file_url;
        public String file_id;
        public String file_base64;
    }
    
    public class Signers {
        public Integer id;
        public String role;
        public String name;
        public String email;
        public Integer order;
        public Integer required;
    }
    
    public class Meta {
        public String Key;
    }
    
    public class FieldData {
        public Integer merge1;
        public String identifier;
        public String name;
        public String options;
        public String group1;
        public String value;
        public String type;
        public Integer x;
        public Integer y;
        public Integer page;
        public Integer width;
        public Integer height;
        public String signer;
        public String validation_type;
        public Integer required;
        public Integer readonly;
        public Integer text_size;
        public String text_color;
        public String text_style;
        public String text_font;
    }
    

}