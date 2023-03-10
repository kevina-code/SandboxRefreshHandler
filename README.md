# SandboxRefreshHandler
This is a solution that takes care of the 'invalid' and '@example.com' dilemma with user emails post sandbox refresh.

Usage: 
1. create Internal_User__mdt records for each user you wish to sanitize email addresses on (and get rid of 'invalid' suffix) post refresh. Whjen creating these records, populate the User_Id__c field with the user's record Id from Production. Also populate the Email__c field with the user's email.
2. When kicking off the sandbox refresh, populate 'SandboxRefreshHandler' into the 'Apex Class' field.

Deploy to Salesforce
====================================
 
<a href="https://githubsfdeploy.herokuapp.com?owner=financialforcedev&amp;repo=apex-mdapi">
  <img src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png" alt="Deploy to Salesforce" />
</a>
