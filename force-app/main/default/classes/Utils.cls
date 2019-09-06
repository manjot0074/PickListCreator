public with sharing class Utils {
    public static String getSessionIdFromVFPage(){
        PageReference visualforcePage = Page.SessionIdPage;
        String content = visualforcePage.getContent().toString();
        Integer s = content.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
                e = content.indexOf('End_Of_Session_Id');
        return content.substring(s, e);
    }
}
