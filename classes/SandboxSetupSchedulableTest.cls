/**
 * Author: Kevin Antonioli
 * Created: 01.06.2022
 *
 * @description: provides apex test code coverage for SandboxSetupSchedulable.cls
 */
@isTest
public class SandboxSetupSchedulableTest {
  @isTest
  static void test_Standard() {
    Integer minute = Datetime.now().addMinutes(10).minute();
    String cronString = '0 ' + minute + ' * * * ?'; // Starting 10m from now, run hourly.  Job will self-cancel once successful.
    SandboxSetupSchedulable job = new SandboxSetupSchedulable();
    Test.startTest();
    System.schedule('Sandbox Setup', cronString, job);
    Test.stopTest();

    User internalUser = [
      SELECT Email
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];

    Assert.isTrue(!internalUser.Email.contains('@example.com'));
    Assert.isTrue(!internalUser.Email.contains('.invalid'));
  }
}