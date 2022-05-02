public class currencyISOWrapper {

	public String terms {get;set;} 
	public String privacy {get;set;} 
	public String from_Z {get;set;} // in json: from
	public Double amount {get;set;} 
	public String timestamp {get;set;} 
	public List<To> to {get;set;} 

	public currencyISOWrapper(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'terms') {
						terms = parser.getText();
					} else if (text == 'privacy') {
						privacy = parser.getText();
					} else if (text == 'from') {
						from_Z = parser.getText();
					} else if (text == 'amount') {
						amount = parser.getDoubleValue();
					} else if (text == 'timestamp') {
						timestamp = parser.getText();
					} else if (text == 'to') {
						to = arrayOfTo(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class To {
		public String quotecurrency {get;set;} 
		public Double mid {get;set;} 

		public To(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'quotecurrency') {
							quotecurrency = parser.getText();
						} else if (text == 'mid') {
							mid = parser.getDoubleValue();
						} else {
							System.debug(LoggingLevel.WARN, 'To consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static currencyISOWrapper parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new currencyISOWrapper(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	




    private static List<To> arrayOfTo(System.JSONParser p) {
        List<To> res = new List<To>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new To(p));
        }
        return res;
    }


}