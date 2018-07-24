String adminEmail = 'testing@example.com';
String namespace = getNamespace();
String giftProfileName = 'Gift Officer';
String majorGiftProfileName = 'Major Gift Officer';

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

        Profile majorGiftProfile = [
            SELECT Id
            FROM Profile
            WHERE Name =: majorGiftProfileName
        ];

        // If users are found, leave and continue the flow
        users = [SELECT Id FROM User WHERE isActive = true AND 
            (ProfileId =: giftProfile.Id OR ProfileId =: majorGiftProfile.Id)];
        if(!users.isEmpty()){
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
        //    ProfileId = majorGiftProfile.Id,
        //    LanguageLocaleKey = 'en_US'
        //);
        //users.add(mjoUser);

        insert users;

    } catch (System.DmlException e) {
        Database.rollback(sp);
        throw new System.DmlException(e.getMessage());
    }
}
