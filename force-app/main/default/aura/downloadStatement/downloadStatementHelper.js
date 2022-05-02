({
        getDonationStatement: function (component) {
                let url = location.href.substr(0, location.href.indexOf('/s/'));
                let startDate = component.get("v.startDate");
                let endDate = component.get("v.endDate");
                let contactId = component.get("v.contactId");
                if (!$A.util.isEmpty(startDate) && !$A.util.isEmpty(endDate) && !$A.util.isEmpty(contactId)) {
                        var currentUrL = url + '/apex/P2P_DownloadStatementPdf?startdate=' + startDate + '&enddate=' + endDate;
                        window.open(currentUrL, '_blank');
                        component.set("v.startDate", '');
                        component.set("v.endDate", '');
                }
                else {
                        //Validating all input fields together by providing the same aureid 'field'	
                        let isAllValid = component.find('field').reduce(function (isValidSoFar, inputCmp) {
                                //display the error messages
                                inputCmp.reportValidity();
                                //check if the validity condition are met or not.
                                return isValidSoFar && inputCmp.checkValidity();
                        }, true);
                }
        }
})