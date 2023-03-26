/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: Scheduleable class to support SandboxRefreshHandler
 *              Sanitizes internal user emails by initiating the removal of the .invalid suffix
 *              Note: the need for a scheduleable class arises from nuances in the User table immediately following a completed sandbox refresh
 * Created    : 01.31.2022
 *
 * Revisions:
 * Date : Name : Notes
 */
public class SandboxSetupSchedulable implements Schedulable {
  /**
   * @description: runs when this class is scheduled from SandboxRefreshHandler
   * @param schedulableContext (SchedulableContext)
   * @return void
   */
  public void execute(SchedulableContext schedulableContext) {
    sanitizeInternalUserEmails();
  }

  /**
   * @description: retrieve internal user Ids and emails from the Internal User custom metadata type,
   *  and use those to remove removing '@example.com' and '.invalid' from the corresponding user records' email field.
   *  Note: for some reason, using a future here is more reliable
   * @param   null
   * @return  void
   */
  @future
  private static void sanitizeInternalUserEmails() {
    try {
      // pull User SF Ids from Internal Users custom metadata type:
      Map<Id, Internal_User__mdt> userIdToInternalUser = new Map<Id, Internal_User__mdt>();
      for (
        Internal_User__mdt internalUser : Test.isRunningTest()
          ? new List<Internal_User__mdt>{
              new Internal_User__mdt(
                User_Id__c = UserInfo.getUserId(),
                Email__c = 'test@abcdefg.com'
              )
            }
          : [SELECT User_Id__c, Email__c FROM Internal_User__mdt]
      ) {
        if (
          internalUser.User_Id__c != null &&
          internalUser.User_Id__c instanceof Id
        ) {
          userIdToInternalUser.put(internalUser.User_Id__c, internalUser);
        }
      }

      // query User object and cleanse emails (only for users defined as an internal user in the custom metadata type):
      List<User> internalUsersToUpdate = new List<User>();
      for (User user : [
        SELECT Id, Email
        FROM User
        WHERE Id IN :userIdToInternalUser.keyset()
      ]) {
        if (userIdToInternalUser.containskey(user.Id)) {
          Internal_User__mdt internalUserCmt = userIdToInternalUser.get(
            user.Id
          );
          user.Email = internalUserCmt.Email__c;
          user.isActive = true;
          internalUsersToUpdate.add(user);
        }
      }

      // Update internal users defined in Internal_User__mdt custom metadata type:
      if (!internalUsersToUpdate.isEmpty()) {
        Database.SaveResult[] srList = Database.update(
          internalUsersToUpdate,
          false
        );
      }
    } catch (Exception e) {
      System.debug(
        'SandboxSetupSchedulable.sanitizeInternalUserEmails exception: ' +
        e.getMessage() +
        ', ' +
        e.getStackTraceString()
      );
    }
  }

  /**
   * @description: finish method to abort the job once it has finished running its logic
   * @param   null
   * @return  void
   */
  private static void finish() {
    try {
      // Cancel this job so it doesn't perpetuate
      for (CronTrigger job : [
        SELECT Id
        FROM CronTrigger
        WHERE CronJobDetail.Name = 'Sandbox Setup'
      ]) {
        System.abortJob(job.Id);
      }
    } catch (Exception e) {
      System.debug(
        'SandboxSetupSchedulable.finish exception: ' +
        e.getMessage() +
        ', ' +
        e.getStackTraceString()
      );
    }
  }
}
