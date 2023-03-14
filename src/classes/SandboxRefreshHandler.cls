/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: run logic on Sandbox refresh, such as remove '.invalid' and '@example.com' from internal user emails
 * Created    : 01.06.2022
 *
 * Revisions:
 * Date : Name : Notes
 */
global class SandboxRefreshHandler implements SandboxPostCopy {
  /**
   * @description: runs when this class is populated in the 'Apex Class' field in the Salesforce Sandbox Refresh UI
   * @param   context (SandboxContext)
   * @return  void
   */
  global void runApexClass(SandboxContext context) {
    // due to nuances in the User table immediately after a sandbox refresh,
    //  push out the execution of the main logic by 60 minutes:
    Integer minute = Datetime.now().addMinutes(60).minute();
    String cronString = '0 ' + minute + ' * * * ?'; // Starting 60m from now, run hourly.  Job will self-cancel once successful.
    SandboxSetupSchedulable job = new SandboxSetupSchedulable();
    System.schedule('Sandbox Setup', cronString, job);
  }
}