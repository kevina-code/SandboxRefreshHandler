/**
 * Author: Kevin Antonioli
 * Created: 01.06.2022
 *
 * @description: apex test code coverage for SandboxRefreshHandler class
 * Note: sometimes the 'update internalUsers' line below will fail on a UNABLE_TO_LOCK_ROW error. This is pretty intermittent.
 *  If this happens, just run the test again (it'll eventually pass)
 */
@isTest
class SandboxRefreshHandlerTest {
  @isTest
  static void testUpdateToCurrentEnvironment() {
    List<String> userIds = new List<String>();
    for (Internal_User__mdt internalUser : [
      SELECT User_Id__c
      FROM Internal_User__mdt
    ]) {
      userIds.add(internalUser.User_Id__c);
    }

    List<User> internalUsers = [
      SELECT Id, Email
      FROM User
      WHERE Id IN :userIds
    ];
    for (User user : internalUsers) {
      // append an .invalid suffix to the user email, just like a sandbox refresh does:
      user.Email += '.invalid';
    }

    update internalUsers;

    Id orgId = UserInfo.getOrganizationId();
    Id sandboxId = UserInfo.getOrganizationId();

    Test.startTest();
    Test.testSandboxPostCopyScript(
      new SandboxRefreshHandler(),
      orgId,
      sandboxId,
      'sandbox'
    );
    Test.stopTest();

    for (User internalUser : [SELECT Email FROM User WHERE Id IN :userIds]) {
      Assert.isTrue(!internalUser.Email.contains('@example.com'));
      Assert.isTrue(!internalUser.Email.contains('.invalid'));
    }
  }
}