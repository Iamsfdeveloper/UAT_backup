public with sharing class SMP_PaymentScheduleHelper {

    /* @future(callout=true)
    public static void calculatePaymentSchedulesFuture(Set<Id> opportunityIdsToRecalculate){
        System.debug('#### calculatePaymentSchedulesFuture');
        System.debug('#### opportunityIdsToRecalculate: ' + opportunityIdsToRecalculate);

        List<Payment_Schedule__c> paymentSchedules = new List<Payment_Schedule__c>();

        List<Opportunity> opportunities = [SELECT Id, Amount, CurrencyIsoCode, 
                                                (SELECT Id, npsp__Amount__c, npsp__General_Accounting_Unit__r.Valid_From__c, npsp__General_Accounting_Unit__r.Expiry_Date__c, 
                                                npsp__General_Accounting_Unit__r.Allowed_Payment_Types__c, npsp__General_Accounting_Unit__r.Donation_Type__c, npsp__General_Accounting_Unit__r.Donation_Frequency__c
                                                FROM npsp__Allocations__r),
                                                
                                                (SELECT Id, Opportunity__c, Schedule_Date__c, Status__c, Amount__c
                                                FROM Payment_Schedules__r 
                                                WHERE Schedule_Date__c >= :Date.Today().toStartOfMonth()
                                                order by Schedule_Date__c ASC),

                                                (SELECT Id, DD_Collection_Period__c, DD_Start_Date__c, DD_End_Date__c 
                                                FROM Income_Direct_Debit__r 
                                                WHERE (DD_End_Date__c = null OR DD_End_Date__c > :Date.Today())
                                                    AND (DD_Status__c = 'New Instruction' OR DD_Status__c = 'First Collection' OR DD_Status__c = 'Ongoing Collection' OR DD_Status__c = 'Final Collection')),

                                                (SELECT Id, RP_Frequency__c, RP_Start_Date__c, RP_End_Date__c, RP_Collection_Day__c  
                                                FROM Income_Card_Payment__r 
                                                WHERE RP_Enabled__c = true AND (RP_End_Date__c = null OR RP_End_Date__c > :Date.Today()))
                                            FROM Opportunity 
                                            WHERE Id IN :opportunityIdsToRecalculate];

        for(Opportunity opp : opportunities)
        {
            System.debug('#### opp: ' + opp);
            System.debug('#### opp.Income_Direct_Debit__r: ' + opp.Income_Direct_Debit__r);
            System.debug('#### opp.Income_Card_Payment__r: ' + opp.Income_Card_Payment__r);

            if(opp.Income_Direct_Debit__r.Size() > 0)
            {
                paymentSchedules.addAll(calculateDirectDebitPaymentSchedules(opp, opp.npsp__Allocations__r, opp.Payment_Schedules__r, Date.Today(), opp.Income_Direct_Debit__r[0].DD_End_Date__c));
            }
            else if(opp.Income_Card_Payment__r.Size() > 0)
            {
                paymentSchedules.addAll(calculateCardPaymentSchedules(opp, opp.npsp__Allocations__r, opp.Payment_Schedules__r, Date.Today(), opp.Income_Card_Payment__r[0].RP_End_Date__c, opp.Income_Card_Payment__r[0].RP_Collection_Day__c, opp.Income_Card_Payment__r[0].RP_Frequency__c));
            }            
        }

        upsert paymentSchedules;
    }

    public static List<Payment_Schedule__c> calculateDirectDebitPaymentSchedules(Opportunity opportunityRecord, List<npsp__Allocation__c> products, 
                                                                        List<Payment_Schedule__c> existingSchedules, 
                                                                        Date calculateFromDate, Date calculateToDate){
        System.debug('#### calculatePaymentSchedules');
        System.debug('#### opportunityRecord: ' + opportunityRecord);
        System.debug('#### existingSchedules: ' + existingSchedules);
        System.debug('#### calculateFromDate: ' + calculateFromDate);
        System.debug('#### calculateToDate: ' + calculateToDate);
        
        if(existingSchedules == null){
            existingSchedules = new List<Payment_Schedule__c>();
        }
        
        Integer numberOfSchedulesToCalculate = 12;        
        
        if(calculateToDate != null){
            numberOfSchedulesToCalculate = calculateFromDate.monthsBetween(calculateToDate);
        }

        // Calculate first dates
        System.debug('#### Calculate when the last existing payment schedule date is and how many ahead it is from today');
        Integer noOfScedulesInFuture = 0;
        Date lastDateScheduled = calculateFromDate;

        lastDateScheduled = Date.Today().Day() <= 12 ? Date.Today() : Date.Today().addMonths(1);

        if(lastDateScheduled < calculateFromDate){
            lastDateScheduled = calculateFromDate;
        }

        for(Payment_Schedule__c ps : existingSchedules)
        {
            if(ps.Schedule_Date__c >= calculateFromDate)
            {
                noOfScedulesInFuture++;
                
                if(ps.Schedule_Date__c > lastDateScheduled)
                {
                    lastDateScheduled = ps.Schedule_Date__c;
                }
            }
        }

        System.debug('#### lastDateScheduled: ' + lastDateScheduled);
        System.debug('#### noOfScedulesInFuture: ' + noOfScedulesInFuture);

        System.debug('#### Generate all missing payment schedules');
        List<SMP_DDServiceHandler.ListCollectionDateWrapper> cdWrapperList = new List<SMP_DDServiceHandler.ListCollectionDateWrapper>();
        
        for(Integer i = noOfScedulesInFuture; i < numberOfSchedulesToCalculate; i++)
        {
            Payment_Schedule__c newPaymentSchedule = new Payment_Schedule__c(Opportunity__c = opportunityRecord.Id,
                                                                            Amount__c = 0,
                                                                            Status__c = 'Outstanding',
                                                                            CurrencyIsoCode = opportunityRecord.CurrencyIsoCode);
            
            newPaymentSchedule.Schedule_Date__c = lastDateScheduled.addMonths(1).toStartOfMonth();
            lastDateScheduled = newPaymentSchedule.Schedule_Date__c;

            if(calculateToDate < lastDateScheduled){
                break;
            }
            
            // Calculate Price
            System.debug('#### Calculate Price');
            for(npsp__Allocation__c alloc : products)
            {
                System.debug('#### alloc: ' + alloc);

                if(alloc.npsp__General_Accounting_Unit__r.Allowed_Payment_Types__c.contains('Direct Debit')
                    && alloc.npsp__General_Accounting_Unit__r.Donation_Type__c == 'Recurring')
                {
                    // If valid from and expiry is blank.
                    // If valid from and expiry is not blank and scheduled date fits between.
                    // If valid from is not blank, expiry date is blank and scheduled date is after valid from date.
                    // If valid from is blank, expiry date is not blank and schedule date is before expiry date.
                    if(alloc.npsp__General_Accounting_Unit__r.Valid_From__c == null && alloc.npsp__General_Accounting_Unit__r.Expiry_Date__c == null
                    || (alloc.npsp__General_Accounting_Unit__r.Valid_From__c != null && alloc.npsp__General_Accounting_Unit__r.Expiry_Date__c != null && newPaymentSchedule.Schedule_Date__c >= alloc.npsp__General_Accounting_Unit__r.Valid_From__c && newPaymentSchedule.Schedule_Date__c <= alloc.npsp__General_Accounting_Unit__r.Expiry_Date__c)
                    || (alloc.npsp__General_Accounting_Unit__r.Valid_From__c != null && alloc.npsp__General_Accounting_Unit__r.Expiry_Date__c == null && newPaymentSchedule.Schedule_Date__c >= alloc.npsp__General_Accounting_Unit__r.Valid_From__c)
                    || (alloc.npsp__General_Accounting_Unit__r.Valid_From__c == null && alloc.npsp__General_Accounting_Unit__r.Expiry_Date__c != null && newPaymentSchedule.Schedule_Date__c <= alloc.npsp__General_Accounting_Unit__r.Expiry_Date__c))
                    {
                        System.debug('#### Valid Product');
                        newPaymentSchedule.Amount__c += alloc.npsp__Amount__c;
                    }                    
                }                
            }

            existingSchedules.add(newPaymentSchedule);

            System.debug('#### New Payment Schedule: ' + newPaymentSchedule);
            
            SMP_DDServiceHandler.ListCollectionDateWrapper cdWrapperObject = new SMP_DDServiceHandler.ListCollectionDateWrapper();
            cdWrapperObject.sd = string.valueOf(newPaymentSchedule.Schedule_Date__c);
            cdWrapperList.add(cdWrapperObject);
        }

        System.debug('##### cdWrapperList: ' + cdWrapperList);
        if(cdWrapperList.Size() > 0)
        {                
            SMP_DDServiceHandler.ListCollectionDateBaseWrapper cdWrapper = new SMP_DDServiceHandler.ListCollectionDateBaseWrapper(cdWrapperList, 'Monthly', '0', '1');

            SMP_DDServiceNextCollectionModelList response = SMP_DDServiceHandler.getNextCollectionDate(cdWrapper);

            System.debug('##### response: ' + response);
            Integer i = noOfScedulesInFuture;
            for(SMP_DDServiceNextCollectionModelList.ProcessListNewDDFirstCollectionDateResult idd : response.ProcessListNewDDFirstCollectionDateResult){
                System.debug('##### idd: ' + idd);
                if(string.isNotBlank(idd.FirstCollectionDate)){
                    System.debug('##### idd.FirstCollectionDate: ' + idd.FirstCollectionDate);
                    String[] strDate = idd.FirstCollectionDate.split('-');
                    System.debug('##### strDate: ' + strDate);
                    Integer myIntDate = integer.valueOf(strDate[2]);
                    Integer myIntMonth = integer.valueOf(strDate[1]);
                    Integer myIntYear = integer.valueOf(strDate[0]);
                    System.debug('##### myIntDate: ' + myIntDate);
                    System.debug('##### myIntMonth: ' + myIntMonth);
                    System.debug('##### myIntYear: ' + myIntYear);

                    if(existingSchedules[i].Schedule_Date__c > Date.Today())
                    {
                        existingSchedules[i].Schedule_Date__c = Date.newInstance(myIntYear, myIntMonth, myIntDate);
                    }
                    
                    System.debug('##### existingSchedules[i].Schedule_Date__c: ' + existingSchedules[i].Schedule_Date__c);
                    i++;
                }
            }
        }   

        System.debug('#### Returned Schedules: ' + existingSchedules);
        return existingSchedules;
    }

    public static List<Payment_Schedule__c> calculateCardPaymentSchedules(Opportunity opportunityRecord, List<npsp__Allocation__c> products, List<Payment_Schedule__c> existingSchedules,                                                                         
                                                                        Date calculateFromDate, Date calculateToDate, String rpCollectionDay, String scheduleFrequency){
        System.debug('#### calculatePaymentSchedules');
        System.debug('#### opportunityRecord: ' + opportunityRecord);
        System.debug('#### products: ' + products);
        System.debug('#### existingSchedules: ' + existingSchedules);
        System.debug('#### calculateFromDate: ' + calculateFromDate);
        System.debug('#### calculateToDate: ' + calculateToDate);
        System.debug('#### scheduleFrequency: ' + scheduleFrequency);
        
        if(existingSchedules == null){
            existingSchedules = new List<Payment_Schedule__c>();
        }
                
        Integer numberOfSchedulesToCalculate;
        
        if(scheduleFrequency == 'Daily')
        {
            numberOfSchedulesToCalculate = calculateToDate != null ? calculateFromDate.daysBetween(calculateToDate) + 1 : 12;
        }
        else if(scheduleFrequency == 'Monthly')
        {
            numberOfSchedulesToCalculate = 12;           
        }

        // Calculate first dates
        System.debug('#### Calculate when the last existing payment schedule date is and how many ahead it is from today');
        Integer noOfScedulesInFuture = 0;
        Date lastDateScheduled = calculateFromDate;

        for(Payment_Schedule__c ps : existingSchedules)
        {
            if(ps.Schedule_Date__c >= calculateFromDate)
            {
                noOfScedulesInFuture++;
                
                if(ps.Schedule_Date__c > lastDateScheduled)
                {
                    lastDateScheduled = ps.Schedule_Date__c;
                }
            }
        }

        System.debug('#### lastDateScheduled: ' + lastDateScheduled);
        System.debug('#### noOfScedulesInFuture: ' + noOfScedulesInFuture);

        System.debug('#### Generate all missing payment schedules');
        
        for(Integer i = noOfScedulesInFuture; i < numberOfSchedulesToCalculate; i++)
        {
            if(calculateToDate < lastDateScheduled){
                break;
            }

            Payment_Schedule__c newPaymentSchedule = new Payment_Schedule__c(Opportunity__c = opportunityRecord.Id,
                                                                            Status__c = 'Outstanding',
                                                                            Amount__c = 0,
                                                                            CurrencyIsoCode = opportunityRecord.CurrencyIsoCode);
            

            if(scheduleFrequency == 'Daily')
            {
                newPaymentSchedule.Schedule_Date__c = lastDateScheduled;
                lastDateScheduled = newPaymentSchedule.Schedule_Date__c.addDays(1);
            }
            else if(scheduleFrequency == 'Monthly')
            {
                Integer rpCollectionDayInteger = Integer.valueOf(rpCollectionDay);
                if(lastDateScheduled.day() != rpCollectionDayInteger)
                {
                    Integer lastDayOfMonth = lastDateScheduled.addMonths(1).toStartOfMonth().addDays(-1).day();

                    if(rpCollectionDayInteger <= lastDayOfMonth){
                        lastDateScheduled = Date.newInstance(lastDateScheduled.year(), lastDateScheduled.month(), rpCollectionDayInteger);
                    }
                }

                newPaymentSchedule.Schedule_Date__c = lastDateScheduled;
                lastDateScheduled = newPaymentSchedule.Schedule_Date__c.addMonths(1);
            }            

            // Calculate Price
            System.debug('#### Calculate Price');
            for(npsp__Allocation__c alloc : products)
            {
                System.debug('#### alloc: ' + alloc);

                if(alloc.npsp__General_Accounting_Unit__r.Allowed_Payment_Types__c.contains('Credit/Debit Card')
                    && alloc.npsp__General_Accounting_Unit__r.Donation_Type__c == 'Recurring')
                {
                    // If valid from and expiry is blank.
                    // If valid from and expiry is not blank and scheduled date fits between.
                    // If valid from is not blank, expiry date is blank and scheduled date is after valid from date.
                    // If valid from is blank, expiry date is not blank and schedule date is before expiry date.
                    if(alloc.npsp__General_Accounting_Unit__r.Valid_From__c == null && alloc.npsp__General_Accounting_Unit__r.Expiry_Date__c == null
                    || (alloc.npsp__General_Accounting_Unit__r.Valid_From__c != null && alloc.npsp__General_Accounting_Unit__r.Expiry_Date__c != null && newPaymentSchedule.Schedule_Date__c >= alloc.npsp__General_Accounting_Unit__r.Valid_From__c && newPaymentSchedule.Schedule_Date__c <= alloc.npsp__General_Accounting_Unit__r.Expiry_Date__c)
                    || (alloc.npsp__General_Accounting_Unit__r.Valid_From__c != null && alloc.npsp__General_Accounting_Unit__r.Expiry_Date__c == null && newPaymentSchedule.Schedule_Date__c >= alloc.npsp__General_Accounting_Unit__r.Valid_From__c)
                    || (alloc.npsp__General_Accounting_Unit__r.Valid_From__c == null && alloc.npsp__General_Accounting_Unit__r.Expiry_Date__c != null && newPaymentSchedule.Schedule_Date__c <= alloc.npsp__General_Accounting_Unit__r.Expiry_Date__c))
                    {
                        System.debug('#### Valid Product');
                        newPaymentSchedule.Amount__c += alloc.npsp__Amount__c;
                    }                    
                }                
            }

            existingSchedules.add(newPaymentSchedule);

            System.debug('#### New Payment Schedule: ' + newPaymentSchedule);
        } 

        System.debug('#### Returned Schedules: ' + existingSchedules);
        return existingSchedules;
    } */

    /* public static void checkRecurringPayment(Set<Id> opportunitiesToCheck){
        System.debug('#### checkDirectDebit');
        System.debug('#### membersToCheck: ' + opportunitiesToCheck);

        List<Income_Direct_Debit__c> directDebits = new List<Income_Direct_Debit__c>();
        List<Income_Card_Payment__c> cardPayments = new List<Income_Card_Payment__c>();

        List<Opportunity> opportunities = [SELECT Id,
                                    (SELECT Id, DD_Status__c, DD_First_Collection_Amount__c, DD_First_Collection_Date__c, DD_Ongoing_Collection_Amount__c, DD_Next_Collection_Date__c 
                                    FROM Income_Direct_Debit__r
                                    WHERE (DD_Status__c = 'New Instruction' OR DD_Status__c = 'First Collection' OR DD_Status__c = 'Ongoing Collection' OR DD_Status__c = 'Final Collection')),
                                    (SELECT Id, RP_Frequency__c, RP_Start_Date__c, RP_End_Date__c, RP_Enabled__c, RP_Amount__c, RP_Next_Payment_Date__c    
                                    FROM Income_Card_Payment__r 
                                    WHERE RP_Enabled__c = true),
                                    (SELECT Id, Opportunity__c, Schedule_Date__c, Status__c, Amount__c 
                                    FROM Payment_Schedules__r 
                                    WHERE Schedule_Date__c >= :Date.Today() AND Status__c = 'Outstanding' AND Amount__c != null AND Amount__c > 0  
                                    order by Schedule_Date__c ASC LIMIT 1) 
                                FROM Opportunity 
                                WHERE Id IN :opportunitiesToCheck];

        for(Opportunity opportunity : opportunities){            
            Payment_Schedule__c ps;

            if(opportunity.Payment_Schedules__r.Size() > 0){
                ps = opportunity.Payment_Schedules__r[0];
            }

            for(Income_Direct_Debit__c dd : opportunity.Income_Direct_Debit__r){                
                directDebits.add(checkDirectDebit(dd, ps));
            }

            for(Income_Card_Payment__c cardPayment : opportunity.Income_Card_Payment__r){
                if(cardPayment.RP_Enabled__c == true){
                    cardPayments.add(checkRepeatCardPayment(cardPayment, ps));
                }                    
            }
        }

        System.debug('#### Updating directDebits: ' + directDebits);
        if(directDebits.Size() > 0)
        {
            update directDebits;
        }   
        
        System.debug('#### Updating cardPayments: ' + cardPayments);
        if(cardPayments.Size() > 0)
        {
            update cardPayments;
        }  
    }

    public static List<Income_Direct_Debit__c> checkDirectDebit(List<Income_Direct_Debit__c> directDebits){
        Set<Id> opportunityIds = new Set<Id>();

        for(Income_Direct_Debit__c dd : directDebits){
            opportunityIds.add(dd.Opportunity__c);
        }

        Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>([SELECT Id,                                    
                                                            (SELECT Id, Opportunity__c, Schedule_Date__c, Status__c, Amount__c 
                                                            FROM Payment_Schedules__r 
                                                            WHERE Schedule_Date__c > :Date.Today() AND Status__c = 'Outstanding' AND Amount__c != null AND Amount__c > 0  
                                                            order by Schedule_Date__c ASC LIMIT 1) 
                                                        FROM Opportunity 
                                                        WHERE Id IN :opportunityIds]);

        for(Income_Direct_Debit__c dd : directDebits){
            Opportunity opportunity = opportunities.get(dd.Opportunity__c);
            Payment_Schedule__c ps;

            if(opportunity != null && opportunity.Payment_Schedules__r.Size() > 0){
                ps = opportunity.Payment_Schedules__r[0];
            }
            
            SMP_PaymentScheduleHelper.checkDirectDebit(dd, ps);
        }

        return directDebits;
    }

    public static Income_Direct_Debit__c checkDirectDebit(Income_Direct_Debit__c dd, Payment_Schedule__c ps){
        if(ps == null){
            dd.DD_Ongoing_Collection_Amount__c = null;
            dd.DD_Next_Collection_Date__c = null;
        }
        else{
            if(dd.DD_Status__c == 'New Instruction' || dd.DD_Status__c == 'First Collection'){
                dd.DD_First_Collection_Date__c = ps.Schedule_Date__c;
                dd.DD_First_Collection_Amount__c = ps.Amount__c;
            }

            dd.DD_Ongoing_Collection_Amount__c = ps.Amount__c;
            dd.DD_Next_Collection_Date__c = ps.Schedule_Date__c;
        }

        return dd;
    }

    public static List<Income_Card_Payment__c> checkRepeatCardPayment(List<Income_Card_Payment__c> cardPayments){
        Set<Id> opportunityIds = new Set<Id>();

        for(Income_Card_Payment__c cardPayment : cardPayments){
            if(cardPayment.RP_Enabled__c == true){
                opportunityIds.add(cardPayment.Opportunity__c);
            }            
        }

        Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>([SELECT Id,                                    
                                                            (SELECT Id, Opportunity__c, Schedule_Date__c, Status__c, Amount__c 
                                                            FROM Payment_Schedules__r 
                                                            WHERE Schedule_Date__c >= :Date.Today() AND Status__c = 'Outstanding' AND Amount__c != null AND Amount__c > 0  
                                                            order by Schedule_Date__c ASC LIMIT 1) 
                                                        FROM Opportunity 
                                                        WHERE Id IN :opportunityIds]);

        for(Income_Card_Payment__c cardPayment : cardPayments){
            if(cardPayment.RP_Enabled__c == true){
                Opportunity opportunity = opportunities.get(cardPayment.Opportunity__c);
                Payment_Schedule__c ps;

                if(opportunity != null && opportunity.Payment_Schedules__r.Size() > 0){
                    ps = opportunity.Payment_Schedules__r[0];
                }

                SMP_PaymentScheduleHelper.checkRepeatCardPayment(cardPayment, ps);
            }            
        }

        return cardPayments;
    }

    public static Income_Card_Payment__c checkRepeatCardPayment(Income_Card_Payment__c cardPayment, Payment_Schedule__c ps){
        if(ps == null){
            cardPayment.RP_Amount__c = null;
            cardPayment.RP_Next_Payment_Date__c = null;
        }
        else{
            cardPayment.RP_Amount__c = ps.Amount__c;
            cardPayment.RP_Next_Payment_Date__c = ps.Schedule_Date__c;
        }

        return cardPayment;
    } */
}