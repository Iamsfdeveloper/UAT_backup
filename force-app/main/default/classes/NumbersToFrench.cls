public class NumbersToFrench {
    
    private static final List<String> dizaineNames = new list<String> {
        ' ',' ','vingt ', 'trente ','quarante ','cinquante ', 'soixante ','soixante ','quatre-vingt ','quatre-vingt'
    };
        
    private static final List<String> uniteNames1 = new list<String> {
    	' ','un ','deux ','trois ','quatre ','cinq ','six ','sept ','huit ','neuf ','dix ','onze ','douze ','treize ',
        'quatorze ','quinze ','seize ','dix-sept ','dix-huit ','dix-neuf '
    };
            
    private static final List<String> uniteNames2 = new list<String> {
        ' ',' ','deux ','trois ','quatre ','cinq ','six ','sept ','huit ','neuf ','dix '
    };
                
    private static String convertZeroToHundred(Integer num) {
            
        Integer laDizaine = num / 10;
        Integer lUnite = math.mod(num,10);
        String resultat =  ' ';
        
        
        if(laDizaine==1||laDizaine==7||laDizaine==9){
            lUnite = lUnite + 10;            
        }
        
        String laLiaison =  ' ';
        if (laDizaine > 1) {
            laLiaison =  '- ';
        }
        
        switch on lUnite {
            when 0 { 
                laLiaison =  ' '; 
            } 
            when 1 {
                if (laDizaine == 8) {
                    laLiaison =  '- ';
                } else {
                    laLiaison =  ' et  ';
                } 
            }
            when 11 { 
                if (laDizaine == 7) {
                    laLiaison =  ' et  ';
                }
            }
            when else { 
            }
        }
        
        // dizaines en lettres
        
        switch on laDizaine {
            when 0 { 
                resultat = uniteNames1[lUnite];
            } 
            when 8 {
                if (lUnite == 0) {
                    resultat = dizaineNames[laDizaine];
                } else {
                    resultat = dizaineNames[laDizaine] + laLiaison + uniteNames1[lUnite];
                } 
            }
            when 11 { 
                if (laDizaine == 7) {
                    laLiaison =  ' et  ';
                }
            }
            when else {
                resultat = dizaineNames[laDizaine] + laLiaison + uniteNames1[lUnite];
            }
        }
        return resultat;
    }
    
    private static String convertLessThanOneThousand(Integer num) {
        
        Integer lesCentaines = num / 100;
        Integer leReste = math.mod(num,100);
        String sReste = convertZeroToHundred(leReste);
        
        String resultat;
        switch on lesCentaines {
            when 0 {
                resultat = sReste;
            } 
            when 1 {
                if (leReste > 0) {
                    resultat =  'cent  ' + sReste;
                } else {
                    resultat =  'cent ';
                } 
            }
            when else { 
                if (leReste > 0) {
                    resultat = uniteNames2[lesCentaines] +  ' cent  ' + sReste;
                } else {
                    resultat = uniteNames2[lesCentaines] +  ' cents ';
                } 
            }
        }
        return resultat;
    }
    
    public static String convert(Long num) {
        if (num == 0) {
            return  'zero ';
        }
        
        String snumber = String.valueOf(num).leftPad(12, '0');
        System.debug(snumber);
        
        Integer lesMilliards = Integer.valueOf(snumber.substring(0, 3));
        Integer lesMillions = Integer.valueOf(snumber.substring(3, 6));
        Integer lesCentMille = Integer.valueOf(snumber.substring(6, 9));
        Integer lesMille = Integer.valueOf(snumber.substring(9, 12));
        
        String tradMilliards;
        switch on lesMilliards {
            when 0 {
                tradMilliards =  ' '; 
            } 
            when 1 { 
                tradMilliards = convertLessThanOneThousand(lesMilliards) +  ' milliard  '; 
            }
            when else { 
                tradMilliards = convertLessThanOneThousand(lesMilliards) +  ' milliards  '; 
            }
        }
        String resultat = tradMilliards;
        
        String tradMillions;
        
        switch on lesMillions {
            when 0 {
                tradMillions =  ' ';
            } 
            when 1 { 
                tradMillions = convertLessThanOneThousand(lesMillions) +  ' million  ';
            }
            when else { 
                tradMillions = convertLessThanOneThousand(lesMillions) +  ' millions  ';
            }
        }
        resultat = resultat + tradMillions;
        
        String tradCentMille;
        
        switch on lesCentMille {
            when 0 {
                tradCentMille =  ' ';
            } 
            when 1 { 
                tradCentMille =  'mille  ';
            }
            when else { 
                tradCentMille = convertLessThanOneThousand(lesCentMille) +  ' mille  ';
            }
        }
        
        resultat = resultat + tradCentMille;
        
        String tradMille;
        tradMille = convertLessThanOneThousand(lesMille);
        resultat = resultat + tradMille;
        
        return resultat;
    }
    
    public static String convertCurrency(Decimal dec){
        
        Long beforeDec= dec.longValue();
        String s = String.valueOf(dec); 
        String afterDecimal = s.substringAfter('.');
        String finalStr = convert(beforeDec) + ' euros ';//' virgule ';
        
        if (afterDecimal != '00') {
            finalStr += ' et ' + convert(long.valueOf(afterDecimal)) + ' cents ';
        }
        
        return finalStr;
        /*String[] chars = afterDecimal.split('');
        for (String ch : chars) {
            switch on ch {
                
                when '0'{
                    finalStr+=' zéro';
                }
                when '1'{
                    finalStr+=' une';
                }
                when '2'{
                    finalStr+=' deux';
                }
                when '3'{
                    finalStr+=' Trois';
                }
                when '4'{
                    finalStr+=' quatre';
                }
                when '5'{
                    finalStr+=' cinq';
                }
                when '6'{
                    finalStr+=' six';
                }
                when '7'{
                    finalStr+=' Sept';
                }
                when '8'{
                    finalStr+=' huit';
                }
                when '9'{
                    finalStr+=' neuf';
                }
            }
            
        }*/
    }
}