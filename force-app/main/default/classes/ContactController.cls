public with sharing class ContactController {
    private static final String URL_REMOTE = 'https://covid19-brazil-api.vercel.app/api/report/v1';

    @AuraEnabled(cacheable=true)
    public static List<dados> getInfoCovid() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint(URL_REMOTE);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(12000);
        
        HttpResponse response = http.send(request);

        if(response.getStatusCode() == 200) {
            CovidInfo resultado = new CovidInfo();
            resultado = (CovidInfo)JSON.deserialize(response.getBody().replaceAll('datetime', 'datetime_x'), CovidInfo.class);
            List<dados> listDados = resultado.data;
            return listDados;
        } else {
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContatos(){
        return [SELECT Id, FirstName, LastName, Phone, Email
                FROM Contact];
    }

    public class CovidInfo {
        @auraenabled
        public List<dados> data;
    }

    public class dados {
        @auraenabled
        public Integer uid;
        @auraenabled
        public String uf;
        @auraenabled
        public String state;
        @auraenabled
        public Integer cases;
        @auraenabled
        public Integer deaths;
        @auraenabled
        public Integer suspects;
        @auraenabled
        public Integer refuses;
        @auraenabled
        public Boolean broadcast;
        @auraenabled
        public String comments;
        @auraenabled
        public Datetime datetime_x;
    }
}