String adminEmail = 'testing@example.com';
String namespace = getNamespace();
String giftProfileName = 'Gift Processor';
String giftProfileName2 = 'Development Officer';

public static String generateContactEmail(String adminEmail, String contactName) {
    List<String> emailParts = adminEmail.split('@');
    return emailParts[0]+'+'+contactName+'@'+emailParts[1];
}

public static String getNamespace() {
    ApexClass ac = [SELECT NameSpacePrefix FROM ApexClass WHERE Name = 'TDTM_Glue'];
    return ac.NameSpacePrefix;
}

public static void AddGiftProcessor() {
    Savepoint sp = Database.setSavepoint();

    try {
        List<User> users = new List<User>();

        Profile giftProfile = [
            SELECT Id
            FROM Profile
            WHERE Name =: giftProfileName
        ];

        Profile giftProfile2 = [
            SELECT Id
            FROM Profile
            WHERE Name =: giftProfileName2
        ];

        // If the user count is maxed out, leave and continue the flow
        users = [SELECT Id 
            FROM User 
            WHERE Profile.UserLicense.LicenseDefinitionKey = 'SFDC' AND isActive = true];
        if(users.size() >= 2){
            return;
        }

        User goUser = new User(
            Username = generateContactEmail(adminEmail,'giftofficer'),
            FirstName = 'Gary',
            LastName = 'Gift-Officer',
            Email = generateContactEmail(adminEmail,'giftofficer'),
            Alias = 'ggift',
            TimeZoneSidKey = 'America/Chicago',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'utf-8',
            ProfileId = giftProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        users.add(goUser);

        // Developer Edition orgs can only have 2 users, the admin and 1 other!
        //User mjoUser = new User(
        //    Username = generateContactEmail(adminEmail,'majorgiftofficer'),
        //    FirstName = 'Mary',
        //    LastName = 'Major-Gift-Officer',
        //    Email = generateContactEmail(adminEmail,'majorgiftofficer'),
        //    Alias = 'mmajor',
        //    TimeZoneSidKey = 'America/Chicago',
        //    LocaleSidKey = 'en_US',
        //    EmailEncodingKey = 'utf-8',
        //    ProfileId = giftProfile2.Id,
        //    LanguageLocaleKey = 'en_US'
        //);
        //users.add(mjoUser);

        insert users;

    } catch (System.DmlException e) {
        Database.rollback(sp);
        throw new System.DmlException(e.getMessage());
    }
}
