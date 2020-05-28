/**
 * @Description: This utlity class is used to generate auto numbers 
 *                  based on the custom setting Auto_Number_Config__c
 */
public class AutoNumberUtil {
    
    List<SObject> records;
    String settingName;
    String configId;
    String fieldAPIName;
    String numberFormat;
    Integer currentNumber;
    Integer totalDigitsInTheFormat;
    String initialFormat;

    public AutoNumberUtil(List<SObject> records, String fieldAPIName,String settingName){
        this.records                = records;
        this.fieldAPIName           = fieldAPIName;
        this.settingName            = settingName;

        getCurrentNumber();
        validateFormat();
    }
    
    public void stampAutoNumber(){
        
        for(SObject record : records){
            record.put(fieldAPIName,getNextNumber());
        }
        updateCurrentNumber();
    }

    public String getNextNumber(){
        String nextNumber;
        String leadingZeroes    = '';
        this.currentNumber      += 1;

        Integer lengthDifference = String.valueOf(currentNumber).length() - this.totalDigitsInTheFormat;
        if(lengthDifference > 0)
            for(Integer i=0;i<lengthDifference;i++)
                leadingZeroes += '0';

        nextNumber = this.initialFormat  + leadingZeroes + currentNumber;

        return nextNumber;
    }

    public void getCurrentNumber(){
        Auto_Number_Config__c config = Auto_Number_Config__c.getInstance(settingName);
        if(config == null)
            throw new AutoNumberException('Auto Number Setting not found : ' + settingName);

        this.numberFormat   = config.Number_Format__c;
        this.currentNumber  = Integer.valueOf(config.Current_Number__c);
        this.configId       = config.Id;
        validateFormat();

        this.totalDigitsInTheFormat = this.numberFormat.substring(this.numberFormat.indexOf('{')+1,
                                        this.numberFormat.indexOf('}')).length();

        this.initialFormat = this.numberFormat.substring(0,this.numberFormat.indexOf('{'));
    } 

    public void validateFormat(){
        if(!Pattern.matches('[a-zA-Z|-]*\\{0*\\}', this.numberFormat))
            throw new AutoNumberException('Invalid Patern. Pattern should be similar to the following format : XXX-{00000}' );
    }

    public void updateCurrentNumber(){
        update new Auto_Number_Config__c(id = this.configId, Current_Number__c = currentNumber);
    }

    public class AutoNumberException extends Exception{}

}