@isTest
private class DataGenerationTest {
  @testSetup
  static void dataCreation() {
      Account account = TestFactory.getAccount('Muddy Waters Inc.', true);
      Contact contact = TestFactory.getContact(account.Id, 'Muddy', 'Waters', true);
      Opportunity opp = New Opportunity();
      opp.Name = 'Long lost record';
      opp.AccountId = account.Id;
      opp.CloseDate = Date.today().addDays(14);
      opp.StageName = 'Prospecting';
      insert opp;
  }
  @isTest
  static void testBruteForceAccountCreation() {
      List<Account> accts = new List<Account>();
      Test.startTest();
          accts = [SELECT Id FROM Account];
      Test.stopTest();
      Assert.areEqual(accts.size(), 1);
  }
  @isTest
  static void testUseTestFactoryToCreateAccountsWithContacts() {
      List<Account> accts;
      List<Contact> contacts;
      TestFactory.generateAccountWithContacts(5);
      Test.startTest();
          accts = [SELECT Id FROM Account];
          contacts = [SELECT Id FROM Contact];
      Test.stopTest();
      Assert.areEqual(accts.size(), 1);
      Assert.areEqual(contacts.size(), 6);
      Assert.areNotEqual(accts.size(), contacts.size());    
  }
    @isTest
  static void testAtTestSetupMethodsRule() {
      List<Opportunity> opps = [SELECT Id, AccountId FROM Opportunity];
      Assert.areEqual(opps.size(), 1);      
  }
}