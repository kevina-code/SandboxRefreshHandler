# SandboxRefreshHandler
This is a solution that takes care of the 'invalid' and '@example.com' dilemma with specified user emails post sandbox refresh.

Tweak to taste. You can add additional logic to automate other post-refresh activities as well.

Usage: 
1. Deploy metadata to Salesforce. 
<a href="https://githubsfdeploy.herokuapp.com">
  <img src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png" alt="Deploy to Salesforce" />
</a>

2. Create **Internal_User__mdt** records in production for each user you wish to sanitize email addresses on (and get rid of 'invalid' suffix) post refresh. Whjen creating these records, populate the **User_Id__c** field with the user's record Id from Production. Also populate the **Email__c** field with the user's email.
![image](https://user-images.githubusercontent.com/124932501/224363432-78b62d72-6cf3-4be2-89a1-0a7f0a34f880.png)

2. When kicking off a sandbox refresh, populate **SandboxRefreshHandler** into the **Apex Class** field.
![image](https://user-images.githubusercontent.com/124932501/224364237-7e8492cd-ae70-41b4-ad82-49a49eaa1606.png)
